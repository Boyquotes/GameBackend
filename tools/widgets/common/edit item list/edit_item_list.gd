@tool
extends ItemList
var _last_selected_index = -1
const _item_heigth = 35

signal send_change_item(old_name:String, new_name:String)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_item_clicked(index, at_position, mouse_button_index):
	if MOUSE_BUTTON_RIGHT == mouse_button_index:
		$P_edit.visible = true
		$P_edit.position = Vector2i(0, at_position.y)
		$P_edit.size = Vector2i(size.x, $P_edit.size.y)
		$P_edit.set_text(get_item_text(index))
		_last_selected_index = index

func _on_p_edit_send_new_text(_text):
	if _last_selected_index > -1:
		emit_signal("send_change_item", get_item_text(_last_selected_index), _text)
		set_item_text(_last_selected_index, _text)
		_last_selected_index = -1
