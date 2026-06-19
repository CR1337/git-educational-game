extends VBoxContainer

@onready var address_line_edit: LineEdit = $TabContainer/ServerConnection/AddressLineEdit

@onready var language_option_button: OptionButton = $TabContainer/Language/LanguageOptionButton

func _ready() -> void:
    self.address_line_edit.text = SettingsData.api_address

func _save_changes() -> void:
    SettingsData.api_address = self.address_line_edit.text

func _on_ok_button_button_up() -> void:
    self._save_changes()
    self.get_tree().change_scene_to_file("res://menus/main_menu.tscn")

func _on_cancel_button_button_up() -> void:
    self.get_tree().change_scene_to_file("res://menus/main_menu.tscn")
