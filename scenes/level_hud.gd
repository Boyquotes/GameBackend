extends MarginContainer

class_name HUD


enum EType{ADD, REMOVE}
enum EHandler{LIFE, HITPOINT}

func _ready():
	pass
	
func hud_event(handler:EHandler, type:EType, value):
	get_tree().call_group("HUD","on_group_hud", handler, type, value)

