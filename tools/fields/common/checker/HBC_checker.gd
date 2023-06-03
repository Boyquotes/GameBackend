@tool
extends HBoxContainer

@export var title:String

signal send_changed(value)

func _ready():
	if not title.is_empty():
		$L_title.text = title
		
func serialize()->Dictionary:
	return {
		$L_title.text.to_snake_case():$CB_checker.button_pressed
	}
	
func section_name()->String:
	return title.to_snake_case()
	
func deserialize(dict:Dictionary):
	var key = $L_title.text.to_snake_case()
	$CB_checker.button_pressed = dict.get(key, false)


func _on_cb_checker_toggled(button_pressed):
	emit_signal("send_changed", button_pressed)
