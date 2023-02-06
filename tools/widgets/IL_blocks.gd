# Список блоков которые можно добавить в карточку интерактива.
# Блок в карточку можно добавить только один раз.
@tool
extends ItemList

const _ext = "tscn"
const _dir_path = "res://addons/GameBackend/tools/blocks"

@onready var blocks_dict = Helper.find_all_files_dict(_dir_path, _ext)

signal send_add_block(block:String)


func _ready():
	clear()
	var blocks = blocks_dict.keys()
	for name in blocks:
		add_item(name)

func _on_tb_close_pressed():
	visible = false

func _on_tb_add_block_pressed():
	visible = true

func _on_item_activated(index):
	var block = get_item_text(index)
	emit_signal("send_add_block", block)
