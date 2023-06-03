@tool
extends VBoxContainer

var _collection = Services.collections

signal send_collection_selected(collection_name:String)


func _ready():
	pass

func _on_vbc_list_send_change_item(old_name, new_name):
	_collection.rename(old_name, new_name)

func _on_hbc_manager_send_clone():
	_collection.clone($VBC_list.get_selected())
	$VBC_list.update()

func _on_hbc_manager_send_create():
	_collection.add()
	$VBC_list.update()

func _on_hbc_manager_send_delete():
	_collection.remove($VBC_list.get_selected())
	$VBC_list.update()

func _on_vbc_list_send_select(collection_name):
	_collection.load_collection(collection_name)
	emit_signal("send_collection_selected", collection_name)
