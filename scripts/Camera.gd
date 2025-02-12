extends Camera2D

@export var zoomSpeed: float = 0.05
@export var zoomMin: float = 0.001
@export var zoomMax: float = 2.0
@export var dragSenstivity: float = 1.0
var touch_start

func _input(event):
	if event is InputEventScreenTouch:
		print("yee")
		if event.is_pressed():
			touch_start = event.position
		else:
			touch_start = null
	elif event is InputEventScreenDrag and touch_start:
		position -= event.relative * dragSenstivity / zoom

	if event is InputEventScreenPinchGesture:
		var pinch_delta = event.relative
		zoom += Vector2(pinch_delta, pinch_delta) * zoomSpeed
		zoom = clamp(zoom, Vector2(zoomMin, zoomMin), Vector2(zoomMax, zoomMax))
	
	# Handle mouse events for dragging
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		position -= event.relative * dragSenstivity / zoom
	
	# Handle mouse events for zooming
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(zoomSpeed, zoomSpeed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoomSpeed, zoomSpeed)
		zoom = clamp(zoom, Vector2(zoomMin, zoomMin), Vector2(zoomMax, zoomMax))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
