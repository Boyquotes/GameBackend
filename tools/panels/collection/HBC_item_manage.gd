@tool
extends HBoxContainer

signal send_add(item:String)
signal send_remove_selected()


func _ready():
	pass


func _on_hbc_manager_send_create():
	emit_signal("send_add", $HBC_combo.get_selected())


func _on_hbc_manager_send_delete():
	emit_signal("send_remove_selected")
