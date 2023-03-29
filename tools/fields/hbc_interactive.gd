@tool
extends HBoxContainer

@onready var _resources:Resources = Services.resource

func _ready():
	$OB_id.clear()
	var id_list = _resources.find_all_interactives_array()
	for item in id_list:
		$OB_id.add_item(item)
	
func serialize()->Dictionary:
	return {
		$L_id.text.to_snake_case():$OB_id.get_item_text($OB_id.get_selected_id())
	}
	
func section_name()->String:
	return $L_id.text.to_snake_case()
	
func deserialize(dict:Dictionary):
	var tmp_id = $L_id.text.to_snake_case()
	if dict.has(tmp_id):
		var title = dict[tmp_id]
		for index in $OB_id.item_count:
			if $OB_id.get_item_text(index) == title:
				$OB_id.select(index)
				break
	
