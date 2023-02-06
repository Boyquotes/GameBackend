# Блок с базовыми свойствами которые должны быть у любого интерактива
@tool
extends MarginContainer

@onready var _fields = $VBC_main/VBC_static_fields

const _block_name = "base_properties"

func _on_tb_minimize_pressed():
	_fields.visible = !$VBC_main/CR_title/TB_minimize.button_pressed
	
func section_name()->String:
	return _block_name
	
func serialize()->Dictionary:
	return {_fields.section_name():_fields.serialize()}
	
func deserialize(dict:Dictionary):
	_fields.deserialize(dict[_fields.section_name()])
	
func clean():
	_fields.clean()
