class_name ApiGame
extends ApiBaseModel

const type_: String = "Game"
var id: String
var player: ApiPlayer
var levelset: ApiLevelset


func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "id": self.id,
        "player": self.player.as_dict(),
        "levelset": self.levelset.as_dict()
    }

static func from_dict(json_object: Dictionary) -> ApiGame:
    var result: ApiGame = ApiGame.new()

    result.id = json_object["id"]
    result.player = ApiPlayer.from_dict(json_object["player"])
    result.levelset = ApiLevelset.from_dict(json_object["levelset"])

    return result

static func deserialize(json_string: String) -> ApiGame:
    return ApiGame.from_dict(JSON.parse_string(json_string))
