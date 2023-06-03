@tool
extends VBoxContainer


signal send_item_selected(item_name:String)
signal send_item_save(item_name:String)

func _ready():
	pass

func _on_hbc_manager_send_save():
	emit_signal("send_item_save", $VBC_list.get_selected())

func _on_vbc_list_send_select(item_name):
	emit_signal("send_item_selected", item_name)
