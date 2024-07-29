extends Node

class_name RLAgent

signal block_selected(block_type: String, parameters: Dictionary)

var q_table = {}
var learning_rate = 0.1
var discount_factor = 0.9
var exploration_rate = 1.0
var exploration_decay = 0.099

func _init():
	q_table = {}

func start_reinforcement_learning(start: Vector2, end: Vector2, grid: Grid):
	print("Starting reinforcement learning to connect ", start, " to ", end)
	
	var current_pos = start
	var steps = 0
	while current_pos != end and steps < 1000:
		var action = choose_action(current_pos, grid)
		var new_pos = take_action(current_pos, action)
		var reward = get_reward(new_pos, end, grid)
		update_q_table(current_pos, action, reward, new_pos)
		current_pos = new_pos
		steps += 1
		
		if new_pos in grid.grid:
			var block = GearData.new()
			block.config(64, 0.2, 15, 0, 100)
			grid.addBlock(current_pos, "Gear", block, 0)
			await get_tree().create_timer(0.2).timeout # Simulate a short delay between actions

func choose_action(pos: Vector2, grid: Grid) -> String:
	var actions = ["up", "down", "left", "right"]
	var valid_actions = []
	
	# Define grid boundaries
	var grid_width = grid.getSize().x
	var grid_height = grid.getSize().y
	
	# Determine valid actions based on current position
	if pos.y > 0:
		valid_actions.append("up")
	if pos.y < grid_height - 1:
		valid_actions.append("down")
	if pos.x > 0:
		valid_actions.append("left")
	if pos.x < grid_width - 1:
		valid_actions.append("right")
	
	# Shuffle valid_actions to avoid biased order
	valid_actions.shuffle()

	if randf() < exploration_rate:
		return valid_actions[randi() % valid_actions.size()]
	else:
		var max_q = -INF
		var best_action = valid_actions[0]
		for action in valid_actions:
			var q_value = q_table.get([pos, action], 0)
			if q_value > max_q:
				max_q = q_value
				best_action = action
		return best_action

func take_action(pos: Vector2, action: String) -> Vector2:
	if action == "up":
		return pos + Vector2(0, -1)
	elif action == "down":
		return pos + Vector2(0, 1)
	elif action == "left":
		return pos + Vector2(-1, 0)
	elif action == "right":
		return pos + Vector2(1, 0)
	return pos

func get_reward(pos: Vector2, end: Vector2, grid: Grid) -> float:
	
	# Check if pos is the same as end
	if pos == end:
		return 0.0  # No reward if pos is the same as end
	
	var offset = pos - end
	if (offset == Vector2(1, 0) or offset == Vector2(-1, 0) or 
		offset == Vector2(0, 1) or offset == Vector2(0, -1)):
		return 100.0  # Reward for being directly adjacent
	
	# Calculate the distance between pos and end
	var distance = pos.distance_to(end)
	
	# Provide a variable reward based on the inverse of the distance
	var distance_reward = 100.0 * distance
	
	return -distance_reward

func update_q_table(pos: Vector2, action: String, reward: float, new_pos: Vector2):
	var old_q_value = q_table.get([pos, action], 0)
	var max_q_new_pos = -INF
	var actions = ["up", "down", "left", "right"]
	for a in actions:
		var q_value = q_table.get([new_pos, a], 0)
		if q_value > max_q_new_pos:
			max_q_new_pos = q_value
	var new_q_value = old_q_value + learning_rate * (reward + discount_factor * max_q_new_pos - old_q_value)
	q_table[[pos, action]] = new_q_value

	exploration_rate *= exploration_decay
