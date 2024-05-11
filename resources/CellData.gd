class_name CellData
extends Object

signal cellChanged(_pos: Vector2)

var pos: Vector2

var floorData: FloorData :
	set(value):
		floorData = value
		emit_signal("cellChanged", pos)
	get:
		return floorData
		
var occupier: Dictionary = {}
	#set(value):
		#occupier = value
		#print("yoo")
		#emit_signal("cellChanged", pos)
	#get:
		#return occupier
		
func _init(_pos: Vector2):
	pos = _pos

@export var name: String
@export var texture: Texture
