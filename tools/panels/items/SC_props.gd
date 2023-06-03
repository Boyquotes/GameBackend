@tool
extends ScrollContainer



func _ready():
	pass
	
func deserialize(dict:Dictionary):
	$VBC_item.deserialize(dict)
	
func serialize()->Dictionary:
	return $VBC_item.serialize()

