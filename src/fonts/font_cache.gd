# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

export(DynamicFontData) var font_data

var _font_per_size = {}


func get_font_with_size(size: int) -> DynamicFont:
	var font = _font_per_size.get(size)
	if not font:
		font = DynamicFont.new()
		font.font_data = font_data
		font.size = size
		_font_per_size[size] = font
	return font
