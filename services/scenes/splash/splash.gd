extends Control
# устанавливаем текстуры для конкретной реализации
@export var background_tex:Texture = null
@export var game_name_tex:Texture = null
@export var studio_logo_tex:Texture = null
@export var init_script:InitTemplate = null
@export var default_scene_path:String

@onready var logs:LoggotLogger = Services.logs
@onready var state:State = Services.state

var state_dict:Dictionary
const state_name = "splash"
const state_last_saved_scene = "last_saved_scene"

func _ready():
	assert(logs)
	logs.info("Splash scene > started.")
	assert(state)
	state_dict = state.get_dict(state_name)
	
	if background_tex:
		$TR_Background_tex.texture = background_tex
	if game_name_tex:
		$TR_Game_name_tex.texture = game_name_tex
	if studio_logo_tex:
		$TR_Studio_logo_tex.texture = studio_logo_tex
		
	# Запускаем инициализационный скрипт в котором запускаем стартовые загрузки и проверки.
	# Скрипт должен быть унаследован от InitTemplate и отправлять сигналы со статусом прогресса.
	# Если не установлен скрипт, запускаем шаблон по умолчанию.
	if init_script == null:
		init_script = load("res://addons/GameBackend/init_template.gd").new()
	init_script.send_progress.connect(on_init_progress)
	init_script.send_complite.connect(on_init_complited)
	add_child(init_script)

# Прогресс от скрипта инициализации отображаем на прогрессбаре
func on_init_progress(value:float):
	if value > 90:
		value = 90
	$TPB_start_progress.value = value
	
# Скрипт инициализации завершился успешно
func on_init_complited():
	logs.info("Splash scene > init complited.")
	# Инит прошел успешно, запускаем загрузку последней сохраненной сцены
	# или сцены по умолчанию (если она предварительно установлена через экспорт).
	var scene_path:String
	if state_dict.has(state_last_saved_scene):
		scene_path = state_dict[state_last_saved_scene]
	else:
		scene_path = default_scene_path
		
	if FileAccess.file_exists(scene_path):
		var packedScene = load(scene_path) as PackedScene
		if packedScene:
			$TPB_start_progress.value = 100
			# Убрать сплеш сцену из рута. В руте лежат автолоад синглтоны и сцены!
			get_tree().change_scene_to_packed(packedScene)
			get_tree().root.remove_child(self)
			queue_free()
		else:
			var message = "Splash scene > {0} - not a PackedScene".format([scene_path])
			logs.error(message)
			OS.alert(message.replace("<",""))
	else:
		var message = "Splash scene > {0}, {1}".format([Helper.error_str[ERR_FILE_BAD_PATH], scene_path])
		logs.error(message)
		OS.alert(message.replace("<",""))
		
func _exit_tree():
	logs.info("Splash scene > exit.")

func _process(delta):
	pass

func _on_tr_studio_logo_tex_gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		OS.shell_open("https://vk.com/public215748579")
