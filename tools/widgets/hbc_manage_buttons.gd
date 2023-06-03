@tool
extends HBoxContainer

@export var create:bool = true
@export var delete:bool = true
@export var clone:bool = true

signal send_create()
signal send_delete()
signal send_clone()

func _ready():
	$TB_create.visible = create
	$TB_delete.visible = delete
	$TB_clone.visible = clone

func _on_tb_clone_pressed():
	emit_signal("send_clone")

func _on_tb_delete_pressed():
	emit_signal("send_delete")

func _on_tb_create_pressed():
	emit_signal("send_create")
