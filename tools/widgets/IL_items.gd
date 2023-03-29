@tool
extends ItemList

var _items:Items = Services.items

signal send_selected_item(name:String)

func _ready():
	clear()
	for name in _items.get_items_list():
		add_item(name)

func _on_item_clicked(index, at_position, mouse_button_index):
	var item_name = get_item_text(index)
	emit_signal("send_selected_item", item_name,)
