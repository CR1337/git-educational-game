class_name ApiRequestEditorResponse
extends ApiRequest

const PATH: String = "/games/{game_id}/levels/{level_id}/editor-response"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_POST

signal request_completed(status_code: int, body: ApiGitResult)

func request(game_id: String, level_id: String, editor_response: ApiEditorResponse) -> Error:
    return self._request(self.get_url(self.PATH.format({"game_id": game_id, "level_id": level_id})), editor_response.serialize())

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    var json_string: String = body.get_string_from_utf8()
    emit_signal("request_completed", response_code, ApiGitResult.deserialize(json_string))
