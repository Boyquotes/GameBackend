extends RefCounted

class_name BaseCommand

var _recipient = null

func _init(recipient:Object):
	_recipient = recipient

func execute():
	pass
	
func undo():
	pass

