extends Node

class_name Globals

@onready var _logs:LoggotLogger = Services.logs

var edited_id:String


func _ready():
	assert(_logs)
	_logs.info("Globals service > started.")

