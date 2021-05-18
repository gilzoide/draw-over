# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Node2D

enum Format {
	PENCIL,
	RECTANGLE,
	ELLIPSE,
}

const Brush = preload("res://brush/brush.gd")

export(Format) var format = Format.PENCIL

export(Color) var color = Color.white
export(float) var line_width = 1.0
var origin: Vector2
var param  # PoolVector2Array for PENCIL, Rect2 for others


func _draw() -> void:
	if format == Format.PENCIL:
		draw_polyline(param, color, line_width)
	elif format == Format.RECTANGLE:
		draw_rect(param, color, false, line_width)
	elif format == Format.ELLIPSE:
		var size = param.size
		var center = param.position + size * 0.5
		draw_set_transform(center, 0, size)
		draw_arc(Vector2.ZERO, 0.5, 0, TAU, int(clamp(max(size.x, size.y), 3, 64)), color)


func start(point: Vector2) -> void:
	origin = point
	if format == Format.PENCIL:
		param = PoolVector2Array([point, point + Vector2(1, 0)])
	else:
		param = Rect2(point, Vector2.ONE)
	update()


func set_brush(brush: Brush) -> void:
	color = brush.color
	line_width = brush.line_width


func update_point(point: Vector2) -> void:
	if format == Format.PENCIL:
		param.append(point)
	else:
		param = Rect2(origin, Vector2.ONE).expand(point)
		if param.size.x < 1:
			param.size.x = 1
		if param.size.y < 1:
			param.size.y = 1
	update()
