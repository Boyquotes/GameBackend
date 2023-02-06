# Статический список полей, сериализация работает без создания виджетов полей, только заполнение.
@tool
extends VBoxContainer

const _block_name = "static_fields"

func section_name()->String:
	return _block_name
	
func serialize()->Dictionary:
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	return dict
	
func deserialize(dict:Dictionary):
	for child in get_children():
		if dict.has(child.section_name()):
			child.deserialize(dict[child.section_name()])
			
func clean():
	for child in get_children():
		child.clean()
