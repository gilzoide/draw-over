extends Resource

const SECTION_GLOBAL = ""
const KEY_PRESENTATION = "presentation"

export(String) var config_path = "user://config.ini"
export(bool) var presentation_mode = false setget set_presentation_mode

var _dirty = false


func _init() -> void:
	var file = ConfigFile.new()
	if file.load(config_path) == OK:
		if file.has_section_key(SECTION_GLOBAL, KEY_PRESENTATION):
			set_presentation_mode(bool(file.get_value(SECTION_GLOBAL, KEY_PRESENTATION, false)))
	else:
		_request_save()


func set_presentation_mode(value: bool) -> void:
	if value != presentation_mode:
		presentation_mode = value
		_request_save()
		emit_signal("changed")


func _save() -> void:
	var file = ConfigFile.new()
	file.set_value(SECTION_GLOBAL, KEY_PRESENTATION, presentation_mode)
	if file.save(config_path) != OK:
		push_warning("Could not save config file")
	_dirty = false


func _request_save() -> void:
	if _dirty:
		return
	_dirty = true
	call_deferred("_save")
