@tool
extends Node

class_name BaseAssetsService

var _logs:LoggotLogger = Services.logs
var _resources:Resources = Services.resource
var _names:PackedStringArray
var _asset_type = "Default"


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(_logs)
	assert(_resources)
	_logs.info("{0} service > ready".format([_asset_type]))
	update()
	
func _exit_tree():
	_logs.info("{0} service > exit".format([_asset_type]))

func get_assets_type()->String:
	return _asset_type
	
func update():
	_names = _resources.find_all_assets_cfg_names(_asset_type)
	
func get_list()->PackedStringArray:
	return _names

func get_filtered_list(find_text:String)->PackedStringArray:
	var test = _resources.find_text_in_assets(_asset_type, find_text)
	return _resources.find_text_in_assets(_asset_type, find_text)
	
func rename(old_name:String, new_name:String):
	_resources.rename_asset(_asset_type, old_name, new_name)
	update()
	
func clone(old_name:String):
	_resources.clone_asset(_asset_type, old_name)
	update()
	
func get_asset(asset_name:String)->Dictionary:
	return _resources.get_asset_cfg_dict(_asset_type, asset_name)
	
func save(asset_name:String, dict:Dictionary):
	_resources.save_asset_cfg(_asset_type, asset_name, dict)
	
func remove(asset_name:String):
	_resources.remove_asset(_asset_type, asset_name)
	update()

func add(dict:Dictionary = {}):
	_resources.create_asset(_asset_type, dict)
	update()
	
