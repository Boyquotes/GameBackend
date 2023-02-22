# Карточка свойств интерактива
@tool
extends VBoxContainer

@onready var _globals:Globals = Services.globals

# Идентификатор которые передали из левого списка для отображения.
var interactive_id:String
# При клонировании карточки добавляем к идентификатору суффикс.
const _clone_suffix = "_clone"
@onready var ID_node = $MC_ID/HBC_ID

# При создании нового интерактива через клонирование или изменение идентификатора
#  просим левый список обновиться.
signal send_update()

func _ready():
	assert(_globals)
	# Создадим директорию для интерактивов если ее раньше не было.
	Resources.make_interactive_dir()
	
func serialize(id:String):
	var dict:Dictionary
	dict[$VBC_blocks.section_name()] = $VBC_blocks.serialize()
	dict[$base_properties.section_name()] = $base_properties.serialize()
	Resources.save_interactive_to_json_file(id, dict)
	
func deserialize(id:String):
	var dict = Resources.load_dict_from_interactive(id)
	if !dict.is_empty() && dict.has($VBC_blocks.section_name()):
		$VBC_blocks.deserialize(dict[$VBC_blocks.section_name()])
	if !dict.is_empty() && dict.has($base_properties.section_name()):
		$base_properties.deserialize(dict[$base_properties.section_name()])
		
func _exit_tree():
	if !interactive_id.is_empty():
		_on_tb_card_save_pressed()

# Из левого списка попросили отобразить карточку интерактива.
func show_id(id:String):
	if !interactive_id.is_empty():
		clean()
	# если передали пустое имя - значит просто очищаем карточку.
	if id.is_empty():
		if !ID_node.value.is_empty():
			_on_tb_card_save_pressed()
		visible = false
		return
	visible = true
	# Последнее имя идентификатора
	interactive_id = id
	# Текущее или новое имя
	ID_node.value = id
	# Идентификатор который редактируем (можно посмотреть из поля).
	_globals.edited_id = id
	deserialize(id)
	
func _on_tb_card_save_pressed():
	# Флаг изменения имени интерактива.
	var is_update_list = false
	if interactive_id.is_empty() || ID_node.value.is_empty():
		OS.alert(tr("anc_id_name_error"))
		editor_interactive_state(tr("anc_id_name_error") + " "+ ID_node.value)
		return
	# Изменилось имя интерактива.
	if interactive_id != ID_node.value:
		# Удалить старый файл с конфигурацией(у него сторое имя).
		Resources.remove_interactive(interactive_id)
		interactive_id = ID_node.value
		_globals.edited_id = ID_node.value
		is_update_list = true
	serialize(interactive_id)
	if is_update_list:
		emit_signal("send_update")
	editor_interactive_state(tr("anc_saved_to_file") + Resources.get_interactive_file_path(interactive_id))

func clean():
	_on_tb_card_save_pressed()
	ID_node.clean()
	$base_properties.clean()
	$VBC_blocks.clean()

func _on_tb_card_clone_pressed():
	# Проверяем, что имя интерактива не дублируется.
	var id_list = Resources.find_all_interactives_array()
	if ID_node.value + _clone_suffix in id_list:
		OS.alert(tr("anc_error_id_name_exist").format([ID_node.value + _clone_suffix]))
		editor_interactive_state(tr("anc_error_id_name_exist").format([ID_node.value + _clone_suffix]))
		return
	# Не нужно удалять старый файл, только создать новый
	if interactive_id != ID_node.value:
		interactive_id = ID_node.value
	else:
		interactive_id = interactive_id + _clone_suffix
		ID_node.value = interactive_id
	_on_tb_card_save_pressed()
	emit_signal("send_update")
	
func editor_interactive_state(state:String):
	$HBC_card_manage/L_state.text = state
		
