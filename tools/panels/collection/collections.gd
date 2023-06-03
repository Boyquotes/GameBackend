@tool
extends HBoxContainer

var _collection = Services.collections

func _ready():
	pass
# вызываем через имя потому, что на данный момент я не знаю сколько ещё у коллекции будет панелей со свойствами.
func _on_vbc_list_send_select_collection_item(item_name):
	$SC_props.update("VBC_item", item_name)

func _on_vbc_collections_send_collection_selected(collection_name):
	$SC_props.visible = true
	$VBC_collection_items.update()
	$SC_props.update("VBC_collection", collection_name)

# при изменении данных в UI они вносятся в словарь. При сохранении 
# мы руками дёргаем сериализацию свойств коллекции и всех её предметов.
func _on_hbc_manager_send_save():
	var collection_name = $VBC_collections/VBC_list.get_selected()
	$SC_props.serialize("VBC_collection", collection_name)
	var items_list = _collection.get_collection_items(collection_name)
	for item_name in items_list:
		$SC_props.serialize("VBC_item", item_name)
	_collection.save_current_collection()


func _on_vbc_list_send_filtering():
	$VBC_collection_items.clear()
	$SC_props.visible = false
