class_name ApiServerConfig
extends ApiBaseModel

const type_: String = "File"
var debug_mode: bool
var local: bool

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "debug_mode": self.debug_mode,
        "local": self.local
    }

static func from_dict(json_object: Dictionary) -> ApiBaseModel:
    var result: ApiServerConfig = ApiServerConfig.new()

    result.debug_mode = json_object["debug_mode"]
    result.local = json_object["local"]

    return result

static func deserialize(json_string: String) -> ApiBaseModel:
    return ApiServerConfig.from_dict(JSON.parse_string(json_string))
