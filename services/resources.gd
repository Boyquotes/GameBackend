@tool
extends Node

class_name Resources

var _queue_to_load:PackedStringArray

var _logs:LoggotLogger = Services.logs
@onready var _timer:Timer = null

const _timer_timeout = 0.5
var progress:Array[float]

# Путь к файлам конфигурации интерактивов
const _res_interactives_dir_path = "res://assets/interactives"
const _user_interactives_dir_path = "user://assets/interactives"
#const _res_locations_dir_path = "res://assets/locations"
#const _user_locations_dir_path = "user://assets/locations"
const _blocks_dir_path = "res://addons/GameBackend/tools/blocks"
const _cfg_extension = "json"
const _scene_extension = "tscn"
const _pwd = ""
#const _location_cfg = "config." + _cfg_extension

signal send_resource_loaded(path:String, res:Resource)
signal send_resource_progress(progress:float)

func _ready():
	assert(_logs)
	_logs.info("Resource service > started")
	_timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = _timer_timeout
	_timer.timeout.connect(_on_timer_timeout)
	
#func get_location_cfg_name():
#	return _location_cfg
	
func get_resource_async(path:String) -> int:#"Error" вызывает ошибку компиляции! 
	if !FileAccess.file_exists(path):
		_logs.info("Resource service > file bad path " + path)
		return ERR_FILE_BAD_PATH;
		
	var state = ResourceLoader.load_threaded_request(path, "", true)
	if state == OK:
		_queue_to_load.append(path)
	else:
		_logs.error("Resource service > {0}, {1}".format([Helper.error_str[state], path]))
		return state

	_logs.info("Resource service > load start " + path)
	_timer.start()
	return OK
	
func _on_timer_timeout():
	if !_queue_to_load.is_empty():
		var curr_path:String
		for idx in _queue_to_load.size():
			curr_path = _queue_to_load[-idx]
			match ResourceLoader.load_threaded_get_status(curr_path, progress):
				ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
					_logs.error("Resource service > load invalid resource " + curr_path)
					_queue_to_load.remove_at(-idx)
				ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					emit_signal("send_resource_progress", float(progress[0] * 100.0))
				ResourceLoader.THREAD_LOAD_FAILED:
					_logs.error("Resource service > load failed " + curr_path)
					_queue_to_load.remove_at(-idx)
				ResourceLoader.THREAD_LOAD_LOADED:
					emit_signal("send_resource_loaded", curr_path, ResourceLoader.load_threaded_get(curr_path))
					_logs.info("Resource service > resource loaded " + curr_path)
					_queue_to_load.remove_at(-idx)
	else:
		_logs.info("Resource service > timer was stopped")
		_timer.stop()

func get_interactive_path()->String:
	if DirAccess.dir_exists_absolute(_user_interactives_dir_path):
		return _user_interactives_dir_path
		
	if DirAccess.dir_exists_absolute(_res_interactives_dir_path):
		return _res_interactives_dir_path
		
	_logs.error("Resource service > path to interactives directory not exist.")
	return ""
	
#func get_location_path()->String:
#	if DirAccess.dir_exists_absolute(_user_locations_dir_path):
#		return _user_locations_dir_path
#
#	if DirAccess.dir_exists_absolute(_res_locations_dir_path):
#		return _res_locations_dir_path
#
#	_logs.error("Resource service > path to locations directory not exist.")
#	return ""
	
func get_blocks_path()->String:
	return _blocks_dir_path
	
func get_interactive_extension()->String:
	return _cfg_extension
	
func get_scene_extension()->String:
	return _scene_extension
	
# Абсолютный путь к файлу конфигурации по имени идентификатора интерактива
func get_interactive_file_path(id:String)->String:
	return  "{0}/{1}.{2}".format([get_interactive_path(), id, _cfg_extension])

func find_all_files_recursive(find_dir:String, extension:String, paths:Dictionary):
	var dir = DirAccess.open(find_dir)
	if dir:
		dir.list_dir_begin()
		while true:
			var next_item = dir.get_next().replace(".import", "")
			if next_item.is_empty():
				break
			if dir.current_is_dir() && next_item != "." && next_item != "..":
				find_all_files_recursive(dir.get_current_dir() + "/" + next_item + "/", extension, paths)
			elif next_item.get_extension() == extension:
				if paths.has(next_item.get_basename()):
					_logs.error("Resource service >  Duplicate resources " + next_item)
				paths[next_item.get_basename()] = dir.get_current_dir() + "/" + next_item
				_logs.info("Resource service > Add path to resource - " + next_item.get_basename())
		dir.list_dir_end()
	else:
		_logs.error("Resource service > An error occurred when trying to access the path " + find_dir)
		
func find_all_dirs_recursive(find_dir:String, paths:Dictionary):
	var dir = DirAccess.open(find_dir)
	if dir:
		dir.list_dir_begin()
		while true:
			var next_item = dir.get_next().replace(".import", "")
			if next_item.is_empty():
				break
			if dir.current_is_dir() && next_item != "." && next_item != "..":
				find_all_dirs_recursive(dir.get_current_dir() + "/" + next_item + "/", paths)
				paths[next_item.get_basename()] = dir.get_current_dir() + "/" + next_item
		dir.list_dir_end()
	else:
		_logs.error("Resource service > An error occurred when trying to access the path " + find_dir)

#func find_all_dirs_locations()->Dictionary:
#	var paths:Dictionary
#	find_all_dirs_recursive(get_location_path(), paths)
#	return paths
	
func find_all_files_dict(start_dir:String, extension:String)->Dictionary:
	var result:Dictionary
	find_all_files_recursive(start_dir, extension, result)
	return result
	
func find_all_files_array(start_dir:String, extension:String)->Array:
	return find_all_files_dict(start_dir, extension).keys()

#func find_all_levels_location_tscn(location_name:String)->Dictionary:
#	var paths_dict = find_all_dirs_locations()
#	if paths_dict.has(location_name):
#		return find_all_files_dict(paths_dict[location_name], get_scene_extension())
#	return {}
	
func save_dict_to_json_file(path:String, dict:Dictionary):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, _pwd) if !OS.is_debug_build() else FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(dict))
	else:
		var message = "State service > File error(save):{0}, {1}".format([Helper.error_str[FileAccess.get_open_error()], path])
		OS.alert(message)
		
func load_dict_from_json_file(path:String)->Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, _pwd) if !OS.is_debug_build() else FileAccess.open(path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var state = json.parse(file.get_as_text(true))
			if state == OK:
				return json.data
			else:
				var message = "State service > JSON Parse Error:{0} at line {1}, {2}".format([json.get_error_message(), json.get_error_line(), path])
				OS.alert(message)
		else:
			var message = "State service > File error(load):{0}, {1}".format([Helper.error_str[FileAccess.get_open_error()], path])
			OS.alert(message)

	return {}

func make_dir(path:String):
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

func make_interactive_dir():
	make_dir(get_interactive_path())
		
func remove_file(path:String):
	DirAccess.remove_absolute(path)

func remove_interactive(id:String):
	remove_file(get_interactive_file_path(id))

func find_all_interactives_array()->PackedStringArray:
	return find_all_files_array(get_interactive_path(), _cfg_extension)

func save_interactive_to_json_file(id:String, dict:Dictionary):
	save_dict_to_json_file(get_interactive_file_path(id), dict)
	
func find_all_interactives_dict()->Dictionary:
	return find_all_files_dict(get_interactive_path(), _cfg_extension)
	
func find_all_blocks_dict()->Dictionary:
	return find_all_files_dict(_blocks_dir_path, _scene_extension)

func load_dict_from_interactive(id:String)->Dictionary:
	return load_dict_from_json_file(get_interactive_file_path(id))
