# Виджет с добавляемыми блоками
@tool
extends VBoxContainer

const _blocks_name = "blocks"
var blocks_dict:Dictionary
# Список ранее добавленных блоков
var created_blocks:PackedStringArray

func _ready():
	blocks_dict = Resources.find_all_blocks_dict()

func _create_block(name:String)->Object:
	if name in created_blocks:
		get_tree().call_group("editor_interactive_state", "editor_interactive_state", "Blocks should not be repeated {0}".format([name]))
		OS.alert("Blocks should not be repeated {0}".format([name]))
		return null
	var add_block = load(blocks_dict[name]).instantiate()
	if add_block:
		add_child(add_block)
		created_blocks.append(name)
	else:
		OS.alert("Block {0} not find".format([name]))
	return add_block


func section_name()->String:
	return _blocks_name
	
func serialize()->Dictionary:
	var dict:Dictionary
	for child in get_children():
		dict[child.section_name()] = child.serialize()
	return dict
	
func deserialize(dict:Dictionary):
	created_blocks.clear()
	for block in dict:
		var child = _create_block(block)
		if child:
			child.deserialize(dict[block])

# Сигнал от списка на добавление блока. 
func _on_il_blocks_send_add_block(block):
	_create_block(block)
	
func clean():
	for child in get_children():
		child.queue_free()
