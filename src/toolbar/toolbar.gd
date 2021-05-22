# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const DrawItem = preload("res://drawing/draw_item.gd")

export(bool) var autohide = false setget set_autohide
export(Resource) var brush = preload("res://main_brush.tres")
export(ButtonGroup) var button_group = preload("res://toolbar/toolbar_buttongroup.tres")

var _is_mouse_inside = false
onready var _buttons = $HBoxContainer.get_children()


func _ready() -> void:
	var _err = brush.connect("changed", self, "_on_brush_changed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_is_mouse_inside = true
		modulate.a = 1
	elif what == NOTIFICATION_MOUSE_EXIT:
		_is_mouse_inside = false
		modulate.a = float(not autohide)


func set_autohide(value: bool) -> void:
	autohide = value
	modulate.a = float(_is_mouse_inside or not value)


func _on_brush_changed() -> void:
	_buttons[brush.format].pressed = true


func _on_format_button_pressed(format: int) -> void:
	brush.format = format
