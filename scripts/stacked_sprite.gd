@tool
class_name StackedSprite extends Node2D

@export var texture:Texture2D
@export var slices_width:int = 16
@export var vertical_spacing:float = .8
@export_range(0, 360) var sprite_rotation:float = 0.0:
	set(val):
		sprite_rotation = val
		if is_inside_tree():
			update_sprites()

@onready var camera:Camera2D = get_viewport().get_camera_2d()
@onready var sprite_hframes:int = texture.get_width() / slices_width

var old_rotation:float = -1.0

func stack_sprites() -> void :
	
	#deletes previous sprites (if exists)
	if get_child_count() > 0:
		for child in get_children():
			child.queue_free()
	
	if texture == null:
		push_warning("No texture assigned!")
		return
	
	#create a Sprite2D node for each hframe and offset
	#their y-position based on order
	for i in range(sprite_hframes):
		var stacked_sprite:Sprite2D = Sprite2D.new()
		stacked_sprite.texture = texture
		stacked_sprite.hframes = sprite_hframes
		stacked_sprite.frame = i
		stacked_sprite.position.y = -i * vertical_spacing
		add_child.call_deferred(stacked_sprite)

func _ready() -> void:
	stack_sprites()

func _physics_process(delta: float) -> void:
		old_rotation = sprite_rotation
		update_sprites()

func update_sprites() -> void:
	if camera:
		rotation_degrees = camera.rotation_degrees - get_parent().rotation_degrees
		
		for i in get_children():
			i.rotation_degrees = sprite_rotation - camera.rotation_degrees
			
			var compare_pos:Vector2 = camera.global_position
			var forward:Vector2 = Vector2.UP.rotated(camera.rotation)
			var depth:float = (global_position - compare_pos).dot(forward)
			#z_index = -int(depth)
	else:
		for i in get_children():
			i.rotation_degrees = sprite_rotation
