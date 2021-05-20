# This file is part of InputKeyEvent Grabber, licensed under CC0 1.0
# Project URL: https://github.com/gilzoide/godot-input-key-event-grabber
extends Button

signal event_updated(event)

export(String) var press_key_text = "Press key combo..."
export(bool) var auto_release_focus = true

var event: InputEventKey = null setget set_event


func _notification(what: int) -> void:
	if what == NOTIFICATION_FOCUS_EXIT:
		_refresh_text()
	elif what == NOTIFICATION_FOCUS_ENTER:
		text = press_key_text


func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			set_event(event)
			if auto_release_focus and not _event_is_modifier(event):
				var next = get_node_or_null(focus_next)
				if next is Control:
					next.grab_focus()
				else:
					release_focus()
		accept_event()



func set_event(value: InputEventKey) -> void:
	event = value
	_refresh_text()
	emit_signal("event_updated", event)


func _refresh_text() -> void:
	text = "" if event == null else event.as_text()


static func _event_is_modifier(event: InputEventKey):
	return event.scancode in [KEY_ALT, KEY_CONTROL, KEY_META, KEY_SHIFT]
