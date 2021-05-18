# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends "res://drawing/draw_item.gd"

const ellipse_points = preload("res://drawing/ellipse_points_resource.tres")


func _draw() -> void:
	var size = rect_size
	var center = size * 0.5
	draw_set_transform(center, 0, Vector2.ONE)
	draw_polyline(ellipse_points.transformed_points(size), color, line_width)
