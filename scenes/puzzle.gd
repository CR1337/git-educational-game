class_name Puzzle
extends BasePuzzle

@onready var file_text_edit: TextEdit = $MarginContainer/PuzzleContainer/UpperContainer/FileTextEdit
@onready var map_text_edit: TextEdit = $MarginContainer/PuzzleContainer/UpperContainer/MapTextEdit
@onready var editor_text_edit: TextEdit = $MarginContainer/EditorContainer/EditorTextEdit

@onready var puzzle_container: Container = $MarginContainer/PuzzleContainer
@onready var editor_container: Container = $MarginContainer/EditorContainer

var displayed_file: ApiFile
var current_editor_request: ApiEditorRequest = null

func set_level(level: ApiLevel) -> void:
    self.map_text_edit.text = level.map.content

func update_file(file: ApiFile) -> void:
    self.displayed_file = file
    self.file_text_edit.text = file.content

func handle_editor_request(editor_request: ApiEditorRequest, use_merge_editor: bool) -> void:
    print("EditorRequest received")

    self.editor_text_edit.text = editor_request.file.content
    self.current_editor_request = editor_request

    self.editor_container.visible = true
    self.puzzle_container.hide()

func _on_reset_level_button_button_up() -> void:
    emit_signal("puzzle_reset")

func _on_run_button_button_up() -> void:
    pass # Replace with function body.

func _on_save_button_button_up() -> void:
    var file: ApiFile = ApiFile.new()
    file.filename = self.displayed_file.filename
    file.content = self.file_text_edit.text
    emit_signal("file_changed", file)

func _on_editor_cancel_button_button_up() -> void:
    var editor_response: ApiEditorResponse = ApiEditorResponse.new()
    editor_response.id = self.current_editor_request.id

    var file: ApiFile = ApiFile.new()
    file.filename = displayed_file.filename
    file.content = ""

    editor_response.file = file
    editor_response.abort = true

    emit_signal("editor_response_available", editor_response)

func _on_editor_save_button_button_up() -> void:
    var editor_response: ApiEditorResponse = ApiEditorResponse.new()
    editor_response.id = self.current_editor_request.id

    var file: ApiFile = ApiFile.new()
    file.filename = displayed_file.filename
    file.content = self.file_text_edit.text

    editor_response.file = file
    editor_response.abort = true

    emit_signal("editor_response_available", editor_response)

    self.editor_container.hide()
    self.puzzle_container.visible = true
