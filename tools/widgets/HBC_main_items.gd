@tool
extends HBoxContainer

var _items:Items = Services.items


func _ready():
	pass

func _on_il_items_send_selected_item(item_name:String):
	$SC_item.deserialize(_items.get_item_dict(item_name))

func _on_vbc_items_send_save_item(item_name):
	_items.save_item_dict(item_name, $SC_item.serialize())
