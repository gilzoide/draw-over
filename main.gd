extends Control

export(Resource) var settings = preload("res://main_settings.tres")


func _ready() -> void:
	_on_settings_changed()
	settings.connect("changed", self, "_on_settings_changed")


func _on_settings_changed() -> void:
	var is_in_presentation = settings.presentation_mode
	mouse_default_cursor_shape = CURSOR_CROSS if is_in_presentation else CURSOR_ARROW
	OS.window_per_pixel_transparency_enabled = is_in_presentation
	OS.window_borderless = is_in_presentation
	get_viewport().transparent_bg = is_in_presentation
