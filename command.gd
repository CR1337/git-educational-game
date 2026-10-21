extends Node
class_name Command

@export var command: PuzzleVm.Command
@export var direction: Direction.Relative
@export var turn_direction: Direction.Turn
@export var tile: PuzzleVmState.Tile
@export_range(0, 255, 1) var number: int

func as_string() -> String:
	var result: String = ""
	
	match self.command:
		PuzzleVm.Command.MOVE:
			result += "move"
			result += " " + str(self.number)
		PuzzleVm.Command.TURN:
			result += "turn"
			result += " "
			match self.turn_direction:
				Direction.Turn.LEFT:
					result += "L"
				Direction.Turn.RIGHT:
					result += "R"
				Direction.Turn.BEHIND:
					result += "B"
		PuzzleVm.Command.PUT:
			result += "put"
			result += " "
			match self.direction:
				Direction.Relative.LEFT:
					result += "L"
				Direction.Relative.RIGHT:
					result += "R"
				Direction.Relative.FORWARD:
					result += "F"
				Direction.Relative.BEHIND:
					result += "B"
				Direction.Relative.HERE:
					result += "H"
		PuzzleVm.Command.REMOVE:
			result += "remove"
			result += " "
			match self.direction:
				Direction.Relative.LEFT:
					result += "L"
				Direction.Relative.RIGHT:
					result += "R"
				Direction.Relative.FORWARD:
					result += "F"
				Direction.Relative.BEHIND:
					result += "B"
				Direction.Relative.HERE:
					result += "H"
		PuzzleVm.Command.SCAN:
			result += "scan"
			result += " "
			match self.direction:
				Direction.Relative.LEFT:
					result += "L"
				Direction.Relative.RIGHT:
					result += "R"
				Direction.Relative.FORWARD:
					result += "F"
				Direction.Relative.BEHIND:
					result += "B"
				Direction.Relative.HERE:
					result += "H"
			result += " "
			match self.tile:
				PuzzleVmState.Tile.ROBOT:
					result += "robot"
				PuzzleVmState.Tile.BOX:
					result += "box"
				PuzzleVmState.Tile.MARK:
					result += "mark"
				PuzzleVmState.Tile.MARK1:
					result += "mark1"
				PuzzleVmState.Tile.MARK2:
					result += "mark2"
				PuzzleVmState.Tile.MARK3:
					result += "mark3"
				PuzzleVmState.Tile.MARK4:
					result += "mark4"
				PuzzleVmState.Tile.EMPTY:
					result += "empty"
				PuzzleVmState.Tile.WALL:
					result += "wall"
				PuzzleVmState.Tile.DESTINATION:
					result += "destination"
				PuzzleVmState.Tile.BUTTON:
					result += "button"
				PuzzleVmState.Tile.DOOR:
					result += "door"
		PuzzleVm.Command.SET:
			result += "set"
		PuzzleVm.Command.CLEAR:
			result += "clear"
		PuzzleVm.Command.TOGGLE:
			result += "toggle"
		PuzzleVm.Command.RANDOM:
			result += "random"
		PuzzleVm.Command.SWAP:
			result += "swap"
		PuzzleVm.Command.LABEL:
			result += "label"
			result += " " + str(self.number)
		PuzzleVm.Command.JUMP:
			result += "jump"
			result += " " + str(self.number)
		PuzzleVm.Command.BRANCH:
			result += "branch"
			result += " " + str(self.number)
		PuzzleVm.Command.NOP:
			result += "nop"
		
	return result
