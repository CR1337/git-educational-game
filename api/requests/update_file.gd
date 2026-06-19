class_name ApiRequestUpdateFile
extends ApiRequest

const PATH: String = "/games/{game_id}/levels/{level_id}/files/{filename}"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_PUT

signal request_completed(status_code: int)

func request(game_id: String, level_id: String, file: ApiFile) -> Error:
    var filename: String = file.filename.split("/")[-1]
    return self._request(self.get_url(self.PATH.format({"game_id": game_id, "level_id": level_id, "filename": filename})), file.serialize())

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    emit_signal("request_completed", response_code)