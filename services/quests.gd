extends Node

class_name Quests

@onready var _logs:LoggotLogger = Services.logs

# Called when the node enters the scene tree for the first time.
func _ready():
	# Проверяем, что сервисы живы.
	assert(_logs)
	_logs.info("Quests service > started.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
