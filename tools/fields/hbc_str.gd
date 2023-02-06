# Поле для строкового свойства.
# Название поля можно задавать динамически из инспектора в родительском узле. 
@tool
extends HBoxContainer

@export var title:String:
	set(_value):
		title = _value
		if $Label:
			$Label.text = _value
		
@export var value:String:
	set(_value):
		value = _value
		if $LineEdit && $LineEdit.text != _value:
			$LineEdit.text = _value

func section_name()->String:
	return title
	
func serialize()->Dictionary:
	return {$Label.text.to_snake_case():$LineEdit.text}
	
func deserialize(dict:Dictionary):
	var tmp_name = $Label.text.to_snake_case()
	if dict.has(tmp_name):
		$LineEdit.text = dict[tmp_name]
	
func clean():
	value = ""

func _on_line_edit_text_changed(new_text):
	value = new_text
