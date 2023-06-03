@tool
extends VBoxContainer

@export var fill_service:String
@export var fill_method:String
@export var filter_method:String
@export var editable:bool

var _last_selected_index = -1
var _list:Array
var _filter:String
const _item_heigth = 35

signal send_change_item(old_name:String, new_name:String)
signal send_select(item_name:String)
signal send_filtering()

func _ready():
	clear()
	update()
	
func update(list:PackedStringArray = []):
	_list.clear()
	if not list.is_empty():
		_list = list
	else:
		# Чтобы сервис был обнаружен
		var node = Services.get_node(fill_service) as Node
		if node && node.has_method(fill_method):
			_list = node.call(fill_method)
	filtering()

func filtering():
	emit_signal("send_filtering")
	$IL.clear()
	if not _filter.is_empty():
		if not filter_method.is_empty() && not fill_service.is_empty():
			var node = Services.get_node(fill_service) as Node
			if node && node.has_method(filter_method):
				var list = node.call(filter_method, _filter)
				for item in list:
					$IL.add_item(item)
		else:
			for item in _list:
				if _filter in item:
					$IL.add_item(item)
	else:
		for item in _list:
			$IL.add_item(item)

func _on_p_edit_send_new_text(_text):
	if _last_selected_index > -1:
		emit_signal("send_change_item", $IL.get_item_text(_last_selected_index), _text)
		_list.erase($IL.get_item_text(_last_selected_index))
		_list.append(_text)
		$IL.set_item_text(_last_selected_index, _text)
		_last_selected_index = -1

func _on_il_item_clicked(index, at_position, mouse_button_index):
	if editable && MOUSE_BUTTON_RIGHT == mouse_button_index:
		$IL/P_edit.visible = true
		$IL/P_edit.position = Vector2i(0, at_position.y)
		$IL/P_edit.size = Vector2i(size.x, $IL/P_edit.size.y)
		$IL/P_edit.set_text($IL.get_item_text(index))
		_last_selected_index = index
	if MOUSE_BUTTON_LEFT == mouse_button_index:
		emit_signal("send_select", $IL.get_item_text(index))

func _on_le_filter_text_submitted(new_text):
	_filter = new_text
	filtering()

func get_selected()->String:
	for index in $IL.get_selected_items():
		return $IL.get_item_text(index)
	return ""

func clear():
	$IL.clear()
