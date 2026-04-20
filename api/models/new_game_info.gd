class_name ApiNewGameInfo
extends ApiBaseModel

const type_: String = "NewGameInfo"
var player: ApiPlayer
var levelset: ApiLevelset

func as_dict() -> Dictionary:
    return {
        "type_": self.type_,
        "player": self.player.as_dict(),
        "levelset": self.levelset.as_dict()
    }

static func from_dict(json_object: Dictionary) -> ApiPlayer:
    var result: ApiPlayer = ApiPlayer.new()

    result.player = ApiPlayer.from_dict(json_object["name"])
    result.levelset = ApiLevelset.from_dict(json_object["levelset"])

    return result

static func deserialize(json_string: String) -> ApiPlayer:
    return ApiPlayer.from_dict(JSON.parse_string(json_string))

