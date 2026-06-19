class_name ApiRequestGetLevels
extends ApiRequest

const PATH: String = "/games/{game_id}/levels"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_GET

signal request_completed(status_code: int, body: Array[ApiLevelNode])

func request(game_id: String) -> Error:
    return self._request(self.get_url(self.PATH.format({"game_id": game_id})))

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    var data: Array = JSON.parse_string(body.get_string_from_utf8())
    var level_nodes: Array[ApiLevelNode] = []
    for level_node_dict in data:
        level_nodes.append(ApiLevelNode.deserialize(JSON.stringify(level_node_dict)))
    emit_signal("request_completed", response_code, level_nodes)
