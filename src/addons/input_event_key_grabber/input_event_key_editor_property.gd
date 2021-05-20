# This file is part of InputKeyEvent Grabber, licensed under CC0 1.0
# Project URL: https://github.com/gilzoide/godot-input-key-event-grabber
extends EditorProperty

const PROPERTIES = PoolStringArray([
	"scancode",
	"unicode",
	"alt",
	"shift",
	"control",
	"meta",
	"command",
])
const InputEventKeyGrabberButton = preload("res://addons/input_event_key_grabber/input_event_key_grabber_button.gd")

var _grabber = InputEventKeyGrabberButton.new()

func _ready() -> void:
	add_child(_grabber)
	_grabber.connect("event_updated", self, "_on_grabber_event_updated")


func update_property() -> void:
	_grabber.event = get_edited_object()


func _on_grabber_event_updated(new_event: InputEventKey) -> void:
	var input_event = get_edited_object()
	for p in PROPERTIES:
		var old = input_event.get(p)
		var new = new_event.get(p)
		if old != new:
			input_event.set(p, new)
			emit_changed(p, new)
