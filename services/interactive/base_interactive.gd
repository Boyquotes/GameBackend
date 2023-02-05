# Скрипт реализует взаимодействие между интерактивными объектами, управляет временем жизни родителя.
# Реализует состояния объекта.

extends Node

class_name BaseInteractive

@onready var _interactives:Interactives = Services.interactives
@onready var _sounds:Sounds = Services.sounds

var damage = 1
var hitpoints = 1:
	set(value):
		if value <= 0:
			# TODO - тут нужно выбирать поведение указанное в конфигурации 
			_interactives.interactive_destroyed_with_parent(get_parent())
		else:
			hitpoints = value
var type = "BASE_TYPE"
var sound:String
	
func play_sound():
	if !sound.is_empty():
		_sounds.play(sound)

# Вероятно удален родитель, удалить запись об интерактиве.
func _exit_tree():
	remove_record()
		
func remove_record():
	if hitpoints > 0:
		_interactives.remove(get_parent())
