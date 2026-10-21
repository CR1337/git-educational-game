extends Node
class_name CommandBlockDragData

var source: Control
var destination: Control

var command: Command
var command_block: CommandBlock
var preview: CommandBlock

func _init(_source: Control, _command: Command, _command_block: CommandBlock, _preview: CommandBlock) -> void:
	self.source = _source
	self.command = _command
	self.command_block = _command_block
	self.preview = _preview
	self.preview.tree_exiting.connect(self._on_tree_exiting)
	
func _on_tree_exiting() -> void:
	self.command_block.queue_free()
