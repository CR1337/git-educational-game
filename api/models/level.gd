class_name ApiLevel
extends ApiBaseModel

const type_: String = "Level"
var id: String
var files: Array[ApiFile]
var map: ApiMap
var clues: Array[String]
var intro: String
var outro: String
var level_node: ApiLevelNode

func as_dict() -> Dictionary:
    var files_: Array[Dictionary] = []
    for file in self.files:
        files_.append(file.as_dict())

    return {
        "type_": self.type_,
        "id": self.id,
        "files": self.files,
        "map": self.map.as_dict(),
        "clues": self.clues,
        "intro": self.intro,
        "outro": self.outro,
        "level_node": self.level_node.as_dict()
    }

static func from_dict(json_object: Dictionary) -> ApiLevel:
    var result: ApiLevel = ApiLevel.new()

    result.id = json_object["id"]

    result.files = []
    for file in json_object["files"]:
        result.files.append(ApiFile.from_dict(file))

    result.map = ApiMap.from_dict(json_object["map"])
    result.clues = json_object["clues"]
    result.intro = json_object["intro"]
    result.outro = json_object["outro"]
    result.level_node = ApiLevelNode.from_dict(json_object["level_node"])

    return result

static func deserialize(json_string: String) -> ApiLevel:
    return ApiLevel.from_dict(JSON.parse_string(json_string))
