extends Node

class_name Sounds

const num_players = 10
var players:Array[AudioStreamPlayer]
@onready var player_background = AudioStreamPlayer.new()
@onready var logs:LoggotLogger = Services.logs

func _ready():
	assert(logs)
	logs.info("Sounds service > started.")
	for num in num_players:
		var player = AudioStreamPlayer.new()
		add_child(player)
		players.append(player)
	add_child(player_background)
	
func _exit_tree():
	logs.info("Sounds service > exit.")

func play(sound_path:String)->bool:
	for player in players:
		if !player.playing:
			player.stream = load(sound_path)
			player.stream.set_loop(false)
			player.play()
			logs.info("Scenes service > Play sound " + sound_path)
			return true
	return false
		
func play_background(sound_path:String):
	player_background.stream = load(sound_path)
	player_background.stream.set_loop(true)
	player_background.play()
	logs.info("Scenes service > Play background sound " + sound_path)
