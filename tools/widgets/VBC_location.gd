@tool
extends VBoxContainer

var _resources:Resources = Services.resource
var _locations:Locations = Services.locations
var _location_path:String

func _ready():
	pass

func serialize():
	if _location_path.is_empty():
		return
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	_resources.save_dict_to_json_file(_location_path, dict)
	
func deserialize(location_name:String):
	if !_location_path.is_empty():
		serialize()
	_location_path = _locations.get_locations().get(location_name, "")
	if _location_path.is_empty() || !DirAccess.dir_exists_absolute(_location_path):
		return
	_location_path = _location_path + "/" + _locations.get_location_cfg_name()
	if FileAccess.file_exists(_location_path):
		var dict = _resources.load_dict_from_json_file(_location_path)
		if !dict.is_empty():
			for child in get_children():
				if dict.has(child.section_name()):
					child.deserialize(dict[child.section_name()])
				
func _exit_tree():
	serialize()
