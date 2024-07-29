class_name Grid
extends TileMap

@export var width: int = 12
@export var height: int = 12
@export var cell_size: int = 128

var blocks = preload("res://scenes/Blocks.tscn").instantiate()
var grid: Dictionary = {}

@export var show_debug: bool = false

func getSize() -> Vector2:
	return Vector2(width, height)

func generateGrid():
	for x in range(width):
		for y in range(height):
			grid[Vector2(x, y)] = CellData.new(Vector2(x, y))
			if show_debug:
				var rect = ReferenceRect.new()
				rect.position = gridToWorld(Vector2(x, y))
				rect.size = Vector2(cell_size, cell_size)
				rect.editor_only = false
				$Debug.add_child(rect)
				var label = Label.new()
				label.position = gridToWorld(Vector2(x, y))
				label.text = str(Vector2(x, y))
				$Debug.add_child(label)
				
func refreshTile(_pos: Vector2) -> void:
	var data = grid[_pos]
	set_cell(0, _pos, data.FloorData.id, data.FloorData.coords)
	set_cell(1, _pos)
		
func gridToWorldFloat(_pos: float) -> float:
	return _pos * cell_size
	
func worldToGridFloat(_pos: float) -> float:
	return floor(_pos / cell_size)
		
func gridToWorld(_pos: Vector2) -> Vector2:
	return _pos * cell_size
	
func worldToGrid(_pos: Vector2) -> Vector2:
	return floor(_pos / cell_size)
	
func addBlock(_pos: Vector2, value: String, init: Resource, layer: int):
	var block: Node2D = blocks.get_node(value).duplicate()
	block.init(init)
	if init.mode != "connect":
		block.position = gridToWorld(_pos) + Vector2(cell_size / 2, cell_size / 2)
	else:
		print("yee")
		block.position = _pos
		_pos = worldToGrid(_pos - Vector2(cell_size / 2, cell_size / 2))
	
	var layer_available = false
	var current_layer = layer
	
	while not layer_available:
		layer_available = true
		if current_layer > 4:
			print("Layer exceeded the maximum allowed layer (4). Discarding block.")
			return
		if grid.has(_pos) and grid[_pos].occupier.has(current_layer) and grid[_pos].occupier[current_layer] is Resource:
			# If any cell in this layer is already occupied, try the next layer
			print("Layer ", current_layer, " occupied by ", grid[_pos].occupier[current_layer], ". Ascending")
			current_layer += 1
			layer_available = false
	
	# Set the layer to the first available layer found
	block.block.layer = current_layer
	grid[_pos].occupier[current_layer] = block.block
	$Blocks.add_child(block)

	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func printGrid():
	for x in range(width):
		for y in range(height):
			print(grid[Vector2(x, y)].occupier, x, y)
		print()
