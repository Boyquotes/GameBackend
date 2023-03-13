@tool
extends HBoxContainer


func _ready():
	pass

func _on_il_locations_send_selected_location(location_name:String):
	$IL_levels.update(location_name)
	$P_properties.update_location(location_name)

func _on_il_levels_send_selected_level(level_path:String):
	$P_properties.update_level(level_path)
