# Панель с карточкой интерактива - это набор свойств игрового объекта который взаимодействует с игрой.
@tool
extends ScrollContainer

@onready var _globals:Globals = Services.globals

signal send_update()


func _ready():
	assert(_globals)

func show_interactive(id:String):
	$VBC_card.show_id(id)

func _on_vbc_card_send_update():
	emit_signal("send_update")
