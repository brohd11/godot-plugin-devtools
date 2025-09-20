@tool
extends "res://addons/plugin_devtools/src/controls/SearchMenu.gd"

func _ready() -> void:
	text = ""
	options.clear()
	options = PackedStringArray(["Control"])
	options.append_array(ClassDB.get_inheriters_from_class(&"Control"))
	var options_to_remove := []
	for option in options:
		if option in EditorInterface.get_editor_theme().get_type_variation_list("Control"):
			options_to_remove.push_back(option)
	for o in options_to_remove:
		var idx = options.find(o)
		options.remove_at(idx) # compat <4.5
	super()
