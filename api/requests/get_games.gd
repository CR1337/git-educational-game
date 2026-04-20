class_name ApiRequestGetGames
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
    var games: Array[ApiGame] = []
    for game_dict in data:
        games.append(ApiGame.deserialize(JSON.stringify(game_dict)))
    emit_signal("request_completed", response_code, games)
