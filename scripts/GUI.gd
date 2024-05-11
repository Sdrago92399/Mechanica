extends CanvasLayer

var invSize = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in invSize:
		var slot = InventorySlot.new(BlockData.new(BlockTypes.GEAR), Vector2(32,32))
		$inv.add_child(slot)
	print($inv.get_child_count())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		self.visible = !self.visible
