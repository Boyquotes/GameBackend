# Работаем на уже существующей в руте сцене.
# Подгружаемся транзитной сценой в рут после завершаемой сцены как чаилд.
# Запускаем в транзитной сцене анимацию фейда с альфой от 0 до 255.
# Когда альфа 255, показываем узел с беком на котором находятся подсказки и прогресс. 
# Удаляем завершаемую сцену.
# Запускаем загрузку сцены на которую нужно перейти.
# Передаем в прогрессбар процент загрузки сцены и ждем сигнала о завершении загрузки.
# Добавляем новую сцену и меняем местами с транзитной.
# Запускаем в транзитной сцене анимацию фейда от 255 до 0 и скрываем подсказки и прогрессбар.
# После завершения анимации удаляем транзитную сцену.
@tool
extends Node

class_name Scenes

enum {
	NONE,
	READY,
	ADD_TRANSIT,
	START_TRANSITE_FADE,
	REMOVE_OLD_SCENE,
	LOAD_NEW_SCENE,
	NEW_SCENE_LOAD_COMPLITE,
	ADD_NEW_SCENE,
	MOVE_NEW_AND_TRANSITE,
	START_TRANSITE_RAISE,
	REMOVE_TRANSITE_SCENE
}

@onready var _logs:LoggotLogger = Services.logs
@onready var _resources:Resources = Services.resource
@export var transite_scene_path:String = "res://addons/GameBackend/services/scenes/transite/transite.tscn"
var _transite_scene_resource:PackedScene = null
var _transite_scene = null
var _change_scene_state = NONE
var _new_scene_path:String

func _next_state():
	_change_scene_state = _change_scene_state + 1
	_logs.info("Scenes service > change scene loading state " + str(_change_scene_state))
	
func _restart_state():
	_change_scene_state = READY
	_new_scene_path = ""
	_logs.info("Scenes service > restart state " + str(_change_scene_state))

func _ready():
	# Проверяем, что сервисы живы.
	assert(_logs)
	assert(_resources)
	_logs.info("Scenes service > started.")
	# Проверяем, что транзитная сцена существует и доступна.
	if transite_scene_path.is_empty():
		_logs.error("Scenes service > the transite scene path is empty.")
		OS.alert("Scenes service > the transite scene path is empty.")
		return
	_transite_scene_resource = load(transite_scene_path) as PackedScene
	if _transite_scene_resource == null:
		var message = "Scenes service > the transite scene {0} - not a PackedScene".format([transite_scene_path])
		_logs.error(message)
		OS.alert(message.replace("<",""))
		return
	# Коннекры в сервис ресурсов для отслеживания асинхронной загрузки.
	# Отдаём в сервис синхронно, ожидаем из него сигнала с прогрессом и завершением.
	_resources.send_resource_progress.connect(on_async_load_progress)
	_resources.send_resource_loaded.connect(on_async_load_complite)
	# READY
	_next_state()
	
func change_scene_from_path_with_transite(scene_path:String):
	_logs.info("Scenes service > start " + scene_path)
	if _change_scene_state != READY:
		_logs.error("Scenes service > state is not READY")
		return false
		
	if !FileAccess.file_exists(scene_path):
		var message = "Scenes service > {0}, {1}".format([Helper.error_str[ERR_FILE_BAD_PATH], scene_path])
		_logs.error(message)
		OS.alert(message.replace("<",""))
		return false
		
	var current_scene = get_tree().current_scene
	if current_scene == null:
		var message = "Scenes service > current scene was not setted."
		_logs.error(message)
		OS.alert(message)
		return false
		
	_new_scene_path = scene_path
		
	# ADD_TRANSIT
	_transite_scene = _transite_scene_resource.instantiate()
	_next_state()
	get_tree().root.add_child(_transite_scene)
	# ждём сигнала о завершении анимации затемнения в транзитной сцене
	# START_TRANSITE_FADE
	_next_state()
	_transite_scene.start_fade_animation()
	await _transite_scene.send_faded
	# REMOVE_OLD_SCENE
	_next_state()
	
	# убрать узел из родителя
	get_tree().root.remove_child(current_scene)
	# удалить на следеющем кадре
	current_scene.queue_free()
	get_tree().current_scene = _transite_scene
	# LOAD_NEW_SCENE
	_next_state()
	_resources.get_resource_async(_new_scene_path)
	
func on_async_load_progress(value:float):
	if _change_scene_state == LOAD_NEW_SCENE:
		_transite_scene.set_progress(value)
	
func on_async_load_complite(scene_path:String, res:Resource):
	if _change_scene_state == LOAD_NEW_SCENE && scene_path == _new_scene_path:
		# NEW_SCENE_LOAD_COMPLITE
		_next_state()
		_transite_scene.set_progress(100)
		if res is PackedScene:
			# ADD_NEW_SCENE
			_next_state()
			var new_scene = (res as PackedScene).instantiate()
			get_tree().root.add_child(new_scene)
			# MOVE_NEW_AND_TRANSITE
			_next_state()
			# Переместим транзитную сцену в конец дерева чтобы она перекрывала новую.
			# В начале дерева идут автолоадные синглтоны, потом сцены!
			get_tree().root.move_child(_transite_scene, -1)
			# START_TRANSITE_RAISE
			_next_state()
			_transite_scene.load_complite()
			await _transite_scene.send_raised
			# REMOVE_TRANSITE_SCENE
			_next_state()
			get_tree().root.remove_child(_transite_scene)
			# удалить на следеющем кадре
			_transite_scene.queue_free()
			get_tree().current_scene = new_scene
			
		else:
			var message = "Scenes service > {0} - not a PackedScene".format([scene_path])
			_logs.error(message)
			OS.alert(message.replace("<",""))
	_restart_state()
