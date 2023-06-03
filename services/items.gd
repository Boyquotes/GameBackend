@tool
extends Node

class_name Items

var _state:State = Services.state
var _logs:LoggotLogger = Services.logs
var _resources:Resources = Services.resource
var _names:PackedStringArray
# Словарь с состоянием сервиса для сериализации
var _state_dict:Dictionary
# Секция с начисленными предметами
const _accrued = "accrued"
const _asset_type = "items"


func _ready():
	assert(_logs)
	assert(_state)
	_state_dict = _state.get_dict(_asset_type)
	_logs.info("Items service > ready")
	update()
	
func update():
	_names = _resources.find_all_assets_tscn_names(_asset_type)
	
func _exit_tree():
	_state.set_dict(_asset_type, _state_dict)
	_logs.info("Items service > exit")
	
# Загружаем сцену предмета если она есть на диске
func get_item_node(node_name:String)->Node:
	# В словаре находятся пары (имя предмета - путь на диске)
	var item_path = _resources.get_asset_tscn_path(_asset_type, node_name)
	if not item_path.is_empty():
		var res_ps = load(item_path) as PackedScene
		if res_ps && res_ps.can_instantiate():
			var new_node = res_ps.instantiate() as Node
			return new_node
		else:
			_logs.error("Items service > item {0} can not instantiate {2}.".format([node_name, _resources.get_scene_extension()]))
	return null
	
func item_accrued(item_name:String, count:int):
	# проверим, что такой предмет существует
	if _names.has(item_name):
		var accrued_items = _state_dict.get(_accrued, {}) as Dictionary
		# количество уже начисленного предмета
		var item_count = accrued_items.get(item_name, 0) as int
		item_count += count
		accrued_items[item_name] = item_count
		_state_dict[_accrued] = accrued_items

func get_item(item_name:String)->Dictionary:
	return _resources.get_asset_cfg_dict(_asset_type, item_name)
	
func save_item(item_name:String, dict:Dictionary):
	_resources.save_asset_cfg(_asset_type, item_name, dict)
	
func get_list()->PackedStringArray:
	return _names

# найти в именах предметов или свойств - результат список имён
func find_in_items(find_text:String)->PackedStringArray:
	return _resources.find_text_in_assets(_asset_type, find_text)
