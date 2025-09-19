@tool
extends EditorPlugin

const tools_dock_scene := preload("uid://bagj2x3qnhgkh")
const plugin_icon := preload("uid://d0mcyi8ajfh02")

var tools_dock : Control
var dock_popup : Popup
var add_to_bottom_button : Button
var _docks : Dictionary[DockSlot, Control] = {}

var dock_manager: DockManager

func _get_plugin_name() -> String:
	return "PluginDevTools"
func _has_main_screen() -> bool:
	return true
func _get_plugin_icon() -> Texture2D:
	return plugin_icon

func _enable_plugin() -> void:
	# Add autoloads here.
	pass

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	DockManager.hide_main_screen_button(self)
	
	name = _get_plugin_name()
	
	add_tool_menu_item(name, _on_tool_menu_pressed)
	
	#tools_dock = tools_dock_scene.instantiate()
	#add_control_to_bottom_panel(tools_dock, "Plugin DevTools")

	# set_dock_tab_icon(tools_dock, plugin_icon)
	# var tc : TabContainer = tools_dock.get_parent()
	# var popup := tc.get_popup()
	# popup.about_to_popup.connect(_add_bottom_panel_button_to_popup)
	# tools_dock.get_child(0).get_child(0).set_popup(popup)

func _exit_tree() -> void:
	if is_instance_valid(dock_manager):
		dock_manager.clean_up()
	
	# remove_control_from_docks(tools_dock)
	
	#remove_control_from_bottom_panel(tools_dock)
	#tools_dock.queue_free()
	pass

func _add_bottom_panel_button_to_popup() -> void:
	var tc : TabContainer = tools_dock.get_parent()
	var popup := tc.get_popup()
	var vbox := popup.get_child(1, true)
	for child in vbox.get_children(true):
		if child is Button:
			if child.text == "Move to Bottom":
				child.show()

func _get_docks() -> void:
	var dummy_control := Control.new()
	for slot in DOCK_SLOT_MAX:
		add_control_to_dock(slot, dummy_control)
		_docks[slot] = dummy_control.get_parent()
		remove_control_from_docks(dummy_control)
	dummy_control.queue_free()

## DockManager
func _on_tool_menu_pressed():
	if is_instance_valid(dock_manager):
		print("%s already instanced." % name)
		return
	var can_be_freed = true
	dock_manager = DockManager.new(self, tools_dock_scene, DockManager.Slot.FLOATING, can_be_freed)
