#@tool
extends CharacterBody2D

class_name CharacterBody2DItem

var _logs:LoggotLogger = Services.logs
var _items:Items = Services.items

const _interactive_id = "interactive_id"

func _ready():
	assert(_logs)
	var dict = _items.get_item_dict(scene_file_path)
	if !dict.is_empty() && dict.has(_interactive_id):
		var linked_interactive_name = dict[_interactive_id][_interactive_id]
		var interactive = Interactive.create(linked_interactive_name)
		if interactive:
			interactive.send_interactive_event.connect(_on_interactive_hitpoint_end)
			add_child(interactive)

func _on_interactive_hitpoint_end(_type, _value):
	pass
