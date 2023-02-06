@tool
extends Node

var unique_effects:Dictionary
var effects_cash:Dictionary
var effects_path:Dictionary

func set_resources_path(path:String, format:String):
	print("Effect manager. Set resources path - ", path, ", format - ", format)
	effects_path.clear()
	Helper_mgr.find_all_files_in_resources(path, format, effects_path)

func _ready():
	print("Effect manager started")
	#Helper_mgr.find_all_files_in_resources("Managers/Effects/", "tscn", effects_path)
	
func set_effect(effect_name:String, effect_parent:Object, settings:Dictionary):
	if effect_parent == null || !effects_path.has(effect_name):
		print("Effect error. effect - ", effect_name, ", parent - ", effect_parent)
		return null
	if !effects_cash.has(effect_name):
		var effect = load(effects_path[effect_name])
		if effect == null:
			print("Load effect error. effect - ", effect_name, ", path - ", effects_path[effect_name])
			return null
		effects_cash[effect_name] = effect
	var new_effect = effects_cash[effect_name].instantiate()
	new_effect.settings = settings
	effect_parent.add_child(new_effect)
	print("Create effect - ", effect_name, ", parent - ", effect_parent)
	return new_effect
	
func set_unique_effect(effect_name:String, effect_parent:Object, settings:Dictionary):
	if unique_effects.has(effect_name) && unique_effects[effect_name]:
		var old_parent = unique_effects[effect_name].get_parent()
		old_parent.remove_child(unique_effects[effect_name])
		effect_parent.add_child(unique_effects[effect_name])
		print("Unique effect - ", effect_name, ", move to parent - ", effect_parent)
		return unique_effects[effect_name]
	else:
		# возможно эффект завершился и удалился
		unique_effects.erase(effect_name)
		var effect = set_effect(effect_name, effect_parent, settings)
		if effect:
			unique_effects[effect_name] = effect
		print("Create unique effect - ", effect_name, ", parent - ", effect_parent)
		return effect
		

func clear():
	print("Clear effects")
	unique_effects.clear()
	effects_cash.clear()
