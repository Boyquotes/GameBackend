@tool
extends VBoxContainer

const _ext = "tscn"
const _dir_path = "res://addons/GameBackend/tools/blocks"

@onready var blocks_dict = Helper.find_all_files_dict(_dir_path, _ext)

const _blocks_name = "blocks"

func _create_block(name:String)->Object:
	var add_block = load(blocks_dict[name]).instantiate()
	if add_block:
		add_child(add_block)
	else:
		OS.alert(tr("anc_error_block_no_find"))
	return add_block

func section_name()->String:
	return _blocks_name
	
func serialize()->Dictionary:
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	return dict
	
func deserialize(dict:Dictionary):
	for block in dict:
		var child = _create_block(block)
		if child:
			child.deserialize(dict[block])

func _on_il_blocks_send_add_block(block):
	_create_block(block)
	
func clean():
	for child in get_children():
		child.queue_free()
