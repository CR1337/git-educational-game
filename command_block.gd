@tool
class_name CommandBlock
extends Control

const MNEMONICS: Dictionary[PuzzleVm.Command, String] = {
	PuzzleVm.Command.MOVE: "MOVE",  
	PuzzleVm.Command.TURN: "TURN", 
	PuzzleVm.Command.PUT: "PUT",  
	PuzzleVm.Command.REMOVE: "REMOVE", 
	PuzzleVm.Command.SCAN: "SCAN", 
	PuzzleVm.Command.SET: "SET",  
	PuzzleVm.Command.CLEAR: "CLEAR",  
	PuzzleVm.Command.TOGGLE: "TOGGLE", 
	PuzzleVm.Command.RANDOM: "RANDOM",  
	PuzzleVm.Command.SWAP: "SWAP", 
	PuzzleVm.Command.LABEL: "LABEL",  
	PuzzleVm.Command.JUMP: "JUMP",  
	PuzzleVm.Command.BRANCH: "BRANCH", 
	PuzzleVm.Command.NOP: "NOP",
}

const COLORS: Dictionary[PuzzleVm.Command, Color] = {
	PuzzleVm.Command.MOVE: Color.ORANGE,  
	PuzzleVm.Command.TURN: Color.ORANGE, 
	PuzzleVm.Command.PUT: Color.WEB_GREEN,  
	PuzzleVm.Command.REMOVE: Color.WEB_GREEN, 
	PuzzleVm.Command.SCAN: Color.DARK_VIOLET, 
	PuzzleVm.Command.SET: Color.CADET_BLUE,  
	PuzzleVm.Command.CLEAR: Color.CADET_BLUE,  
	PuzzleVm.Command.TOGGLE: Color.CADET_BLUE, 
	PuzzleVm.Command.RANDOM: Color.CADET_BLUE,  
	PuzzleVm.Command.SWAP: Color.CADET_BLUE, 
	PuzzleVm.Command.LABEL: Color.WEB_GRAY,  
	PuzzleVm.Command.JUMP: Color.PALE_VIOLET_RED,  
	PuzzleVm.Command.BRANCH: Color.PALE_VIOLET_RED, 
	PuzzleVm.Command.NOP: Color.FLORAL_WHITE,
}

const HAS_TURN_DIRECTION: Dictionary[PuzzleVm.Command, bool] = {
	PuzzleVm.Command.MOVE: false,  
	PuzzleVm.Command.TURN: true, 
	PuzzleVm.Command.PUT: false,  
	PuzzleVm.Command.REMOVE: false, 
	PuzzleVm.Command.SCAN: false, 
	PuzzleVm.Command.SET: false,  
	PuzzleVm.Command.CLEAR: false,  
	PuzzleVm.Command.TOGGLE: false, 
	PuzzleVm.Command.RANDOM: false,  
	PuzzleVm.Command.SWAP: false, 
	PuzzleVm.Command.LABEL: false,  
	PuzzleVm.Command.JUMP: false,  
	PuzzleVm.Command.BRANCH: false, 
	PuzzleVm.Command.NOP: false,
}

const HAS_DIRECTION: Dictionary[PuzzleVm.Command, bool] = {
	PuzzleVm.Command.MOVE: false,  
	PuzzleVm.Command.TURN: false, 
	PuzzleVm.Command.PUT: true,  
	PuzzleVm.Command.REMOVE: true, 
	PuzzleVm.Command.SCAN: true, 
	PuzzleVm.Command.SET: false,  
	PuzzleVm.Command.CLEAR: false,  
	PuzzleVm.Command.TOGGLE: false, 
	PuzzleVm.Command.RANDOM: false,  
	PuzzleVm.Command.SWAP: false, 
	PuzzleVm.Command.LABEL: false,  
	PuzzleVm.Command.JUMP: false,  
	PuzzleVm.Command.BRANCH: false, 
	PuzzleVm.Command.NOP: false,
}

const HAS_TILE: Dictionary[PuzzleVm.Command, bool] = {
	PuzzleVm.Command.MOVE: false,  
	PuzzleVm.Command.TURN: false, 
	PuzzleVm.Command.PUT: false,  
	PuzzleVm.Command.REMOVE: false, 
	PuzzleVm.Command.SCAN: true, 
	PuzzleVm.Command.SET: false,  
	PuzzleVm.Command.CLEAR: false,  
	PuzzleVm.Command.TOGGLE: false, 
	PuzzleVm.Command.RANDOM: false,  
	PuzzleVm.Command.SWAP: false, 
	PuzzleVm.Command.LABEL: false,  
	PuzzleVm.Command.JUMP: false,  
	PuzzleVm.Command.BRANCH: false, 
	PuzzleVm.Command.NOP: false,
}

const HAS_NUMBER: Dictionary[PuzzleVm.Command, bool] = {
	PuzzleVm.Command.MOVE: true,  
	PuzzleVm.Command.TURN: false, 
	PuzzleVm.Command.PUT: false,  
	PuzzleVm.Command.REMOVE: false, 
	PuzzleVm.Command.SCAN: false, 
	PuzzleVm.Command.SET: false,  
	PuzzleVm.Command.CLEAR: false,  
	PuzzleVm.Command.TOGGLE: false, 
	PuzzleVm.Command.RANDOM: false,  
	PuzzleVm.Command.SWAP: false, 
	PuzzleVm.Command.LABEL: true,  
	PuzzleVm.Command.JUMP: true,  
	PuzzleVm.Command.BRANCH: true, 
	PuzzleVm.Command.NOP: false,
}

@onready var color_rect: ColorRect = $ColorRect
@onready var mnemonic_label: Label = $HFlowContainer/MnemonicLabel
@onready var turn_direction_option_button: OptionButton = $HFlowContainer/TurnDirectionOptionButton
@onready var direction_option_button: OptionButton = $HFlowContainer/DirectionOptionButton
@onready var tile_option_button: OptionButton = $HFlowContainer/TileOptionButton
@onready var spin_box: SpinBox = $HFlowContainer/SpinBox

var _is_ready: bool = false

var _command: Command
@export var command: Command:
	get:
		return _command
	set(value):
		_command = value
		if _is_ready:
			_update_appearance()
			
@export var enable_drag_n_drop: bool
		
func _ready() -> void:
	self._is_ready = true
	self._update_appearance()
		
func _update_appearance() -> void:
	self.color_rect.color = self.COLORS[self._command.command]
	self.mnemonic_label.text = self.MNEMONICS[self._command.command]
	self.turn_direction_option_button.visible = self.HAS_TURN_DIRECTION[self._command.command]
	self.direction_option_button.visible = self.HAS_DIRECTION[self._command.command]
	self.tile_option_button.visible = self.HAS_TILE[self._command.command]
	self.spin_box.visible = self.HAS_NUMBER[self._command.command]

func get_turn_direction() -> Direction.Turn:
	if not self.HAS_TURN_DIRECTION[self._command.command]:
		return Direction.Turn.NONE
	return (self.turn_direction_option_button.selected + 1) as Direction.Turn
	
func set_turn_direction(turn_direction: Direction.Turn) -> void:
	self.turn_direction_option_button.selected = (turn_direction as int) - 1
	
func get_direction() -> Direction.Relative:
	if not self.HAS_DIRECTION[self._command.command]:
		return Direction.Relative.NONE
	return (self.direction_option_button.selected + 1) as Direction.Relative
	
func set_direction(direction: Direction.Relative) -> void:
	self.direction_option_button.selected = (direction as int) - 1
	
func get_tile() -> PuzzleVmState.Tile:
	if not self.HAS_TILE[self._command.command]:
		return PuzzleVmState.Tile.EMPTY
	return [
		PuzzleVmState.Tile.ROBOT, 
		PuzzleVmState.Tile.BOX, 
		PuzzleVmState.Tile.MARK, 
		PuzzleVmState.Tile.MARK1, 
		PuzzleVmState.Tile.MARK2, 
		PuzzleVmState.Tile.MARK3, 
		PuzzleVmState.Tile.MARK4, 
		PuzzleVmState.Tile.EMPTY, 
		PuzzleVmState.Tile.WALL, 
		PuzzleVmState.Tile.DESTINATION, 
		PuzzleVmState.Tile.BUTTON, 
		PuzzleVmState.Tile.DOOR
	][self.tile_option_button.selected]
	
func set_tile(tile: PuzzleVmState.Tile) -> void:
	self.tile_option_button.selected = [
		PuzzleVmState.Tile.ROBOT, 
		PuzzleVmState.Tile.BOX, 
		PuzzleVmState.Tile.MARK, 
		PuzzleVmState.Tile.MARK1, 
		PuzzleVmState.Tile.MARK2, 
		PuzzleVmState.Tile.MARK3, 
		PuzzleVmState.Tile.MARK4, 
		PuzzleVmState.Tile.EMPTY, 
		PuzzleVmState.Tile.WALL, 
		PuzzleVmState.Tile.DESTINATION, 
		PuzzleVmState.Tile.BUTTON, 
		PuzzleVmState.Tile.DOOR
	].find(tile)
	
func get_number() -> int:
	if not self.HAS_NUMBER[self._command.command]:
		return -1
	return int(self.spin_box.value)
	
func set_number(number: int) -> void:
	self.spin_box.value = number
	
func _get_drag_data(at_position: Vector2) -> Variant:
	if not self.enable_drag_n_drop:
		return null
	
	var preview: CommandBlock = preload("res://command_block.tscn").instantiate()
	preview.command = self.command
	preview.size = self.size
	
	var drag_data: CommandBlockDragData = CommandBlockDragData.new(self.get_parent(), self._command, self, preview)
	
	self.set_drag_preview(preview)
	
	return drag_data
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not self.enable_drag_n_drop:
		return false
	return data is CommandBlockDragData
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var parent: Control = self.get_parent_control()
	var _global_position: Vector2 = self.get_global_transform().origin + at_position
	var position_at_parent: Vector2 = parent.get_global_transform().affine_inverse() * _global_position
	self.get_parent().handle_drop_data(position_at_parent, data as CommandBlockDragData)
