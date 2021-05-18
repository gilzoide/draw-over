# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

export(float, 1, 128) var line_width = 1 setget set_line_width
export(Color) var color = Color.white setget set_color


func set_line_width(value: float) -> void:
	if value != line_width:
		line_width = value
		emit_signal("changed")


func set_color(value: Color) -> void:
	if value != color:
		color = value
		emit_signal("changed")