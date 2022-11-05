extends Node

class_name HelperService

enum {
	FORMAT_HOURS   = 0x2,
	FORMAT_MINUTES = 0x4,
	FORMAT_SECONDS = 0x8,
	FORMAT_DEFAULT = 0x2 | 0x4 | 0x8
}

const error_str = {
	OK: "No error.",
	FAILED: "Generic error.",
	ERR_UNAVAILABLE: "Unavailable error.",
	ERR_UNCONFIGURED: "Unconfigured error.",
	ERR_UNAUTHORIZED: "Unauthorized error.",
	ERR_PARAMETER_RANGE_ERROR: "Parameter range error.",
	ERR_OUT_OF_MEMORY: "Out of memory (OOM) error.",
	ERR_FILE_NOT_FOUND: "File: Not found error.",
	ERR_FILE_BAD_DRIVE: "File: Bad drive error.",
	ERR_FILE_BAD_PATH: "File: Bad path error.",
	ERR_FILE_NO_PERMISSION: "File: No permission error.",
	ERR_FILE_ALREADY_IN_USE: "File: Already in use error.",
	ERR_FILE_CANT_OPEN: "File: Can't open error.",
	ERR_FILE_CANT_WRITE: "File: Can't write error.",
	ERR_FILE_CANT_READ: "File: Can't read error.",
	ERR_FILE_UNRECOGNIZED: "File: Unrecognized error.",
	ERR_FILE_CORRUPT: "File: Corrupt error.",
	ERR_FILE_MISSING_DEPENDENCIES: "File: Missing dependencies error.",
	ERR_FILE_EOF: "File: End of file (EOF) error.",
	ERR_CANT_OPEN: "Can't open error.",
	ERR_CANT_CREATE: "Can't create error.",
	ERR_QUERY_FAILED: "Query failed error.",
	ERR_ALREADY_IN_USE: "Already in use error.",
	ERR_LOCKED: "Locked error.",
	ERR_TIMEOUT: "Timeout error.",
	ERR_CANT_CONNECT: "Can't connect error.",
	ERR_CANT_RESOLVE: "Can't resolve error.",
	ERR_CONNECTION_ERROR: "Connection error.",
	ERR_CANT_ACQUIRE_RESOURCE: "Can't acquire resource error.",
	ERR_CANT_FORK: "Can't fork process error.",
	ERR_INVALID_DATA: "Invalid data error.",
	ERR_INVALID_PARAMETER: "Invalid parameter error.",
	ERR_ALREADY_EXISTS: "Already exists error.",
	ERR_DOES_NOT_EXIST: "Does not exist error.",
	ERR_DATABASE_CANT_READ: "Database: Read error.",
	ERR_DATABASE_CANT_WRITE: "Database: Write error.",
	ERR_COMPILATION_FAILED: "Compilation failed error.",
	ERR_METHOD_NOT_FOUND: "Method not found error.",
	ERR_LINK_FAILED: "Linking failed error.",
	ERR_SCRIPT_FAILED: "Script failed error.",
	ERR_CYCLIC_LINK: "Cycling link (import cycle) error.",
	ERR_INVALID_DECLARATION: "Invalid declaration error.",
	ERR_DUPLICATE_SYMBOL: "Duplicate symbol error.",
	ERR_PARSE_ERROR: "Parse error.",
	ERR_BUSY: "Busy error.",
	ERR_SKIP: "Skip error.",
	ERR_HELP: "Help error.",
	ERR_BUG: "Bug error.",
	ERR_PRINTER_ON_FIRE: "Printer on fire error. (This is an easter egg, no engine methods return this error code.)"
} 

func _ready():
	print("Helper service started")
	randomize()

func format_timestamp_to_str(time, format = FORMAT_DEFAULT, digit_format = "%02d")->String:
	var digits = []

	if format & FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)

	if format & FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)

	if format & FORMAT_SECONDS:
		var seconds = digit_format % [int(ceil(time)) % 60]
		digits.append(seconds)

	var formatted = String()
	var colon = " : "

	for idx in digits.size():
		formatted += digits[idx]
		if idx != digits.size() - 1:
			formatted += colon
	return formatted

func _find_all_files_recursive(find_dir:String, extension:String, paths:Dictionary):
	var dir = DirAccess.open(find_dir)
	if dir:
		dir.list_dir_begin()
		while true:
			var next_item = dir.get_next().replace(".import", "")
			if next_item.is_empty():
				break
			if dir.current_is_dir() && next_item != "." && next_item != "..":
				_find_all_files_recursive(dir.get_current_dir() + "/" + next_item + "/", extension, paths)
			elif next_item.get_extension() == extension:
				if paths.has(next_item.get_basename()):
					print("Error. Duplicate resources " + next_item)
				paths[next_item.get_basename()] = dir.get_current_dir() + "/" + next_item
				print("Add path to resource - ", next_item.get_basename())
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path " + find_dir)
		
func find_all_files_dict(start_dir:String, extension:String)->Dictionary:
	var ret = {}
	_find_all_files_recursive(start_dir, extension, ret)
	return ret
	
func find_all_files_array(start_dir:String, extension:String)->Array:
	return find_all_files_dict(start_dir, extension).values()

func get_dict_from_encrypted_json(path:String, pwd:String)->Dictionary:
	if FileAccess.file_exists(path):
		#var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, pwd)
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var state = json.parse(file.get_as_text(true))
			if state == OK:
				print("Helper service > Loaded " + path)
				return json.data
			else:
				print("Helper service > JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line(), ", " + path)
				OS.alert("Helper service > JSON Parse Error: " + json.get_error_message() + " at line " + json.get_error_line() + ", " + path)
		else:
			print("Helper service > File error: " + error_str[FileAccess.get_open_error()] + ", " + path)
			OS.alert("Helper service > File error: " + error_str[FileAccess.get_open_error()] + ", " + path)
	else:
		print("Helper service > File not exists " + path)
	return {}
	
func set_dict_to_encrypted_json(dict:Dictionary, path:String, pwd:String):
	#var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, pwd)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var test = JSON.stringify(dict)
		file.store_line(JSON.stringify(dict))
	else:
		print("Helper service > File error: " + error_str[FileAccess.get_open_error()] + ", " + path)
		OS.alert("Helper service > File error: " + error_str[FileAccess.get_open_error()] + ", " + path)
		
