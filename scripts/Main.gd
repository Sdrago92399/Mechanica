extends Node2D

@onready var grid: Grid = $Grid

# Called when the node enters the scene tree for the first time.
func _ready():
	grid.generateGrid()
	var block: Object
	
	block = BlockData.new(GearData.new())
	block.t.config(79,0.2,15,0,100)
	grid.addBlock(Vector2(0,1), "SourceGear", block, 0)
	
	block = BlockData.new(GearData.new())
	block.t.config(79,0.1,0,0,100)
	grid.addBlock(Vector2(2,1), "Gear", block,0)
	
	block = BlockData.new(GearData.new())
	block.t.config(79,0.2,0,0,100)
	grid.addBlock(Vector2(4,1), "Gear", block, 0)
	
	block = BlockData.new(RodData.new())
	grid.addBlock(Vector2(3,1), "GearXCam", block, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
