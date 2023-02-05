@tool
extends VBoxContainer

const _default_button_text = "Default_ID"
const _panel_name = "left_list_panel"
@onready var _list = $SC_list/VBC_list
@onready var _button_group = ButtonGroup.new()
const _json_ext = "json"
const _interactives_dir_path = "user://gdpanel/interactives"

signal send_select_interactive_id(id:String)


func _ready():
	if !DirAccess.dir_exists_absolute(_interactives_dir_path):
		DirAccess.make_dir_recursive_absolute(_interactives_dir_path)
	
	var interactive_list = Helper.find_all_files_array(_interactives_dir_path, _json_ext)
	for name in interactive_list:
		_list.add_child(create_button(name))
	
	
func create_button(name:String = "")->Button:
	var button = Button.new()
	button.toggle_mode = true
	button.button_group = _button_group
	button.text = _default_button_text if name.is_empty() else name
	button.pressed.connect(_on_interactive_button_click)
	return button
	
func change_selected_id(id:String):
	_button_group.get_pressed_button().text = id
	
func _on_interactive_button_click():
	if _button_group:
		emit_signal("send_select_interactive_id", _button_group.get_pressed_button().text)
		

func _on_tb_create_pressed():
	for button in _list.get_children():
		if button.text == _default_button_text:
			OS.alert("Interactive with name {0} already exists!".format([_default_button_text]))
			return
			
	_list.add_child(create_button())
	
func get_panel_name()->String:
	return _panel_name
	
