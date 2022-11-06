extends Node

var state = null :
	get:
		if state == null:
			state = load("res://addons/GameBackend/services/state.gd").new()
			state.helper = helper
			add_child(state)
		return state
	
var helper = null :
	get:
		if helper == null:
			helper = load("res://addons/GameBackend/services/helper.gd").new()
			add_child(helper)
		return helper
	
