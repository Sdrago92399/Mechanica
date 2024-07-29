extends AnimatedSprite2D

var block: Resource
@onready var main = get_tree().root.get_node("Main")
@onready var grid: Grid = main.get_node("Grid")
@onready var gear_polygon = Polygon2D.new()

func init(value: Object):
	block = value

# Called when the node enters the scene tree for the first time.
func _ready():
	block.prepare(self)
	add_child(gear_polygon)
	block.draw_rod(gear_polygon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update angular velocity based on torque
	var input: Resource = block.getInput(grid, block)
	
	if input:  # Check if input is valid
		if block.mode == "cam":
			block.centre = block.revolve(input.centre, deg_to_rad(input.rotation), block.centre)
			position.x = block.centre.x
		elif block.mode == "connect":
			var init_pos: Vector2 = block.start_pos
			block.start_pos = block.revolve(input.centre, deg_to_rad(input.rotation), block.start_pos)
			var diff = block.start_pos - init_pos
			position += diff

