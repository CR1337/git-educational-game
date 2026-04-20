extends PanelContainer

@onready var vbox_container: VBoxContainer = $VBoxContainer
@onready var player_name_line_edit: LineEdit = $VBoxContainer/PlayerNameContainer/PlayerNameLineEdit
@onready var levelset_option_button: OptionButton = $VBoxContainer/LevelsetContainer/LevelsetOptionButton
@onready var new_game_request: ApiRequestNewGame = $ApiRequestNewGame
@onready var get_levelsets_request: ApiRequestGetLevelsets = $ApiRequestGetLevelsets
@onready var loading_screen: LoadingScreen = $LoadingScreen


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var err = self.get_levelsets_request.request()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass



func _on_api_request_new_game_request_failed(result: int, status_code: int) -> void:
    self.loading_screen.display_error(tr("LOC_COMMUNICATION_ERROR") + ", result: " + str(result) + ", status_code: " + str(status_code))

func _on_api_request_new_game_request_completed(_status_code: int, body: ApiGame) -> void:
    GameData.game = body
    self.get_tree().change_scene_to_file("res://scenes/level_selection.tscn")


func _on_start_game_button_button_up() -> void:
    var player: ApiPlayer = ApiPlayer.new()
    player.name = self.player_name_line_edit.text
    var new_game_info: ApiNewGameInfo = ApiNewGameInfo.new()
    new_game_info.player = player
    new_game_info.levelset = ApiLevelset.new()
    new_game_info.levelset.id = self.levelset_option_button.get_item_text(self.levelset_option_button.selected)

    var err = self.new_game_request.request(new_game_info)
    if err == OK:
        self.loading_screen.visible = true
        self.vbox_container.hide()



func _on_loading_screen_back_button_pressed() -> void:
    self.vbox_container.visible = true
    self.loading_screen.hide()



func _on_api_request_get_levelsets_request_failed(_result: int, _status_code: int) -> void:
    self.levelset_option_button.add_item("main")

func _on_api_request_get_levelsets_request_completed(_status_code: int, body: Array[ApiLevelset]) -> void:
    for levelset in body:
        self.levelset_option_button.add_item(levelset.id)
