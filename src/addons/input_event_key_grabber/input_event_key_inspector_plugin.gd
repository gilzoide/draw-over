# This file is part of InputKeyEvent Grabber, licensed under CC0 1.0
# Project URL: https://github.com/gilzoide/godot-input-key-event-grabber
extends EditorInspectorPlugin

const InputEventKeyEditorProperty = preload("res://addons/input_event_key_grabber/input_event_key_editor_property.gd")


func can_handle(object: Object) -> bool:
	return object is InputEventKey


func parse_begin(object: Object) -> void:
	var editor_property = InputEventKeyEditorProperty.new()
	add_property_editor_for_multiple_properties("Key Combo", InputEventKeyEditorProperty.PROPERTIES, editor_property)
