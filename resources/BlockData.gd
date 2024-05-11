class_name BlockData
extends Resource

@export var name: String
@export var texture: Texture
@export var width: int = 1
@export var height: int = 1 
@export var scale: Vector2 = Vector2(1, 1)
#@export var unbuiltTexture: Texture
#@export var resourcesRequired: Dictionary
#@export var buildingTime: int = 1
#@export var destroyingTime: int = 1

#@export var maxPressure: float = 10 
#@export var maxHeat: float = 10
#@export var dexterity: float = 10

@export var t: Resource
@export var friction: float = 0.1
@export var forceInputDirection: String = "All"
@export var forceOutputDirection: String = "All"
enum motionType{Rotational, Linear}
@export var force: float = 0.0
@export var freeSockets: int = 1
@export var layer: int = 0

var centre: Vector2

func _init(type: Object):
	t = type
			

