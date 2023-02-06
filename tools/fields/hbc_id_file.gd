# Статическое поле для установки соответствия идентификатора интерактива и проигрываемого 
# звука при столкновении.
@tool
extends HBoxContainer

@onready var _resource:Resources = Services.resource
@onready var _globals:Globals = Services.globals


func _ready():
	assert(_resource)
	assert(_globals)
	# Редактируется идентификатор и он установлен в глобальные переменные для запрета выбора себя
	if !_globals.edited_id.is_empty():
		var id_list = Helper.find_all_files_array(_resource.get_interactive_path(), _resource.get_interactive_extension())
		for item in id_list:
			if item != _globals.edited_id:
				$OB_id.add_item(item)
	
func serialize()->Dictionary:
	return {
		$L_id.text.to_snake_case():$OB_id.get_item_text($OB_id.get_selected_id()),
		$L_path.text.to_snake_case():$LE_path.text
	}
	
func deserialize(dict:Dictionary):
	var tmp_id = $L_id.text.to_snake_case()
	var tmp_path = $L_path.text.to_snake_case()
	if dict.has(tmp_id):
		for index in $OB_id.item_count:
			if $OB_id.get_item_text(index) == dict[tmp_id]:
				$OB_id.select(index)
				break
	if dict.has(tmp_path):
		if !FileAccess.file_exists(tmp_path): 
			$LE_path.text = dict[tmp_path]

func _on_tb_close_pressed():
	queue_free()

# Файл со звуком должен существовать на диске
func _on_le_path_text_changed(new_text):
	if !FileAccess.file_exists(new_text):
		$LE_path.placeholder_text = new_text
		$LE_path.text = ""
		OS.alert(tr("anc_file_not_exist"))
	
