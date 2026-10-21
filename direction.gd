class_name Direction
extends Object

enum Absolute {
	NONE = 0, NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4
}

enum Relative {
	NONE = 0, LEFT = 1, RIGHT = 2, FORWARD = 3, BEHIND = 4 , HERE = 5
}

enum Turn {
	NONE = 0, LEFT = 1, RIGHT = 2, BEHIND = 3
}

static func absolute_to_vec(absolute_direction: Absolute) -> Vector2:
	return {
		Absolute.NONE:  Vector2( 0.0,  0.0),
		Absolute.NORTH: Vector2( 0.0, -1.0),
		Absolute.SOUTH: Vector2( 0.0,  1.0),
		Absolute.EAST:  Vector2( 1.0,  0.0),
		Absolute.WEST:  Vector2(-1.0,  0.0)
	}[absolute_direction].round()

static func relative_to_vec(relative_direction: Relative) -> Vector2:
	return {
		Relative.NONE:    Vector2( 0.0,  0.0),
		Relative.LEFT:    Vector2(-1.0,  0.0),
		Relative.RIGHT:   Vector2( 1.0,  0.0),
		Relative.FORWARD: Vector2( 0.0, -1.0),
		Relative.BEHIND:  Vector2( 0.0,  1.0),
		Relative.HERE:    Vector2( 0.0,  0.0)
	}[relative_direction].round()
	
static func relative_with_absolute_to_vec(relative_direction: Relative, absolute_direction: Absolute) -> Vector2:
	var v = relative_to_vec(relative_direction)
	return {
		Absolute.NONE: Vector2.ZERO,
		Absolute.NORTH: v,
		Absolute.EAST: Vector2(-v.y, v.x),
		Absolute.SOUTH: -v,
		Absolute.WEST: Vector2(v.y, -v.x)
	}[absolute_direction].round()

static func turn_to_angle(turn_direction: Turn) -> float:
	return {
		Turn.NONE:        0.0,
		Turn.LEFT:  -PI / 2.0,
		Turn.RIGHT:  PI / 2.0,
		Turn.BEHIND: PI,
	}[turn_direction]
	
static func rotate(from: Absolute, by: Turn) -> Absolute:
	return {
		Turn.NONE: {
			Absolute.NONE:  Absolute.NONE,
			Absolute.NORTH: Absolute.NORTH,
			Absolute.SOUTH: Absolute.SOUTH,
			Absolute.EAST:  Absolute.EAST,
			Absolute.WEST:  Absolute.WEST
		}[from],
		Turn.LEFT: {
			Absolute.NONE:  Absolute.NONE,
			Absolute.NORTH: Absolute.WEST,
			Absolute.SOUTH: Absolute.EAST,
			Absolute.EAST:  Absolute.NORTH,
			Absolute.WEST:  Absolute.SOUTH
		}[from],
		Turn.RIGHT: {
			Absolute.NONE:  Absolute.NONE,
			Absolute.NORTH: Absolute.EAST,
			Absolute.SOUTH: Absolute.WEST,
			Absolute.EAST:  Absolute.SOUTH,
			Absolute.WEST:  Absolute.NORTH
		}[from],
		Turn.BEHIND: {
			Absolute.NONE:  Absolute.NONE,
			Absolute.NORTH: Absolute.SOUTH,
			Absolute.SOUTH: Absolute.NORTH,
			Absolute.EAST:  Absolute.WEST,
			Absolute.WEST:  Absolute.EAST
		}[from]
	}[by]
	
static func move(from: Vector2, to: Relative, with: Absolute) -> Vector2:
	var offset: Vector2 = Direction.relative_with_absolute_to_vec(to, with)
	var target: Vector2 = from + offset
	return target.round()
