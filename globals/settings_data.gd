extends Node

enum Language { DE, EN }

const LOCAL_API_ADDRESS: String = "http://localhost:8080"
const SERVER_API_ADDRESS: String = "https://www.hpi.uni-potsdam.de/hirschfeld/gitgame"

var api_address: String = LOCAL_API_ADDRESS

var language: Language = Language.DE

var server_config: ApiServerConfig

var get_server_config_request: ApiRequestGetServerConfig

func _ready() -> void:
    self.get_server_config_request = ApiRequestGetServerConfig.new()
    self.add_child(self.get_server_config_request)
    self.get_server_config_request.request_completed.connect(self._get_server_config_request_completed)
    self.get_server_config_request.request()


func _get_server_config_request_completed(_status_code: int, body: ApiServerConfig) -> void:
    self.server_config = body
    if self.server_config.local:
        self.api_address = self.LOCAL_API_ADDRESS
    else:
        self.api_address = self.SERVER_API_ADDRESS