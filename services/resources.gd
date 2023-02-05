extends Node

class_name Resources

var _queue_to_load:PackedStringArray

var _logs:LoggotLogger = Services.logs
@onready var _timer:Timer = null

const _timer_timeout = 0.5
var progress:Array[float]

const _interactives_dir_path = "user://gdpanel/interactives"
const _interactive_extension = "json"

signal send_resource_loaded(path:String, res:Resource)
signal send_resource_progress(progress:float)

func _ready():
	assert(_logs)
	_logs.info("Resource service > started")
	_timer = Timer.new()
	add_child(_timer)
	_timer.wait_time = _timer_timeout
	_timer.timeout.connect(_on_timer_timeout)
	
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

func get_interactives_path()->String:
	return _interactives_dir_path
	
func get_interactive_extension()->String:
	return _interactive_extension
	
func get_interactive_file_path(id:String)->String:
	return  "{0}/{1}.{2}".format([_interactives_dir_path, id, _interactive_extension])
