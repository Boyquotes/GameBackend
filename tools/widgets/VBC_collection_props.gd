@tool
extends VBoxContainer

var _collections:Collections = Services.collections
@export var collection_name:String

func _ready():
	pass # Replace with function body.

func serialize():
	if collection_name.is_empty():
		return
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	_collections.save_item_dict(collection_name, dict)
	
func deserialize(item_name:String):
	if !collection_name.is_empty():
		serialize()
	var dict = _collections.get_item_dict(item_name)
	collection_name = item_name
	if !dict.is_empty():
		for child in get_children():
			if dict.has(child.section_name()):
				child.deserialize(dict[child.section_name()])
				
func _exit_tree():
	serialize()
