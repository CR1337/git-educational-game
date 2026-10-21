extends VBoxContainer
class_name CodeBlockList

var _is_ready: bool = false

var _program: String
@export_multiline() var program: String:
	get:
		return _program
	set(value):
		_program = value
		if _is_ready:
			_update_command_blocks()
			
var _enable_drag_n_drop: bool
@export var enable_drag_n_drop: bool:
	get:
		return _enable_drag_n_drop
	set(value):
		_enable_drag_n_drop = value
		if _is_ready:
			_update_command_blocks()

func _update_command_blocks() -> void:
	var parser: CommandParser = CommandParser.new()
	var commands: Array[Command] = parser.parse(self._program)
	
	for block in self.get_children():
		self.remove_child(block)
	
	for command in commands:
		var block: CommandBlock = preload("res://command_block.tscn").instantiate()
		block.command = command
		self.add_child(block)
		
		block.set_turn_direction(command.turn_direction)
		block.set_direction(command.direction)
		block.set_tile(command.tile)
		block.set_number(command.number)
		
		block.enable_drag_n_drop = self._enable_drag_n_drop
		
func rewrite_program() -> void:
	var result: String = ""
	for command_block in self.get_children():
		if not command_block is CommandBlock:
			continue
		result += command_block.command.as_string() + "\n"
	self._program = result

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is CommandBlockDragData
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	self.handle_drop_data(at_position, data as CommandBlockDragData)
		
func handle_drop_data(at_position: Vector2, data: CommandBlockDragData) -> void:
	var drag_data: CommandBlockDragData = data as CommandBlockDragData
	
	var child_amount: int = self.get_child_count()
	var target_index: int = 0
	
	if child_amount == 0:
		target_index = 0
	else:
		var found: bool = false
		for i in child_amount:
			var child: CommandBlock = self.get_child(i)
			
			if at_position.y < child.position.y:
				target_index = i
				found = true
				break
				
		if not found:
			target_index = child_amount
			
	var new_block: CommandBlock = preload("res://command_block.tscn").instantiate()
	new_block.command = drag_data.command
	self.add_child(new_block)
	self.move_child(new_block, target_index)
	new_block.set_direction(drag_data.command.direction)
	new_block.set_turn_direction(drag_data.command.turn_direction)
	new_block.set_tile(drag_data.command.tile)
	new_block.set_number(drag_data.command.number)
	
	self.rewrite_program()
	
	return
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._is_ready = true
	_update_command_blocks()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
