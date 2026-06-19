class_name ApiGitCommand
extends ApiBaseModel

const type_: String = "GitCommand"
var argv: Array

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "argv": self.argv
    }

static func from_dict(json_object: Dictionary) -> ApiGitCommand:
    var result: ApiGitCommand = ApiGitCommand.new()

    result.argv = json_object["argv"]

    return result

static func deserialize(json_string: String) -> ApiGitCommand:
    return ApiGitCommand.from_dict(JSON.parse_string(json_string))
