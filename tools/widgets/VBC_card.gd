@tool
extends VBoxContainer

var _resource:Resources = Services.resource

const _json_ext = ".json"
const _interactives_dir_path = "user://gdpanel/interactives"
var interactive_id:String
		
signal send_change_id(id:String)

func _ready():
	assert(_resource)
	if !DirAccess.dir_exists_absolute(_interactives_dir_path):
		DirAccess.make_dir_recursive_absolute(_interactives_dir_path)
	
func serialize(id:String):
	var dict:Dictionary
	dict[$VBC_blocks.section_name()] = $VBC_blocks.serialize()
	dict[$base_properties.section_name()] = $base_properties.serialize()
	Helper.save_dict_to_json_file(_interactives_dir_path + "/" + id + _json_ext, dict)
	
func deserialize(id:String):
	var dict = Helper.load_dict_from_json_file(_interactives_dir_path + "/" + id + _json_ext)
	if !dict.is_empty() && dict.has($VBC_blocks.section_name()):
		$VBC_blocks.deserialize(dict[$VBC_blocks.section_name()])
	if !dict.is_empty() && dict.has($base_properties.section_name()):
		$base_properties.deserialize(dict[$base_properties.section_name()])

func show_id(id:String):
	clean()
	visible = true
	interactive_id = id
	$HBC_ID.value = id
	deserialize(id)
	
func _on_tb_card_save_pressed():
	if interactive_id.is_empty() || $HBC_ID.value.is_empty():
		OS.alert(tr("anc_id_name_error"))
		$HBC_card_manage/L_state.text = tr("anc_id_name_error") + " "+ $HBC_ID.value
		return
	if interactive_id != $HBC_ID.value:
		DirAccess.remove_absolute(_resource.get_interactives_file_path(interactive_id))
		emit_signal("send_change_id", $HBC_ID.value)
	serialize($HBC_ID.value)
	interactive_id = $HBC_ID.value
	$HBC_card_manage/L_state.text = tr("anc_saved_to_file") + _resource.get_interactives_file_path(interactive_id)

func clean():
	$HBC_ID.clean()
	$base_properties.clean()
	$VBC_blocks.clean()
