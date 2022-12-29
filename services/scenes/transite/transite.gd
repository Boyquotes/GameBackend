extends Control

signal send_faded()
signal send_raised()

func _ready():
	$TR_Background_tex.visible = false
	
func start_fade_animation():
	$AnimationPlayer.play("fade")
	
func load_complite():
	$TR_Background_tex.visible = false
	$AnimationPlayer.play("rise")
	
func set_progress(value:float):
	$TR_Background_tex/TPB_start_progress.value = value

func _on_animation_player_animation_finished(anim_name:String):
	match anim_name:
		"fade":
			emit_signal("send_faded")
			$TR_Background_tex.visible = true
		"rise":
			emit_signal("send_raised")
