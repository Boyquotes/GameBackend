extends Node

class_name State

const CUR_STATES_PATH = "user://states/state.txt"
const STATES_ARCHIVE = "user://states/zip_archive"
const CUR_ZIP_PATH = "user://states/zip_archive/%s_state.zip"

var _user_data = {}
var _timer:Timer = null
var _is_data_changed = false
@onready var logs:LoggotLogger = Services.logs

var _guard : Mutex
var _semaphore : Semaphore
var _thread : Thread
var _exit_thread = false

@export var _pwd:String
@export var _save_timeout_sec = 30

func write_zip_file():
	var writer = ZIPPacker.new()
	var err = writer.open(CUR_ZIP_PATH % Time.get_datetime_string_from_system(true))
	if err != OK:
		return err
	writer.start_file("state.txt")
	writer.write_file(FileAccess.get_file_as_bytes(CUR_STATES_PATH));
	writer.close_file()
	writer.close()
	return OK

func _ready():
	assert(logs)
	logs.info("State service > started.")
	_timer = Timer.new()
	_timer.timeout.connect(_on_timer_timeout)
	_timer.wait_time = _save_timeout_sec
	add_child(_timer)
	if !DirAccess.dir_exists_absolute(STATES_ARCHIVE):
		DirAccess.make_dir_recursive_absolute(STATES_ARCHIVE)
	_load_data()
	_guard = Mutex.new()
	_semaphore = Semaphore.new()
	_thread = Thread.new()
	_thread.start(Callable(self,"_thread_process"))
	
func _exit_tree():
	logs.info("State service > Exit tree")
	save_data()
	_guard.lock()
	_exit_thread = true
	_guard.unlock()
	_semaphore.post()
	_thread.wait_to_finish()

func _on_timer_timeout():
	logs.debug("State service > Timer timeout")
	save_data()
	
func _get_dict_from_json_file(path:String, pwd:String)->Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, pwd) if !OS.is_debug_build() else FileAccess.open(path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var state = json.parse(file.get_as_text(true))
			if state == OK:
				logs.info("State service > Loaded " + path)
				return json.data
			else:
				var message = "State service > JSON Parse Error:{0} at line {1}, {2}".format([json.get_error_message(), json.get_error_line(), path])
				logs.error(message)
				OS.alert(message)
		else:
			var message = "State service > File error(load):{0}, {1}".format([Helper.error_str[FileAccess.get_open_error()], path])
			logs.error(message)
			OS.alert(message)
	else:
		logs.info("State service > File not exists " + path)
	return {}

func _load_data():
	logs.info("State service > Loading...")
	_user_data = _get_dict_from_json_file(CUR_STATES_PATH, _pwd)

func save_data():
	logs.debug("State service > Saving...")
	if _is_data_changed:
		_semaphore.post()
		_is_data_changed = false
		_timer.start()
	
func set_dict(key:String, dict:Dictionary):
	_guard.lock()
	_user_data[key] = dict
	_guard.unlock()
	_is_data_changed = true
	
func get_dict(key:String)->Dictionary:
	return _user_data[key] if _user_data.has(key) else {}
	
func _thread_process():
	while true:
		_semaphore.wait()

		_guard.lock()
		var should_exit = _exit_thread
		_guard.unlock()

		if should_exit:
			break

		if _user_data.is_empty():
			continue
		else:
			_guard.lock()
			var saved_data = _user_data.duplicate(true)
			_guard.unlock()
			var file = FileAccess.open_encrypted_with_pass(CUR_STATES_PATH, FileAccess.WRITE, _pwd) if !OS.is_debug_build() else FileAccess.open(CUR_STATES_PATH, FileAccess.WRITE)
			if file:
				file.store_line(JSON.stringify(saved_data))
			else:
				var message = "State service > File error(save):{0}, {1}".format([Helper.error_str[FileAccess.get_open_error()], CUR_STATES_PATH])
				logs.error(message)
				OS.alert(message)
