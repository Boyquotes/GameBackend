@tool
extends VBoxContainer

var _resources:Resources = Services.resource
var _level_path:String

func _ready():
	pass

func serialize():
	if _level_path.is_empty():
		return
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	_resources.save_dict_to_json_file(_level_path, dict)
	
func deserialize(level_path:String):
	if !_level_path.is_empty():
		serialize()
	_level_path = level_path.get_basename() + "." + _resources.get_interactive_extension()
	if FileAccess.file_exists(_level_path):
		var dict = _resources.load_dict_from_json_file(_level_path)
		if !dict.is_empty():
			for child in get_children():
				if dict.has(child.section_name()):
					child.deserialize(dict[child.section_name()])
				
func _exit_tree():
	serialize()
