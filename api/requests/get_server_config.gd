class_name ApiRequestGetServerConfig
extends ApiRequest

const PATH: String = "/server-config"
const METHOD: HTTPClient.Method = HTTPClient.METHOD_GET

signal request_completed(status_code: int, body: ApiServerConfig)

func request() -> Error:
    return self._request((self.get_url(self.PATH)))

func _request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if self._handle_failed_request(result, response_code):
        return

    var server_config: ApiServerConfig = ApiServerConfig.deserialize(body.get_string_from_utf8())
    emit_signal("request_completed", response_code, server_config)