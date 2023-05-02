@tool
extends VBoxContainer

@onready var _collections:Collections = Services.collections
var _current_collection_name:String
@onready var _OB_can_add_items = $HBC_items_manager/OB_can_add_items
var _filter:String

signal send_selected_item(item_name:String)


func _ready():
	_OB_can_add_items.clear()
	$IL_items.clear()

func update(collection_name:String):
	_OB_can_add_items.clear()
	$IL_items.clear()
	
	if _filter.is_empty():
		for item in _collections.get_can_add_items(collection_name):
			_OB_can_add_items.add_item(item)
			
		for item in _collections.get_collection_items(collection_name):
			$IL_items.add_item(item)
	else:
		for item in _collections.get_can_add_items(collection_name):
			if _filter in item.to_lower():
				_OB_can_add_items.add_item(item)
			
		for item in _collections.get_collection_items(collection_name):
			if _filter in item:
				$IL_items.add_item(item)
		
	_current_collection_name = collection_name


func _on_tb_create_pressed():
	var item_name = _OB_can_add_items.text as String
	if not item_name.is_empty() && not _current_collection_name.is_empty():
		_collections.add_collection_item(item_name)
		update(_current_collection_name)


func _on_tb_delete_pressed():
	for index in $IL_items.get_selected_items():
		_collections.remove_item(_current_collection_name, $IL_items.get_item_text(index))
		update(_current_collection_name)
		emit_signal("send_select_item", "")


func _on_le_filter_items_text_submitted(new_text):
	_filter = new_text.to_lower()
	if not _current_collection_name.is_empty():
		update(_current_collection_name)


func _on_il_items_item_clicked(index, at_position, mouse_button_index):
	emit_signal("send_selected_item", $IL_items.get_item_text(index))

