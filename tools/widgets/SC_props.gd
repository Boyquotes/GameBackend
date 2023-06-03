@tool
extends ScrollContainer

@onready var _collections:Collections = Services.collections
var _current_collection:String
var _current_item:String

func _ready():
	Helper.one_child_visible($P_props/VBC_collection_props)

func update_collection_props(collection_name:String):
	Helper.one_child_visible($P_props/VBC_collection_props)
	_current_collection = collection_name
	_current_item = ""
	var dict = _collections.get_collection_props(collection_name)
	$P_props/VBC_collection_props.deserialize(dict)
	
func update_item_props(item_name:String):
	Helper.one_child_visible($P_props/VBC_item_props)
	var dict = _collections.get_collection_item(item_name)
	$P_props/VBC_item_props.deserialize(dict)
	_current_item = item_name

func save_current():
	if not _current_collection.is_empty() && _current_item.is_empty():
		_collections.add_collection_props(_current_collection, $P_props/VBC_collection_props.serialize())
	if not _current_item.is_empty():
		_collections.add_collection_item(_current_item, $P_props/VBC_item_props.serialize())
	_collections.save_current_collection()
