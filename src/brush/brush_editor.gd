# Copyright (c) 2021 Gil Barbosa Reis.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends Control

const Brush = preload("res://brush/brush.gd")

export(Resource) var brush
export(Resource) var settings

onready var _line_width_slider = $LineWidth/HSlider
onready var _line_width_spinbox = $LineWidth/SpinBox
onready var _color_picker = $ColorPicker


func _ready() -> void:
	_line_width_slider.share(_line_width_spinbox)
	if settings:
		if not settings.loaded:
			yield(settings, "loaded")
		for color in settings.color_presets:
			_color_picker.add_preset(color)
	var _err = _color_picker.connect("preset_added", self, "_on_color_preset_changed")
	_err = _color_picker.connect("preset_removed", self, "_on_color_preset_changed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible and brush:
		_line_width_slider.value = brush.line_width
		_color_picker.color = brush.color


func _on_line_width_slider_value_changed(value: float) -> void:
	if brush:
		brush.line_width = value


func _on_color_changed(color: Color) -> void:
	if brush:
		brush.color = color


func _on_color_preset_changed(_color: Color) -> void:
	if settings:
		settings.color_presets = _color_picker.get_presets()
