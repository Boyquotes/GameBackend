@tool
extends HBoxContainer

@export var title:String:
	set(_value):
		title = _value
		if $Label:
			$Label.text = _value
		
@export var value:int = 0:
	set(_value):
		if $LineEdit && $LineEdit.text != str(_value):
			value = _value
			$LineEdit.text = str(value)

func section_name()->String:
	return title
	
func serialize()->Dictionary:
	return {$Label.text.to_snake_case():$LineEdit.text}
	
func deserialize(dict:Dictionary):
	var tmp_name = $Label.text.to_snake_case()
	if dict.has(tmp_name):
		$LineEdit.text = str(dict[tmp_name])


func _on_line_edit_text_submitted(new_text):
	value = int(new_text)
	
func clean():
	value = 0
