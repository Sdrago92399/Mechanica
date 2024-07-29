extends Node2D

@onready var grid: Grid = $Grid
@onready var inventory: CanvasLayer = $Inventory
@onready var occupier_label: Label = $OccupierLabel

@export var cell_size: int = 128
var selected_block_type: String = ""
var selected_parameters: Dictionary = {}
var connect_mode = false
var interface_mode = false
var connect_start: Vector2
var connect_end: Vector2
var awaiting_second_click = false

# Import the RLAgent class
var rl_agent: RLAgent

# Called when the node enters the scene tree for the first time.
func _ready():
	grid.generateGrid()
	inventory.connect("block_selected", Callable(self, "_on_block_selected"))
	inventory.connect("connect_mode_started", Callable(self, "_on_connect_mode_started"))
	inventory.connect("interface_mode_started", Callable(self, "_on_interface_mode_started"))
	
	rl_agent = RLAgent.new()
	add_child(rl_agent)
	rl_agent.connect("block_selected", Callable(self, "_on_block_selected"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var local_mouse_pos = grid.to_local(mouse_pos)
	var grid_pos = grid.worldToGrid(local_mouse_pos)
	
	if grid_pos in grid.grid:
		var occupiers_info = ""
		for layer in grid.grid[grid_pos].occupier.keys():
			var block = grid.grid[grid_pos].occupier[layer]
			if block:
				occupiers_info += str(layer) + ": " + block.mode + "\n"
		occupier_label.text = occupiers_info
		occupier_label.position = mouse_pos + Vector2(10, 10)
		occupier_label.visible = true
	else:
		occupier_label.visible = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if selected_block_type != "":
			if grid_pos in grid.grid:
				if connect_mode:
					if awaiting_second_click:
						if grid_pos != connect_start: # Ensure the second click is different
							connect_end = grid_pos
							place_block(connect_start, connect_end)
							connect_mode = false
							awaiting_second_click = false
					else:
						connect_start = grid_pos
						awaiting_second_click = true
				else:
					place_block(grid_pos)
		else:
			if grid_pos in grid.grid:
				if interface_mode:
					if awaiting_second_click:
						if grid_pos != connect_start: # Ensure the second click is different
							connect_end = grid_pos
							print("yee")
							if grid.grid[connect_start].occupier[0] is GearData and grid.grid[connect_end].occupier[0] is GearData:
								print("yea")
								rl_agent.start_reinforcement_learning(connect_start, connect_end, grid)
							interface_mode = false
							awaiting_second_click = false
					else:
						print("yeo")
						connect_start = grid_pos
						awaiting_second_click = true

func _on_block_selected(block_type: String, parameters: Dictionary):
	selected_block_type = block_type
	selected_parameters = parameters

func _on_connect_mode_started(block_type: String, parameters: Dictionary):
	connect_mode = true
	selected_block_type = block_type
	selected_parameters = parameters

func _on_interface_mode_started():
	interface_mode = true

func place_block(pos: Vector2, end_pos: Vector2 = Vector2()):
	var block: Object
	var size = selected_parameters["Size"] if selected_parameters.has("Size") else 64
	if selected_block_type == "Source":
		block = GearData.new()
		block.config(size, 0.2, 15, 0, 100, "source")
		grid.addBlock(pos, "Gear", block, 0)
	elif selected_block_type == "Gear":
		block = GearData.new()
		block.config(size, 0.2, 15, 0, 100)
		grid.addBlock(pos, "Gear", block, 0)
	elif selected_block_type == "Rod":
		if end_pos != Vector2():
			var center_pos = (grid.gridToWorld(pos) + grid.gridToWorld(end_pos)) / 2 + Vector2(cell_size / 2, cell_size / 2)
			var rod_length = pos.distance_to(end_pos)
			var angle = rad_to_deg(pos.angle_to_point(end_pos))
			block = RodData.new()
			block.config(0, 100, rod_length, "connect", angle)
			grid.addBlock(center_pos, "Rod", block, 1)
		else:
			block = RodData.new()
			block.config(0, 100, size / 10, "cam")
			grid.addBlock(pos, "Rod", block, 1)
	selected_block_type = ""
	selected_parameters = {}
