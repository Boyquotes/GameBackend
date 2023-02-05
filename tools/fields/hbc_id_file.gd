@tool
extends HBoxContainer

@onready var _resource:Resources = Services.resource
@onready var _globals:Globals = Services.globals


func _ready():
	assert(_resource)
	assert(_globals)
	if !_globals.edited_id.is_empty():
		var id_list = Helper.find_all_files_array(_resource.get_interactives_path(), _resource.get_interactive_extension())
		for item in id_list:
			if item != _globals.edited_id:
				$OB_id.add_item(item)
	
func serialize()->Dictionary:
	return {
		$L_id.text.to_snake_case():$OB_id.text,
		$L_path.text.to_snake_case():$LE_path.text
	}
	
func deserialize(dict:Dictionary):
	var tmp_id = $L_id.text.to_snake_case()
	var tmp_path = $L_path.text.to_snake_case()
	if dict.has(tmp_id):
		$OB_id.text = dict[tmp_id]
	if dict.has(tmp_path):
		$LE_path.text = dict[tmp_path]

func _on_tb_close_pressed():
	queue_free()

func _on_le_path_text_submitted(new_text):
	if !FileAccess.file_exists(new_text):
		$LE_path.text = ""
		OS.alert(tr("anc_file_not_exist"))
