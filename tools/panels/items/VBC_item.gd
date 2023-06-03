@tool
extends VBoxContainer


func _ready():
	pass

var _accrue_state:bool = false
	
func serialize()->Dictionary:
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	return dict
	
func deserialize(dict:Dictionary):
	for child in get_children():
		child.deserialize(dict.get(child.section_name(), {}))

func _on_hbc_accrue_send_changed(value):
	_accrue_state = value
	if value == true:
		$HBC_collection.set_select(0)
		$HBC_collection.visible = false
	else:
		$HBC_collection.visible = true


