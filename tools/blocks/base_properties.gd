# Блок с базовыми свойствами которые должны быть у любого интерактива
@tool
extends MarginContainer

@onready var _fields = $VBC_main/VBC_static_fields
const _default_script = "res://addons/GameBackend/tools/blocks/scripts/base_properties.gd"

const _block_name = "base_properties"
const _block_script_name = "script" 
var _block_handle_script:String:
	set(_value):
		_block_handle_script = _default_script if _value.is_empty() else _value
		$VBC_main/HBC_data_manage/L_script.text = _block_handle_script.get_file()

func _on_tb_minimize_pressed():
	_fields.visible = !$VBC_main/CR_title/TB_minimize.button_pressed
	
func section_name()->String:
	return _block_name
	
func serialize()->Dictionary:
	return {
		_block_script_name: _block_handle_script,
		_fields.section_name():_fields.serialize()
		}
	
func deserialize(dict:Dictionary):
	if dict.has(_block_script_name):
		_block_handle_script = dict[_block_script_name]
	_fields.deserialize(dict[_fields.section_name()])
	
func clean():
	_fields.clean()
	_block_handle_script = ""


func _on_tb_add_script_pressed():
	$FileDialog.visible = true


func _on_file_dialog_file_selected(path):
	_block_handle_script = path
