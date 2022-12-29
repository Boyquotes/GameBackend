extends Node

class_name InitTemplate

@onready var logs:LoggotLogger = Services.logs

signal send_progress(value:float)
signal send_complite()


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(logs)
	logs.info("Init template > started.")
	emit_signal("send_progress", 100)
	emit_signal("send_complite")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _exit_tree():
	logs.info("Init template > exit.")
