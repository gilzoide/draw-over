extends Control

const DrawItem = preload("res://draw_item.gd")

export(Resource) var settings = preload("res://main_settings.tres")

var _dragging = false


func _ready() -> void:
	grab_focus()
	_on_settings_changed()
	settings.connect("changed", self, "_on_settings_changed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_dragging = false


func _gui_input(event: InputEvent) -> void:
	if event.is_action_released("toggle_background"):
		settings.presentation_mode = not settings.presentation_mode
	elif event.is_action_released("clear_drawings"):
		_clear_items()
	elif event.is_action("drag_hold") and not event.is_echo():
		if event.is_pressed():
			_dragging = true
			_start_item(get_local_mouse_position())
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		_update_last_item(event.position)


func _on_settings_changed() -> void:
	var is_in_presentation = settings.presentation_mode
	mouse_default_cursor_shape = CURSOR_CROSS if is_in_presentation else CURSOR_ARROW
	OS.window_per_pixel_transparency_enabled = is_in_presentation
	OS.window_borderless = is_in_presentation
	get_viewport().transparent_bg = is_in_presentation


func _start_item(point: Vector2) -> void:
	var item = DrawItem.new()
	add_child(item)
	item.start(point)


func _update_last_item(point: Vector2) -> void:
	var child_count = get_child_count()
	if child_count > 0:
		var item = get_child(child_count - 1)
		item.update_point(point)


func _pop_item() -> void:
	var child_count = get_child_count()
	if child_count > 0:
		var item = get_child(child_count - 1)
		remove_child(item)
		item.queue_free()


func _clear_items() -> void:
	var children = get_children()
	children.invert()
	for child in children:
		remove_child(child)
		child.queue_free()
