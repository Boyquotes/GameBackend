# Скрипт реализует взаимодействие между интерактивными объектами, управляет временем жизни родителя.
# Реализует состояния объекта.

extends Node

class_name Interactive

enum {
	HITPOINT_END
	}

var _logs:LoggotLogger = Services.logs
var _id:String

const _block_base = "base_properties"
const _blocks = "blocks"
const _linked_script = "script"
const _name_interactive = "interactive"

var interactives:Dictionary

signal send_interactive_event(id:String, type, value)

static func create(id:String)->Interactive:
	var interactive = Interactive.new()
	if interactive._inited(id):
		return interactive
	else:
		return null

func _inited(id:String)->bool:
	assert(_logs)
	var dict = Resources.load_dict_from_interactive(id)
	if !dict.is_empty():
		_id = id
		name = _name_interactive
		return _pars_interactive_dict(dict)
	else:
		_logs.error("Interactive {0} was not loaded.".format([id]))
		OS.alert("Interactive {0} was not loaded.".format([id]))
		return false

func interact(body:Node):
	var interactive_opposite = body.get_node(_name_interactive) as Interactive
	if interactive_opposite:
		for block_name in interactives:
			interactives[block_name].interact(interactive_opposite)
#			if interactive_opposite.interactives.has(block_name):
#				interactives[block_name].interact(interactive_opposite.interactives[block_name])

func _pars_block_dict(dict:Dictionary, block_name:String)->bool:
	if dict.has(_linked_script):
		var script_path = dict[_linked_script] as String
		if FileAccess.file_exists(script_path):
			var script = load(script_path).new() as BaseBlock
			if script && script.pars_dict(dict):
				interactives[block_name] = script
				script.name = block_name
				script._id = _id
				add_child(script)
			else:
				_logs.error("Interactive {0},block {1}, section {2} was not parsed.".format([_id, block_name, _linked_script]))
				OS.alert("Interactive {0},block {1}, section {2} was not parsed.".format([_id, block_name, _linked_script]))
				return false
		else:
			_logs.error("Interactive {0}, file {1} not exist .".format([_id, script_path]))
			OS.alert("Interactive {0}, file {1} not exist .".format([_id, script_path]))
			return false
	else:
		_logs.error("Interactive {0} has not section {1}.".format([_id, _linked_script]))
		OS.alert("Interactive {0} has not section {1}.".format([_id, _linked_script]))
		return false
	return true
	
func _pars_interactive_dict(dict:Dictionary)->bool:
	if dict.has(_block_base):
		var base = dict[_block_base] as Dictionary
		if _pars_block_dict(base, _block_base):
			if dict.has(_blocks):
				var blocks = dict[_blocks] as Dictionary
				for block_name in blocks:
					if !_pars_block_dict(blocks[block_name], block_name):
						return false
		else:
			return false
	else:
		_logs.error("Interactive {0} has not block {1}.".format([_id, _block_base]))
		OS.alert("Interactive {0} has not block {1}.".format([_id, _block_base]))
		return false
	return true

func interact_handler(type, value):
	match type:
		HITPOINT_END:
			emit_signal("send_interactive_event",_id, type, value)
			

