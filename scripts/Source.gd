extends AnimatedSprite2D

var block: BlockData
@onready var main = get_tree().root.get_node("Main")
@onready var grid: Grid = main.get_node("Grid")

func init(value: Object):
	block = value

# Called when the node enters the scene tree for the first time.
func _ready():
	block.t.prepare(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	block.centre = position
	block.t.rotation = block.t.rotate(block.t.torque, block.t.rotation, delta)
	rotation_degrees = block.t.rotation
	block.t.torque = block.t.angularVelocityToTorque(block.t.angularVelocity)
