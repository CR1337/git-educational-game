class_name PuzzleVm
extends Node

enum Command {
	MOVE, TURN,
	PUT, REMOVE,
	SCAN,
	SET, CLEAR, TOGGLE, RANDOM, SWAP,
	LABEL, JUMP, BRANCH,
	NOP
}

@export var state: PuzzleVmState

var pi: int
var pcs: Array[int]
var commands: Array[Array]
var terminated: Array[bool]
var done: bool

signal robot_terminated(i: int)
signal all_terminated()
	
func _position_from_directions(origin: Vector2, absolute_direction: Direction.Absolute, relative_direction: Direction.Relative) -> Vector2:
	return Direction.move(origin, relative_direction, absolute_direction)	
	
func _scan_for_tile(tile: PuzzleVmState.Tile, static_tile: PuzzleVmState.Tile, dynamic_tiles: Array) -> bool:
	match tile:
		PuzzleVmState.Tile.ROBOT:
			for i in PuzzleVmState.MAX_ROBOT_AMOUNT:
				if PuzzleVmState.Tile.ROBOT + i in dynamic_tiles:
					return true
			return false
		PuzzleVmState.Tile.BOX:
			for i in PuzzleVmState.MAX_ROBOT_AMOUNT:
				if PuzzleVmState.Tile.BOX + i in dynamic_tiles:
					return true
			return false
		PuzzleVmState.Tile.MARK:
			for i in PuzzleVmState.MAX_ROBOT_AMOUNT:
				if PuzzleVmState.Tile.MARK + i in dynamic_tiles:
					return true
			return false
		PuzzleVmState.Tile.MARK1:
			return PuzzleVmState.Tile.MARK + 0 in dynamic_tiles
		PuzzleVmState.Tile.MARK2:
			return PuzzleVmState.Tile.MARK + 1 in dynamic_tiles
		PuzzleVmState.Tile.MARK3:
			return PuzzleVmState.Tile.MARK + 2 in dynamic_tiles
		PuzzleVmState.Tile.MARK4:
			return PuzzleVmState.Tile.MARK + 3 in dynamic_tiles
		PuzzleVmState.Tile.EMPTY:
			return static_tile & PuzzleVmState.TILE_TYPE_MASK == PuzzleVmState.Tile.EMPTY and dynamic_tiles.size() == 0
		PuzzleVmState.Tile.WALL:
			return static_tile & PuzzleVmState.TILE_TYPE_MASK  == PuzzleVmState.Tile.WALL
		PuzzleVmState.Tile.DESTINATION:
			return static_tile & PuzzleVmState.TILE_TYPE_MASK == PuzzleVmState.Tile.DESTINATION
		PuzzleVmState.Tile.BUTTON:
			return static_tile & PuzzleVmState.TILE_TYPE_MASK == PuzzleVmState.Tile.BUTTON
		PuzzleVmState.Tile.DOOR:
			return static_tile & PuzzleVmState.TILE_TYPE_MASK == PuzzleVmState.Tile.DOOR
	return false
	
func _jump_to(label_index: int) -> void:
	for i in self.commands[self.pi].size():
		if self.commands[self.pi][i].command == Command.LABEL:
			if self.commands[self.pi][i].number == label_index:
				self.pcs[self.pi] = i
				return

func initialize(program_descriptions: PackedStringArray) -> void:
	self.pi = 0
	self.done = false
	self.pcs = []
	self.commands = []
	self.terminated = []
	for i in self.state.MAX_ROBOT_AMOUNT:
		self.pcs.append(0)
		self.commands.append([])
		self.terminated.append(not self.state.get_robot_available(i))
		var parser: CommandParser = CommandParser.new()
		self.commands[i] = parser.parse(program_descriptions[i])
					
func step() -> void:
	if self.done:
		return 
		
	var command: Command = self.commands[self.pi][self.pcs[self.pi]]
	var robot_position: Vector2 = self.state.get_robot_position(self.pi)
	
	match command.command:
		Command.MOVE:
			var amount: int = command.number
			if self.pi == 1 and amount == 1:
				pass
			for i in amount:
				if not self.state.move_robot(self.pi):
					break
			
		Command.TURN:
			self.state.turn_robot(self.pi, command.turn_direction)
			
		Command.PUT:
			var pos: Vector2 = Direction.move(robot_position, command.direction, self.state.robot_directions[self.pi])
			self.state.put_mark(self.pi, pos.x, pos.y)
			
		Command.REMOVE:
			var pos: Vector2 = Direction.move(robot_position, command.direction, self.state.robot_directions[self.pi])
			self.state.remove_mark(pos.x , pos.y)
			
		Command.SCAN:
			var pos: Vector2 = Direction.move(robot_position, command.direction, self.state.robot_directions[self.pi])
			var static_tile: PuzzleVmState.Tile = self.state.get_static_tile(pos[0], pos[1])
			var dynamic_tiles: Array = self.state.get_dynamic_tiles(pos[0], pos[1])
			if self._scan_for_tile(command.tile, static_tile, dynamic_tiles):
				self.state.set_a_register(self.pi)
			else:
				self.state.clear_a_register(self.pi)
				
		Command.SET:
			self.state.set_a_register(self.pi)
			
		Command.CLEAR:
			self.state.clear_a_register(self.pi)
			
		Command.TOGGLE:
			self.state.toggle_a_register(self.pi)
			
		Command.RANDOM:
			self.state.randomize_a_register(self.pi)
			
		Command.SWAP:
			self.state.swap_registers(self.pi)
		
		Command.LABEL:
			pass
			
		Command.JUMP:
			self._jump_to(command.number)
			
		Command.BRANCH:
			if self.state.get_a_register(self.pi) == 1:
				self._jump_to(command.number)
				
		Command.NOP:
			pass
			
	self.pcs[self.pi] += 1
	if self.pcs[self.pi] >= self.commands[self.pi].size():
		if not self.terminated[self.pi]:
			terminated[self.pi] = true
			emit_signal("robot_terminated", self.pi)
	else:
		while self.commands[self.pi][self.pcs[self.pi]].command == Command.LABEL:
			self.pcs[self.pi] += 1
			if self.pcs[self.pi] >= self.commands[self.pi].size():
				if not self.terminated[self.pi]:
					terminated[self.pi] = true
					emit_signal("robot_terminated", self.pi)
			
	var all_have_terminated: bool = true
	for t in self.terminated:
		all_have_terminated = all_have_terminated and t
		
	if all_have_terminated:
		self.done = true
		emit_signal("all_terminated")
			
	self.pi = (self.pi + 1) % self.state.MAX_ROBOT_AMOUNT
	while not self.done and self.terminated[self.pi]:
		self.pi = (self.pi + 1) % self.state.MAX_ROBOT_AMOUNT
