class_name PuzzleVM
extends Node

signal tile_moved(from_x: int, from_y: int, to_x: int, to_y: int, tile: String)
signal program_halted(index: int)
signal all_programs_halted(solved: bool)
signal next_program(from: int, to: int)
signal runtime_error(index: int, message: String)

var state: PuzzleVMState = PuzzleVMState.new()

var width: int
var height: int
var map_layer_0: Array[Array]
var map_layer_1: Array[Array]
var programs: Array[Array] = []
var cooperative: Array[bool] = []
var halted: Array[bool] = []

const layer_0_tiles: Array[String] = [".", "#", "!", "?", "&", "w", "x", "y", "z", "<", ">", "^", "v"]
const layer_1_tiles: Array[String] = ["0", "1", "2", "3", "=", "$", "K", "L", "W", "X", "Y", "Z"]
const robot_tiles: Array[String] = ["0", "1", "2", "3"]
const empty_tiles: Array[String] = [".", "!", "?", "&", "<", ">", "^", "v"]
const pushable_tiles: Array[String] = ["=", "$"]
const item_tiles: Array[String] = ["K"]
const interactable_tiles: Array[String] = ["L", "w", "x", "y", "z"]
const solid_tiles: Array[String] = ["#", "W", "X", "Y", "Z", "L"]

var program_amount: int
var current_program_index: int
var program_counters: Array[int]
var flags: Array[Array]
var signal_flags: Array[Array]
var items: Array[String]
var x_positions: Array[int]
var y_positions: Array[int]
var labels: Array[Array]

func set_map(map: ApiMap) -> void:
    self.state.set_map(map)

func set_program(index: int, file: ApiFile, preemptive: bool) -> void:
    self.state.set_program(index, file, preemptive)

func start() -> void:
    self.program_amount = self.programs.size()
    self.current_program_index = 0

    self.program_counters = []
    self.flags = []
    self.signal_flags = []
    self.items = []
    self.x_positions = []
    self.y_positions = []

    for i in self.program_amount:
        self.program_counters[i] = -1
        self.flags.append([0, 0, 0, 0])
        self.signal_flags.append([0, 0, 0, 0])
        self.items[i] = "."

        var found: bool = false
        for y in self.height:
            for x in self.width:
                if str(i) == self.map_layer_1[y][x]:
                    self.x_positions[i] = x
                    self.y_positions[i] = y
                    found = true
                    break
            if found:
                break

func parse_direction(d: String) -> Array[int]:
    match d:
        "north":
            return [0, -1]
        "west":
            return [-1, 0]
        "east":
            return [1, 0]
        "south":
            return [0, 1]
        "here":
            return [0, 0]

func parse_number(n: String) -> int:
    return int(n)

func parse_tile(t: String) -> Array:
    if t in self.map_layer_0 or t in self.map_layer_1:
        return [t, true]
    else:
        return [t, false]

func is_out_of_bounds(x: int, y: int) -> bool:
    return x < 0 or y < 0 or x >= self.width or y >= self.height

func get_next_program() -> int:
    var program: int = self.current_program_index
    program += 1
    if program == self.program_amount:
        program = 0
    return program

func get_new_state_after_operation(must_goto_next_program: bool, can_goto_next_program: bool, goto_next_command: bool, jump: bool, jump_target: int, done: bool) -> Array[Variant]:
    return [
        self.get_next_program()
            if must_goto_next_program or (self.cooperative and can_goto_next_program)
            else self.current_program_index,

    ]

func operation_move(dx: int, dy: int) -> Array:
    var target_x = self.x_positions[self.current_program_index]
    var target_y = self.y_positions[self.current_program_index]

    if self.is_out_of_bounds(target_x, target_y):
        return self.get_new_state_after_operation(false, true, true, false, -1, true)

    var target_tile_0: String = self.map_layer_0[target_y][target_x]
    var target_tile_1: String = self.map_layer_1[target_y][target_x]

    if target_tile_0 in self.solid_tiles:
        pass  # TODO: return

    if target_tile_1 in self.robot_tiles:
        pass  # TODO: return

    if target_tile_1 not in self.pushable_tiles:
        self.emit_signal(
            "tile_moved",
            self.x_positions[self.current_program_index],
            self.y_positions[self.current_program_index],
            target_x,
            target_y,
            str(self.current_program_index)
        )
        self.x_positions[self.current_program_index] = target_x
        self.y_positions[self.current_program_index] = target_y
        # TODO: return

    var pushable_target_x: int = target_x * 2
    var pushable_target_y: int = target_y * 2

    if self.is_out_of_bounds(pushable_target_x, pushable_target_y):
        pass
        # TODO: return







func operation_pick(dx: int, dy: int) -> Array:
    pass  # TODO

func operation_drop(dx: int, dy: int) -> Array:
    pass  # TODO

func operation_scan(dx: int, dy: int, t: String, t_category: bool, n: int) -> Array:
    pass  # TODO

func operation_set(n: int) -> Array:
    pass  # TODO

func operation_clear(n: int) -> Array:
    pass  # TODO

func operation_toggle(n: int) -> Array:
    pass  # TODO

func operation_signal(n: int) -> Array:
    pass  # TODO

func operation_listen(n: int) -> Array:
    pass  # TODO

func operation_poll(n1: int, n2: int) -> Array:
    pass  # TODO

func operation_wait() -> Array:
    pass  # TODO

func operation_next() -> Array:
    pass  # TODO

func operation_yield(n: int) -> Array:
    pass  # TODO

func operation_halt() -> Array:
    pass  # TODO

func operation_label(n: int) -> Array:
    pass  # TODO

func operation_jump(n: int) -> Array:
    pass  # TODO

func operation_jump_if(n1: int, n2: int) -> Array:
    pass  # TODO

func step() -> void:
    var amount_halted: int = 0
    while self.halted[self.current_program_index]:
        self.current_program_index = self.get_next_program()
        self.amount_halted += 1

        if self.amount_halted == self.program_amount:
            self.emit_signal("all_programs_halted", self.is_solved())
            return

    var program: Array = self.programs[self.current_program_index]
    var command: Array = program[self.program_counters[self.current_program_index]]
    var operation: String = command[0]
    var operands: Array[String] = command.slice(1)

    var next_program_index: int
    var next_command_index: int
    var done: bool = false

    while not done:

        var direction_operand: Array[int]
        var tile_operant: Array[Variant]

        var dx: int
        var dy: int
        var t: String
        var t_category: bool
        var n: int
        var n1: int
        var n2: int

        var new_state: Array[Variant]

        match operation:
            "move":
                direction_operand = self.parse_direction(operands[0])
                dx = direction_operand[0]
                dy = direction_operand[1]
                new_state = self.operation_move(dx, dy)

            "pick":
                direction_operand = self.parse_direction(operands[0])
                dx = direction_operand[0]
                dy = direction_operand[1]
                new_state = self.operation_pick(dx, dy)

            "drop":
                direction_operand = self.parse_direction(operands[0])
                dx = direction_operand[0]
                dy = direction_operand[1]
                new_state = self.operation_drop(dx, dy)

            "scan":
                direction_operand = self.parse_direction(operands[0])
                dx = direction_operand[0]
                dy = direction_operand[1]
                tile_operant = self.parse_tile(operands[1])
                t = tile_operant[0]
                t_category = tile_operant[1]
                n = self.parse_number(operands[2])
                new_state = self.operation_scan(dx, dy, t, t_category, n)

            "set":
                n = self.parse_number(operands[0])
                new_state = self.operation_set(n)

            "clear":
                n = self.parse_number(operands[0])
                new_state = self.operation_clear(n)

            "toggle":
                n = self.parse_number(operands[0])
                new_state = self.operation_toggle(n)

            "signal":
                n = self.parse_number(operands[0])
                new_state = self.operation_signal(n)

            "listen":
                n = self.parse_number(operands[0])
                new_state = self.operation_listen(n)

            "poll":
                n1 = self.parse_number(operands[0])
                n2 = self.parse_number(operands[1])
                new_state = self.operation_poll(n1, n2)

            "wait":
                new_state = self.operation_wait()

            "next":
                new_state = self.operation_next()

            "yield":
                n = self.parse_number(operands[0])
                new_state = self.operation_yield(n)

            "halt":
                self.halted[self.current_program_index] = true
                new_state = self.operation_halt()

            "label":
                n = self.parse_number(operands[0])
                new_state = self.operation_label(n)

            "jump":
                n = self.parse_number(operands[0])
                new_state = self.operation_jump(n)

            "jump_if":
                n1 = self.parse_number(operands[0])
                n2 = self.parse_number(operands[1])
                new_state = self.operation_jump_if(n1, n2)

        next_program_index = new_state[0]
        next_command_index = new_state[1]
        done = new_state[2]

    self.program_counters[self.current_program_index] = next_command_index
    self.current_program_index = next_program_index







