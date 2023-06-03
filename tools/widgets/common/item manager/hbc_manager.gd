@tool
extends HBoxContainer

@export var create:bool
@export var delete:bool
@export var save:bool
@export var clone:bool

signal send_create()
signal send_delete()
signal send_save()
signal send_clone()

func _ready():
	$TB_create.visible = create
	$TB_delete.visible = delete
	$TB_save.visible = save
	$TB_clone.visible = clone

func _on_tb_create_pressed():
	emit_signal("send_create")

func _on_tb_delete_pressed():
	emit_signal("send_delete")

func _on_tb_save_pressed():
	emit_signal("send_save")

func _on_tb_clone_pressed():
	emit_signal("send_clone")

