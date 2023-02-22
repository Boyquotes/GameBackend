extends BaseBlock

class_name HitpointBlock


# Значения целочисленного поля:
# -1  - не учитывать в расчётах
# 0   - ошибка или значение не указано
# >0  - корректное значение
var damage = -1
var hitpoints = -1:
	set(value):
		hitpoints = value
		if value == 0:
			var parent = get_parent()
			if parent && parent.has_method(_interact_handler_method):
				parent.interact_handler(Interactive.HITPOINT_END, value)
			else:
				_error_block_notify(_interact_handler_method)

const _name_damage = "damage"
const _name_hitpoints = "hitpoints"
const _static_fields = "static_fields"


func _pars_field_int(dict:Dictionary, field_name:String)->int:
	if dict.has(field_name):
		return str(dict[field_name]).to_int()
	else:
		_error_field_notify(_name_damage)
		return 0

func pars_dict(dict:Dictionary)->bool:
	if dict.has(_static_fields):
		var static_fields = dict[_static_fields]
		if static_fields.has(_name_damage):
			damage = str(static_fields[_name_damage]).to_int()
		else:
			_error_field_notify(_name_damage)
			return false
		if static_fields.has(_name_hitpoints):
			hitpoints = str(static_fields[_name_hitpoints]).to_int()
		else:
			_error_field_notify(_name_hitpoints)
			return false
	else:
		_error_section_notify(_static_fields)
		return false
	return true
	
func interact(inter:Interactive):
	if inter.interactives.has(name):
		var opposite_block = inter.interactives[name] as HitpointBlock
		if opposite_block:
			if hitpoints > 0 && opposite_block.damage > 0:
				var result = hitpoints - opposite_block.damage
				hitpoints = result if result > 0 else 0
			if opposite_block.hitpoints > 0 && damage > 0:
				var result = opposite_block.hitpoints - damage
				opposite_block.hitpoints = result if result > 0 else 0
		
