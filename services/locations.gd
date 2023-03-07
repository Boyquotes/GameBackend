# Сервис локаций отвечает за предоставление следующего уровня по запросу сцены.
# Уровни должны быть расположены в папке асетов ресурсов или хранилища пользователя.
# Уровни должны именоваться уникально для автоматической сортировки (<имя локации>_<номер уровеня>)
# Следующим будет загружаться следующий по алфавиту уровень или первый если все уровни пройдены

@tool
extends Node

class_name Locations

@onready var _state:State = Services.state
@onready var _logs:LoggotLogger = Services.logs
@onready var _resources:Resources = Services.resource
# Проверит не скачали ли мы в хранилище ассеты, если скачали возьмёт оттуда иначе из ресурсов
# Это пути к папкам, папки называются именами локаций и содержат уровни
@onready var _paths:Dictionary = _resources.find_all_dirs_locations()
const _state_name = "locations"
# Секция с пройденными уровнями в локациях
const _passed = "passed"
# Словарь с состоянием сервиса для сериализации
var _state_dict:Dictionary

func _ready():
	assert(_logs)
	assert(_state)
	_state_dict = _state.get_dict(_state_name)
	_logs.info("Location service > ready")
	
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



