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
		if has_node("SpinBox") && $SpinBox.value != _value:
			$SpinBox.value = value
			
signal send_value_changed()

func section_name()->String:
	return title.to_snake_case()
	
func serialize()->Dictionary:
	return {$Label.text.to_snake_case():$SpinBox.value}
	
func deserialize(dict:Dictionary):
	var tmp_name = $Label.text.to_snake_case()
	if dict.has(tmp_name):
		$SpinBox.value = dict[tmp_name] as int
	
func clean():
	value = 0

func _on_line_edit_text_changed(new_text):
	value = int(new_text)


func _on_spin_box_value_changed(_value):
	value = _value
	emit_signal("send_value_changed")
