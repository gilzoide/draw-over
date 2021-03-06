# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

export(int, 3, 128) var point_count = 64 setget set_point_count

var points: PoolVector2Array


func _init() -> void:
	_refresh_points()


func set_point_count(value: int) -> void:
	value = int(max(value, 3))
	if value != point_count:
		point_count = value
		_refresh_points()
		emit_signal("changed")


func _refresh_points() -> void:
	points.resize(point_count + 1)
	var each_angle = TAU / (point_count - 1)
	for i in point_count + 1:
		var angle = i * each_angle
		points[i] = Vector2(cos(angle), sin(angle))
