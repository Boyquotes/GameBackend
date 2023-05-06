@tool
extends Node

class_name Collections

var _logs:LoggotLogger = Services.logs
var _resources:Resources = Services.resource
var _items:Items = Services.items
var _paths:Dictionary
var _names:PackedStringArray
var _current_collection:Dictionary
var _current_collection_name:String
var _can_add_collection_items:Array
var _is_collection_changed:bool = false

const _items_section = "items"
const _collection_props = "props"
const _asset_type = "collections"


func _ready():
	assert(_logs)
	_logs.info("Collections service > ready")
	update()
	
func update():
	_paths = _resources.find_all_assets_cfg_files_dict(_asset_type)
	_names = _paths.keys()


func get_collections()->PackedStringArray:
	return _names
	
func remove_collection(collection_name:String):
	if collection_name in _paths:
		_resources.remove_file(_paths[collection_name])
		update()

# добавить коллекцию с соданием файла на диске и обновлением списка если новая
func add_collection(collection_name:String, dict:Dictionary = {_items_section:{}, _collection_props:{}}):
	var path = _resources.get_assets_path(_asset_type) + "/" + collection_name
	_resources.save_dict_to_cfg_file(path, dict)
	update()
	
# найти в именах коллекций её предметов или свойст - результат список имён коллекций
func find_in_collections(find_text:String)->PackedStringArray:
	var indexes = _resources.find_in_text_files(_paths.values(), find_text)
	var list:PackedStringArray
	for index in indexes:
		list.append(_names[index])
	return list
		
func rename_collection(old_name:String, new_name:String):
	_resources.rename_file(_paths[old_name], new_name)
	
func clone_collection(old_name:String, new_name:String):
	_resources.copy_file(_paths[old_name], new_name)
	
# загрузить указанную коллекцию в текущую
func load_collection(collection_name:String)->bool:
	if not collection_name.is_empty() && collection_name == _current_collection_name:
		return true
	if collection_name in _paths:
		_current_collection = _resources.load_dict_from_json_file(_paths[collection_name])
		_current_collection_name = collection_name
		_is_collection_changed = false
		# составить список доступных для добавления в коллекцию предметов
		if _items_section in _current_collection:
			var items_list = _current_collection[_items_section].keys()
			_can_add_collection_items = _items.get_items_list()
			for item_name in items_list:
				_can_add_collection_items.erase(item_name)
		return true
	else:
		_logs.error("Collections service > path to collection {0} not exist.".format([collection_name]))
	_current_collection.clear()
	_current_collection_name = ""
	_can_add_collection_items.clear()
	return false

func get_collection_props(collection_name:String)->Dictionary:
	load_collection(collection_name)
	if _collection_props in _current_collection:
		return _current_collection[_collection_props]
	return {}
	
func add_collection_props(collection_name:String, props_dict:Dictionary):
	if not _current_collection_name.is_empty():
		var props = get_collection_props(collection_name)
		_current_collection[_collection_props] = props_dict
		_is_collection_changed = true
		
func get_collection_item(item_name:String)->Dictionary:
	if _items_section in _current_collection:
		return _current_collection[_items_section].get(item_name, {})
	return {}
	
func add_collection_item(item_name:String, props_dict:Dictionary = {}):
	if _items_section in _current_collection:
		var items = _current_collection[_items_section]
		items[item_name] = props_dict
		_current_collection[_items_section] = items
		_can_add_collection_items.erase(item_name)
		_is_collection_changed = true
		
func get_collection_items(collection_name:String)->PackedStringArray:
	if _items_section in _current_collection:
		var items = _current_collection[_items_section] as Dictionary
		return items.keys()
		
	return []
		
# удалить предмет из текущей коллекции
func remove_item(collection_name:String, item_name:String):
	if _items_section in _current_collection:
		var items = _current_collection[_items_section] as Dictionary
		items.erase(item_name)
		_current_collection[_items_section] = items
		_can_add_collection_items.erase(item_name)
		_is_collection_changed = true

# сохранить текущую коллекцию
func save_current_collection():
	if not _current_collection_name.is_empty() && _is_collection_changed:
		add_collection(_current_collection_name, _current_collection)

# список доступных для добавления в данную коллекцию предметов
func get_can_add_items(collection_name:String)->PackedStringArray:
	load_collection(collection_name)
	return _can_add_collection_items
	
