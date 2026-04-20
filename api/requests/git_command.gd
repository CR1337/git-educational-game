class_name ApiRequestGitCommand
extends ApiRequest


const PATH: String = "/games/{game_id}/levels/{level_id}/git-command"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_POST

signal request_completed_with_git_result(status_code: int, body: ApiGitResult)
signal request_completed_with_editor_request(status_code: int, body: ApiEditorRequest)

func request(game_id: String, level_id: String, git_command: ApiGitCommand) -> Error:
    return self._request(self.get_url(self.PATH.format({"game_id": game_id, "level_id": level_id})), git_command.serialize())

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    var json_string: String = body.get_string_from_utf8()
    var data: Dictionary = JSON.parse_string(json_string)
    match data["type_"]:
        "GitResult":
            emit_signal("request_completed_with_git_result", response_code, ApiGitResult.deserialize(json_string))

        "EditorRequest":
            emit_signal("request_completed_with_editor_request", response_code, ApiEditorRequest.deserialize(json_string))