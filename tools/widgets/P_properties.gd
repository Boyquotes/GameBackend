@tool
extends Panel

var _resources:Resources = Services.resource


func _ready():
	pass
	
func update_location(location_name:String):
	if !location_name.is_empty():
		Helper.one_child_visible($SC_location)
		$SC_location/VBC_location.deserialize(location_name)
	
func update_level(level_path:String):
	if FileAccess.file_exists(level_path):
		Helper.one_child_visible($SC_level)
		$SC_level/VBC_level.deserialize(level_path)


