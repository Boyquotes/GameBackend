@tool
extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

		
func deserialize(dict:Dictionary):
	$VBC_item.deserialize(dict)
		
func serialize()->Dictionary:
	return $VBC_item.serialize()
	
