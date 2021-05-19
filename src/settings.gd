# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Resource

signal loaded()

const SECTION_GLOBAL = ""
const SECTION_COLOR = "color"
const KEY_PRESET = "presets"

export(String) var config_path = "user://config.ini"
export(PoolColorArray) var color_presets: PoolColorArray setget set_color_presets

var _dirty = false
var loaded = false


func _init() -> void:
	call_deferred("_load")


func set_color_presets(value: PoolColorArray) -> void:
	color_presets = value
	_request_save()
	emit_signal("changed")


func _load() -> void:
	var file = ConfigFile.new()
	if file.load(config_path) == OK:
		if file.has_section_key(SECTION_COLOR, KEY_PRESET):
			var value = file.get_value(SECTION_COLOR, KEY_PRESET, null)
			if value is PoolColorArray:
				color_presets = value
		emit_signal("changed")
	loaded = true
	emit_signal("loaded")


func _save() -> void:
	var file = ConfigFile.new()
	if not color_presets.empty():
		file.set_value(SECTION_COLOR, KEY_PRESET, color_presets)
	if file.save(config_path) != OK:
		push_warning("Could not save config file")
	_dirty = false


func _request_save() -> void:
	if _dirty:
		return
	_dirty = true
	call_deferred("_save")
