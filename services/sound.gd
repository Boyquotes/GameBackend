extends Node

class_name Sounds

const num_players = 10
var players:Dictionary
@onready var player_background = AudioStreamPlayer.new()
@onready var logs:LoggotLogger = Services.logs

func _ready():
	assert(logs)
	logs.info("Sounds service > started.")
	for num in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		players[player] = null
		player.finished.connect(_on_stream_finished)
	add_child(player_background)
	
func _exit_tree():
	logs.info("Sounds service > exit.")
		
func _on_stream_finished(player):
	players[player] = null
	
func play(sound_path:String)->bool:
	if !players.values().has(sound_path):
		for player in players.keys():
			if players[player] == null:
				player.stream = load(sound_path)
				player.stream.set_loop(false)
				players[player] = sound_path
				player.play()
				logs.info("Scenes service > Play sound " + sound_path)
				return true
	return false
		
func play_background(sound_path:String):
	player_background.stream = load(sound_path)
	player_background.stream.set_loop(true)
	player_background.play()
	logs.info("Scenes service > Play background sound " + sound_path)
