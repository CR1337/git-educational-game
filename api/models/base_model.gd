@abstract
class_name ApiBaseModel
extends Resource

@abstract
func as_dict() -> Dictionary

func serialize() -> String:
    return JSON.stringify(self.as_dict())

static func from_dict(_json_object: Dictionary) -> ApiBaseModel:
    push_error("Tried to call a abstract method")
    return null

static func deserialize(_json_string: String) -> ApiBaseModel:
    push_error("Tried to call a abstract method")
    return null