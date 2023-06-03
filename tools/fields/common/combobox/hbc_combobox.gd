@tool
extends HBoxContainer

@export var _title:String
@export var _fill_service:String
@export var _fill_method:String
var _list:Array
var _filter:String
const _none = "None"

func _ready():
	clear()
	update()
	if not _title.is_empty():
		$L_title.text = _title
		$L_title.visible = true
	else:
		$L_title.visible = false
		
func update(list:PackedStringArray = []):
	_list.clear()
	_list.append(_none)
	if not list.is_empty():
		_list.append_array(list)
	else:
		var node = Services.get_node(_fill_service) as Node
		if node && node.has_method(_fill_method):
			_list.append_array(node.call(_fill_method))

	filtering()
			
func filtering():
	$OB_list.clear()
	if not _filter.is_empty():
		for item in _list:
			if _filter in item:
				$OB_list.add_item(item)
	else:
		for item in _list:
			$OB_list.add_item(item)
	
func serialize()->Dictionary:
	return {
		_title.to_snake_case():$OB_list.get_item_text($OB_list.get_selected_id())
	}
	
func section_name()->String:
	return _title.to_snake_case()
	
func deserialize(dict:Dictionary):
	$OB_list.select(0)
	var key = $L_title.text.to_snake_case()
	var value = dict.get(key, 0)
	var index = _list.find(value)
	if index > -1:
		$OB_list.select(index)

func _on_le_filter_text_submitted(new_text):
	_filter = new_text
	filtering()

func get_selected()->String:
	return $OB_list.text if $OB_list.text != _none else ""

func set_select(index:int):
	$OB_list.select(index)

func clear():
	$OB_list.clear()

func _on_ob_list_item_selected(index):
	pass # Replace with function body.
