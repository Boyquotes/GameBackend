@tool
extends HBoxContainer

signal send_create()
signal send_delete()
signal send_save()
signal send_clone()
signal send_find(new_text:String)

func _ready():
	pass

func _on_tb_create_pressed():
	emit_signal("send_create")

func _on_tb_delete_pressed():
	emit_signal("send_delete")

func _on_tb_save_pressed():
	emit_signal("send_save")

func _on_tb_clone_pressed():
	emit_signal("send_clone")

func _on_le_find_str_text_submitted(new_text):
	emit_signal("send_find", new_text)
