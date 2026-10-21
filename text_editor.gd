extends VBoxContainer
class_name TextEditor

@export var original_text: String

@onready var text_edit: TextEdit = $TextEdit

signal text_saved(original_text: String, new_text: String)
signal edit_cancelled(original_text: String)

func _ready() -> void:
	self.text_edit.text = self.original_text


func _on_cancel_button_pressed() -> void:
	self.emit_signal("edit_cancelled", self.original_text)


func _on_save_button_pressed() -> void:
	self.emit_signal("text_saved", self.original_text, self.text_edit.text)
