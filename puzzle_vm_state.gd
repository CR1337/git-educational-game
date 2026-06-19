class_name PuzzleVMState
extends Node

signal all_programs_halted(solved: bool)
signal program_halted(index: int)
signal runtime_error(index: int, message: String)

enum Layer {
    SOLID = 0,
    PUSH = 1,
    ROBOT = 2
}
const layer_tiles: Array[Array] = [
    [".", "#", "!", "?", "&", "w", "x", "y", "z", "<", ">", "^", "v"],
    ["=", "$", "K", "L", "W", "X", "Y", "Z"],
    ["0", "1", "2", "3"]
]

const robot_tiles: Array[String] = ["0", "1", "2", "3"]
const empty_tiles: Array[String] = [".", "!", "?", "&", "<", ">", "^", "v"]
const pushable_tiles: Array[String] = ["=", "$"]
const item_tiles: Array[String] = ["K"]
const interactable_tiles: Array[String] = ["L", "w", "x", "y", "z"]
const solid_tiles: Array[String] = ["#", "W", "X", "Y", "Z", "L"]

var map_size: Vector2i
var map_layers: Array[Array]


var pi: int

var pcs: Array[int] = []
var is_cooperative: Array[bool] = []
var is_halted: Array[bool] = []

var items: Array[String] = []
var positions: Array[Array] = []
var programs: Array[Array] = []
var flags: Array[Array] = []
var signal_flags: Array[Array] = []
var label_positions: Array[Array] = []

func place_tile(pos: Vector2i, tile: String) -> void:
    pass

func set_map(map: ApiMap) -> void:
    self.map_size = Vector2i(map.width, map.height)

    self.map_layers = [[], []]
    for y in self.map_size.y:
        self.map_layers[Layer.SOLID].append([])
        self.map_layers[Layer.PUSH].append([])
        self.map_layers[Layer.ROBOT].append([])
        for x in self.map_size.x:
            self.map_layers[Layer.SOLID][y].append(".")
            self.map_layers[Layer.PUSH][y].append(".")
            self.map_layers[Layer.ROBOT][y].append(".")

    var pos: Vector2i = Vector2i.ZERO
    for tile in map.content:
        if tile == "\ņ":
            pos.x = 0
            pos.y += 1
        else:
            self.place_tile(pos, place_tile)
            x += 1

    for patch in map.patches:
        pos = Vector2i(patch[0], patch[1])
        const tile: String = patch[2]
        self.place_tile(pos, tile)

func set_program(index: int, file: ApiFile, preemptive: bool) -> void:
    assert(index >= 0 and index <= 3)

    while self.programs.size() < index + 1:
        self.items.append(".")
        self.positions.append([])
        self.programs.append([])
        self.flags.append([0, 0, 0, 0])
        self.signal_flags.append([0, 0, 0, 0])
        self.label_positions.append([])

    var lines: Array[String] = file.content.split("---", false)[0].strip_edges().split("\n", false)

    self.programs[index] = []
    for line_idx in lines.size():
        var line = lines[line_idx]
        var parfts: Array[String] = line.split(" ", false)
        self.programs[index].append(parts)
        if parts[0] == "label":
            var label_index: int = int(parts[1])
            self.label_positions[index][label_index] = line_idx

    self.cooperative[index] = not preemptive


func initialize() -> void:
    self.pi = 0
    for i in self.programs.size():
        self.is_halted[i] = false
        self.pcs[i] = 0
        while self.programs[i][self.pcs[i]][0] == "label":
            self.pcs[i] += 1
            if self.pcs[i] >= self.programs[i].size():
                self.is_halted[i] = true

        # TODO: init positions

func is_solved() -> bool:
    pass  # TODO

func goto_next_program(depth: int = 0) -> void:
    if depth >= self.programs.size():
        self.emit_signal("all_programs_halted", self.is_solved())
        return
    self.pi = (self.pi + 1) % self.programs.size()
    while self.is_halted[self.pi]:
        self.goto_next_program(depth + 1)

func goto_program(index: int) -> void:
    self.pi = index
    if self.is_halted[self.pi]:
        goto_next_program(1)

func goto_next_command() -> void:
    self.pcs[self.pi] += 1
    while self.programs[self.pi][self.pcs[self.pi]][0] == "label":
        self.pcs[self.pi] += 1

    if self.pcs[self.pi] >= self.programs[self.pi].size():
        self.emit_signal("program_halted", self.pi)

func goto_command(index: int) -> void:
    if self.label_positions[self.pi][index] == -1:
        self.emit_signal("runtime_error", tr("LOC_MISSING_LABEL_ERROR") + " " + str(index))
        return

    self.pcs[self.pi] = self.label_positions[self.pi][index]

func move(position: Vector2i, direction: Vector2i, robot: bool) -> bool:
    var new_position: Vector2i = position + direction
    var map_rect: Rect2i = Rect2i(Vector2i.ZERO, self.map_size + Vector2i(1, 1))
    if not map_rect.has_point(new_position):
        return false

    if self.map_layers[Layer.SOLID][new_position.y][new_position.x] in self.solid_tiles:
        return false

    if self.map_layers[Layer.ROBOT] [new_position.y][new_position.x] in self.robot_tiles:
        return false

    if self.map_layers[Layer.PUSH][new_position.y][new_position.x] in self.empty_tiles:
        return true

    if force <= 0:
        return false

    var tile: String = self.map_layers[1][position.y][position.x]

    const do_move: bool = (tile in self.robot_tiles and force >= 2) or (tile in self.pushable_tiles and force >= 1)

    if do_move:
        self.map_layers[1][new_position.y][new_position.x] = self.map_layers[1][position.y][position.x]
        self.map_layers[1][position.y][position.x] = "."

    return do_move


func pick(position: Vector2i, direction: Vector2i) -> bool:
    pass


func drop(position: Vector2i, direction: Vector2i) -> bool:
    pass
