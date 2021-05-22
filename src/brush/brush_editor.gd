# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends "res://control_always_inside_viewport.gd"

const Brush = preload("res://brush/brush.gd")

export(Resource) var brush = preload("res://main_brush.tres")
export(Resource) var settings = preload("res://main_settings.tres")

onready var _line_width_slider = $VBoxContainer/LineWidth/HSlider
onready var _line_width_spinbox = $VBoxContainer/LineWidth/SpinBox
onready var _font_size_slider = $VBoxContainer/FontSize/HSlider
onready var _font_size_spinbox = $VBoxContainer/FontSize/SpinBox
onready var _color_picker = $VBoxContainer/ColorPicker


func _ready() -> void:
	_line_width_slider.share(_line_width_spinbox)
	_font_size_slider.share(_font_size_spinbox)
	
	if settings:
		if not settings.loaded:
			yield(settings, "loaded")
		for color in settings.color_presets:
			_color_picker.add_preset(color)
	if brush:
		_line_width_slider.value = brush.line_width
		_font_size_slider.value = brush.font_size
	
	var _err = _color_picker.connect("preset_added", self, "_on_color_preset_changed")
	_err = _color_picker.connect("preset_removed", self, "_on_color_preset_changed")
	_err = _color_picker.connect("color_changed", self, "_on_color_changed")
	_err = _line_width_slider.connect("value_changed", self, "_on_line_width_slider_value_changed")
	_err = _font_size_slider.connect("value_changed", self, "_on_font_size_slider_value_changed")


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree() and brush:
			_line_width_slider.value = brush.line_width
			_font_size_slider.value = brush.font_size
			_color_picker.color = brush.color
	elif what == NOTIFICATION_MODAL_CLOSE:
		if settings:
			settings.brush_size = brush.line_width
			settings.font_size = brush.font_size
		queue_free()


func _on_line_width_slider_value_changed(value: float) -> void:
	if brush:
		brush.line_width = value


func _on_font_size_slider_value_changed(value: float) -> void:
	if brush:
		brush.font_size = int(value)


func _on_color_changed(color: Color) -> void:
	if brush:
		brush.color = color


func _on_color_preset_changed(_color: Color) -> void:
	if settings:
		settings.color_presets = _color_picker.get_presets()
