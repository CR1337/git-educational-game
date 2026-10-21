class_name PuzzleGrid
extends SubViewportContainer

@onready var static_tilemap: TileMapLayer = $SubViewport/StaticTilemap
@onready var marker_tilemap: TileMapLayer = $SubViewport/MarkerTilemap
@onready var robots_node: Node2D = $SubViewport/Robots
@onready var boxes_node: Node2D = $SubViewport/Boxes

@export_category("Map")
@export_multiline() var map_description: String

@export_category("VM")
@export var puzzle_vm: PuzzleVm
@export var puzzle_vm_state: PuzzleVmState
@export_multiline var program1: String
@export_multiline var program2: String
@export_multiline var program3: String
@export_multiline var program4: String

var robots: Array[Robot]
var boxes: Dictionary[Vector2i, Box]

var time_waited: float = 0.0

const TEXTURE_OFFSETS: Dictionary[PuzzleVmState.Tile, Vector2i] = {
	PuzzleVmState.Tile.MARK + 0:    Vector2i(8, 1),
	PuzzleVmState.Tile.MARK + 1:    Vector2i(9, 1),
	PuzzleVmState.Tile.MARK + 2:    Vector2i(10, 1),
	PuzzleVmState.Tile.MARK + 3:    Vector2i(11, 1),
	PuzzleVmState.Tile.MARK1:       Vector2i(8, 1),
	PuzzleVmState.Tile.MARK2:       Vector2i(9, 1),
	PuzzleVmState.Tile.MARK3:       Vector2i(10, 1),
	PuzzleVmState.Tile.MARK4:       Vector2i(11, 1),
	PuzzleVmState.Tile.EMPTY:       Vector2i(0, 0),
	PuzzleVmState.Tile.WALL:        Vector2i(1, 0),
	PuzzleVmState.Tile.DESTINATION: Vector2i(2, 0),
	PuzzleVmState.Tile.BUTTON + 0:  Vector2i(0, 3),
	PuzzleVmState.Tile.BUTTON + 1:  Vector2i(1, 3),
	PuzzleVmState.Tile.BUTTON + 2:  Vector2i(2, 3),
	PuzzleVmState.Tile.BUTTON + 3:  Vector2i(3, 3),   
	PuzzleVmState.Tile.BUTTON + 4:  Vector2i(4, 3),
	PuzzleVmState.Tile.BUTTON + 5:  Vector2i(5, 3),
	PuzzleVmState.Tile.BUTTON + 6:  Vector2i(6, 3),
	PuzzleVmState.Tile.BUTTON + 7:  Vector2i(7, 3),
	PuzzleVmState.Tile.BUTTON + 8:  Vector2i(0, 4),
	PuzzleVmState.Tile.BUTTON + 9:  Vector2i(1, 4),
	PuzzleVmState.Tile.BUTTON + 10: Vector2i(2, 4),
	PuzzleVmState.Tile.BUTTON + 11: Vector2i(3, 4),
	PuzzleVmState.Tile.BUTTON + 12: Vector2i(4, 4),
	PuzzleVmState.Tile.BUTTON + 13: Vector2i(5, 4),
	PuzzleVmState.Tile.BUTTON + 14: Vector2i(6, 4),
	PuzzleVmState.Tile.BUTTON + 15: Vector2i(7, 4),
	PuzzleVmState.Tile.DOOR + 0:    Vector2i(0, 5),
	PuzzleVmState.Tile.DOOR + 1:    Vector2i(1, 5),
	PuzzleVmState.Tile.DOOR + 2:    Vector2i(2, 5),
	PuzzleVmState.Tile.DOOR + 3:    Vector2i(3, 5),   
	PuzzleVmState.Tile.DOOR + 4:    Vector2i(4, 5),
	PuzzleVmState.Tile.DOOR + 5:    Vector2i(5, 5),
	PuzzleVmState.Tile.DOOR + 6:    Vector2i(6, 5),
	PuzzleVmState.Tile.DOOR + 7:    Vector2i(7, 5),
	PuzzleVmState.Tile.DOOR + 8:    Vector2i(0, 6),
	PuzzleVmState.Tile.DOOR + 9:    Vector2i(1, 6),
	PuzzleVmState.Tile.DOOR + 10:   Vector2i(2, 6),
	PuzzleVmState.Tile.DOOR + 11:   Vector2i(3, 6),
	PuzzleVmState.Tile.DOOR + 12:   Vector2i(4, 6),
	PuzzleVmState.Tile.DOOR + 13:   Vector2i(5, 6),
	PuzzleVmState.Tile.DOOR + 14:   Vector2i(6, 6),
	PuzzleVmState.Tile.DOOR + 15:   Vector2i(7, 6)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("PuzzleGrid ready")
	self.puzzle_vm_state.initialize(self.map_description)
	
	self.robots = [null, null, null, null]
	self.boxes = {}
	var program_descriptions: Array[String] = ["", "", "", ""]
	
	for y in PuzzleVmState.MAX_MAP_HEIGHT:
		for x in PuzzleVmState.MAX_MAP_WIDTH:
			self.static_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(15, 15))
			self.marker_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(15, 15))
	
	for y in self.puzzle_vm_state.map_height:
		for x in self.puzzle_vm_state.map_width:			
			for tile in self.puzzle_vm_state.get_dynamic_tiles(x, y):
				if tile == PuzzleVmState.Tile.BOX:
					var box: Box = preload("res://box.tscn").instantiate() as Box
					box.on_destination = self.puzzle_vm_state.get_static_tile(x, y) == PuzzleVmState.Tile.DESTINATION
					box.position = Vector2(x, y) * Box.TILE_SIZE + Vector2(1, 1) * Box.TILE_SIZE / 2
					self.boxes[Vector2i(x, y)] = box
					self.boxes_node.add_child(box)
					
				elif tile & PuzzleVmState.TILE_TYPE_MASK == PuzzleVmState.Tile.ROBOT:
					var index: int = tile & PuzzleVmState.TILE_INDEX_MASK
					var robot: Robot = preload("res://robot.tscn").instantiate() as Robot
					robot.position = Vector2(x, y) * Box.TILE_SIZE + Vector2(1, 1) * Robot.TILE_SIZE / 2
					robot.index = index
					self.robots[index] = robot
					self.robots_node.add_child(robot)
					program_descriptions[index] = [self.program1, self.program2, self.program3, self.program4][index]
					
				elif tile & PuzzleVmState.TILE_TYPE_MASK == PuzzleVmState.Tile.MARK or tile in [PuzzleVmState.Tile.MARK1, PuzzleVmState.Tile.MARK2, PuzzleVmState.Tile.MARK3, PuzzleVmState.Tile.MARK4]:
					self.marker_tilemap.set_cell(Vector2i(x, y), 0, self.TEXTURE_OFFSETS[tile])
					
			var tile: PuzzleVmState.Tile = puzzle_vm_state.get_static_tile(x, y)
			var texture_offset: Vector2i = self.TEXTURE_OFFSETS[tile]
			self.static_tilemap.set_cell(Vector2i(x, y), 0, texture_offset)
			
					
	self.puzzle_vm.initialize(PackedStringArray(program_descriptions))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.time_waited += delta
	if self.time_waited >= 0.5:
		self.time_waited = 0.0
		self.puzzle_vm.step()


func _on_puzzle_vm_all_terminated() -> void:
	print("All robots terminated.")
	pass # Replace with function body.


func _on_puzzle_vm_robot_terminated(i: int) -> void:
	print("Robot " + str(i) + " terminated.")
	pass # Replace with function body.


func _on_puzzle_vm_state_a_register_changed(i: int, v: int) -> void:
	self.robots[i].a_register = v


func _on_puzzle_vm_state_b_register_changed(i: int, v: int) -> void:
	self.robots[i].b_register = v


func _on_puzzle_vm_state_box_moved(source_x: int, source_y: int, target_x: int, target_y: int) -> void:
	var box: Box = self.boxes[Vector2i(source_x, source_y)]
	self.boxes.erase(Vector2i(source_x, source_y))
	self.boxes[Vector2i(target_x, target_y)] = box
	box.move(Vector2(target_x, target_y) - Vector2(source_x, source_y))
	if self.puzzle_vm_state.get_static_tile(target_x, target_y) == PuzzleVmState.Tile.DESTINATION:
		box.on_destination = true
	else:
		box.on_destination = false

func _on_puzzle_vm_state_button_changed(state: bool, i: int, buttons_xs: Array[int], button_ys: Array[int], door_xs: Array[int], door_ys: Array[int]) -> void:
	for idx in door_xs.size():
		if not state:
			self.static_tilemap.set_cell(
				Vector2i(door_xs[idx], door_ys[idx]),
				0,
				Vector2i(i if i < 8 else i / 2, 5 if i < 8 else 6)
			)
		else:
			self.static_tilemap.set_cell(
				Vector2i(door_xs[idx], door_ys[idx]),
				0,
				Vector2i(5, 0)
			)

func _on_puzzle_vm_state_mark_placed(i: int, x: int, y: int) -> void:
	self.marker_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(8 + i, 1))


func _on_puzzle_vm_state_mark_removed(x: int, y: int) -> void:
	self.marker_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(11, 0))


func _on_puzzle_vm_state_robot_moved(i: int, source_x: int, source_y: int, target_x: int, target_y: int) -> void:
	var robot: Robot = self.robots[i]
	robot.move(Vector2(target_x, target_y) - Vector2(source_x, source_y))


func _on_puzzle_vm_state_robot_turned(i: int, direction: Direction.Turn) -> void:
	var robot: Robot = self.robots[i]
	robot.rotate_by(direction)
