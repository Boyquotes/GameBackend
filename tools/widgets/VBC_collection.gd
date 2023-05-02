# Список доступных коллекций и панель добавления, удаления, поиска.
@tool
extends VBoxContainer

@onready var _collections:Collections = Services.collections

# Имя коллекции по умолчанию.
const _default_collection = "Default_collection"
const _clone_default_suffix = "_clone"
const _new_default_suffix = "_new"

# Сигнал в правую панель для отображения элементов коллекции и настроек.
signal send_select_collection(collection_name:String)

func update():
	$IL_collections.clear()
	for collection_name in _collections.get_collections():
		$IL_collections.add_item(collection_name)

func add_item(collection_name:String = _default_collection):
	if collection_name in _collections.get_collections():
		collection_name = _get_new_selected_name()

	var index = $IL_collections.add_item(collection_name)
	$IL_collections.deselect_all()
	$IL_collections.select(index)
	_collections.add_collection(collection_name)
	emit_signal("send_select_collection", collection_name)


func _ready():
	update()


func _get_new_selected_name(suffix:String = "")->String:
	for index in $IL_collections.get_selected_items():
		var new_name = $IL_collections.get_item_text(index)
		while new_name in _collections.get_collections_array():
			new_name += suffix
		return new_name
	return ""


func _on_il_collections_item_clicked(index, at_position, mouse_button_index):
	if MOUSE_BUTTON_RIGHT != mouse_button_index:
		emit_signal("send_select_collection", $IL_collections.get_item_text(index))


func _on_il_collections_send_change_item(old_name, new_name):
	if not new_name.is_empty():
		_collections.rename_collection(old_name, new_name)
		_collections.update()


func _on_hbc_manager_send_clone():
	for index in $IL_collections.get_selected_items():
		var new_name = _get_new_selected_name(_clone_default_suffix)
		if not new_name.is_empty():
			_collections.clone_collection($IL_collections.get_item_text(index), new_name)
			_collections.update()
			update()
		return


func _on_hbc_manager_send_create():
	add_item()


func _on_hbc_manager_send_delete():
	for index in $IL_collections.get_selected_items():
		_collections.remove_collection($IL_collections.get_item_text(index))
		$IL_collections.remove_item(index)
	emit_signal("send_select_collection", "")


func _on_hbc_manager_send_find(new_text):
	# Удалили текст запроса - возвращаем полный список.
	if new_text.is_empty():
		update()
		return
	var names = _collections.find_in_collections(new_text)
	$IL_collections.clear()
	if not names.is_empty():
		for _name in names:
			$IL_collections.add_item(_name)


func _on_hbc_manager_send_save():
	_collections.save_current_collection()

