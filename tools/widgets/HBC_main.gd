@tool
extends HBoxContainer


func _on_vbc_left_panel_send_select_interactive_id(id):
	$SC_right_panel.show_interactive(id)


func _on_sc_right_panel_send_update():
	$VBC_left_panel.update()
