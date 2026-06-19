@abstract
class_name ApiRequest
extends Node

const CUSTOM_HEADERS: PackedStringArray = [
    "Content-Type: application/json"
]

var http_request: HTTPRequest
@export var timeout: float = 10.0  # s

signal request_failed(result: int, status_code: int)

func _ready() -> void:
    self.http_request = HTTPRequest.new()
    self.add_child(self.http_request)
    self.http_request.request_completed.connect(self._request_completed)

func _request(url: String, body: String = "") -> Error:
    self.http_request.timeout = self.timeout
    return self.http_request.request(
        url,
        self.CUSTOM_HEADERS,
        self.METHOD,
        body
    )

func get_url(path: String) -> String:
    if path.begins_with("http"):
        return path
    else:
        return SettingsData.api_address + "/api" + path

func _handle_failed_request(result: int, status_code: int) -> bool:
    if result != 0 or status_code >= 300:
        emit_signal("request_failed", result, status_code)
        return true
    return false


@abstract
func _request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void