# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const UNDOREDO_ACTION_DRAW_ITEM = "draw_item"
const UNDOREDO_ACTION_CLEAR_ITEMS = "clear_items"
const Brush = preload("res://brush/brush.gd")
const DrawItem = preload("res://drawing/draw_item.gd")
const DrawItemPencil = preload("res://drawing/draw_item_pencil.gd")
const DrawItemRectangle = preload("res://drawing/draw_item_rectangle.gd")
const DrawItemEllipse = preload("res://drawing/draw_item_ellipse.gd")
const DrawItemText = preload("res://drawing/draw_item_text.gd")
var DRAW_ITEM_PER_FORMAT = [
	DrawItemPencil,
	DrawItemRectangle,
	DrawItemEllipse,
	DrawItemText,
]

export(Resource) var brush = preload("res://main_brush.tres")
export(Resource) var main_ui_visibility = preload("res://main_ui_visibility.tres")
export(Resource) var settings = preload("res://main_settings.tres")

var _BrushEditor: PackedScene
var _color_shortcuts = {}
var _dragging = false
var _undoredo = UndoRedo.new()

onready var _brush_cursor = $BrushCursor
onready var _draw_items_container = $DrawItemsContainer
onready var _toolbar = $Toolbar
onready var _undo_button = $Toolbar/HBoxContainer/UndoButton
onready var _redo_button = $Toolbar/HBoxContainer/RedoButton


func _ready() -> void:
	grab_focus()
	
	_on_undoredo_version_changed()
	_undoredo.connect("version_changed", self, "_on_undoredo_version_changed")
	_undo_button.connect("pressed", _undoredo, "undo")
	_redo_button.connect("pressed", _undoredo, "redo")
	
	if not settings.loaded:
		yield(settings, "loaded")
	brush.line_width = settings.brush_size
	brush.font_size = settings.font_size
	_on_settings_changed()
	settings.connect("changed", self, "_on_settings_changed")
	
	main_ui_visibility.connect("changed", self, "_on_main_ui_visibility_changed")
	
	_toolbar.connect("minimum_size_changed", _toolbar, "set_anchors_and_margins_preset", [Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE])


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_undoredo.disconnect("version_changed", self, "_on_undoredo_version_changed")
		_undoredo.free()
		_undoredo = null
	elif what == NOTIFICATION_MOUSE_ENTER:
		_brush_cursor.visible = not _dragging
		_brush_cursor.position = get_local_mouse_position()
	elif what == NOTIFICATION_MOUSE_EXIT or what == NOTIFICATION_FOCUS_EXIT:
		_brush_cursor.visible = false


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("clear_drawings"):
		_clear_items()
	elif event.is_action_pressed("toggle_transparent_background"):
		main_ui_visibility.transparent_background = not main_ui_visibility.transparent_background
	elif event.is_action_pressed("toggle_autohide_toolbar"):
		main_ui_visibility.autohide_toolbar = not main_ui_visibility.autohide_toolbar
	elif event.is_action_pressed("format_pencil"):
		brush.format = Brush.Format.PENCIL
	elif event.is_action_pressed("format_rectangle"):
		brush.format = Brush.Format.RECTANGLE
	elif event.is_action_pressed("format_ellipse"):
		brush.format = Brush.Format.ELLIPSE
	elif event.is_action_pressed("format_text"):
		brush.format = Brush.Format.TEXT
	elif event.is_action_pressed("redo"):
		# NOTE: is_action_pressed("undo") returns true for Shift+Control+Z,
		# so "redo" must be handled before "undo"
		_undoredo.redo()
	elif event.is_action_pressed("undo"):
		_undoredo.undo()
	elif event.is_action("drag_hold") and not event.is_echo():
		if event.is_pressed():
			_start_item(get_local_mouse_position())
		else:
			_stop_item()
	elif event.is_action_pressed("open_brush_editor"):
		_open_brush_editor()
	elif _dragging:
		if event.is_action_pressed("ui_cancel"):
			_undoredo.undo()
			_stop_item()
		elif event is InputEventMouseMotion:
			_update_last_item(event.position)
	elif event is InputEventMouseMotion:
		_brush_cursor.position = event.position
	elif event is InputEventKey and event.is_pressed() and not event.is_echo():
		var color = _color_shortcuts.get(event.scancode)
		if color:
			brush.color = color


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		grab_focus()


func _set_transparent_background(enabled: bool) -> void:
	OS.window_per_pixel_transparency_enabled = enabled
	get_viewport().transparent_bg = enabled


func _set_autohide_toolbar(enabled: bool) -> void:
	_toolbar.autohide = enabled


func _on_undoredo_version_changed() -> void:
	_undo_button.disabled = not _undoredo.has_undo()
	_redo_button.disabled = not _undoredo.has_redo()


func _start_item(point: Vector2) -> void:
	var item = DRAW_ITEM_PER_FORMAT[brush.format].new()
	item.set_brush(brush)
	Input.set_use_accumulated_input(brush.format != Brush.Format.PENCIL)
	item.start(point)
	_set_dragging(item.supports_dragging())
	_undoredo.create_action(UNDOREDO_ACTION_DRAW_ITEM)
	_undoredo.add_do_method(_draw_items_container, "add_child", item)
	_undoredo.add_do_reference(item)
	_undoredo.add_undo_method(_draw_items_container, "remove_child", item)
	_undoredo.commit_action()


func _stop_item() -> void:
	_set_dragging(false)
	Input.set_use_accumulated_input(true)


func _set_dragging(value: bool) -> void:
	_dragging = value
	_brush_cursor.visible = not value


func _update_last_item(point: Vector2) -> void:
	var child_count = _draw_items_container.get_child_count()
	if child_count > 0:
		var item = _draw_items_container.get_child(child_count - 1)
		item.update_point(point)


func _clear_items() -> void:
	var children = _draw_items_container.get_children()
	if children.empty():
		return
	_undoredo.create_action(UNDOREDO_ACTION_CLEAR_ITEMS)
	for child in children:
		_undoredo.add_do_method(_draw_items_container, "remove_child", child)
		_undoredo.add_undo_method(_draw_items_container, "add_child", child)
		_undoredo.add_undo_reference(child)
	_undoredo.commit_action()


func _open_brush_editor() -> void:
	if not _BrushEditor:
		_BrushEditor = load("res://brush/BrushEditor.tscn")
	var editor = _BrushEditor.instance()
	add_child(editor)
	editor.rect_position = get_local_mouse_position()
	editor.set_as_toplevel(true)
	editor.show_modal()


func _on_settings_changed() -> void:
	_color_shortcuts.clear()
	var color_presets = settings.color_presets
	for i in min(color_presets.size(), 9):
		_color_shortcuts[KEY_1 + i] = color_presets[i]
	if color_presets.size() >= 10:
		_color_shortcuts[KEY_0] = color_presets[9]


func _on_main_ui_visibility_changed() -> void:
	_set_transparent_background(main_ui_visibility.transparent_background)
	_set_autohide_toolbar(main_ui_visibility.autohide_toolbar)


func _on_clear_drawings_pressed():
	_clear_items()
