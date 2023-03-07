# Список блоков которые можно добавить в карточку интерактива.
# Блок в карточку можно добавить только один раз.
@tool
extends ItemList

@onready var _resources:Resources = Services.resource

signal send_add_block(block:String)


func _ready():
	clear()
	var blocks = _resources.find_all_blocks_dict().keys()
	for name in blocks:
		add_item(name)

func _on_tb_close_pressed():
	visible = false

func _on_tb_add_block_pressed():
	visible = true

func _on_item_activated(index):
	var block = get_item_text(index)
	emit_signal("send_add_block", block)
