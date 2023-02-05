extends BaseCommand

class_name MoveCommand

var _offset:Vector2

func _init(recipient:Object,offset:Vector2,recipient):
	_offset = offset

func execute():
	assert(_recipient.has_method("move"))
	_recipient.move(_offset)
	
func undo():
	assert(_recipient.has_method("move"))
	_recipient.move(-_offset)

