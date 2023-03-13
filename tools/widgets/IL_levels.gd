@tool
extends ItemList

var _locations:Locations = Services.locations
var _levels:Dictionary

signal send_selected_level(level_path:String)

func _ready():
	pass
	
func update(location_name:String):
	clear()
	_levels = _locations.find_all_levels_location_tscn(location_name)
	for name in _levels.keys():
		add_item(name)

func _on_item_clicked(index, at_position, mouse_button_index):
	var level_name = get_item_text(index)
	emit_signal("send_selected_level", _levels[level_name])
