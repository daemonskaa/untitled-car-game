@tool
class_name BuildingPoly extends Node2D

@export_range(1, 512) var WIDTH: int = 128 # X
@export_range(1, 512) var LENGTH: int = 64 # Y
@export_range(1, 512) var HEIGHT:int = 128 # Z

@export_group("Textures")
@export var EAST:Texture2D
@export var WEST:Texture2D
@export var NORTH:Texture2D
@export var SOUTH:Texture2D
@export var TOP:Texture2D

var sprite_rotation:float = 0.0
@onready var camera = get_viewport().get_camera_2d()
@onready var hitbox:CollisionShape2D = $CollisionShape2D
@onready var shadow:LightOccluder2D = $LightOccluder2D

var base_points:Array[Vector2]
var end_points:Array[Vector2]

var rotated_base:Array[Vector2]
var rotated_end:Array[Vector2]

var faces:Dictionary = {
	'west':null,
	'east':null,
	'south':null,
	'north':null,
	'roof':null
}

var face_uvs = PackedVector2Array([
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1)
	])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_points()
	set_face_points(base_points, end_points)

func set_colliders() -> void:
	hitbox.shape.size = Vector2(WIDTH, LENGTH)
	shadow.occluder.polygon = PackedVector2Array(base_points)

func set_points() -> void:
	base_points = [
		Vector2(-WIDTH/2, -LENGTH/2),
		Vector2(-WIDTH/2, LENGTH/2),
		Vector2(WIDTH/2, LENGTH/2),
		Vector2(WIDTH/2, -LENGTH/2)] #TL, BL, BR, TR (counter-clockwise)
	
	end_points = [
		Vector2(-WIDTH/2, -LENGTH/2 - HEIGHT),
		Vector2(-WIDTH/2, LENGTH/2 - HEIGHT),
		Vector2(WIDTH/2, LENGTH/2 - HEIGHT),
		Vector2(WIDTH/2, -LENGTH/2 - HEIGHT)] #TL, BL, BR, TR (counter-clockwise)

func set_face_points(base, end) -> void:
	faces['west'] = PackedVector2Array([
		base[0], end[0], end[1], base[1]])
	faces['east'] = PackedVector2Array([
		base[2], end[2], end[3], base[3]])
	faces['south'] = PackedVector2Array([
		base[3], end[3], end[0], base[0]])
	faces['north'] = PackedVector2Array([
		base[1], end[1], end[2], base[2]])
	faces['roof'] = PackedVector2Array(end)

func update_points() -> void:
	rotated_base.clear()
	rotated_end.clear()
	for point:Vector2 in base_points:
		rotated_base.append(point)
	for point:Vector2 in base_points:
		rotated_end.append(point  + Vector2(0, -HEIGHT).rotated(camera.rotation - rotation))
	
	set_face_points(rotated_base, rotated_end)

func _physics_process(delta: float) -> void:
	sprite_rotation = rotation_degrees
	if not Engine.is_editor_hint():
		update_points()
		queue_redraw()
	else:
		set_colliders()
		

func _draw() -> void:
	var pos:Vector2 = camera.global_position if camera else get_viewport().size / 2
	var face_data = []
	
	# 3. ONLY sort the walls. Leave the roof out of the loop.
	for face_name in faces:
		if face_name == 'roof': continue 

		var points = faces[face_name]
		var area = 0
		for i in range(points.size()):
			var p1 = points[i]
			var p2 = points[(i + 1) % points.size()]
			area -= (p2.x - p1.x) * (p2.y + p1.y)
		
		# Only add to face_data if it's a 'front' face (sign depends on your winding)
		if area > 0: 
			var midpoint = Vector2.ZERO
			for p in points: midpoint += p
			midpoint /= points.size()
			face_data.append({"points": points, "center": global_position + midpoint, "side": face_name})
	
	for face in face_data:
		if face.side == "east":
			draw_polygon(face.points, [Color("white")], face_uvs, EAST)
		if face.side == "west":
			draw_polygon(face.points, [Color("white")], face_uvs, WEST)
		if face.side == "north":
			draw_polygon(face.points, [Color("white")], face_uvs, NORTH)
		if face.side == "south":
			draw_polygon(face.points, [Color("white")], face_uvs, SOUTH)

	draw_polygon(faces['roof'], [Color("white")], face_uvs, TOP)
