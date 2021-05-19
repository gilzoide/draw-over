# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends "res://drawing/draw_item.gd"

var lines: PoolStringArray

var _font: Font
var _ascent: float
var _line_height: float
var _previous_focused: Control


func _ready() -> void:
	lines.append("")
	_refresh_font()
	_previous_focused = get_focus_owner()
	focus_mode = Control.FOCUS_ALL
	grab_focus()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_refresh_font()


func _draw() -> void:
	var position = Vector2(0, _ascent)
	for line in lines:
		draw_string(_font, position, line, color)
		position.y += _line_height
	if has_focus():
		var last_line_size = _font.get_string_size(_get_last_line())
		var caret_origin = Vector2(last_line_size.x + 2, position.y - _line_height)
		var caret_end = caret_origin - Vector2(0, _ascent)
		draw_line(caret_origin, caret_end, color)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event is InputEventMouseButton:
		_return_focus()
	elif event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_BACKSPACE:
			var last_line = _get_last_line()
			var size = last_line.length()
			if size > 0:
				_update_last_line(last_line.left(size - 1))
				update()
			elif lines.size() > 1:
				lines.remove(lines.size() - 1)
				update()
		elif event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER:
			lines.append("")
			update()
		else:
			var c = char(event.unicode)
			if not c.empty():
				_update_last_line(_get_last_line() + c)
				update()


func _refresh_font() -> void:
	_font = get_font("font", "Label")
	_ascent = _font.get_ascent()
	_line_height = _font.get_height()


func _get_last_line() -> String:
	return lines[lines.size() - 1]


func _update_last_line(value: String) -> void:
	lines[lines.size() - 1] = value


func _return_focus() -> void:
	if _previous_focused:
		_previous_focused.grab_focus()
	else:
		release_focus()
	focus_mode = Control.FOCUS_NONE
