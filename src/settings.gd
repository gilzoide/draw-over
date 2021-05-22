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
const SECTION_BRUSH = "brush"
const SECTION_FONT = "font"
const KEY_BRUSH_SIZE = "size"
const KEY_FONT_SIZE = "size"
const KEY_COLOR_PRESETS = "color_presets"
const Brush = preload("res://brush/brush.gd")

export(String) var config_path = "user://config.ini"
export(PoolColorArray) var color_presets: PoolColorArray setget set_color_presets
export(int) var brush_size: int = Brush.DEFAULT_LINE_WIDTH setget set_brush_size
export(int) var font_size: int = Brush.DEFAULT_FONT_SIZE setget set_font_size

var _dirty = false
var loaded = false


func _init() -> void:
	call_deferred("_load")


func set_color_presets(value: PoolColorArray) -> void:
	color_presets = value
	_request_save()
	emit_signal("changed")


func set_brush_size(value: int) -> void:
	if value != brush_size:
		brush_size = value
		_request_save()
		emit_signal("changed")


func set_font_size(value: int) -> void:
	if value != font_size:
		font_size = value
		_request_save()
		emit_signal("changed")


func _load() -> void:
	var file = ConfigFile.new()
	if file.load(config_path) == OK:
		var value
		value = file.get_value(SECTION_BRUSH, KEY_COLOR_PRESETS, 0)
		if value is PoolColorArray:
			color_presets = value
		
		value = convert(file.get_value(SECTION_BRUSH, KEY_BRUSH_SIZE, Brush.DEFAULT_LINE_WIDTH), TYPE_INT)
		brush_size = int(max(value, 1))
		
		value = convert(file.get_value(SECTION_FONT, KEY_FONT_SIZE, Brush.DEFAULT_FONT_SIZE), TYPE_INT)
		font_size = int(max(value, 8))
		
		emit_signal("changed")
	loaded = true
	emit_signal("loaded")


func _save() -> void:
	var file = ConfigFile.new()
	if not color_presets.empty():
		file.set_value(SECTION_BRUSH, KEY_COLOR_PRESETS, color_presets)
	if brush_size != Brush.DEFAULT_LINE_WIDTH:
		file.set_value(SECTION_BRUSH, KEY_BRUSH_SIZE, brush_size)
	if font_size != Brush.DEFAULT_FONT_SIZE:
		file.set_value(SECTION_FONT, KEY_FONT_SIZE, font_size)
	if file.save(config_path) != OK:
		push_warning("Could not save config file")
	_dirty = false


func _request_save() -> void:
	if _dirty or not loaded:
		return
	_dirty = true
	call_deferred("_save")
