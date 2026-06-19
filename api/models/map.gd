class_name ApiMap
extends ApiBaseModel

const type_: String = "Map"
var id: String
var width: int
var height: int
var content: String
var patches: Array

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "id": self.id,
        "width": self.width,
        "height": self.height,
        "content": self.content,
        "patches": self.patches
    }

static func from_dict(json_object: Dictionary) -> ApiMap:
    var result: ApiMap = ApiMap.new()

    result.id = json_object["id"]
    result.width = json_object["width"]
    result.height = json_object["height"]
    result.content = json_object["content"]
    result.patches = json_object["patches"]

    return result

static func deserialize(json_string: String) -> ApiMap:
    return ApiMap.from_dict(JSON.parse_string(json_string))
