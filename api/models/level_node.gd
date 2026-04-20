class_name ApiLevelNode
extends ApiBaseModel

const type_: String = "LevelNode"
var id: String
var name: String
var started: bool
var solved: bool

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "id": self.id,
        "name": self.name,
        "started": self.started,
        "solved": self.solved
    }

static func from_dict(json_object: Dictionary) -> ApiLevelNode:
    var result: ApiLevelNode = ApiLevelNode.new()

    result.id = json_object["id"]
    result.name = json_object["name"]
    result.started = json_object["started"]
    result.solved = json_object["solved"]

    return result

static func deserialize(json_string: String) -> ApiLevelNode:
    return ApiLevelNode.from_dict(JSON.parse_string(json_string))
