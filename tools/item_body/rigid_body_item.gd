#@tool
extends RigidBody2D

class_name DynamicBody2DItem

var _logs:LoggotLogger = Services.logs
var _items:Items = Services.items
var _interactive:Interactive = null

const _interactive_id = "interactive_id"

func _ready():
	assert(_logs)
	var dict = _items.get_item_dict(scene_file_path)
	if !dict.is_empty() && dict.has(_interactive_id):
		var linked_interactive_name = dict[_interactive_id][_interactive_id]
		_interactive = Interactive.create(linked_interactive_name)
		if _interactive:
			_interactive.send_interactive_event.connect(_on_interactive_hitpoint_end)
			body_entered.connect(_on_body_entered)
			add_child(_interactive)
			
func _on_body_entered(body):
	if _interactive:
		_interactive.interact(body)

func _on_interactive_hitpoint_end(_type, _value):
	pass
