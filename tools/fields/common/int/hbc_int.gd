# Поле для целочисленного свойства.
# Название поля можно задавать динамически из инспектора в родительском узле. 
@tool
extends HBoxContainer

@export var title:String#:

func _ready():
	$Label.text = title
	$SpinBox.set_value_no_signal(default_value)
			
@export var default_value:int
var _last_manual_value = 0
var _reset_value = 0

signal send_change_int_value()

func section_name()->String:
	return title.to_snake_case()
	
func serialize()->Dictionary:
	return {$Label.text.to_snake_case():$SpinBox.value}

func deserialize(dict:Dictionary = {}):
	_reset_value = int(dict.get($Label.text.to_snake_case(), default_value))
	$SpinBox.set_value_no_signal(_reset_value)

func _on_spin_box_value_changed(_value):
	# По неизвестной причине вручную измененное значение одинарно переустанавливается при установке из кода нового значения!
	if _last_manual_value != _value:
		emit_signal("send_change_int_value")
		_last_manual_value = _value
	else:
		$SpinBox.set_value_no_signal(_reset_value)
