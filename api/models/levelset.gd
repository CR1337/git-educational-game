class_name ApiLevelset
extends ApiBaseModel

const type_: String = "Levelset"
var id: String

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "id": self.id
    }

static func from_dict(json_object: Dictionary) -> ApiLevelset:
    var result: ApiLevelset = ApiLevelset.new()

    result.id = json_object["id"]

    return result

static func deserialize(json_string: String) -> ApiLevelset:
    return ApiLevelset.from_dict(JSON.parse_string(json_string))


