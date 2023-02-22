extends Node

class_name BaseBlock

var _logs:LoggotLogger = Services.logs

const _interact_handler_method = "interact_handler"
var _id:String


func pars_dict(dict:Dictionary)->bool:
	return false
	
func interact(inter:Interactive):
	pass
	
func _error_field_notify(field_name:String):
	_logs.error("In block {0} not exist field {1}.".format([name, field_name]))
	OS.alert("In block {0} not exist field {1}.".format([name, field_name]))
	
func _error_section_notify(section_name:String):
	_logs.error("Block {0} have not section {1}.".format([name, section_name]))
	OS.alert("Block {0} have not section {1}.".format([name, section_name]))
	
func _error_block_notify(method_name:String):
	_logs.error("Block {0} have not parent method {1}.".format([name, method_name]))
	OS.alert("Block {0} have not parent method {1}.".format([name, method_name]))
