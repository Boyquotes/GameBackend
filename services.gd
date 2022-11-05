extends Node

var state:StateService = null :
	get:
		if state == null:
			state = StateService.new()
			state.helper = helper
			add_child(state)
		return state
	
var helper:HelperService = null :
	get:
		if helper == null:
			helper = HelperService.new()
			add_child(helper)
		return helper
	
