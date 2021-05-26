# Copyright (c) 2021 Gil Barbosa Reis.
#
# This file is part of Draw Over: https://github.com/gilzoide/draw-over
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
extends BaseButton

signal clear_drawings_pressed()

enum {
	TRANSPARENT_BACKGROUND,
	AUTOHIDE,
	CLEAR_DRAWINGS,
	LANGUAGE,
}

const LANGUAGE_SUBMENU_NAME = "language_submenu"

export(Resource) var main_ui_visibility = preload("res://main_ui_visibility.tres")
export(Resource) var settings = preload("res://main_settings.tres")

var _popup_menu: PopupMenu
var _language_submenu: PopupMenu


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if _popup_menu:
			_popup_menu.queue_free()
			_popup_menu = null
			_language_submenu = null


func _pressed() -> void:
	if not _popup_menu:
		_popup_menu = _create_popup_menu()
		var _err = _popup_menu.connect("about_to_show", self, "_on_popup_menu_about_to_show")
		_err = _popup_menu.connect("id_pressed", self, "_on_popup_menu_id_pressed")
		_language_submenu = _popup_menu.get_node(LANGUAGE_SUBMENU_NAME)
		_err = _language_submenu.connect("about_to_show", self, "_on_language_submenu_about_to_show")
		_err = _language_submenu.connect("id_pressed", self, "_on_language_submenu_id_pressed")
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


func _on_language_submenu_about_to_show() -> void:
	_language_submenu.set_item_checked(_language_submenu.get_item_index(settings.locale), true)


func _on_language_submenu_id_pressed(id: int) -> void:
	settings.locale = id


func _create_popup_menu() -> PopupMenu:
	var popup_menu = PopupMenu.new()
	popup_menu.add_check_item(tr("Transparent background"), TRANSPARENT_BACKGROUND)
	popup_menu.set_item_tooltip(popup_menu.get_item_index(TRANSPARENT_BACKGROUND), tr("Set the window background fully transparent."))
	popup_menu.set_item_shortcut(popup_menu.get_item_index(TRANSPARENT_BACKGROUND), load("res://shortcuts/toggle_transparent_background_shortcut.tres"))
	
	popup_menu.add_check_item(tr("Autohide toolbar"), AUTOHIDE)
	popup_menu.set_item_tooltip(popup_menu.get_item_index(AUTOHIDE), tr("Hide the toolbar automatically and show it again when mouse is over."))
	popup_menu.set_item_shortcut(popup_menu.get_item_index(AUTOHIDE), load("res://shortcuts/toggle_autohide_toolbar_shortcut.tres"))
	
	popup_menu.add_separator()
	
	popup_menu.add_item(tr("Clear drawings"), CLEAR_DRAWINGS)
	popup_menu.set_item_tooltip(popup_menu.get_item_index(CLEAR_DRAWINGS), tr("Remove all drawings on screen."))
	popup_menu.set_item_shortcut(popup_menu.get_item_index(CLEAR_DRAWINGS), load("res://shortcuts/clear_drawings_shortcut.tres"))
	
	popup_menu.add_separator()
	
	var language_popup_menu = PopupMenu.new()
	language_popup_menu.name = LANGUAGE_SUBMENU_NAME
	language_popup_menu.add_radio_check_item(tr("System default"), settings.Locale.SYSTEM_DEFAULT)
	language_popup_menu.add_radio_check_item("English", settings.Locale.ENGLISH)
	language_popup_menu.add_radio_check_item("Português", settings.Locale.PORTUGUESE)
	popup_menu.add_child(language_popup_menu)
	
	popup_menu.add_submenu_item(tr("Language"), LANGUAGE_SUBMENU_NAME, LANGUAGE)
	
	return popup_menu
