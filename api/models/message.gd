class_name ApiMessage
extends ApiBaseModel

const type_: String = "Message"
var name: String

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "name": self.name
    }

static func from_dict(json_object: Dictionary) -> ApiMessage:
    var result: ApiMessage = ApiMessage.new()

    result.name = json_object["name"]

    return result

static func deserialize(json_string: String) -> ApiMessage:
    return ApiMessage.from_dict(JSON.parse_string(json_string))
