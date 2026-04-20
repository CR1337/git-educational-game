class_name ApiEditorResponse
extends ApiBaseModel

const type_: String = "EditorResponse"
var id: String
var file: ApiFile
var abort: bool

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "id": self.id,
        "file": self.file.as_dict(),
        "abort": self.abort
    }

static func from_dict(json_object: Dictionary) -> ApiEditorResponse:
    var result: ApiEditorResponse = ApiEditorResponse.new()

    result.id = json_object["id"]
    result.file = ApiFile.from_dict(json_object["file"])
    result.abort = json_object["abort"]

    return result

static func deserialize(json_string: String) -> ApiEditorResponse:
    return ApiEditorResponse.from_dict(JSON.parse_string(json_string))
