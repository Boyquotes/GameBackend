@tool
extends Panel

signal send_new_text(_text:String)


func _ready():
	pass 
	
func set_text(old_text:String):
	$LineEdit.text = old_text

func _on_line_edit_text_submitted(new_text):
	emit_signal("send_new_text", new_text)
	visible = false
