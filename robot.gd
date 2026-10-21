class_name Robot
extends Sprite2D

var _a_register: int = 0
@export var a_register: int:
	get:
		return _a_register
	set(value):
		_a_register = min(1, max(0, value))	
		update_texture()
		
var _b_register: int = 0
@export var b_register: int:
	get:
		return _b_register
	set(value):
		_b_register = min(1, max(0, value))	
		update_texture()
		
var _index: int = 0
@export var index: int:
	get:
		return _index
	set(value):
		_index = value % 4
		update_texture()

const MOVEMENT_DURATION: float = 0.2  # seconds
const TILE_SIZE: int = 16

var movement_stack: Array[Vector2]
var is_ready: bool = false
		
func get_texture_offset_from_property_set(property_set: Variant) -> Vector2i:
	const PROPERTIES_TO_OFFSET: Dictionary[Array, Vector2i] = {
		[0, 0, 0]: Vector2i(0, 1),
		[0, 0, 1]: Vector2i(1, 1),
		[0, 0, 2]: Vector2i(2, 1),
		[0, 0, 3]: Vector2i(3, 1),
		[1, 0, 0]: Vector2i(4, 1),
		[1, 0, 1]: Vector2i(5, 1),
		[1, 0, 2]: Vector2i(6, 1),
		[1, 0, 3]: Vector2i(7, 1),
		[0, 1, 0]: Vector2i(0, 2),
		[0, 1, 1]: Vector2i(1, 2),
		[0, 1, 2]: Vector2i(2, 2),
		[0, 1, 3]: Vector2i(3, 2),
		[1, 1, 0]: Vector2i(4, 2),
		[1, 1, 1]: Vector2i(5, 2),
		[1, 1, 2]: Vector2i(6, 2),
		[1, 1, 3]: Vector2i(7, 2)
	}
	return PROPERTIES_TO_OFFSET[property_set]

func get_property_set() -> Variant:
	return [self._a_register, self._b_register, self._index]
	
func update_texture() -> void:
	if not self.is_ready:
		return
	
	var offset: Vector2i = self.get_texture_offset_from_property_set(self.get_property_set())
	offset *= self.TILE_SIZE
	
	var atlas: AtlasTexture = self.texture as AtlasTexture
	atlas.region = Rect2i(offset, atlas.region.size)
	self.texture = atlas
	
func move(by: Vector2) -> void:
	self.movement_stack.append(by)
	
func rotate_by(by: Direction.Turn) -> void:
	self.rotate(Direction.turn_to_angle(by))
	
func process_movement() -> void:
	if self.movement_stack.size() == 0:
		return
	var target: Vector2 = self.position
	var tween: Tween = self.create_tween()
	var stack_size: int = self.movement_stack.size()
	while self.movement_stack.size() > 0:
		target += self.movement_stack.pop_front() * self.TILE_SIZE
		tween.tween_property(self, "position", target, self.MOVEMENT_DURATION / stack_size)
	
func _ready() -> void:
	self._a_register = 0
	self._b_register = 0
	self.is_ready = true
	self.update_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.process_movement()
