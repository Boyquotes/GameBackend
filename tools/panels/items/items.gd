@tool
extends HBoxContainer

var _items:Items = Services.items
var _interactives:Interactives = Services.interactives
var _collections:Collections = Services.collections

func _ready():
	pass


func _on_vbc_items_send_item_selected(item_name):
	$SC_props.deserialize(_items.get_item(item_name))


func _on_vbc_items_send_item_save(item_name):
	var dict = $SC_props.serialize()
	_items.save_item(item_name, dict)

