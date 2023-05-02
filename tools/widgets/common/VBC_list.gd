@tool
extends VBoxContainer

@export var list_name:String
var _is_deserialized = false

signal send_item_changed()

func _ready():
	pass
	
func section_name()->String:
	return list_name

func serialize()->Dictionary:
	if list_name.is_empty() || _is_deserialized == false || visible == false:
		return {}
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	return dict
	
func deserialize(dict:Dictionary):
	_is_deserialized = true
	for child in get_children():
		if dict.has(child.section_name()):
			child.deserialize(dict[child.section_name()])
		else:
			child.clean()


func _on_hbc_int_send_value_changed():
	emit_signal("send_item_changed")
