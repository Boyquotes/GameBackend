extends HBoxContainer

var _hart_ps = preload("res://addons/GameBackend/scenes/tr_hart.tscn")

func _ready():
	pass
	
func on_group_hud(handler:HUD.EHandler, type:HUD.EType, value):
	if handler == HUD.EHandler.LIFE:
		match type:
			HUD.EType.ADD:
				if value as int > 0:
					for item in value:
						add_child(_hart_ps.instantiate())
			HUD.EType.REMOVE:
				if value as int > 0:
					for item in value:
						if get_child_count() > 0:
							remove_child(get_children().back())
