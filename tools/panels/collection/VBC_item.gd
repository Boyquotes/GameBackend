@tool
extends VBoxContainer

var _collections = Services.collections

var _item_name:String

func _on_hbc_drop_percent_send_change_int_value():
	serialize()
	
func _ready():
	pass

func update(value:String):
	_item_name = value
	deserialize()
	
func serialize():
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	_collections.add_current_collection_item(_item_name, dict)
	
func deserialize():
	var dict = _collections.get_current_collection_item(_item_name)
	for child in get_children():
		child.deserialize(dict.get(child.section_name(), {}))
