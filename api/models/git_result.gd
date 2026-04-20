class_name ApiGitResult
extends ApiBaseModel

const type_: String = "GitResult"
var id: String
var returncode: int
var stdout: String
var stderr: String

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "id": self.id,
        "returncode": self.returncode,
        "stdout": self.stdout,
        "stderr": self.stderr
    }

static func from_dict(json_object: Dictionary) -> ApiGitResult:
    var result: ApiGitResult = ApiGitResult.new()

    result.id = json_object["id"]
    result.returncode = json_object["returncode"]
    result.stdout = json_object["stdout"]
    result.stderr = json_object["stderr"]

    return result

static func deserialize(json_string: String) -> ApiGitResult:
    return ApiGitResult.from_dict(JSON.parse_string(json_string))
