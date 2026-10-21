extends Node
class_name CommandParser

func _turn_direction_from_string(string: String) -> Direction.Turn:
	match string:
		"L":
			return Direction.Turn.LEFT
		"R":
			return Direction.Turn.RIGHT
		"B":
			return Direction.Turn.BEHIND
		_:
			return Direction.Turn.NONE

func _direction_from_string(string: String) -> Direction.Relative:
	match string:
		"L":
			return Direction.Relative.LEFT
		"R":
			return Direction.Relative.RIGHT
		"F":
			return Direction.Relative.FORWARD
		"B":
			return Direction.Relative.BEHIND
		"H":
			return Direction.Relative.HERE
		_:
			return Direction.Relative.NONE
	
func _tile_from_string(string: String) -> PuzzleVmState.Tile:
	match string:
		"robot":
			return PuzzleVmState.Tile.ROBOT
		"box":
			return PuzzleVmState.Tile.BOX
		"mark":
			return PuzzleVmState.Tile.MARK
		"mark1":
			return PuzzleVmState.Tile.MARK1
		"mark2":
			return PuzzleVmState.Tile.MARK2
		"mark3":
			return PuzzleVmState.Tile.MARK3
		"mark4":
			return PuzzleVmState.Tile.MARK4
		"empty":
			return PuzzleVmState.Tile.EMPTY
		"wall":
			return PuzzleVmState.Tile.WALL
		"destination":
			return PuzzleVmState.Tile.DESTINATION
		"button":
			return PuzzleVmState.Tile.BUTTON
		"door":
			return PuzzleVmState.Tile.DOOR
	return PuzzleVmState.Tile.EMPTY

func parse(program: String) -> Array[Command]:
	var commands: Array[Command] = []
	var lines: PackedStringArray = program.rsplit("\n", false, 0)
	
	for line in lines:
		var components: PackedStringArray = line.rsplit(" ", false, 3)
		var command_str = components[0]
		var paramteter_strs = components.slice(1)
		
		var command: Command = Command.new()
		command.command = PuzzleVm.Command.NOP
		command.direction = Direction.Relative.NONE
		command.turn_direction = Direction.Turn.NONE
		command.tile = PuzzleVmState.Tile.EMPTY
		command.number = 0
		
		match command_str:
			"move":
				command.command = PuzzleVm.Command.MOVE
				command.number = int(paramteter_strs[0])
			"turn":
				command.command = PuzzleVm.Command.TURN
				command.turn_direction = _turn_direction_from_string(paramteter_strs[0])
				
			"put":
				command.command = PuzzleVm.Command.PUT
				command.direction = _direction_from_string(paramteter_strs[0])
			"remove":
				command.command = PuzzleVm.Command.REMOVE
				command.direction = _direction_from_string(paramteter_strs[0])
				
			"scan":
				command.command = PuzzleVm.Command.SCAN
				command.direction = _direction_from_string(paramteter_strs[0])
				command.tile = _tile_from_string(paramteter_strs[1])
				
			"set":
				command.command = PuzzleVm.Command.SET
			"clear":
				command.command = PuzzleVm.Command.CLEAR
			"toggle":
				command.command = PuzzleVm.Command.TOGGLE
			"random":
				command.command = PuzzleVm.Command.RANDOM
			"swap":
				command.command = PuzzleVm.Command.SWAP
				
			"label":
				command.command = PuzzleVm.Command.LABEL
				command.number = int(paramteter_strs[0])
			"jump":
				command.command = PuzzleVm.Command.JUMP
				command.number = int(paramteter_strs[0])
			"branch":
				command.command = PuzzleVm.Command.BRANCH
				command.number = int(paramteter_strs[0])
		
			"nop":
				command.command = PuzzleVm.Command.NOP
				
		commands.append(command)
		
	return commands
