extends Control

@onready var address_text_edit: TextEdit = $Panels/CenterPanel/TabBar/DebugContainer/AddressTextEdit
@onready var file_tab_container: TabContainer = $Panels/CenterPanel/TabBar/DebugContainer/FileTabContainer
@onready var map_text_edit: TextEdit = $Panels/CenterPanel/TabBar/DebugContainer/MapTextEdit
@onready var metadata_text_edit: TextEdit = $Panels/CenterPanel/TabBar/DebugContainer/MetadataTextEdit

# HTTP Requests
var get_levels_request: HTTPRequest
var new_game_request: HTTPRequest
var get_level_request: HTTPRequest

var game_id: String
var level_id: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.get_levels_request = HTTPRequest.new()
    self.add_child(self.get_levels_request)
    self.get_levels_request.request_completed.connect(self._get_levels_request_completed)

    self.new_game_request = HTTPRequest.new()
    self.add_child(self.new_game_request)
    self.new_game_request.request_completed.connect(self._new_game_request_completed)

    self.get_level_request = HTTPRequest.new()
    self.add_child(self.get_level_request)
    self.get_level_request.request_completed.connect(self._get_level_request_completed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _get_levels_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    var response: Array = JSON.parse_string(body.get_string_from_utf8())
    print(response)
    self.level_id = response[0]["id"]

    var address: String = self.address_text_edit.text + "/games/" + self.game_id + "/levels/" + self.level_id
    var error = self.get_level_request.request(address, [], HTTPClient.METHOD_GET)
    if error != OK:
        print("An error accoured")

func _get_level_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    var response = JSON.parse_string(body.get_string_from_utf8())
    print(response)

    self.map_text_edit.text = response["map"]["content"]
    self.metadata_text_edit.text = JSON.stringify(response["level_node"])



func _new_game_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
    var response = JSON.parse_string(body.get_string_from_utf8())
    print(response)
    self.game_id = response["id"]

    var address: String = self.address_text_edit.text + "/games/" + self.game_id + "/levels"
    var error = self.get_levels_request.request(address, [], HTTPClient.METHOD_GET)
    if error != OK:
        print("An error accoured")


func _on_request_button_button_up() -> void:
    var address: String = self.address_text_edit.text + "/games/new"
    var player: Dictionary = {
        "type_": "Player",
        "name": "player"
    }
    var player_str: String = JSON.stringify(player)
    print(player_str)
    var error = self.new_game_request.request(address, ["Content-Type: application/json"], HTTPClient.METHOD_POST, player_str)
    if error != OK:
        print("An error accoured")
