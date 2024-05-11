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
	# Update angular velocity based on torque
	var input: BlockData = block.t.getInput(grid, block)
	block.centre = block.t.revolve(input.centre, deg_to_rad(input.t.rotation), block.centre)
	position.x = block.centre.x
