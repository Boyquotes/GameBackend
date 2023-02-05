extends BaseCommand

class_name CreateCommand

var _point:Vector2
var _object_type:int

func _init(recipient:Object,point:Vector2,object_type:int,recipient):
	_point = point
	_object_type = object_type

func execute():
	assert(_recipient.has_method("create"))
	_recipient.create(_point, _object_type)
	
func undo():
	assert(_recipient.has_method("delete"))
	_recipient.delete(_point, _object_type)
