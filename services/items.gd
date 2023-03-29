@tool
extends Node

class_name Items

var _state:State = Services.state
var _logs:LoggotLogger = Services.logs
var _resources:Resources = Services.resource
# Проверит не скачали ли мы в хранилище ассеты, если скачали возьмёт оттуда иначе из ресурсов
var _paths:Dictionary
# Словарь с состоянием сервиса для сериализации
var _state_dict:Dictionary

const _state_name = "items"
# Секция с начисленными предметами
const _accrued = "accrued"
const _res_items_dir_path = "res://assets/items"
const _user_items_dir_path = "user://assets/items"

func _ready():
	assert(_logs)
	assert(_state)
	_state_dict = _state.get_dict(_state_name)
	_logs.info("Items service > ready")
	_paths = _resources.find_all_files_dict(_get_items_path(), _resources.get_scene_extension())
	
func _exit_tree():
	_state.set_dict(_state_name, _state_dict)
	_logs.info("Items service > exit")
	
# Загружаем сцену предмета если она есть на диске
func get_item_node(node_name:String)->Node:
	# В словаре находятся пары (имя предмета - путь на диске)
	var item_path = _paths.get(node_name, "") as String
	if !item_path.is_empty():
		var res_ps = load(item_path) as PackedScene
		if res_ps && res_ps.can_instantiate():
			var new_node = res_ps.instantiate() as Node
			return new_node
		else:
			_logs.error("Items service > item {0} can not instantiate {2}.".format([node_name, _resources.get_scene_extension()]))
	return null
	
func item_accrued(item_name:String, count:int):
	# проверим, что такой предмет существует
	if _paths.has(item_name):
		var accrued_items = _state_dict.get(_accrued, {}) as Dictionary
		# количество уже начисленного предмета
		var item_count = accrued_items.get(item_name, 0) as int
		item_count += count
		accrued_items[item_name] = item_count
		_state_dict[_accrued] = accrued_items

func get_item_dict(item_name:String)->Dictionary:
	var cfg_path:String
	if item_name.is_absolute_path():
		cfg_path = item_name.replace(_resources.get_scene_extension(), _resources.get_interactive_extension())
	else:
		cfg_path = _get_items_path() + "/" + item_name + "." + _resources.get_interactive_extension()
	if FileAccess.file_exists(cfg_path):
		return _resources.load_dict_from_json_file(cfg_path)
	return {}
	
func _get_items_path()->String:
	if DirAccess.dir_exists_absolute(_user_items_dir_path):
		return _user_items_dir_path
		
	if DirAccess.dir_exists_absolute(_res_items_dir_path):
		return _res_items_dir_path
		
	_logs.error("Items service > path to items directory not exist.")
	return ""
	
func save_item_dict(item_name:String, dict:Dictionary):
	var path = _paths.get(item_name, "") as String
	path = path.replace(_resources.get_scene_extension(), _resources.get_interactive_extension())
	if !path.is_empty():
		_resources.save_dict_to_json_file(path, dict)
	
func get_items_list()->Array:
	return _paths.keys()

