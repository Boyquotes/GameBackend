# Список доступных интерактивов и панель добавления, удаления, поиска.
@tool
extends VBoxContainer

# Имя интерактива по умолчанию.
const _default_id = "Default_ID"
var _resource:Resources = Services.resource
var _id_name_list:PackedStringArray

# Сигнал в правую панель для отображения интерактива.
signal send_select_interactive_id(id:String)

func update():
	_id_name_list = Helper.find_all_files_array(_resource.get_interactive_path(), _resource.get_interactive_extension())
	$IL_IDs.clear()
	for name in _id_name_list:
		$IL_IDs.add_item(name)


func add_item(id:String = _default_id):
	if id in _id_name_list:
		OS.alert(tr("Interactive with name {0} already exists!").format([id]))
		return

	var index = $IL_IDs.add_item(id)
	$IL_IDs.deselect_all()
	$IL_IDs.select(index)
	_id_name_list.append(id)
	get_tree().call_group("editor_interactive_state", "editor_interactive_state", "Add " + $IL_IDs.get_item_text(id))
	

func _ready():
	assert(_resource)
	Helper.make_dir(_resource.get_interactive_path())
	_id_name_list = Helper.find_all_files_array(_resource.get_interactive_path(), _resource.get_interactive_extension())
	$IL_IDs.clear()
	for name in _id_name_list:
		$IL_IDs.add_item(name)

func _on_tb_create_pressed():
	add_item()
	
func _on_tb_delete_pressed():
	for index in $IL_IDs.get_selected_items():
		Helper.remove_file(_resource.get_interactive_file_path($IL_IDs.get_item_text(index)))
		get_tree().call_group("editor_interactive_state", "editor_interactive_state", "Remove " + $IL_IDs.get_item_text(index))
		$IL_IDs.remove_item(index)
	emit_signal("send_select_interactive_id", "")

func _on_il_i_ds_item_activated(index):
	emit_signal("send_select_interactive_id", $IL_IDs.get_item_text(index))


func _on_tb_find_pressed():
	var text = $HBC_bottom_block/LE_find_str.text as String
	# Удалили текст запроса - возвращаем полный список.
	if text.is_empty():
		update()
		return
	var list:PackedStringArray
	var dict = Helper.find_all_files_dict(_resource.get_interactive_path(), _resource.get_interactive_extension())
	# Ищем в имени идентификатора, если нет - то в конфигурации.
	for id_name in dict:
		if id_name.findn(text) > -1 || FileAccess.get_file_as_string(dict[id_name]).findn(text) > -1:
			list.append(id_name)
	_id_name_list = list
	$IL_IDs.clear()
	for name in _id_name_list:
		$IL_IDs.add_item(name)
