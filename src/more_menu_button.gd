# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends BaseButton

signal background_transparency_set(enabled)

enum {
	TRANSPARENT_BACKGROUND,
}

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
	_popup_menu.set_item_checked(idx, get_viewport().transparent_bg)


func _on_popup_menu_id_pressed(id: int) -> void:
	if id == TRANSPARENT_BACKGROUND:
		var idx = _popup_menu.get_item_index(TRANSPARENT_BACKGROUND)
		emit_signal("background_transparency_set", not _popup_menu.is_item_checked(idx))


static func _create_popup_menu() -> PopupMenu:
	var popup_menu = PopupMenu.new()
	popup_menu.add_check_item("Transparent background", TRANSPARENT_BACKGROUND)
	popup_menu.set_item_tooltip(popup_menu.get_item_index(TRANSPARENT_BACKGROUND), """
	Set the background fully transparent.
	Use Control+T for setting the background transparent at anytime.
	Use Control+B for setting the background opaque at anytime.
	""")
	return popup_menu
