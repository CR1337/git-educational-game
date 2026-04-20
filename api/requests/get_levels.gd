class_name ApiRequestGetLevels
extends ApiRequest

const PATH: String = "/games"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_GET

signal request_completed(status_code: int, body: Array[ApiGame])

func request() -> Error:
    return self._request(self.get_url(self.PATH))

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    var data: Array[Dictionary] = JSON.parse_string(body.get_string_from_utf8())
    var level_nodes: Array[ApiLevelNode] = []
    for level_node_dict in data:
        level_nodes.append(ApiLevelNode.deserialize(JSON.stringify(level_node_dict)))
    emit_signal("request_completed", response_code, level_nodes)
