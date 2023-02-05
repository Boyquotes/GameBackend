# Сервис предоставляет услуги по передаче команд от отправителя к получателю.
# Принцип работы: 
# 1. Отправитель выбирает тип команды. Если нужной команды нет в списке, отправитель её создаёт и регистрирует.
# 2. Отправитель запрашивает объект команды из очереди и устанавливает данные для получателя(переменные, вызов методов).
# 3. Отправитель может сразу указать получателя/получателей в объекте. Если получатель не указан, сервис 
#    передаёт команду текущему активному получателю зарегистрированному в сервисе. Если указан получатель и выбран
#    текущий активный получатель/получатели - команда вызывается для них всех по очереди.
# 4. Для команд запрошенных отправителем формируется пул объектов команд, пул закольцован и имеет указатель текущей команды в пуле.
# 5. Получатель должен иметь вызываемые методы и уметь обрабатывать переданные данные.
# 6. Создавать новый тип команды необходимо наследуясь от базового типа команды.
# 7. Перед выполнением команды однократно проверяется наличие у получателя указанного метода
# 8. Базовый класс команды содержит поля:
#    - временную отметку в миллисекундах
#    - метод execute выполняющий вызод метода получателя и передачу ему данных
#    - метод undo выполняющий вызов метода получателя с данными для отката команды
#    - метод serialize выполняющий сериализацию команды (для хранения на диске или передачи по сети)4

extends Node

class_name CommandService

var _commands = []
var _current_index = 0
var _end_index = 0
const _max_commands = 50
enum {NEXT, PREV, ADD}
var state = ADD

func _ready():
	print("Command service start")
	# устанавливаем фиксированный размер массива 
	_commands.resize(_max_commands)
	
func _exit_tree():
	print("Command service stop")

func add(command):
	_commands[_current_index] = command
	command.execute()
	set_next_index()
	_end_index = _current_index
	state = ADD

func next():
	# если указатель указывает(после PREV) в пустой элемент или в конец - переходим на следующий
	if state == PREV && (_end_index == _current_index || _commands[_current_index] == null):
		set_next_index()
	if _end_index != _current_index && _commands[_current_index] != null:
		_commands[_current_index].execute()
		set_next_index()
		state = NEXT

func prev():
	# если зашли после добавления или после NEXT указывающий на конец - переходим на один назад
	if (state == NEXT || state == ADD) && (_end_index == _current_index || _commands[_current_index] == null):
		set_prev_index()
	if _end_index != _current_index && _commands[_current_index] != null:
		_commands[_current_index].undo()
		set_prev_index()
		state = PREV

func set_next_index():
	_current_index += 1
	if _current_index == _max_commands:
		_current_index = 0
		
func set_prev_index():
	_current_index -= 1
	if _current_index < 0:
		_current_index = _max_commands - 1
