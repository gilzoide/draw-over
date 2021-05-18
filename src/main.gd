# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

enum Mode {
	BOARD,
	TRANSPARENT,
	PRESENTATION,
}

const UNDOREDO_ACTION_DRAW_ITEM = "draw_item"
const UNDOREDO_ACTION_CLEAR_ITEMS = "clear_items"
const DrawItem = preload("res://drawing/draw_item.gd")
const DrawItemPencil = preload("res://drawing/draw_item_pencil.gd")
const DrawItemRectangle = preload("res://drawing/draw_item_rectangle.gd")
const DrawItemEllipse = preload("res://drawing/draw_item_ellipse.gd")
var DRAW_ITEM_PER_FORMAT = [
	DrawItemPencil,
	DrawItemRectangle,
	DrawItemEllipse,
]

export(Resource) var brush = preload("res://main_brush.tres")
export(Resource) var settings = preload("res://main_settings.tres")

var _dragging = false
var _undoredo = UndoRedo.new()

onready var _brush_editor_popup = $BrushEditorPopup
onready var _draw_items_container = $DrawItemsContainer
onready var _toolbar = $Toolbar


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
	if event.is_action_pressed("mode_board"):
		_set_mode(Mode.BOARD)
	if event.is_action_pressed("mode_transparent"):
		_set_mode(Mode.TRANSPARENT)
	elif event.is_action_pressed("mode_presentation"):
		_set_mode(Mode.PRESENTATION)
	elif event.is_action_pressed("clear_drawings"):
		_clear_items()
	elif event.is_action_pressed("format_pencil"):
		_toolbar.set_current(DrawItem.Format.PENCIL)
	elif event.is_action_pressed("format_rectangle"):
		_toolbar.set_current(DrawItem.Format.RECTANGLE)
	elif event.is_action_pressed("format_ellipse"):
		_toolbar.set_current(DrawItem.Format.ELLIPSE)
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
		_brush_editor_popup.popup(Rect2(get_global_mouse_position(), _brush_editor_popup.rect_size))
	elif _dragging:
		if event.is_action_pressed("ui_cancel"):
			_undoredo.undo()
			_stop_item()
		elif event is InputEventMouseMotion:
			_update_last_item(event.position)


func _set_mode(mode: int) -> void:
	_toolbar.visible = mode == Mode.BOARD or mode == Mode.TRANSPARENT
	var transparent = mode == Mode.TRANSPARENT or mode == Mode.PRESENTATION
	OS.window_per_pixel_transparency_enabled = transparent
	get_viewport().transparent_bg = transparent


func _on_settings_changed() -> void:
	pass


func _start_item(point: Vector2) -> void:
	_dragging = true
	var format = _toolbar.current_format()
	var item = DRAW_ITEM_PER_FORMAT[format].new()
	item.set_brush(brush)
	Input.set_use_accumulated_input(format != DrawItem.Format.PENCIL)
	item.start(point)
	_undoredo.create_action(UNDOREDO_ACTION_DRAW_ITEM)
	_undoredo.add_do_method(_draw_items_container, "add_child", item)
	_undoredo.add_do_reference(item)
	_undoredo.add_undo_method(_draw_items_container, "remove_child", item)
	_undoredo.commit_action()


func _stop_item() -> void:
	_dragging = false
	Input.set_use_accumulated_input(true)


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
