@tool
extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_vbc_left_panel_send_select_interactive_id(id):
	$SC_right_panel.show_interactive(id)


func _on_sc_right_panel_send_change_id(id):
	$VBC_left_panel.change_selected_id(id)
