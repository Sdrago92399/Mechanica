extends AnimatedSprite2D

var block: GearData
@onready var main = get_tree().root.get_node("Main")
@onready var grid: Grid = main.get_node("Grid")
@onready var gear_polygon = Polygon2D.new()

func init(value: GearData):
	block = value

# Called when the node enters the scene tree for the first time.
func _ready():
	block.prepare(self)
	if not has_node("gear_polygon"):
		gear_polygon = Polygon2D.new()
		gear_polygon.name = "gear_polygon"
		add_child(gear_polygon)
	block.draw_gear(gear_polygon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if block.mode == "source":
		block.torque = block.angularVelocityToTorque(block.angularVelocity)
	else:
		var input: Resource = block.getInput(grid, block)
		if input:  # Check if input is valid
			if input.mode == "connect":
				#block.rotation = block.rotateWithRod(input.end_pos, block.centre)
				block.torque = block.calculateTorque(input.force, input.end_pos.distance_to(block.centre), block.radius)
			else:
				block.torque = block.calculateTorque(input.torque, input.radius, block.radius)
		else:
			block.torque = 0
	block.rotation = block.rotate(block.torque, block.rotation, delta)
	rotation_degrees = block.rotation

