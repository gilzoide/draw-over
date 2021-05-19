# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends "res://drawing/draw_item.gd"

var _text_edit: TextEdit


func _draw() -> void:
	if not _text_edit:
		draw_rect(Rect2(Vector2.ZERO, rect_size), Color.white, false)


func stop() -> void:
	.stop()
	if _text_edit:
		return
	_text_edit = TextEdit.new()
	_text_edit.context_menu_enabled = false
	_text_edit.add_color_override("font_color", color)
	_text_edit.add_color_override("font_color_readonly", color)
	var _err = _text_edit.connect("focus_entered", self, "_on_text_edit_focus_entered")
	_err = _text_edit.connect("focus_exited", self, "_on_text_edit_focus_exited")
	add_child(_text_edit)
	_text_edit.grab_focus()
	update()


func _on_text_edit_focus_entered() -> void:
	# give TextEdit the whole available rect while editing
	_text_edit.rect_size = get_parent_control().rect_size - rect_position


func _on_text_edit_focus_exited() -> void:
	# shrink TextEdit to the text size
	_text_edit.rect_size = _measure_text_edit_size(_text_edit)
	_text_edit.deselect()


static func _measure_text_edit_size(text_edit: TextEdit) -> Vector2:
	var font = text_edit.get_font("font")
	var line_height = font.get_height()
	var size = Vector2.ZERO
	for i in text_edit.get_line_count():
		var line = text_edit.get_line(i)
		size.x = max(size.x, font.get_string_size(line).x)
		size.y += line_height
	return size + Vector2(line_height, line_height)
