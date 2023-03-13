# Сервис локаций отвечает за предоставление следующего уровня по запросу сцены.
# Уровни должны быть расположены в папке асетов ресурсов или хранилища пользователя.
# Уровни должны именоваться уникально для автоматической сортировки (<имя локации>_<номер уровеня>)
# Следующим будет загружаться следующий по алфавиту уровень или первый если все уровни пройдены

@tool
extends Node

class_name Locations

var _state:State = Services.state
var _logs:LoggotLogger = Services.logs
var _resources:Resources = Services.resource
# Проверит не скачали ли мы в хранилище ассеты, если скачали возьмёт оттуда иначе из ресурсов
# Это пути к папкам, папки называются именами локаций и содержат уровни
var _paths:Dictionary
# Словарь с состоянием сервиса для сериализации
var _state_dict:Dictionary

const _state_name = "locations"
# Секция с пройденными уровнями в локациях
const _passed = "passed"
const _res_locations_dir_path = "res://assets/locations"
const _user_locations_dir_path = "user://assets/locations"
const _location_cfg = "config.json"

func _ready():
	assert(_logs)
	assert(_state)
	_state_dict = _state.get_dict(_state_name)
	_logs.info("Location service > ready")
	_paths = find_all_dirs_locations()
	
func _exit_tree():
	_state.set_dict(_state_name, _state_dict)
	_logs.info("Location service > exit")
	
# Загружаем сцену по индексу если она есть на диске
func _load_scene(all_levels:Dictionary, index:int)->Node:
	# В словаре находятся пары (имя уровня - путь на диске)
	var all_levels_keys = all_levels.keys()
	if index < all_levels_keys.size():
		var level_name =  all_levels_keys[index]
		var res_ps = load(all_levels[level_name]) as PackedScene
		if res_ps && res_ps.can_instantiate():
			var new_node = res_ps.instantiate() as Node
			# Устанавливаем уровня в узел, при завершении уровня его мы передадим в метод location_level_passed
			# чтобы сохранить отметку о прохождении
			new_node.name = level_name
			return new_node
		else:
			_logs.error("Location service > level {0} can not instantiate {2}.".format([level_name, _resources.get_scene_extension()]))
	return null
	
func get_next_level_for_location(location:String):
	if _paths.has(location):
		# По имени локации находим путь к папке с уровнями и складываем всё в словарь
		var all_levels = _resources.find_all_files_dict(_paths[location], _resources.get_scene_extension()) as Dictionary
		var location_dict = _state_dict.get(location, {}) as Dictionary
		# Уровни которые уже прошли
		var passed_levels = location_dict.get(_passed, []) as Array
		if passed_levels.is_empty():
			if !all_levels.is_empty():
				return _load_scene(all_levels, 0)
			else:
				_logs.error("Location service > location {0} {1} doesn't have levels.".format([location, _resources.get_scene_extension()]))
		else:
			var last_level = passed_levels.back() as String
			var ind = all_levels.keys().find(last_level)
			if ind > -1:
				# уровень найден в ресурсах
				if ind + 1 < all_levels.keys().size():
					return _load_scene(all_levels, ind + 1)
				else:
					# последний уровень
					# переключаемся на первый или показываем финальную заставку если пройдены все 
					# локации или квесты
					return _load_scene(all_levels, 0)
			# уровня нет в списке всех уровней
			else:
				_logs.error("Location service > level {0} in location {1} not exist.".format([last_level, location]))
				OS.alert("Location service > level {0} in location {1} not exist.".format([last_level, location]))
	return null
	
func location_level_passed(location:String, level:String):
	var location_dict = _state_dict.get(location, {}) as Dictionary
	var passed_levels = location_dict.get(_passed, []) as Array
	passed_levels.append(level)
	location_dict[_passed] = passed_levels
	_state_dict[location] = location_dict

func get_cfg_dict_for_location(location:String)->Dictionary:
	var cfg_path = _paths.get(location, "") + "/" + _location_cfg
	if FileAccess.file_exists(cfg_path):
		return _resources.load_dict_from_json_file(cfg_path)
	return {}
	
func get_location_path()->String:
	if DirAccess.dir_exists_absolute(_user_locations_dir_path):
		return _user_locations_dir_path
		
	if DirAccess.dir_exists_absolute(_res_locations_dir_path):
		return _res_locations_dir_path
		
	_logs.error("Location service > path to locations directory not exist.")
	return ""
	
func find_all_dirs_locations()->Dictionary:
	var paths:Dictionary
	_resources.find_all_dirs_recursive(get_location_path(), paths)
	return paths
	
func find_all_levels_location_tscn(location_name:String)->Dictionary:
	if _paths.has(location_name):
		return _resources.find_all_files_dict(_paths[location_name], _resources.get_scene_extension())
	return {}

func get_locations()->Dictionary:
	return _paths

func get_location_cfg_name():
	return _location_cfg
