extends Control

@onready var game_id_line_edit: LineEdit = $TabContainer/GeneralInfoGridContainer/GameIdLineEdit
@onready var player_name_line_edit: LineEdit = $TabContainer/GeneralInfoGridContainer/PlayerNameLineEdit
@onready var levelset_id_line_edit: LineEdit = $TabContainer/GeneralInfoGridContainer/LevelsetIdLineEdit

@onready var level_id_line_edit: LineEdit = $TabContainer/LevelDataGridContainer/LevelIdLineEdit
@onready var level_name_line_edit: LineEdit = $TabContainer/LevelDataGridContainer/LevelNameLineEdit
@onready var level_started_line_edit: LineEdit = $TabContainer/LevelDataGridContainer/LevelStartedLineEdit
@onready var level_solved_line_edit: LineEdit = $TabContainer/LevelDataGridContainer/LevelSolvedLineEdit
@onready var intro_text_edit: TextEdit = $TabContainer/LevelDataGridContainer/IntroTextEdit
@onready var outro_text_edit: TextEdit = $TabContainer/LevelDataGridContainer/OutroTextEdit
@onready var clues_item_list: ItemList = $TabContainer/LevelDataGridContainer/CluesItemList
@onready var map_text_edit: TextEdit = $TabContainer/LevelDataGridContainer/MapTextEdit
@onready var patches_item_list: ItemList = $TabContainer/LevelDataGridContainer/PatchesItemList

@onready var files_item_list: ItemList = $TabContainer/FilesGridContainer/FilesItemList
@onready var file_text_edit: TextEdit = $TabContainer/FilesGridContainer/FileTextEdit

@onready var git_argv_line_edit: LineEdit = $TabContainer/GitGridContainer/GitArgvLineEdit
@onready var result_type_line_edit: LineEdit = $TabContainer/GitGridContainer/ResultTypeLineEdit
@onready var returncode_line_edit: LineEdit = $TabContainer/GitGridContainer/ReturncodeLineEdit
@onready var stdout_text_edit: TextEdit = $TabContainer/GitGridContainer/StdoutTextEdit
@onready var stderr_text_edit: TextEdit = $TabContainer/GitGridContainer/StderrTextEdit
@onready var git_session_id_line_edit: LineEdit = $TabContainer/GitGridContainer/GitSessionIdLineEdit
@onready var file_content_text_edit: TextEdit = $TabContainer/GitGridContainer/FileContentTextEdit
@onready var abort_check_box: CheckBox = $TabContainer/GitGridContainer/AbortCheckBox
@onready var submit_file_content_button: Button = $TabContainer/GitGridContainer/SubmitFileContentButton

@onready var get_level_request: ApiRequestGetLevel = $Requests/ApiRequestGetLevel
@onready var reset_level_request: ApiRequestResetLevel = $Requests/ApiRequestResetLevel
@onready var set_level_started_request: ApiRequestSetLevelStarted = $Requests/ApiRequestSetLevelStarted
@onready var set_level_solved_request: ApiRequestSetLevelSolved = $Requests/ApiRequestSetLevelSolved
@onready var get_files_request: ApiRequestGetFiles = $Requests/ApiRequestGetFiles
@onready var get_file_request: ApiRequestGetFile = $Requests/ApiRequestGetFile
@onready var update_file_request: ApiRequestUpdateFile = $Requests/ApiRequestUpdateFile
@onready var git_command_request: ApiRequestGitCommand = $Requests/ApiRequestGitCommand
@onready var editor_response_request: ApiRequestEditorResponse = $Requests/ApiRequestEditorResponse


var selected_filename: String = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.game_id_line_edit.text = GameData.game.id
    self.player_name_line_edit.text = GameData.game.player.name
    self.levelset_id_line_edit.text = GameData.game.levelset.id
    self.update_level_data()
    self.update_files()


func update_level_data() -> void:
    self.get_level_request.request(GameData.game.id, GameData.current_level_id)

func update_files() -> void:
    self.get_files_request.request(GameData.game.id, GameData.current_level_id)


"""
General Infos
- game id
- player name
- levelset id

Level Data
- level id
- level name
- level started
- level solved
- intro
- outro
- clues
- map
    - width
    - height
    - content
    - patches

Files

API Interface
- reset level
- set started
- set solved
- update file
- git command
- editor response
"""


func _on_set_solved_button_button_up() -> void:
    self.set_level_solved_request.request(GameData.game.id, GameData.current_level_id)


func _on_set_started_button_button_up() -> void:
    self.set_level_started_request.request(GameData.game.id, GameData.current_level_id)


func _on_reset_level_button_button_up() -> void:
    self.reset_level_request.request(GameData.game.id, GameData.current_level_id)


func _on_save_changes_button_button_up() -> void:
    if self.selected_filename == "":
        print("No file to save!")
        return

    var file: ApiFile = ApiFile.new()
    file.filename = self.selected_filename
    file.content = self.file_text_edit.text

    self.update_file_request.request(GameData.game.id, GameData.current_level_id, file)


func _on_reload_files_button_button_up() -> void:
    self.update_files()


func _on_reload_level_data_button_button_up() -> void:
    self.update_level_data()


func _on_submit_file_content_button_button_up() -> void:
    var file: ApiFile = ApiFile.new()
    file.filename = "filename"
    file.content = self.file_content_text_edit.text

    var editor_response = ApiEditorResponse.new()
    editor_response.id = self.git_session_id_line_edit.text
    editor_response.file = file
    editor_response.abort = self.abort_check_box.button_pressed

    self.editor_response_request.request(GameData.game.id, GameData.current_level_id, editor_response)


func _on_submit_button_button_up() -> void:
    var git_command: ApiGitCommand = ApiGitCommand.new()
    git_command.argv = Array(self.git_argv_line_edit.text.split(" ", false))
    self.git_command_request.request(GameData.game.id, GameData.current_level_id, git_command)


func _on_api_request_editor_response_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("editor_response", result, status_code)


func _on_api_request_editor_response_request_completed(_status_code: int, body: ApiGitResult) -> void:
    self.result_type_line_edit.text = body.type_
    self.returncode_line_edit.text = str(body.returncode)
    self.stdout_text_edit.text = body.stdout
    self.stderr_text_edit.text = body.stderr
    self.git_session_id_line_edit.text = body.id
    self.submit_file_content_button.disabled = true


func _on_api_request_git_command_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("git_command", result, status_code)


func _on_api_request_git_command_request_completed_with_git_result(_status_code: int, body: ApiGitResult) -> void:
    self.result_type_line_edit.text = body.type_
    self.returncode_line_edit.text = str(body.returncode)
    self.stdout_text_edit.text = body.stdout
    self.stderr_text_edit.text = body.stderr
    self.git_session_id_line_edit.text = body.id
    self.file_content_text_edit.text = ""
    self.submit_file_content_button.disabled = true


func _on_api_request_git_command_request_completed_with_editor_request(_status_code: int, body: ApiEditorRequest) -> void:
    self.result_type_line_edit.text = body.type_
    self.returncode_line_edit.text = "?"
    self.stdout_text_edit.text = body.stdout
    self.stderr_text_edit.text = body.stderr
    self.git_session_id_line_edit.text = body.id
    self.file_content_text_edit.text = body.file.content
    self.submit_file_content_button.disabled = false


func _on_api_request_update_file_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("update_file", result, status_code)


func _on_api_request_update_file_request_completed(_status_code: int) -> void:
    pass  # nothing to do here


func _on_api_request_get_file_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("get_file", result, status_code)


func _on_api_request_get_file_request_completed(_status_code: int, body: ApiFile) -> void:
    self.file_text_edit.text = body.content


func _on_api_request_get_files_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("get_files", result, status_code)


func _on_api_request_get_files_request_completed(_status_code: int, body: Array[String]) -> void:
    self.files_item_list.clear()
    for filename in body:
        self.files_item_list.add_item(filename)


func _on_api_request_set_level_solved_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("set_level_solved", result, status_code)


func _on_api_request_set_level_solved_request_completed(_status_code: int) -> void:
    self.update_level_data()


func _on_api_request_set_level_started_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("set_level_started", result, status_code)


func _on_api_request_set_level_started_request_completed(_status_code: int) -> void:
    self.update_level_data()


func _on_api_request_reset_level_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("reset_level", result, status_code)


func _on_api_request_reset_level_request_completed(_status_code: int, _body: ApiLevel) -> void:
    self.update_level_data()
    self.update_files()


func _on_api_request_get_level_request_failed(result: int, status_code: int) -> void:
    self.print_request_failed("get_level", result, status_code)

func _on_api_request_get_level_request_completed(_status_code: int, body: ApiLevel) -> void:
    self.level_id_line_edit.text = body.id
    self.level_name_line_edit.text = body.level_node.name
    self.level_started_line_edit.text = "yes" if body.level_node.started else "no"
    self.level_solved_line_edit.text = "yes" if body.level_node.solved else "no"
    self.intro_text_edit.text = body.intro
    self.outro_text_edit.text = body.outro
    self.clues_item_list.clear()
    for clue in body.clues:
        self.clues_item_list.add_item(clue)
    self.map_text_edit.text = body.map.content
    self.patches_item_list.clear()
    var patches: Array = body.map.patches
    for patch in patches:
        self.patches_item_list.add_item("(" + str(int(patch[0])) + ", " + str(int(patch[1])) + "): " + patch[2])

func print_request_failed(request_name: String, result: int, status_code: int) -> void:
    print("Request '" + request_name + "' failed with status code " + str(status_code) + ". (" + str(result) + ")")


func _on_files_item_list_item_selected(index: int) -> void:
    var filename = self.files_item_list.get_item_text(index)
    self.selected_filename = filename
    self.get_file_request.request(GameData.game.id, GameData.current_level_id, filename)
