@tool
extends HBoxContainer


func _ready():
	pass

func _on_il_items_send_selected_item(item_name:String):
	$SC_item.update_item(item_name)
