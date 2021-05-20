# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends BaseButton

signal clear_drawings_pressed()
signal config_brush_pressed()

enum {
	TRANSPARENT_BACKGROUND,
	AUTOHIDE,
	CLEAR_DRAWINGS,
	CONFIG_BRUSH,
}

export(Resource) var main_ui_visibility = preload("res://main_ui_visibility.tres")

var _popup_menu: PopupMenu


func _pressed() -> void:
	if not _popup_menu:
		_popup_menu = _create_popup_menu()
		var _err = _popup_menu.connect("about_to_show", self, "_on_popup_menu_about_to_show")
		_err = _popup_menu.connect("id_pressed", self, "_on_popup_menu_id_pressed")
		add_child(_popup_menu)
	var global_rect = get_global_rect()
	var size = _popup_menu.get_combined_minimum_size()
	_popup_menu.popup(Rect2(global_rect.position.x, global_rect.end.y, size.x, size.y))


func _on_popup_menu_about_to_show() -> void:
	var idx = _popup_menu.get_item_index(TRANSPARENT_BACKGROUND)
	_popup_menu.set_item_checked(idx, main_ui_visibility.transparent_background)
	
	idx = _popup_menu.get_item_index(AUTOHIDE)
	_popup_menu.set_item_checked(idx, main_ui_visibility.autohide_toolbar)


func _on_popup_menu_id_pressed(id: int) -> void:
	var idx = _popup_menu.get_item_index(id)
	if id == TRANSPARENT_BACKGROUND:
		main_ui_visibility.transparent_background = not _popup_menu.is_item_checked(idx)
	elif id == AUTOHIDE:
		main_ui_visibility.autohide_toolbar = not _popup_menu.is_item_checked(idx)
	elif id == CLEAR_DRAWINGS:
		emit_signal("clear_drawings_pressed")
	elif id == CONFIG_BRUSH:
		emit_signal("config_brush_pressed")


static func _create_popup_menu() -> PopupMenu:
	var popup_menu = PopupMenu.new()
	popup_menu.add_check_item("Transparent background", TRANSPARENT_BACKGROUND)
	popup_menu.set_item_tooltip(popup_menu.get_item_index(TRANSPARENT_BACKGROUND), """
	Set the background fully transparent.
	""")
	popup_menu.set_item_shortcut(popup_menu.get_item_index(TRANSPARENT_BACKGROUND), load("res://shortcuts/toggle_transparent_background_shortcut.tres"))
	
	popup_menu.add_check_item("Autohide toolbar", AUTOHIDE)
	popup_menu.set_item_tooltip(popup_menu.get_item_index(AUTOHIDE), """
	Hide the toolbar automatically and show it again when mouse is over.
	""")
	popup_menu.set_item_shortcut(popup_menu.get_item_index(AUTOHIDE), load("res://shortcuts/toggle_autohide_toolbar_shortcut.tres"))
	
	popup_menu.add_separator()
	
	popup_menu.add_item("Clear drawings", CLEAR_DRAWINGS)
	popup_menu.set_item_tooltip(popup_menu.get_item_index(CLEAR_DRAWINGS), """
	Remove all current drawings.
	""")
	popup_menu.set_item_shortcut(popup_menu.get_item_index(CLEAR_DRAWINGS), load("res://shortcuts/clear_drawings_shortcut.tres"))
	
	popup_menu.add_item("Configure brush", CONFIG_BRUSH)
	popup_menu.set_item_tooltip(popup_menu.get_item_index(CONFIG_BRUSH), """
	(Right click anywhere)
	Open the brush configuration popup, including drawing and font size and color.
	""")
	return popup_menu
