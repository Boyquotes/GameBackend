@tool
extends Node

class_name Interactives

@onready var _logs:LoggotLogger = Services.logs
var _interactives:Dictionary
var _count = 0;


func _ready():
	# Проверяем, что сервисы живы.
	assert(_logs)
	_logs.info("Interactives service > started.")

func create(parent:Node, type:String)->bool:
	# найти в конфиге указанный тип
	var interactive = BaseInteractive.new()
	# TODO - init the interactive from a json
	interactive.type = type
	# ---------------------------------------
	if "ONE_PUNCH_RECT" == type:
		interactive.damage = 1
		interactive.hitpoints = 1
		interactive.sound = "res://addons/GameBackend/sounds/impact/impactMining_000.ogg"
	if "BALL" == type:
		interactive.damage = 1
		interactive.hitpoints = 1000
	# ---------------------------------------
	parent.add_child(interactive)
	_interactives[parent] = interactive
	return true

# Узлы между которыми произошло взаимодействие, они могут не содержать интерактива.
func interact(parent1:Node, parent2:Node)->bool:
	if _interactives.has_all([parent1, parent2]):
		var interactive1 = _interactives[parent1]
		var interactive2 = _interactives[parent2]
		interactive1.hitpoints -= interactive2.damage
		interactive2.hitpoints -= interactive1.damage
		interactive1.play_sound()
		interactive2.play_sound()
	else:
		return false
	return true
	
func interactive_destroyed_with_parent(parent:Node):
	remove(parent)
	parent.queue_free()
	
func remove(parent:Node):
	_interactives.erase(parent)
