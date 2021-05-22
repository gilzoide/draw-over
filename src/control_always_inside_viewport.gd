# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

var _is_changing_rect = false


func _ready() -> void:
	_on_item_rect_changed()
	var _err = connect("item_rect_changed", self, "_on_item_rect_changed")


func _on_item_rect_changed() -> void:
	if _is_changing_rect:  # avoid recursion
		return
	var rect = get_rect()
	var viewport_rect = get_viewport_rect()
	if not viewport_rect.has_point(rect.end):
		_is_changing_rect = true
		rect.position.x = clamp(rect.position.x, 0, viewport_rect.end.x - rect.size.x)
		rect.position.y = clamp(rect.position.y, 0, viewport_rect.end.y - rect.size.y)
		rect_position = rect.position
		_is_changing_rect = false
