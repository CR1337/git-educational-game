class_name ApiRequestNewGame
extends ApiRequest


const PATH: String = "/games/new"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_POST

signal request_completed(status_code: int, body: ApiGame)

func request(new_game_info: ApiNewGameInfo) -> Error:
    return self._request(self.get_url(self.PATH), new_game_info.serialize())

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    var game: ApiGame = ApiGame.deserialize(body.get_string_from_utf8())
    emit_signal("request_completed", response_code, game)