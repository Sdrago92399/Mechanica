class_name RodData
extends Resource

@export var name: String
@export var texture: Texture
@export var width: int = 1
@export var height: int = 1 
@export var scale: Vector2 = Vector2(1, 1)
@export var layer: int

var centre: Vector2
var start_pos: Vector2
var end_pos: Vector2
var momentum: float = 0.0
var force: float = 0.0

@export var linearVelocity: float = 0
@export var inertia: float = 100.0
@export var length: float = 128.0
@export var mode: String = "basic"
@export var rotation: float = 0.0

func config(linearVelocity: float, inertia: float, length: float, mode: String = "basic", rotation: float = 0.0):
	self.linearVelocity = linearVelocity
	self.inertia = inertia
	self.length = length
	self.mode = mode
	self.rotation = rotation
	self.momentum = linearVelocity * inertia
	self.force = momentum / (1/60)
	
func prepare(node: Node2D):
	node.block.centre = node.position
	node.block.start_pos = node.position - Vector2(cos(deg_to_rad(node.block.rotation)), sin(deg_to_rad(node.block.rotation))) * (node.grid.gridToWorldFloat(node.block.length / 2))
	node.block.end_pos = node.position + Vector2(cos(deg_to_rad(node.block.rotation)), sin(deg_to_rad(node.block.rotation))) * (node.grid.gridToWorldFloat(node.block.length / 2))
	node.rotation_degrees = node.block.rotation
	node.block.scale = node.scale 
	var input: Resource = node.block.getInput(node.grid, node.block)
	if mode == "cam":
		if input:
			node.position = Vector2(input.centre.x + input.radius, input.centre.y)
			node.block.centre = node.position
			node.block.scale.x = input.scale.x
			node.block.force = input.torque * (input.radius / input.radius) #input gear radius/rod's distance from center
	elif mode == "connect":
		if input:
			node.position += Vector2(input.radius, 0)
			node.block.start_pos += Vector2(input.radius, 0)
			node.block.end_pos += Vector2(input.radius, 0)
			node.block.centre = node.position
			node.block.force = input.torque * (input.radius / input.radius) #input gear radius/rod's distance from center
		node.block.scale.x = node.block.length
		initScale(node)
	
func initScale(node: Node2D):
	var scaleRatio: Vector2 = (node.block.scale / node.scale).ceil()
	var start_pos = node.block.start_pos
	var end_pos = node.block.end_pos
	start_pos = node.grid.worldToGrid(start_pos)
	end_pos = node.grid.worldToGrid(end_pos)
	
	# Bresenham's line algorithm to get all grid positions the rod occupies
	var x0 = int(start_pos.x)
	var y0 = int(start_pos.y)
	var x1 = int(end_pos.x)
	var y1 = int(end_pos.y)

	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx - dy

	while true:
		if node.grid.grid.has(Vector2(x0, y0)):
			node.grid.grid[Vector2(x0, y0)].occupier[node.block.layer] = node.block
		if x0 == x1 and y0 == y1:
			break
		var e2 = err * 2
		if e2 > -dy:
			err -= dy
			x0 += sx
		if e2 < dx:
			err += dx
			y0 += sy

	node.scale = node.block.scale

	
func getInput(grid: Grid, recieverBlock: Resource) -> Resource:
	var grid_pos = grid.worldToGrid(recieverBlock.centre)
	if grid_pos in grid.grid and recieverBlock.mode == "connect":
		grid_pos = grid.worldToGrid(recieverBlock.start_pos)
	if grid_pos in grid.grid:
		var current_layer = recieverBlock.layer - 1
		while current_layer >= 0:
			if current_layer in grid.grid[grid_pos].occupier and grid.grid[grid_pos].occupier[current_layer] is GearData:
				return grid.grid[grid_pos].occupier[current_layer]
			current_layer -= 1
	return null

func momentumToLinearVelocity(momentum: float):
		return momentum / inertia
		
func linearVelocityToMomentum(linearVelocity: float):
		return linearVelocity * inertia

func revolve(senderCenter: Vector2, senderRotation: float, receiverCenter: Vector2) -> Vector2:
	var radius: float = senderCenter.distance_to(receiverCenter)
	return senderCenter + Vector2(radius * cos(senderRotation), radius * sin(senderRotation))

# New function to draw the rod
func draw_rod(polygon2d: Polygon2D):
	var half_length = length / 2
	var width = 10.0  # Set the width of the rod
	var points = [
		Vector2(-half_length, -width / 2),
		Vector2(half_length, -width / 2),
		Vector2(half_length, width / 2),
		Vector2(-half_length, width / 2)
	]

	polygon2d.polygon = points

	# Adding an outline using Line2D
	var outline = Line2D.new()
	outline.width = 4.0  # Adjust this value for outline thickness
	outline.default_color = Color(0, 0, 0)  # Outline color, adjust as necessary

	for point in points:
		outline.add_point(point)
	# Close the outline loop
	outline.add_point(points[0])

	polygon2d.add_child(outline)
