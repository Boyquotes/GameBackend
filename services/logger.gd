extends Node

signal stopped_and_flushed()

const FLUSH_RATE_SEC = 5

var _loggers = {}
var _last_flush_time = 0

func _ready():
	pass

func _process(delta):
	_last_flush_time += delta
	if _last_flush_time >= FLUSH_RATE_SEC:
		_last_flush_time = 0
		_flush()

func get_logger(name:String, appender : LoggotAppender = null) -> LoggotLogger :
	if _loggers.has(name):
		return _loggers[name]
	else:
		var logger = LoggotLogger.new(LoggotConstants.Level.DEBUG, name)
		if appender != null:
			logger.attach_appender(appender)
		_loggers[name] = logger
		return _loggers[name]

func _flush():
	for name in _loggers:
		_loggers[name].flush()

func stop_and_flush():
	for name in _loggers:
		_loggers[name].stop()
		_loggers[name].flush()
	emit_signal("stopped_and_flushed")

func _exit_tree():
	stop_and_flush()
