extends Control

const UNDOREDO_ACTION_DRAW_ITEM = "draw_item"
const UNDOREDO_ACTION_CLEAR_ITEMS = "clear_items"
const DrawItem = preload("res://draw_item.gd")

export(Resource) var settings = preload("res://main_settings.tres")

var _dragging = false
var _format = DrawItem.Format.LINE_STRIP
var _undoredo = UndoRedo.new()


func _ready() -> void:
	grab_focus()
	_on_settings_changed()
	settings.connect("changed", self, "_on_settings_changed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_undoredo.free()
		_undoredo = null
	elif what == NOTIFICATION_MOUSE_EXIT:
		_dragging = false


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_background"):
		settings.presentation_mode = not settings.presentation_mode
	elif event.is_action_pressed("clear_drawings"):
		_clear_items()
	elif event.is_action_pressed("format_line_strip"):
		_format = DrawItem.Format.LINE_STRIP
	elif event.is_action_pressed("format_rectangle"):
		_format = DrawItem.Format.RECTANGLE
	elif event.is_action_pressed("format_ellipse"):
		_format = DrawItem.Format.ELLIPSE
	elif event.is_action_pressed("redo"):
		# NOTE: is_action_pressed("undo") returns true for Shift+Control+Z,
		# so "redo" must be handled before "undo"
		_undoredo.redo()
	elif event.is_action_pressed("undo"):
		_undoredo.undo()
	elif event.is_action("drag_hold") and not event.is_echo():
		if event.is_pressed():
			_dragging = true
			_start_item(get_local_mouse_position())
		else:
			_dragging = false
	elif _dragging:
		if event.is_action_pressed("ui_cancel"):
			_undoredo.undo()
			_dragging = false
		elif event is InputEventMouseMotion:
			_update_last_item(event.position)


func _on_settings_changed() -> void:
	var is_in_presentation = settings.presentation_mode
	mouse_default_cursor_shape = CURSOR_CROSS if is_in_presentation else CURSOR_ARROW
	OS.window_per_pixel_transparency_enabled = is_in_presentation
	OS.window_borderless = is_in_presentation
	get_viewport().transparent_bg = is_in_presentation


func _start_item(point: Vector2) -> void:
	var item = DrawItem.new()
	item.format = _format
	item.start(point)
	_undoredo.create_action(UNDOREDO_ACTION_DRAW_ITEM)
	_undoredo.add_do_method(self, "add_child", item)
	_undoredo.add_do_reference(item)
	_undoredo.add_undo_method(self, "remove_child", item)
	_undoredo.commit_action()


func _update_last_item(point: Vector2) -> void:
	var child_count = get_child_count()
	if child_count > 0:
		var item = get_child(child_count - 1)
		item.update_point(point)


func _clear_items() -> void:
	var children = get_children()
	if children.empty():
		return
	_undoredo.create_action(UNDOREDO_ACTION_CLEAR_ITEMS)
	for child in children:
		_undoredo.add_do_method(self, "remove_child", child)
		_undoredo.add_undo_method(self, "add_child", child)
		_undoredo.add_undo_reference(child)
	_undoredo.commit_action()
