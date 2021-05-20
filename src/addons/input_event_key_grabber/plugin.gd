# This file is part of InputKeyEvent Grabber, licensed under CC0 1.0
# Project URL: https://github.com/gilzoide/godot-input-key-event-grabber
tool
extends EditorPlugin

const InputEventKeyGrabberButton = preload("res://addons/input_event_key_grabber/input_event_key_grabber_button.gd")
const InputEventKeyInspectorPlugin = preload("res://addons/input_event_key_grabber/input_event_key_inspector_plugin.gd")

var _inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	add_custom_type("InputEventKeyGrabberButton", "Button", InputEventKeyGrabberButton, null)
	_inspector_plugin = InputEventKeyInspectorPlugin.new()
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)
	_inspector_plugin = null
	remove_custom_type("InputEventKeyGrabberButton")
