# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const DrawItem = preload("res://drawing/draw_item.gd")

export(ButtonGroup) var button_group = preload("res://toolbar/toolbar_buttongroup.tres")
export(bool) var autohide = false setget set_autohide

var _is_mouse_inside = false
onready var _buttons = $HBoxContainer.get_children()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_is_mouse_inside = true
		modulate.a = 1
	elif what == NOTIFICATION_MOUSE_EXIT:
		_is_mouse_inside = false
		modulate.a = float(not autohide)


func set_current(current: int) -> void:
	_buttons[current].pressed = true


func set_autohide(value: bool) -> void:
	autohide = value
	modulate.a = float(_is_mouse_inside or not value)


func current_format() -> int:
	var pressed_button = button_group.get_pressed_button()
	return pressed_button.get_position_in_parent()

