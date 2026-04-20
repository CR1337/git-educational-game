class_name LoadingScreen
extends TextureRect

@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var back_button: Button = $VBoxContainer/BackButton
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

signal back_button_pressed()

func display_error(error_message: String) -> void:
    message_label.text = error_message
    progress_bar.hide()
    back_button.visible = true

func reset() -> void:
    message_label.text = "LOC_LOADING"
    progress_bar.visible = true
    back_button.hide()

func _on_back_button_button_up() -> void:
    emit_signal("back_button_pressed")
    self.reset()
