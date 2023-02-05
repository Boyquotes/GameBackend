@tool
extends MarginContainer

@onready var _fields = $VBC_main/VBC_dynamic_fields
@onready var res_field = preload("res://addons/GameBackend/tools/fields/hbc_id_file.tscn")

const _block_name = "sound_links"


func _ready():
	_fields.res_dynamic = res_field

func _on_tb_minimize_pressed():
	_fields.visible = !$VBC_main/CR_title/TB_minimize.button_pressed
	
func section_name()->String:
	return _block_name
	
func serialize()->Dictionary:
	return {_fields.section_name():_fields.serialize()}
	
func deserialize(dict:Dictionary):
	_fields.deserialize(dict[_fields.section_name()])

func _on_tb_close_pressed():
	queue_free()

func _on_tb_add_field_pressed():
	_fields.add_child(res_field.instantiate())
