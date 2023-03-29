@tool
extends VBoxContainer

var _items:Items = Services.items
var _item_name:String

func _ready():
	pass

func serialize():
	if _item_name.is_empty():
		return
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	_items.save_item_dict(_item_name, dict)
	
func deserialize(item_name:String):
	if !_item_name.is_empty():
		serialize()
	var dict = _items.get_item_dict(item_name)
	_item_name = item_name
	if !dict.is_empty():
		for child in get_children():
			if dict.has(child.section_name()):
				child.deserialize(dict[child.section_name()])
				
func _exit_tree():
	serialize()
