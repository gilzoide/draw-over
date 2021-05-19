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

onready var _buttons = $HBoxContainer.get_children()


func set_current(current: int) -> void:
	_buttons[current].pressed = true


func current_format() -> int:
	var pressed_button = button_group.get_pressed_button()
	return pressed_button.get_position_in_parent()
