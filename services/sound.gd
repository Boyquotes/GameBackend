@tool
extends Node

class_name Sounds

const _num_players = 10
var _players:Array[AudioStreamPlayer]
@onready var _player_background = AudioStreamPlayer.new()
@onready var _logs:LoggotLogger = Services.logs

func _ready():
	assert(_logs)
	_logs.info("Sounds service > started.")
	for num in _num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
	add_child(_player_background)
	
func _exit_tree():
	_logs.info("Sounds service > exit.")

func play(sound_path:String)->bool:
	for player in _players:
		if !player.playing:
			player.stream = load(sound_path)
			player.stream.set_loop(false)
			player.play()
			_logs.info("Scenes service > Play sound " + sound_path)
			return true
	return false
		
func play_background(sound_path:String):
	_player_background.stream = load(sound_path)
	_player_background.stream.set_loop(true)
	_player_background.play()
	_logs.info("Scenes service > Play background sound " + sound_path)
