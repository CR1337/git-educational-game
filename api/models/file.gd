class_name ApiFile
extends ApiBaseModel

const type_: String = "File"
var filename: String
var content: String

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "filename": self.filename,
        "content": self.content
    }

static func from_dict(json_object: Dictionary) -> ApiFile:
    var result: ApiFile = ApiFile.new()

    result.filename = json_object["filename"]
    result.content = json_object["content"]

    return result

static func deserialize(json_string: String) -> ApiFile:
    return ApiFile.from_dict(JSON.parse_string(json_string))
