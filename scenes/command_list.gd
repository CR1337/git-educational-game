extends ItemList

var selected_index: int

func _get_drag_data(_at_position: Vector2) -> Variant:
    var data: String = self.get_item_text(self.selected_index)
    print("_get_drag_data: " + data)
    var preview_label: Label = Label.new()
    preview_label.text = data
    set_drag_preview(preview_label)
    return data

func _on_item_selected(index: int) -> void:
    self.selected_index = index
