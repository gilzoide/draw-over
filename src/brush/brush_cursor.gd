# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Node2D

export(Resource) var brush = preload("res://main_brush.tres")
export(Resource) var font_cache = preload("res://fonts/DroidSans_cache.tres")


func _ready() -> void:
	var _err = brush.connect("changed", self, "update")


func _draw() -> void:
	if brush.format != brush.Format.TEXT:
		draw_circle(Vector2.ZERO, max(1, brush.line_width * 0.5), brush.color)
