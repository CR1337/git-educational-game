class_name ApiGitGraph
extends ApiBaseModel

const type_: String = "GitCommand"
var nodes: Array[String]
var children: Dictionary[String, Array]
var parents: Dictionary[String, Array]
var head: String
var tags: Dictionary[String, String]
var commit_messages: Dictionary[String, String]
var branch_names: Dictionary[String, String]

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "nodes": self.nodes,
        "children": self.children,
        "parents": self.parents,
        "head": self.head,
        "tags": self.tags,
        "commit_messages": self.commit_messages,
        "branch_names": self.branch_names
    }

static func from_dict(json_object: Dictionary) -> ApiGitGraph:
    var result: ApiGitGraph = ApiGitGraph.new()

    result.nodes = json_object["nodes"]
    result.children = json_object["children"]
    result.parents = json_object["parents"]
    result.head = json_object["head"]
    result.tags = json_object["tags"]
    result.commit_messages = json_object["commit_messages"]
    result.branch_names = json_object["branch_names"]

    return result

static func deserialize(json_string: String) -> ApiGitGraph:
    return ApiGitGraph.from_dict(JSON.parse_string(json_string))
