# Ленивая инициализация сервисов, реализация паттерна сервис локатор
# ВАЖНО! Сервисы, к которым нужно обратиться - необходимо инициализировать ДО создания узла(в родителе)!
@tool
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
		var serv_name = path.get_file().trim_suffix(".gd")
		service.name = serv_name
		add_child(service)
	return service

var state = null :
	get:
		if !state:
			state = _get_singleton(state, "res://addons/GameBackend/services/state.gd")
		return state
		
var logs:LoggotLogger = null :
	get:
		if !logs:
			if _logger == null:
				_ready()
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
		if !resource:
			resource = _get_singleton(resource, "res://addons/GameBackend/services/resources.gd")
		return resource
		
var scenes = null :
	get:
		if !scenes:
			scenes = _get_singleton(scenes, "res://addons/GameBackend/services/scenes.gd")
		return scenes
		
var sounds = null :
	get:
		if !sounds:
			sounds = _get_singleton(sounds, "res://addons/GameBackend/services/sound.gd")
		return sounds
		
var quests = null :
	get:
		if !quests:
			quests = _get_singleton(quests, "res://addons/GameBackend/services/quests.gd")
		return quests
		
var globals = null :
	get:
		if !globals:
			globals = _get_singleton(globals, "res://addons/GameBackend/services/globals.gd")
		return globals
		
var locations = null :
	get:
		if !locations:
			locations = _get_singleton(locations, "res://addons/GameBackend/services/locations.gd")
		return locations
		
var items = null :
	get:
		if !items:
			items = _get_singleton(items, "res://addons/GameBackend/services/items.gd")
		return items
		
var collections = null :
	get:
		if !collections:
			collections = _get_singleton(collections, "res://addons/GameBackend/services/collections.gd")
		return collections
		
var interactives = null :
	get:
		if !interactives:
			interactives = _get_singleton(interactives, "res://addons/GameBackend/services/interactives.gd" )
		return interactives
		
