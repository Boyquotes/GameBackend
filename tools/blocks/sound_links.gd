# Блок соответствия звуков при взаимодействии интерактивов.
# Указываются идентификатор из существующих на диске кроме своего и абсолютный путь к фалу со звуком.
# При обработке столкновения будет проверен второй интерактив и если он есть в списке, то будет
# проигран звук.
@tool
extends MarginContainer

@onready var _fields = $VBC_main/VBC_dynamic_fields
@onready var res_field = preload("res://addons/GameBackend/tools/fields/hbc_id_file.tscn")
const _default_script = "res://addons/GameBackend/tools/blocks/scripts/sound_properties.gd"

const _block_name = "sound_links"
const _block_script_name = "script" 
var _block_handle_script:String:
	set(_value):
		_block_handle_script = _default_script if _value.is_empty() else _value
		$VBC_main/HBC_data_manage/L_script.text = _block_handle_script.get_file()


func _ready():
	_fields.res_dynamic = res_field

func _on_tb_minimize_pressed():
	_fields.visible = !$VBC_main/CR_title/TB_minimize.button_pressed
	
func section_name()->String:
	return _block_name
	
func serialize()->Dictionary:
	return {
		_block_script_name: _block_handle_script,
		_fields.section_name():_fields.serialize()
		}
	
func deserialize(dict:Dictionary):
	if dict.has(_block_script_name):
		_block_handle_script = dict[_block_script_name]
	_fields.deserialize(dict[_fields.section_name()])

func _on_tb_close_pressed():
	queue_free()

func _on_tb_add_field_pressed():
	_fields.add_child(res_field.instantiate())

func _on_tb_add_script_pressed():
	$FileDialog.visible = true

func _on_file_dialog_file_selected(path):
	_block_handle_script = path
