extends Node

@onready var logger = load("res://addons/GameBackend/services/logger.gd").new()

func _ready():
	if logger:
		add_child(logger)

var state = null :
	get:
		if state == null:
			state = load("res://addons/GameBackend/services/state.gd").new()
			state.log = log
			add_child(state)
		return state
	
var helper = null :
	get:
		if helper == null:
			helper = load("res://addons/GameBackend/services/helper.gd").new()
			add_child(helper)
		return helper
		
var log = null :
	get:
		if log == null:
			log = logger.get_logger("main_log")
			if OS.is_debug_build():
				log.attach_appender(LoggotAsyncAppender.new(LoggotFileAppender.new()))
				log.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))
				log.set_level(LoggotConstants.Level.DEBUG)
			else:
				log.attach_appender(LoggotAsyncAppender.new(LoggotFileAppender.new()))
				log.set_level(LoggotConstants.Level.WARN)
		return log
	
