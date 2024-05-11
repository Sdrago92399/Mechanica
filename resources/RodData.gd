class_name RodData
extends Resource

@export var linearVelocity: float = 0
@export var momentum: float = 0.0
@export var inertia: float = 100.0
@export var length: float = 128.0

func config(linearVelocity: float, momentum: float, inertia: float, length: float):
	self.linearVelocity = linearVelocity
	self.momentum = momentum
	self.inertia = inertia
	self.length = length
	
func prepare(node: Node2D):
	node.block.centre = node.position
	var input: BlockData = node.block.t.getInput(node.grid, node.block)
	node.position = Vector2(input.centre.x + input.t.radius, input.centre.y)
	node.block.centre = node.position
	
	#remove this later
	node.block.scale = node.scale 
	
	node.block.scale.x = input.scale.x
	scale(node)
	
func scale(node: Node2D):
	var scaleRatio: Vector2 = (node.block.scale / node.scale).ceil()
	print(node.grid.worldToGrid(node.position))
	for i in range(-scaleRatio.x + 1, scaleRatio.x):
		for j in range(-scaleRatio.y + 1, scaleRatio.y):
			node.grid.grid[node.grid.worldToGrid(node.position) + Vector2(i, j)].occupier[node.block.layer] = node.grid.grid[node.grid.worldToGrid(node.position)].occupier[node.block.layer]
	node.scale = node.block.scale
	
func getInput(grid: Grid, recieverBlock: BlockData) -> BlockData: 
	return grid.grid[grid.worldToGrid(recieverBlock.centre)].occupier[recieverBlock.layer - 1]

func momentumToLinearVelocity(momentum: float):
		return momentum / inertia
		
func linearVelocityToMomentum(linearVelocity: float):
		return linearVelocity * inertia

func revolve(senderCenter: Vector2, senderRotation: float, receiverCenter: Vector2) -> Vector2:
	var radius: float = senderCenter.distance_to(receiverCenter)
	return senderCenter + Vector2(radius * cos(senderRotation), radius * sin(senderRotation))
