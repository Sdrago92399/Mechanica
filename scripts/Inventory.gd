extends CanvasLayer

signal block_selected(block_type: String, parameters: Dictionary)
signal connect_mode_started()
signal interface_mode_started()

@onready var block_type = ""
@onready var parameters = {
	"linearVelocity": 0,
	"momentum": 0,
	"inertia": 100,
	"length": 128
}
@onready var connect_mode = false
@onready var interface_mode = false

func _ready():
	$VBoxContainer/ButtonSource.connect("pressed", Callable(self, "_on_button_source_pressed"))
	$VBoxContainer/ButtonGear.connect("pressed", Callable(self, "_on_button_gear_pressed"))
	$VBoxContainer/ButtonRod.connect("pressed", Callable(self, "_on_button_rod_pressed"))
	$VBoxContainer/ButtonConnect.connect("pressed", Callable(self, "_on_connect_pressed"))
	$VBoxContainer/ButtonInterface.connect("pressed", Callable(self, "_on_interface_pressed"))
	$VBoxContainer/Size.connect("value_changed", Callable(self, "_on_parameter_changed").bind("Size"))

func _on_button_source_pressed():
	block_type = "Source"
	connect_mode = false
	interface_mode = false
	emit_signal("block_selected", block_type, parameters)

func _on_button_gear_pressed():
	block_type = "Gear"
	connect_mode = false
	interface_mode = false
	emit_signal("block_selected", block_type, parameters)

func _on_button_rod_pressed():
	block_type = "Rod"
	connect_mode = false
	interface_mode = false
	emit_signal("block_selected", block_type, parameters)

func _on_connect_pressed():
	connect_mode = true
	interface_mode = false
	block_type = "Rod"
	emit_signal("connect_mode_started", block_type, parameters)

func _on_interface_pressed():
	connect_mode = false
	interface_mode = true
	block_type = ""
	emit_signal("interface_mode_started")

func _on_parameter_changed(value, parameter_name):
	parameters[parameter_name] = value
