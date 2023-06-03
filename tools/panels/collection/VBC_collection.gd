@tool
extends VBoxContainer

var _collections = Services.collections

func _ready():
	pass

func update(value:String):
	deserialize()

func _on_hbc_max_items_send_change_int_value():
	serialize()

func _on_hbc_min_items_send_change_int_value():
	serialize()
	
func serialize():
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	_collections.add_current_collection_props(dict)
	
func deserialize():
	var dict = _collections.get_current_collection_props()
	for child in get_children():
		child.deserialize(dict.get(child.section_name(), {}))
