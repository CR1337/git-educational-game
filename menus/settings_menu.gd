extends VBoxContainer

@onready var protocol_option_button: OptionButton = $TabContainer/ServerConnection/ProtocolOptionButton
@onready var address_line_edit: LineEdit = $TabContainer/ServerConnection/AddressLineEdit
@onready var port_spin_box: SpinBox = $TabContainer/ServerConnection/PortSpinBox

@onready var language_option_button: OptionButton = $TabContainer/Language/LanguageOptionButton

func _ready() -> void:
    self.protocol_option_button.select(0 if SettingsData.api_protocol == SettingsData.ApiProtocol.HTTP else 1)
    self.address_line_edit.text = SettingsData.api_address
    self.port_spin_box.value = SettingsData.api_port

func _save_changes() -> void:
    SettingsData.api_protocol = SettingsData.ApiProtocol.HTTP if self.protocol_option_button.selected == 0 else SettingsData.ApiProtocol.HTTPS
    SettingsData.api_address = self.address_line_edit.text
    SettingsData.api_port = round(self.port_spin_box.value)

func _on_ok_button_button_up() -> void:
    self._save_changes()
    self.get_tree().change_scene_to_file("res://menus/main_menu.tscn")

func _on_cancel_button_button_up() -> void:
    self.get_tree().change_scene_to_file("res://menus/main_menu.tscn")
