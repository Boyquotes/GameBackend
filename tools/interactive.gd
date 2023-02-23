# Скрипт реализует взаимодействие между интерактивными объектами, управляет временем жизни родителя.
# Реализует состояния объекта.

extends Node

class_name Interactive

enum {
	HITPOINT_END
	}

var _logs:LoggotLogger = Services.logs
var _id:String

# Названия секций в конфигурации
const _block_base = "base_properties"
const _blocks = "blocks"
const _linked_script = "script"
# Имя скрипта интерактива в сцене по умолчанию
const _name_interactive = "interactive"

# Блоки интерактива прочитанные из конфигурации
var interactives:Dictionary

# Сигнал сцене содержащей интерактив с событием
signal send_interactive_event(type, value)

# Фабричный метод для игтерактива
static func create(id:String)->Interactive:
	var interactive = Interactive.new()
	if interactive._inited(id):
		return interactive
	else:
		return null

# Инициализация интерактива
func _inited(id:String)->bool:
	assert(_logs)
	var dict = Resources.load_dict_from_interactive(id)
	if !dict.is_empty():
		_id = id
		# Добавляем скрипту имя под которым оно будет чиститься у родительской сцены
		name = _name_interactive
		return _pars_interactive_dict(dict)
	else:
		_logs.error("Interactive {0} was not loaded.".format([id]))
		return false

# Произошло столкновение родительской сцены с другой
func interact(body:Node):
	# Проверяем есть ли у второго узла интерактив
	if body.has_node(_name_interactive):
		var interactive_opposite = body.get_node(_name_interactive) as Interactive
		if interactive_opposite:
			# В свои блоки передаём интерактив второй сцены с которой произойдёт обработка данных
			for block_name in interactives:
				interactives[block_name].interact(interactive_opposite)

# Парсим словарь блока
func _pars_block_dict(dict:Dictionary, block_name:String)->bool:
	# Ищем у блока ассоциированный скрипт обрабатывающий его данные
	if dict.has(_linked_script):
		var script_path = dict[_linked_script] as String
		if FileAccess.file_exists(script_path):
			var script = load(script_path).new() as BaseBlock
			if script && script.pars_dict(dict):
				# Добавляем ссылку на новый блок в словарь интерактива чтобы не искать дочерний узел
				interactives[block_name] = script
				# Для блока добавляем его имя так как оно будет нужно для поиска в словаре второй сцены
				script.name = block_name
				# Добавляем имя интерактива в блок чтоб потом не спрашивать у родителя
				script._id = _id
				add_child(script)
			else:
				_logs.error("Interactive {0},block {1}, section {2} was not parsed.".format([_id, block_name, _linked_script]))
				return false
		else:
			_logs.error("Interactive {0}, file {1} not exist .".format([_id, script_path]))
			return false
	else:
		_logs.error("Interactive {0} has not section {1}.".format([_id, _linked_script]))
		return false
	return true
	
# Парсим словарь интерактива
func _pars_interactive_dict(dict:Dictionary)->bool:
	# У каждого интерактива должен быть блок с обязательной информацией(базовый)
	if dict.has(_block_base):
		var base = dict[_block_base] as Dictionary
		if _pars_block_dict(base, _block_base):
			# Добавляем опциональные блоки из соответствующей секции конфигурации
			if dict.has(_blocks):
				var blocks = dict[_blocks] as Dictionary
				for block_name in blocks:
					if !_pars_block_dict(blocks[block_name], block_name):
						return false
		else:
			return false
	else:
		_logs.error("Interactive {0} has not block {1}.".format([_id, _block_base]))
		return false
	return true

# Сообщение от блока
func interact_handler(type, value):
	match type:
		HITPOINT_END:
			emit_signal("send_interactive_event", type, value)
			

