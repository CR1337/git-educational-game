class_name PuzzleVmState
extends Node

const MAX_BUTTON_AMOUNT: int = 16
const MAX_ROBOT_AMOUNT: int = 4

enum Tile {
	ROBOT       = 0b00010000,
	BOX         = 0b00100000,
	MARK        = 0b00110000,
	MARK1       = 0b01000000,
	MARK2       = 0b01000001,
	MARK3       = 0b01000010,
	MARK4       = 0b01000011,
	EMPTY       = 0b01010000,
	WALL        = 0b01100000,
	DESTINATION = 0b01110000,
	BUTTON      = 0b10000000,
	DOOR        = 0b10010000
}

const TILE_TYPE_MASK: int = 0b11110000
const TILE_INDEX_MASK: int = 0b00001111

const TILE_IS_MOVABLE: Dictionary[Tile, bool] = {
	ROBOT       = true,
	BOX         = true,
	MARK        = false,
	EMPTY       = false,
	WALL        = false,
	DESTINATION = false,
	BUTTON      = false,
	DOOR        = false
}

const TILE_IS_DYNAMIC: Dictionary[Tile, bool] = {
	ROBOT       = true,
	BOX         = true,
	MARK        = true,
	EMPTY       = false,
	WALL        = false,
	DESTINATION = false,
	BUTTON      = false,
	DOOR        = false
}

enum AbsoluteDirection {
	 NORTH, EAST, WEST, SOUTH
}

enum RelativeDirection {
	LEFT, RIGHT, FORWARD, BELOW
}

enum TurnDirection {
	LEFT, RIGHT
}

const ABSOLUTE_DIRECTION_NORTH: Vector2 = Vector2( 0, -1)
const ABSOLUTE_DIRECTION_EAST:  Vector2 = Vector2( 1,  0)
const ABSOLUTE_DIRECTION_SOUTH: Vector2 = Vector2( 0,  1)
const ABSOLUTE_DIRECTION_WEST:  Vector2 = Vector2(-1,  0)

const RELATIVE_DIRECTION_LEFT:    Vector2 = Vector2(-1,  0)
const RELATIVE_DIRECTION_RIGHT:   Vector2 = Vector2( 1,  0)
const RELATIVE_DIRECTION_FORWARD: Vector2 = Vector2( 0, -1)
const RELATIVE_DIRECTION_BELOW:   Vector2 = Vector2( 0,  0)

const TURN_DIRECTION_LEFT: int = 0
const TURN_DIRECTION_RIGHT: int = 1
const TURN_DIRECTION_ANGLES: Array[float] = [PI / 2, -PI / 2]

const MAX_MAP_WIDTH: int = 16
const MAX_MAP_HEIGHT: int = 16

var map_width: int
var map_height: int
var static_map: Array[Array]  # Array of Array of Tile
var dynamic_map: Array[Array]  # Array of Array of Array of Tile

var robot_positions: Array[Vector2]
var robot_directions: Array[Direction.Absolute]
var robot_available: Array[bool]

var button_states: Array[bool]
var button_available: Array[bool]
var button_amount: int
var destination_amount: int

var a_registers: Array[int]
var b_registers: Array[int]

signal robot_moved(i: int, source_x: int, source_y: int, target_x: int, target_y: int)
signal robot_turned(i: int, direction: Direction.Turn)
signal box_moved(source_x: int, source_y: int, target_x: int, target_y: int)
signal mark_placed(i: int, x: int, y: int)
signal mark_removed(x: int, y: int)
signal button_changed(state: bool, i: int, buttons_xs: Array[int], button_ys: Array[int], door_xs: Array[int], door_ys: Array[int])
signal a_register_changed(i: int, v: int)
signal b_register_changed(i: int, v: int)

func initialize(map_description: String) -> void:
	var lines: PackedStringArray = map_description.rsplit("\n", false, 0)
	
	var width_height: PackedStringArray = lines[0].rsplit(" ", false, 2)
	self.map_width = int(width_height[0])
	self.map_height = int(width_height[1])
	self.dynamic_map = []
	self.static_map = []
	
	self.button_amount = 0
	self.destination_amount = 0
	self.button_states = []
	self.button_available = []
	for i in self.MAX_BUTTON_AMOUNT:
		self.button_states.append(false)
		self.button_available.append(false)
	
	var grid: PackedStringArray = lines.slice(1, self.map_height + 2)
	for y in self.map_height:
		self.dynamic_map.append([])
		self.static_map.append([])
		for x in self.map_width:
			self.dynamic_map.append([])
			self.dynamic_map[y].append([])
			var tile_str: String = grid[y][x]
			match tile_str:
				".":
					self.static_map[y].append(Tile.EMPTY)
				"#":
					self.static_map[y].append(Tile.WALL)
				"*":
					self.static_map[y].append(Tile.DESTINATION)
					self.destination_amount += 1
				"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p":
					var button_index: int = ord(tile_str) - ord("a")
					self.static_map[y].append(Tile.BUTTON + button_index)
					self.button_available[button_index] = true
					self.button_amount += 1
				"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P":
					self.static_map[y].append(Tile.DOOR + ord(tile_str) - ord("A"))
					
	self.robot_positions = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
	self.robot_directions = [Direction.Absolute.NORTH, Direction.Absolute.NORTH, Direction.Absolute.NORTH, Direction.Absolute.NORTH]
	self.robot_available = [false, false, false, false]
	var movables_strings: PackedStringArray = lines.slice(self.map_height + 1)
	for movables_string in movables_strings:
		var x_y_tile: PackedStringArray = movables_string.rsplit(" ", false, 3)
		var x: int = int(x_y_tile[0])
		var y: int = int(x_y_tile[1])
		var tile_str: String = x_y_tile[2]
		match tile_str:
			"+":
				self.dynamic_map[y][x].append(Tile.BOX)
			"1", "2", "3", "4":
				var robot_index: int = int(tile_str) - 1
				self.robot_positions[robot_index] = Vector2(x, y)
				self.robot_available[robot_index] = true
				self.dynamic_map[y][x].append(Tile.ROBOT + robot_index)
			"5", "6", "7", "8":
				self.dynamic_map[y][x].append(Tile.MARK + int(tile_str) - self.MAX_BUTTON_AMOUNT - 1)
	
	self.a_registers = [0, 0, 0, 0]
	self.b_registers = [0, 0, 0, 0]
	
func get_static_tile(x: int, y: int) -> Tile:
	return self.static_map[y][x]
	
func get_dynamic_tiles(x: int, y: int) -> Array[Tile]:
	return self.dynamic_map[y][x] as Array[Tile]
	
func get_robot_position(i: int) -> Vector2:
	if self.robot_available[i]:
		return self.robot_positions[i]
	return Vector2.INF

func get_robot_available(i: int) -> bool:
	return self.robot_available[i]
	
func get_map_width() -> int:
	return self.map_width
	
func get_map_height() -> int:
	return self.map_height
	
func get_button_available(i: int) -> bool:
	return self.button_available[i]
	
func get_button_state(i: int) -> bool:
	return self.button_states[i]
	
func get_a_register(i: int) -> int:
	return self.a_registers[i]
	
func get_b_register(i: int) -> int:
	return self.b_registers[i]
	
func turn_robot(i: int, turn_direction: Direction.Turn) -> void:
	self.robot_directions[i] = Direction.rotate(self.robot_directions[i], turn_direction)
	self.emit_signal("robot_turned", i, turn_direction)
	
func _change_button(i: int, v: bool) -> void:
	if self.button_states[i] == v:
		return
		
	var button_xs: Array[int] = []
	var button_ys: Array[int] = []
	var door_xs: Array[int] = []
	var door_ys: Array[int] = []
		
	self.button_states[i] = v
	
	for y in self.map_height:
		for x in self.map_width:
			if self.static_map[y][x] & TILE_TYPE_MASK == Tile.BUTTON:
				if self.static_map[y][x] & TILE_INDEX_MASK == i:
					button_xs.append(x)
					button_ys.append(y)
			elif self.static_map[y][x] & TILE_TYPE_MASK == Tile.DOOR:
				if self.static_map[y][x] & TILE_INDEX_MASK == i:
					door_xs.append(x)
					door_ys.append(y)
	
	if button_xs.size() > 0:
		emit_signal("button_changed", v, i, button_xs, button_ys, door_xs, door_ys)

func _update_buttons() -> void:
	for y in self.map_height:
		for x in self.map_width:
			if self.static_map[y][x] & TILE_TYPE_MASK == Tile.BUTTON:
				var pressurized: bool = false
				for dynamic_tile in self.get_dynamic_tiles(x, y):
					if dynamic_tile & TILE_TYPE_MASK in [Tile.ROBOT, Tile.BOX]:
						pressurized = true
						break
				
				var button_index: int = self.static_map[y][x] & TILE_INDEX_MASK
				if pressurized:
					self._change_button(button_index, true)
				else:
					self._change_button(button_index, false)
				
func _move_movable(x: int, y: int, direction: Direction.Absolute, is_robot_move: bool, robot_index: int) -> bool:
	var target: Vector2 = Vector2(x, y) + Direction.absolute_to_vec(direction)
	
	if target.x < 0 or target.x >= self.map_width or target.y < 0 or target.y >= self.map_height:
		return false
		
	if self.static_map[target.y][target.x] in [Tile.WALL]:
		return false
		
	if self.static_map[target.y][target.x] & TILE_TYPE_MASK == Tile.DOOR:
		if not self.button_states[self.static_map[target.y][target.x] & TILE_INDEX_MASK]:
			return false
	
	var source_dynamic_tiles: Array = self.get_dynamic_tiles(x, y)
	var target_dynamic_tiles: Array = self.get_dynamic_tiles(int(target.x), int(target.y))
	
	for tile in target_dynamic_tiles:
		if tile & TILE_TYPE_MASK == Tile.ROBOT:
			return false
			
	if Tile.BOX in target_dynamic_tiles:
		if not is_robot_move:
			return false
		elif not self._move_movable(int(target.x), int(target.y), direction, false, robot_index):
			return false
			
	if is_robot_move:
		self.robot_positions[robot_index] = target
		source_dynamic_tiles.erase(Tile.ROBOT + robot_index)
		target_dynamic_tiles.append(Tile.ROBOT + robot_index)
		emit_signal("robot_moved", robot_index, x, y, target.x, target.y)
	else:
		source_dynamic_tiles.erase(Tile.BOX)
		target_dynamic_tiles.append(Tile.BOX)
		emit_signal("box_moved", x, y, target.x, target.y)
		
	return true
			
func move_robot(i: int) -> bool:
	var robot_position: Vector2 = self.get_robot_position(i)
	var moved: bool = self._move_movable(int(robot_position.x), int(robot_position.y), robot_directions[i], true, i)	
	if moved:
		self._update_buttons()
	return moved
	
func put_mark(i: int, x: int, y: int) -> void:
	self.remove_mark(x, y)
	if self.static_map[y][x] == Tile.WALL:
		return
	var dynamic_tiles: Array = self.get_dynamic_tiles(x, y)
	dynamic_tiles.append(Tile.MARK + i)
	emit_signal("mark_placed", i, x, y)

			
func remove_mark(x: int, y: int) -> bool:
	var dynamic_tiles: Array = self.get_dynamic_tiles(x, y)
	var found_indices: Array[int] = []
	
	for i in dynamic_tiles.size():
		if dynamic_tiles[i] & TILE_TYPE_MASK == Tile.MARK:
			found_indices.append(i)
			
	found_indices.sort_custom(func(a: int, b: int) -> bool: return a > b)

	for i in found_indices:
		dynamic_tiles.pop_at(i)
		
	if found_indices.size() > 0:
		emit_signal("mark_removed", x, y)
		return true
		
	return false
		
func set_a_register(i: int) -> void:
	self.a_registers[i] = 1
	emit_signal("a_register_changed", i, self.a_registers[i])
	
func clear_a_register(i: int) -> void:
	self.a_registers[i] = 0
	emit_signal("a_register_changed", i, self.a_registers[i])
	
func toggle_a_register(i: int) -> void:
	if self.a_registers[i] == 0:
		self.a_registers[i] = 1
	else:
		self.a_registers[i] = 0
	emit_signal("a_register_changed", i, self.a_registers[i])
		
func randomize_a_register(i: int) -> void:
	self.a_registers[i] = randi() % 2
	emit_signal("a_register_changed", i, self.a_registers[i])
	
func set_b_register(i: int) -> void:
	self.b_registers[i] = 1
	emit_signal("b_register_changed", i, self.b_registers[i])
	
func clear_b_register(i: int) -> void:
	self.b_registers[i] = 0
	emit_signal("b_register_changed", i, self.b_registers[i])
	
func toggle_b_register(i: int) -> void:
	if self.b_registers[i] == 0:
		self.b_registers[i] = 1
	else:
		self.b_registers[i] = 0
	emit_signal("b_register_changed", i, self.b_registers[i])
		
func randomize_b_register(i: int) -> void:
	self.b_registers[i] = randi() % 2
	emit_signal("b_register_changed", i, self.b_registers[i])
	
func swap_registers(i: int) -> void:
	var tmp: int = self.a_registers[i]
	self.a_registers[i] = self.b_registers[i]
	self.b_registers[i] = tmp
	emit_signal("a_register_changed", i, self.a_registers[i])
	emit_signal("b_register_changed", i, self.b_registers[i])
	
func is_solved() -> bool:
	for y in self.map_height:
		for x in self.map_width:
			
			if self.static_map[y][x] == Tile.DESTINATION:
				var covered: bool = false
				
				for tile in self.get_dynamic_tiles(x, y):
					if Tile.BOX == tile:
						covered = true
						break
						
				if not covered:
					return false
					
	return true
