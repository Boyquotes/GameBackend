# Обработчик воспроизведения звуков при столкновении интерактивов

extends BaseBlock

class_name SoundLinks

var _sounds:Sounds = Services.sounds
var _sound_links:Dictionary

const _name_id = "interactive_id"
const _name_path = "path_to_sound"
const _dynamic_fields = "dynamic_fields"


func pars_dict(dict:Dictionary)->bool:
	if dict.has(_dynamic_fields):
		var dynamic_fields_array = dict[_dynamic_fields]
		for item_dict in dynamic_fields_array:
			if item_dict.has(_name_id) && item_dict.has(_name_path):
				_sound_links[item_dict[_name_id]] = item_dict[_name_path]
			else:
				pass
	else:
		_error_section_notify(_dynamic_fields)
		return false
	return true
	
func interact(inter:Interactive):
	# У себя в списке проверяем есть ли звук для другого интерактива
	var sound_path = _sound_links[inter._id] as String
	if !sound_path.is_empty():
		_sounds.play(sound_path)
