# Поле для целочисленного свойства.
# Название поля можно задавать динамически из инспектора в родительском узле. 
@tool
extends HBoxContainer

@export var title:String:
	set(_value):
		title = _value
		if $Label:
			$Label.text = _value
		
@export var value:int = 0:
	set(_value):
		value = _value
		if $LineEdit && $LineEdit.text != str(_value):
			$LineEdit.text = str(value)

func section_name()->String:
	return title.to_snake_case()
	
func serialize()->Dictionary:
	return {$Label.text.to_snake_case():$LineEdit.text}
	
func deserialize(dict:Dictionary):
	var tmp_name = $Label.text.to_snake_case()
	if dict.has(tmp_name):
		$LineEdit.text = str(dict[tmp_name])
	
func clean():
	value = 0

func _on_line_edit_text_changed(new_text):
	value = int(new_text)
