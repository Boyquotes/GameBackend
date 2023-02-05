@tool
extends ScrollContainer

@onready var _globals:Globals = Services.globals

signal send_change_id(id:String)


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(_globals)

func show_interactive(id:String):
	_globals.edited_id = id
	$VBC_card.show_id(id)


func _on_vbc_card_send_change_id(id):
	# В глобальные переменные устанавливаем текущий редактируемый id.
	# В редакторе бывает необходимо не применять настройки к редактируемому объекту(напр. ссылки на звук)
	_globals.edited_id = id
	emit_signal("send_change_id", id)


