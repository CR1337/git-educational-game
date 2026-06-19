extends LineEdit

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    return data is String


func _drop_data(_at_position: Vector2, data: Variant) -> void:
    print("_drop_data: " + data)
    if not data is String:
        return
    if self.text != "":
        self.text += " "