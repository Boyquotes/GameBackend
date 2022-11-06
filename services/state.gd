extends Node

var _user_data = {}
var _path = "user://states"
var _name = "state.dat"
var _path_to_state = _path + "/" + _name
var _zip_extend = ".gdzip"
var _timer = null
var _is_data_changed = true

var helper = null

@export var _pwd = ""
@export var _save_timeout_sec = 30

func _ready():
	#Services.helper
	print("State service started.")
	_timer = Timer.new()
	_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	add_child(_timer)
	_timer.wait_time = _save_timeout_sec
	if not DirAccess.dir_exists_absolute(_path):
		DirAccess.make_dir_absolute(_path)
	_load_data()
	
func _exit_tree():
	print("State service > Exit tree:  save state " + _path_to_state)
	save_data()

func _on_timer_timeout():
	print("State service > Timer timeout: - save state " + _path_to_state)
	save_data()
	
func _load_data():
	if helper:
		print("State service > Loading...: " + _path_to_state)
		_user_data = helper.get_dict_from_encrypted_json(_path_to_state, _pwd)

func save_data():
	if _is_data_changed == false:
		return
	if helper:
		helper.set_dict_to_encrypted_json(_user_data, _path_to_state, _pwd)
		print("State service >  Save state: ", _path_to_state)
		_is_data_changed = false
		_timer.start()
	
func set_dict(key:String, dict:Dictionary):
	_user_data[key] = dict
	
func get_dict(key:String)->Dictionary:
	return _user_data[key] if _user_data.has(key) else {}
