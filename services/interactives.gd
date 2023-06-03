@tool
extends Node

class_name Interactives

var _logs:LoggotLogger = Services.logs
var _resources:Resources = Services.resource
var _names:PackedStringArray

const _asset_type = "interactives"


func _ready():
	assert(_logs)
	_logs.info("Interactives service > ready")
	update()
	
func update():
	_names = _resources.find_all_assets_cfg_names(_asset_type)
	
func get_list()->PackedStringArray:
	return _names

