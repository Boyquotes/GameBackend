# Глобальные константы и переменные
@tool
extends Node

class_name Globals

@onready var _logs:LoggotLogger = Services.logs

# Обновляем идентификатор интерактива который сейчас редактируем чтобы не выбрать в списке себя
var edited_id:String


func _ready():
	assert(_logs)
	_logs.info("Globals service > started.")

