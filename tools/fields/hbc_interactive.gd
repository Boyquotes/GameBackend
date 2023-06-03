@tool
extends HBoxContainer

var _interactives:Interactives = Services.interactives
const _none = "None"

func _ready():
	update()
		
func update(exclude_list:PackedStringArray = []):
	$OB_id.clear()
	$OB_id.add_item(_none)
	for item in _interactives.get_items_list():
		if item not in exclude_list:
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
				
	
