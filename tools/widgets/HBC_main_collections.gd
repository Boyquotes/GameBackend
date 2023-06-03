@tool
extends HBoxContainer


func _ready():
	pass # Replace with function body.


func _on_vbc_collection_send_select_collection(collection_name):
	$VBC_items.update(collection_name)
	$SC_props.update_collection_props(collection_name)


func _on_vbc_items_send_selected_item(item_name):
	$SC_props.update_item_props(item_name)


func _on_vbc_collection_send_save_current():
	$SC_props.save_current()
