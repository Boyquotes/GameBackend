@tool
extends EditorPlugin

const _icon_GDPanel = preload("res://addons/GameBackend/icons/PNG/White/1x/gear.png")
const _packedscene_GDPanel = preload("res://addons/GameBackend/tools/GDPanel.tscn")

const _AUTOLOAD_NAME = "Services"

var _scene_GDPanel = null

func _enter_tree():
	add_autoload_singleton(_AUTOLOAD_NAME,"res://addons/GameBackend/services.gd" )
	_scene_GDPanel = _packedscene_GDPanel.instantiate()
	_scene_GDPanel.name = "GDPanel"
	get_editor_interface().get_editor_main_screen().add_child(_scene_GDPanel)
	_make_visible(false)

func _make_visible(visible):
	if _scene_GDPanel:
		_scene_GDPanel.visible = visible

func _exit_tree():
	remove_autoload_singleton(_AUTOLOAD_NAME)
	if _scene_GDPanel:
		_scene_GDPanel.queue_free()
		
func _get_plugin_name():
	return "Game designer panel"
	
func _has_main_screen() -> bool:
	return true
		
func _get_plugin_icon() -> Texture2D:
	return _icon_GDPanel
