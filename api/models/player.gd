class_name ApiPlayer
extends ApiBaseModel

const type_: String = "Player"
var name: String

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "name": self.name
    }

static func from_dict(json_object: Dictionary) -> ApiPlayer:
    var result: ApiPlayer = ApiPlayer.new()

    result.name = json_object["name"]
    return result

static func deserialize(json_string: String) -> ApiPlayer:
    return ApiPlayer.from_dict(JSON.parse_string(json_string))
