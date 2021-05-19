# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

enum Format {
	PENCIL,
	RECTANGLE,
	ELLIPSE,
	TEXT,
}

const Brush = preload("res://brush/brush.gd")

export(Color) var color = Color.white setget set_color
export(float) var line_width = 1.0 setget set_line_width
var origin: Vector2 setget set_origin


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS


func set_color(value: Color) -> void:
	if value != color:
		color = value
		update()


func set_line_width(value: float) -> void:
	if value != line_width:
		line_width = value
		update()


func set_origin(value: Vector2) -> void:
	origin = value


func start(point: Vector2) -> void:
	set_origin(point)
	rect_position = point
	rect_size = Vector2.ONE
	update()


func set_brush(brush: Brush) -> void:
	color = brush.color
	line_width = brush.line_width
	update()


func update_point(point: Vector2) -> void:
	_update_point(point)
	update()


func _update_point(point: Vector2) -> void:
	var rect = Rect2(origin, Vector2.ONE).expand(point)
	if rect.size.x < 1:
		rect.size.x = 1
	if rect.size.y < 1:
		rect.size.y = 1
	rect_position = rect.position
	rect_size = rect.size
