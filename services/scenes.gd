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

@onready var logs:LoggotLogger = Services.logs
@onready var resources:Resources = Services.resource
@export var transite_scene_path:String = "res://addons/GameBackend/services/scenes/transite/transite.tscn"
var transite_scene_resource:PackedScene = null
var transite_scene = null
var change_scene_state = NONE
var new_scene_path:String

func _next_state():
	change_scene_state = change_scene_state + 1
	logs.info("Scenes service > change scene loading state " + str(change_scene_state))
	
func _restart_state():
	change_scene_state = READY
	new_scene_path = ""
	logs.info("Scenes service > restart state " + str(change_scene_state))

func _ready():
	# Проверяем, что сервисы живы.
	assert(logs)
	assert(resources)
	logs.info("Scenes service > started.")
	# Проверяем, что транзитная сцена существует и доступна.
	if transite_scene_path.is_empty():
		logs.error("Scenes service > the transite scene path is empty.")
		OS.alert("Scenes service > the transite scene path is empty.")
		return
	transite_scene_resource = load(transite_scene_path) as PackedScene
	if transite_scene_resource == null:
		var message = "Scenes service > the transite scene {0} - not a PackedScene".format([transite_scene_path])
		logs.error(message)
		OS.alert(message.replace("<",""))
		return
	# Коннекры в сервис ресурсов для отслеживания асинхронной загрузки.
	# Отдаём в сервис синхронно, ожидаем из него сигнала с прогрессом и завершением.
	resources.send_resource_progress.connect(on_async_load_progress)
	resources.send_resource_loaded.connect(on_async_load_complite)
	# READY
	_next_state()
	
func change_scene_from_path_with_transite(scene_path:String):
	logs.info("Scenes service > start " + scene_path)
	if change_scene_state != READY:
		logs.error("Scenes service > state is not READY")
		return false
		
	if !FileAccess.file_exists(scene_path):
		var message = "Scenes service > {0}, {1}".format([Helper.error_str[ERR_FILE_BAD_PATH], scene_path])
		logs.error(message)
		OS.alert(message.replace("<",""))
		return false
		
	var current_scene = get_tree().current_scene
	if current_scene == null:
		var message = "Scenes service > current scene was not setted."
		logs.error(message)
		OS.alert(message)
		return false
		
	new_scene_path = scene_path
		
	# ADD_TRANSIT
	transite_scene = transite_scene_resource.instantiate()
	_next_state()
	get_tree().root.add_child(transite_scene)
	# ждём сигнала о завершении анимации затемнения в транзитной сцене
	# START_TRANSITE_FADE
	_next_state()
	transite_scene.start_fade_animation()
	await transite_scene.send_faded
	# REMOVE_OLD_SCENE
	_next_state()
	
	# убрать узел из родителя
	get_tree().root.remove_child(current_scene)
	# удалить на следеющем кадре
	current_scene.queue_free()
	get_tree().current_scene = transite_scene
	# LOAD_NEW_SCENE
	_next_state()
	resources.get_resource_async(new_scene_path)
	
func on_async_load_progress(value:float):
	if change_scene_state == LOAD_NEW_SCENE:
		transite_scene.set_progress(value)
	
func on_async_load_complite(scene_path:String, res:Resource):
	if change_scene_state == LOAD_NEW_SCENE && scene_path == new_scene_path:
		# NEW_SCENE_LOAD_COMPLITE
		_next_state()
		transite_scene.set_progress(100)
		if res is PackedScene:
			# ADD_NEW_SCENE
			_next_state()
			var new_scene = (res as PackedScene).instantiate()
			get_tree().root.add_child(new_scene)
			# MOVE_NEW_AND_TRANSITE
			_next_state()
			# Переместим транзитную сцену в конец дерева чтобы она перекрывала новую.
			# В начале дерева идут автолоадные синглтоны, потом сцены!
			get_tree().root.move_child(transite_scene, -1)
			# START_TRANSITE_RAISE
			_next_state()
			transite_scene.load_complite()
			await transite_scene.send_raised
			# REMOVE_TRANSITE_SCENE
			_next_state()
			get_tree().root.remove_child(transite_scene)
			# удалить на следеющем кадре
			transite_scene.queue_free()
			get_tree().current_scene = new_scene
			
		else:
			var message = "Scenes service > {0} - not a PackedScene".format([scene_path])
			logs.error(message)
			OS.alert(message.replace("<",""))
	_restart_state()
