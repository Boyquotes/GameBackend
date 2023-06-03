@tool
extends VBoxContainer

var _collection = Services.collections

func _ready():
	pass 
	
func update():
	$VBC_list.update()
	$HBC_item_manage/HBC_combo.update()
	

func _on_hbc_item_manage_send_add(item):
	_collection.add_current_collection_item(item)
	update()


func _on_hbc_item_manage_send_remove_selected():
	_collection.remove_current_collection_item($VBC_list.get_selected())
	update()
	
func clear():
	$VBC_list.clear()
	$HBC_item_manage/HBC_combo.clear()
