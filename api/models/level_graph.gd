class_name ApiLevelGraph
extends ApiBaseModel

const type_: String = "LevelGraph"
var start_levels: Array[ApiLevelNode]
var edges: Dictionary[String, Array]  # Array of ApiLevelNode

func as_dict() -> Dictionary:
    var start_levels_: Array[Dictionary] = []
    for level in self.start_levels:
        start_levels_.append(level.as_dict())

    var edges_: Dictionary[String, Array] = {}
    for level_id in edges:
        edges_[level_id] = []
        for level_node in self.edges[level_id]:
            edges_[level_id].append(level_node.as_dict())

    return {
        "type_": self.type_,
        "start_levels": start_levels_,
        "edges": edges_
    }

static func from_dict(json_object: Dictionary) -> ApiLevelGraph:
    var result: ApiLevelGraph = ApiLevelGraph.new()

    result.start_levels = []
    for level in json_object["start_levels"]:
        result.start_levels.append(ApiLevelNode.from_dict(level))

    result.edges = {}
    for level_id in json_object["edges"]:
        result.edges[level_id] = []
        for level_node in json_object["edges"][level_id]:
            result.edges[level_id].append(ApiLevelNode.from_dict(level_node))

    return result

static func deserialize(json_string: String) -> ApiLevelGraph:
    return ApiLevelGraph.from_dict(JSON.parse_string(json_string))
