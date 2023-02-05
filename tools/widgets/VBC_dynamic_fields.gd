@tool
extends VBoxContainer

const _fields_name = "dynamic_fields"

var res_dynamic = null

func section_name()->String:
	return _fields_name
	
func serialize()->Array:
	var array = []
	for child in get_children():
		array.append(child.serialize())
	return array
	
func deserialize(array:Array):
	if res_dynamic:
		for item in array:
			var dynamic_field = res_dynamic.instantiate()
			if dynamic_field:
				add_child(dynamic_field)
				dynamic_field.deserialize(item)
