# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

export(bool) var transparent_background = false setget set_transparent_background
export(bool) var autohide_toolbar = false setget set_autohide_toolbar


func set_transparent_background(value: bool) -> void:
	if value != transparent_background:
		transparent_background = value
		emit_signal("changed")


func set_autohide_toolbar(value: bool) -> void:
	if value != autohide_toolbar:
		autohide_toolbar = value
		emit_signal("changed")
