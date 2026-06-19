extends PanelContainer

@onready var get_level_graph_request: ApiRequestGetLevelGraph = $ApiRequestGetLevelGraph
@onready var graph_edit: GraphEdit = $GraphEdit

var selected_node: GraphNode = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.get_level_graph_request.request(GameData.game.id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass






func _on_graph_edit_node_deselected(_node: GraphNode) -> void:
    self.selected_node = null


func _on_graph_edit_node_selected(node: GraphNode) -> void:
    self.selected_node = node

func _on_graph_edit_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
            if self.selected_node != null:
                GameData.current_level_id = self.selected_node.title
                self.get_tree().change_scene_to_file("res://scenes/git_interface.tscn")




func _on_api_request_get_level_graph_request_failed(result: int, status_code: int) -> void:
    pass # TODO

func _on_api_request_get_level_graph_request_completed(status_code: int, body: ApiLevelGraph) -> void:
    var nodes: Dictionary[String, GraphNode] = {}

    for start_level in body.start_levels:
        var node: GraphNode = GraphNode.new()
        node.title = start_level.id
        nodes[start_level.id] = node
        self.graph_edit.add_child(node)

    for source_level_id in body.edges:
        var target_level_nodes: Array[ApiLevelNode] = body.edges[source_level_id]
        for target_level_node in target_level_nodes:
            var node: GraphNode = GraphNode.new()
            node.title = target_level_node.id
            nodes[target_level_node.id] = node
            self.graph_edit.add_child(node)

    for source_level_id in body.edges:
        var target_level_nodes: Array[ApiLevelNode] = body.edges[source_level_id]
        for target_level_node in target_level_nodes:
            self.graph_edit.connect_node(source_level_id, 0, target_level_node.id, 0)

    self.graph_edit.arrange_nodes()



