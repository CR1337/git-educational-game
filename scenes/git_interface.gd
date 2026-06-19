extends Control

@onready var file_list: ItemList = $Panels/LeftPanel/FileList
@onready var git_graph: GraphEdit = $Panels/LeftPanel/GitGraph
@onready var puzzle: Puzzle = $Panels/CenterPanel/TabBar/Puzzle
@onready var command_line: LineEdit = $Panels/CenterPanel/HBoxContainer/CommandLine
@onready var command_list: ItemList = $Panels/RightPanel/CommandList

@onready var get_files_request: ApiRequestGetFiles = $Requests/ApiRequestGetFiles
@onready var get_file_request: ApiRequestGetFile = $Requests/ApiRequestGetFile
@onready var get_level_request: ApiRequestGetLevel = $Requests/ApiRequestGetLevel
@onready var editor_response_request: ApiRequestEditorResponse = $Requests/ApiRequestEditorResponse
@onready var set_level_solved_request: ApiRequestSetLevelSolved = $Requests/ApiRequestSetLevelSolved
@onready var git_command_request: ApiRequestGitCommand = $Requests/ApiRequestGitCommand
@onready var reset_level_request: ApiRequestResetLevel = $Requests/ApiRequestResetLevel
@onready var update_file_request: ApiRequestUpdateFile = $Requests/ApiRequestUpdateFile



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.get_level_request.request(GameData.game.id, GameData.current_level_id)
    self.get_files_request.request(GameData.game.id, GameData.current_level_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass



func _on_submit_button_button_up() -> void:
    var git_command: ApiGitCommand = ApiGitCommand.new()
    git_command.argv = self.command_line.text.split(" ")
    self.git_command_request.request(GameData.game.id, GameData.current_level_id, git_command)
    self.command_line.text = ""


func _on_api_request_get_files_request_completed(_status_code: int, body: Array[String]) -> void:
    self.file_list.clear()
    self.file_list.add_item(".")
    for file in body:
        self.file_list.add_item(file)

    self.get_file_request.request(GameData.game.id, GameData.current_level_id, body[0])



func _on_api_request_get_file_request_completed(_status_code: int, body: ApiFile) -> void:
    self.puzzle.update_file(body)


func _on_api_request_get_level_request_completed(_status_code: int, body: ApiLevel) -> void:
    self.puzzle.set_level(body)


func _on_api_request_git_command_request_completed_with_editor_request(status_code: int, body: ApiEditorRequest) -> void:
    var basename: String = body.file.filename.split("/")[-1]
    var use_merge_editor: bool = false
    match basename:
        "COMMIT_EDITMSG", "git-rebase-todo", "TAG_EDITMSG", "NOTES_EDITMSG", "config", ".gitconfig":
            pass
        _:
            use_merge_editor = true

    self.puzzle.handle_editor_request(body, use_merge_editor)


func _on_api_request_git_command_request_completed_with_git_result(status_code: int, body: ApiGitResult) -> void:
    print("Stdout: " + body.stdout)
    print("Stderr: " + body.stderr)
    pass # TODO: update git graph


func _on_puzzle_editor_response_available(editor_response: ApiEditorResponse) -> void:
    print("_on_puzzle_editor_response_available")
    self.editor_response_request.request(GameData.game.id, GameData.current_level_id, editor_response)


func _on_api_request_editor_response_request_completed(status_code: int, body: ApiGitResult) -> void:
    pass # TODO: update git graph


func _on_puzzle_puzzle_solved() -> void:
    self.set_level_solved_request.request(GameData.game.id, GameData.current_level_id)


func _on_api_request_set_level_solved_request_completed(status_code: int) -> void:
    pass # TODO


func _on_puzzle_puzzle_reset() -> void:
    self.reset_level_request.request(GameData.game.id, GameData.current_level_id)


func _on_api_request_reset_level_request_completed(status_code: int, body: ApiLevel) -> void:
    pass # TODO: reload everything


func _on_puzzle_file_changed(file: ApiFile) -> void:
    self.update_file_request.request(GameData.game.id, GameData.current_level_id, file)


func _on_api_request_update_file_request_completed(status_code: int) -> void:
    pass # TODO


func _on_file_list_item_selected(index: int) -> void:
    var filename: String = self.file_list.get_item_text(index)
    if filename == ".":
        return
    self.get_file_request.request(GameData.game.id, GameData.current_level_id, filename)
