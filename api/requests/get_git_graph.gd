class_name ApiRequestGetGitGraph
extends ApiRequest

const PATH: String = "/games/{game_id}/levels/{level_id}/git-graph"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_GET

signal request_completed(status_code: int, body: ApiGitGraph)

func request(game_id: String, level_id: String) -> Error:
    return self._request(self.get_url(self.PATH.format({"game_id": game_id, "level_id": level_id})))

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    var level: ApiGitGraph = ApiGitGraph.deserialize(body.get_string_from_utf8())
    emit_signal("request_completed", response_code, level)