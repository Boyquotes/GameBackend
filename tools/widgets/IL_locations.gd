@tool
extends ItemList

var _locations:Locations = Services.locations

signal send_selected_location(name:String)

func _ready():
	clear()
	for name in _locations.find_all_dirs_locations().keys():
		add_item(name)

func _on_item_clicked(index, at_position, mouse_button_index):
	var location_name = get_item_text(index)
	emit_signal("send_selected_location", location_name,)
