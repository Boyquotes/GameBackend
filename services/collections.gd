@tool
extends BaseAssetsService

class_name Collections

var _items:Items = Services.items
var _current_collection:Dictionary
var _current_collection_name:String
var _can_add_collection_items:Array
const _items_section = "items"
const _collection_props = "props"
const _drop_item_percent = "drop_percent"
const _min_items = "min_drop_items"
const _max_items = "max_drop_items"


func _ready():
	_asset_type = "collections"
	super._ready()
	randomize()

# загрузить указанную коллекцию в текущую
func load_collection(collection_name:String)->bool:
	if collection_name.is_empty():
		return false
	
	if not collection_name.is_empty() && collection_name == _current_collection_name:
		return true
		
	if collection_name in _names:
		_current_collection = _resources.get_asset_cfg_dict(_asset_type, collection_name)
		_current_collection_name = collection_name
		# составить список доступных для добавления в коллекцию предметов
		var items_list = _current_collection.get(_items_section, {}).keys()
		_can_add_collection_items = _items.get_list().duplicate()
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

func get_current_collection_props()->Dictionary:
	return get_collection_props(_current_collection_name)

func add_collection_props(collection_name:String, props_dict:Dictionary):
	if not _current_collection_name.is_empty():
		var props = get_collection_props(collection_name)
		_current_collection[_collection_props] = props_dict

func add_current_collection_props(props_dict:Dictionary):
	add_collection_props(_current_collection_name, props_dict)

func get_current_collection_item(item_name:String)->Dictionary:
	if _items_section in _current_collection:
		return _current_collection[_items_section].get(item_name, {})
	return {}
	
func add_current_collection_item(item_name:String, props_dict:Dictionary = {}):
	if not item_name.is_empty():
		var items = _current_collection.get(_items_section, {})
		items[item_name] = props_dict
		_current_collection[_items_section] = items
		
func get_collection_items(collection_name:String)->PackedStringArray:
	load_collection(collection_name)
	if _items_section in _current_collection:
		var items = _current_collection[_items_section] as Dictionary
		return items.keys()
		
	return []

func get_current_collection_items()->PackedStringArray:
	return get_collection_items(_current_collection_name)

func remove_current_collection_item(item_name:String):
	if _items_section in _current_collection:
		var items = _current_collection[_items_section] as Dictionary
		items.erase(item_name)
		_current_collection[_items_section] = items
		_can_add_collection_items.erase(item_name)

func save_current_collection():
	if not _current_collection_name.is_empty():
		save(_current_collection_name, _current_collection)

# список доступных для добавления в данную коллекцию предметов
func get_can_add_items(collection_name:String)->PackedStringArray:
	load_collection(collection_name)
	return _can_add_collection_items
	
func get_current_can_add_items()->PackedStringArray:
	load_collection(_current_collection_name)
	return _can_add_collection_items
	
# получить список предметов выпавших из коллекции
func get_drop_items(collection_name:String)->PackedStringArray:
	load_collection(collection_name)
	var result:PackedStringArray
	if _items_section in _current_collection:
		var items = _current_collection.get(_items_section, {}) as Dictionary
		var props = _current_collection.get(_collection_props, {}) as Dictionary
		var min_items = props.get(_min_items, 1)
		var max_items = props.get(_max_items, 100)
		var max_item_perc = 0
		var max_item_name:String 
		var perc:int
		# проходя по всем предметам ищем максимальный процент - этот предмет дадим если ничего не выпадет
		for item_name in items.keys():
			# процент выпадения предмета из коллекции
			perc = items.get(item_name, {}).get(_drop_item_percent, {}).get(_drop_item_percent, 0)
			# проверяем вдруг это предмет с максимальным процентом
			if perc > max_item_perc:
				max_item_perc = perc
				max_item_name = item_name
			# рандомное число попадает в интервал процентов выпадения предмета - начисляем
			if randi_range(1, 100) <= perc:
				result.append(item_name)
		# если выпало больше максимума и максимум валидный - обрезать результат
		if result.size() > max_items && max_items >= min_items:
			result.resize(max_items)
				
		if result.is_empty() && not max_item_name.is_empty():
			result.append(max_item_name)
			
	return result
