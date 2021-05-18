# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends "res://drawing/draw_item.gd"

var points: PoolVector2Array


func _draw() -> void:
	draw_set_transform(-rect_position, 0, Vector2.ONE)
	draw_polyline(points, color, line_width)


func set_origin(value: Vector2) -> void:
	.set_origin(value)
	points = PoolVector2Array([origin, origin + Vector2(1, 0)])


func _update_point(value: Vector2) -> void:
	var rect = Rect2(rect_position, rect_size).expand(value)
	rect_position = rect.position
	rect_size = rect.size
	points.append(value)
