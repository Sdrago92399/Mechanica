class_name GearData
extends Resource

@export var name: String
@export var width: int = 1
@export var height: int = 1 
@export var scale: Vector2 = Vector2(1, 1)
@export var layer: int
var centre: Vector2
const defaultRadius: float = 63.0
var radius: float = defaultRadius
var rotation: float = 0.0
@export var numberOfTeeth: int = 79
@export var teethPerPixel: float = 0.5
@export var angularVelocity: float = 0
@export var torque: float = 0.0
@export var inertia: float = 100.0
@export var mode: String = "basic"

func config(numberOfTeeth: int, teethPerPixel: float, angularVelocity: float, torque: float, inertia: float, mode: String = "basic"):
	self.numberOfTeeth = numberOfTeeth
	self.teethPerPixel = teethPerPixel
	self.angularVelocity = angularVelocity
	self.torque = torque
	self.inertia = inertia
	self.radius = (numberOfTeeth / teethPerPixel) / (2 * PI)
	self.mode = mode
	
func prepare(node: Node2D):
	node.block.scale = Vector2(node.block.radius / node.block.defaultRadius, node.block.radius / node.block.defaultRadius)
	initScale(node)
	node.block.centre = node.position
	
func initScale(node: Node2D):
	var scaleRatio: Vector2 = (node.block.scale / node.scale).ceil()
	var layer_available = false
	var current_layer = node.block.layer
	
	while not layer_available:
		layer_available = true
		for i in range(-scaleRatio.x + 1, scaleRatio.x):
			for j in range(-scaleRatio.y + 1, scaleRatio.y):
				if i == 0 and j == 0:
					continue
				var grid_pos = node.grid.worldToGrid(node.position) + Vector2(i, j)
				if node.grid.grid.has(grid_pos) and node.grid.grid[grid_pos].occupier[current_layer] is Resource:
					# If any cell in this layer is already occupied, try the next layer
					layer_available = false
					current_layer += 1
					break
			if not layer_available:
				break
	
	# Set the layer to the first available layer found
	node.block.layer = current_layer

	# Now occupy the cells in the available layer
	for i in range(-scaleRatio.x + 1, scaleRatio.x):
		for j in range(-scaleRatio.y + 1, scaleRatio.y):
			var grid_pos = node.grid.worldToGrid(node.position) + Vector2(i, j)
			if node.grid.grid.has(grid_pos):
				node.grid.grid[grid_pos].occupier[node.block.layer] = node.block
	
	node.scale = node.block.scale

	
func getInput(grid: Grid, receiverBlock: Resource) -> Resource:
	var grid_pos = grid.worldToGrid(receiverBlock.centre)
	var directions = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)] # Left, Right, Up, Down
	
	for direction in directions:
		var adjacent_pos = grid_pos + direction
		if adjacent_pos in grid.grid:
			if receiverBlock.layer in grid.grid[adjacent_pos].occupier and grid.grid[adjacent_pos].occupier[receiverBlock.layer] is GearData:
				if grid.grid[adjacent_pos].occupier[receiverBlock.layer].torque != 0:
					return grid.grid[adjacent_pos].occupier[receiverBlock.layer]
	if grid_pos in grid.grid:
		if receiverBlock.layer-1 in grid.grid[grid_pos].occupier and grid.grid[grid_pos].occupier[receiverBlock.layer-1] is GearData:
			if grid.grid[grid_pos].occupier[receiverBlock.layer-1].torque != 0:
				return grid.grid[grid_pos].occupier[receiverBlock.layer-1]
		elif receiverBlock.layer+1 in grid.grid[grid_pos].occupier and grid.grid[grid_pos].occupier[receiverBlock.layer+1] is GearData:
			return grid.grid[grid_pos].occupier[receiverBlock.layer+1]
		else:
			var current_layer = receiverBlock.layer + 1
			while current_layer <= 5:
				if current_layer in grid.grid[grid_pos].occupier and grid.grid[grid_pos].occupier[current_layer] is RodData:
					if grid.grid[grid_pos].occupier[current_layer].mode == "connect":
						return grid.grid[grid_pos].occupier[current_layer]
				current_layer += 1
	return null
	
func torqueToAngularVelocity(torque: float):
	return torque / inertia
		
func angularVelocityToTorque(abgularVelocity: float):
	return angularVelocity * inertia
		
func rotate(torque: float, rotation: float, time: float) -> float:
	return fmod(rotation + torqueToAngularVelocity(torque) * time, 360.0)
			
func calculateTorque(senderToque:float, senderRadius: float, receiverRadius: float) -> float:
	return (receiverRadius * senderToque) / senderRadius

func rotateWithRod(senderCenter: Vector2, receiverCenter: Vector2) -> float:
	var direction: Vector2 = receiverCenter - senderCenter
	return atan2(direction.y, direction.x)

# New function to draw gear
func draw_gear(polygon2d: Polygon2D):
	var points = []
	var step = (2 * PI) / numberOfTeeth
	var outer_radius = radius
	var inner_radius = radius - (teethPerPixel * 20)  # Increase the difference for more pronounced teeth

	for i in range(numberOfTeeth):
		var angle = i * step
		var outer_point = Vector2(outer_radius * cos(angle), outer_radius * sin(angle))
		var inner_point = Vector2(inner_radius * cos(angle + step / 2), inner_radius * sin(angle + step / 2))
		points.append(outer_point)
		points.append(inner_point)

	polygon2d.polygon = points

	# Adding an outline using Line2D
	var outline = Line2D.new()
	outline.width = 1.0  # Adjust this value for outline thickness
	outline.default_color = Color(0, 0, 0)  # Outline color, adjust as necessary

	for point in points:
		outline.add_point(point)
	# Close the outline loop
	# outline.add_point(points[0])

	polygon2d.add_child(outline)

