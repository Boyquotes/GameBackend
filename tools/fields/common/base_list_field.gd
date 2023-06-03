@tool
extends VBoxContainer

class_name BaseListField

@export var fill_service:String
@export var fill_method:String
@export var filter_method:String

var _list:Array
var _filter:String

var _list_node:Node = null

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
	
func clear():
	if _list_node != null && _list_node.has_method("clear"):
		_list_node.clear()
		
func filtering():
	emit_signal("send_filtering")
	clear()
	if not _filter.is_empty():
		if not filter_method.is_empty() && not fill_service.is_empty():
			var node = Services.get_node(fill_service) as Node
			if node && node.has_method(filter_method):
				var list = node.call(filter_method, _filter)
				if _list_node != null && _list_node.has_method("add_item"):
					for item in list:
						_list_node.add_item(item)
		else:
			if _list_node != null && _list_node.has_method("add_item"):
				for item in _list:
					if _filter in item:
						_list_node.add_item(item)
	else:
		if _list_node != null && _list_node.has_method("add_item"):
			for item in _list:
				_list_node.add_item(item)
	
func on_filter_text_submitted(new_text):
	_filter = new_text
	filtering()
	
func get_selected()->String:
	return ""
