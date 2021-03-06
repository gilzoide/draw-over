# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

enum Format {
	PENCIL,
	RECTANGLE,
	ELLIPSE,
	TEXT,
}

const DEFAULT_LINE_WIDTH = 2
const DEFAULT_FONT_SIZE = 24

export(float, 1, 128) var line_width = DEFAULT_LINE_WIDTH setget set_line_width
export(int, 8, 128) var font_size = DEFAULT_FONT_SIZE setget set_font_size
export(Color) var color = Color.white setget set_color
export(Format) var format = Format.PENCIL setget set_format


func set_line_width(value: float) -> void:
	if value != line_width:
		line_width = value
		emit_signal("changed")


func set_font_size(value: int) -> void:
	if value != font_size:
		font_size = value
		emit_signal("changed")


func set_color(value: Color) -> void:
	if value != color:
		color = value
		emit_signal("changed")


func set_format(value: int) -> void:
	assert(value >= 0 and value <= Format.size(), "FIXME: invalid drawing format")
	if value != format:
		format = value
		emit_signal("changed")
