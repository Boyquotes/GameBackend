@tool
extends ScrollContainer



func _ready():
	pass
	
func update(prop_panel:String, value:String):
	var props = $VBC_props.get_node(prop_panel)
	if props && props.has_method("update"):
		props.update(value)
		Helper.one_child_visible(props)
		
func serialize(prop_panel:String, value:String):
	var props = $VBC_props.get_node(prop_panel)
	if props && props.has_method("update"):
		props.update(value)
	if props && props.has_method("serialize"):
		props.serialize()
		
		

