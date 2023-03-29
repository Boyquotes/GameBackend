@tool
extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_item(item_name:String):
	visible = true
	if !item_name.is_empty():
		$VBC_item.deserialize(item_name)
