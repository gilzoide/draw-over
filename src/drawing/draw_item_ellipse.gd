# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends "res://drawing/draw_item.gd"

const ellipse_points = preload("res://drawing/circle_points_resource.tres")


func _draw() -> void:
	var center = rect_size * 0.5
	var transform = Transform2D(Vector2(center.x, 0), Vector2(0, center.y), center)
	draw_polyline(transform.xform(ellipse_points.points), color, line_width)
