@tool
extends VBoxContainer

var _items:Items = Services.items
var _collections:Collections = Services.collections
var _interactives:Interactives = Services.interactives

signal send_save_item(item_name:String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_tb_save_pressed():
	for index in $IL_items.get_selected_items():
		emit_signal("send_save_item", $IL_items.get_item_text(index))
		return


func _on_le_filter_items_text_submitted(new_text):
	# Удалили текст запроса - возвращаем полный список.
	if new_text.is_empty():
		$IL_items.update()
		return
	var names = _items.find_in_items(new_text)
	$IL_items.clear()
	if not names.is_empty():
		for _name in names:
			$IL_items.add_item(_name)
