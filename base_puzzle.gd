@abstract
class_name BasePuzzle
extends Container

signal editor_response_available(editor_response: ApiEditorResponse)

signal file_changed(file: ApiFile)

signal puzzle_solved()

signal puzzle_reset()

@abstract
func set_level(level: ApiLevel) -> void

@abstract
func update_file(file: ApiFile) -> void

@abstract
func handle_editor_request(editor_request: ApiEditorRequest, use_merge_editor: bool) -> void



