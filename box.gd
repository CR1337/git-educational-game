extends Sprite2D
class_name Box

var _on_destination: bool = false
@export var on_destination: bool:
	get:
		return _on_destination
	set(value):
		_on_destination = value
		update_texture()

const MOVEMENT_DURATION: float = 0.2  # seconds
const TILE_SIZE: int = 16

var movement_stack: Array[Vector2]
var is_ready: bool = false

func get_texture_offset_from_property_set(property_set: Variant) -> Vector2i:
	const PROPERTIES_TO_OFFSET: Dictionary[bool, Vector2i] = {
		true: Vector2i(4, 0),
		false: Vector2i(3, 0)
	}
	return PROPERTIES_TO_OFFSET[property_set]

func get_property_set() -> Variant:
	return self._on_destination
	
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
	
func process_movement() -> void:
	if self.movement_stack.size() == 0:
		return
	var target: Vector2 = self.position
	var tween: Tween = self.create_tween()
	var stack_size: int = self.movement_stack.size()
	while self.movement_stack.size() > 0:
		target += self.movement_stack.pop_front() * self.TILE_SIZE
		tween.tween_property(self, "position", target, self.MOVEMENT_DURATION / stack_size)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.is_ready = true
	#self.update_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.process_movement()
