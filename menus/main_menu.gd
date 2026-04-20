extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass



func _on_info_button_button_up() -> void:
    get_tree().change_scene_to_file("res://menus/info_screen.tscn")


func _on_settings_button_button_up() -> void:
    get_tree().change_scene_to_file("res://menus/settings_menu.tscn")

func _on_play_button_button_up() -> void:
    get_tree().change_scene_to_file("res://menus/new_game_menu.tscn")


func _on_level_editor_button_button_up() -> void:
    pass # Replace with function body.
    # TODO
