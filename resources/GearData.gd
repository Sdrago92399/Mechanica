class_name GearData
extends Resource

const defaultRadius: float = 63.0
var radius: float = defaultRadius
var rotation: float = 0.0
@export var numberOfTeeth: int = 79
@export var teethPerPixel: float = 0.5
@export var angularVelocity: float = 0
@export var torque: float = 0.0
@export var inertia: float = 100.0

func config(numberOfTeeth: int, teethPerPixel: float, angularVelocity: float, torque: float, inertia: float):
	self.numberOfTeeth = numberOfTeeth
	self.teethPerPixel = teethPerPixel
	self.angularVelocity = angularVelocity
	self.torque = torque
	self.inertia = inertia
	self.radius = (numberOfTeeth / teethPerPixel) / (2 * PI)
	
func prepare(node: Node2D):
	node.block.scale = Vector2(node.block.t.radius / node.block.t.defaultRadius, node.block.t.radius / node.block.t.defaultRadius)
	scale(node)
	node.block.centre = node.position
	
func scale(node: Node2D):
	var scaleRatio: Vector2 = (node.block.scale / node.scale).ceil()
	for i in range(-scaleRatio.x + 1, scaleRatio.x):
		for j in range(-scaleRatio.y + 1, scaleRatio.y):
			node.grid.grid[node.grid.worldToGrid(node.position) + Vector2(i, j)].occupier[node.block.layer] = node.grid.grid[node.grid.worldToGrid(node.position)].occupier[node.block.layer]
	node.scale = node.block.scale
	
func getInput(grid: Grid, recieverBlock: BlockData) -> BlockData:
	return grid.grid[grid.worldToGrid(recieverBlock.centre - Vector2(recieverBlock.t.radius, 0)) - Vector2(1,0)].occupier[recieverBlock.layer]
	
func torqueToAngularVelocity(torque: float):
		return torque / inertia
		
func angularVelocityToTorque(abgularVelocity: float):
		return angularVelocity * inertia
		
func rotate(torque: float, rotation: float, time: float) -> float:
	return fmod(rotation + torqueToAngularVelocity(torque) * time, 360.0)
			
func gearToGearTorque(senderToque:float, senderRadius: float, receiverRadius: float) -> float:
	return (receiverRadius * senderToque) / senderRadius
