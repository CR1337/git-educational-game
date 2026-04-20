class_name ApiRequestGetLevelsets
extends ApiRequest

const PATH: String = "/levelsets"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_GET

signal request_completed(status_code: int, body: Array[ApiLevelset])

func request() -> Error:
    return self._request(self.get_url(self.PATH))

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    var data: Array = JSON.parse_string(body.get_string_from_utf8())
    var levelsets: Array[ApiLevelset] = []
    for levelset_dict in data:
        levelsets.append(ApiLevelset.deserialize(JSON.stringify(levelset_dict)))
    emit_signal("request_completed", response_code, levelsets)
