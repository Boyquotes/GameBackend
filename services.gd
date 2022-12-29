# Ленивая инициализация сервисов, реализация паттерна сервис локатор

extends Node

var _logger:Logger = null

func _ready():
	# Логер запускаем отдельно и первым для установки его инстанса
	_logger = load("res://addons/GameBackend/services/logger.gd").new()
	if _logger:
		add_child(_logger)
	# Проверяем, что установлена стартовая сплеш сцена
	var main_scene = ProjectSettings.get_setting("application/run/main_scene")
	var splash_scene = "res://addons/GameBackend/services/scenes/splash/splash.tscn"
	if main_scene != splash_scene:
		OS.alert("Текущая стартовая сцена {0}, а должна быть {1}".format([main_scene, splash_scene]))
		
func _get_singleton(service, path:String):
	if service == null:
		service = load(path).new()
		add_child(service)
	return service

var state = null :
	get:
		return _get_singleton(state, "res://addons/GameBackend/services/state.gd")
		
var logs:LoggotLogger = null :
	get:
		if logs == null:
			logs = _logger.get_logger()
			# пресет логера для отладки - собираем более широкую воронку
			if OS.is_debug_build():
				logs.attach_appender(LoggotAsyncAppender.new(LoggotFileAppender.new()))
				logs.attach_appender(LoggotAsyncAppender.new(LoggotConsoleAppender.new()))
				logs.set_level(LoggotConstants.Level.DEBUG)
			else:
				# пресет для релиза - берем только предупреждения и ошибки
				logs.attach_appender(LoggotAsyncAppender.new(LoggotFileAppender.new()))
				logs.set_level(LoggotConstants.Level.WARN)
		return logs
		
var resource = null :
	get:
		return _get_singleton(resource, "res://addons/GameBackend/services/resources.gd")
		
var scenes = null :
	get:
		return _get_singleton(scenes, "res://addons/GameBackend/services/scenes.gd")
		
var sounds = null :
	get:
		return _get_singleton(sounds, "res://addons/GameBackend/services/sound.gd")
