class_name ApiEditorRequest
extends ApiBaseModel

const type_: String = "EditorRequest"
var id: String
var file: ApiFile
var stdout: String
var stderr: String

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "id": self.id,
        "file": self.file.as_dict(),
        "stdout": self.stdout,
        "stderr": self.stderr
    }

static func from_dict(json_object: Dictionary) -> ApiEditorRequest:
    var result: ApiEditorRequest = ApiEditorRequest.new()

    result.id = json_object["id"]
    result.file = ApiFile.from_dict(json_object["file"])
    result.stdout = json_object["stdout"]
    result.stdin = json_object["stdin"]

    return result


static func deserialize(json_string: String) -> ApiEditorRequest:
    return ApiEditorRequest.from_dict(JSON.parse_string(json_string))