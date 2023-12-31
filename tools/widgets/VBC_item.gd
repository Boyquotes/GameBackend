@tool
extends VBoxContainer

func _ready():
	pass

func serialize()->Dictionary:
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	return dict
	
func deserialize(dict:Dictionary):
	for child in get_children():
		child.deserialize(dict.get(child.section_name(), {}))
