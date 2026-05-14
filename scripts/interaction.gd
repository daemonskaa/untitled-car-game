extends Control

@onready var player:Player = get_tree().current_scene.get_node('Player')
@onready var camera:Camera2D = get_viewport().get_camera_2d()
@onready var animation:AnimationPlayer = $AnimationPlayer

var body:Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.interaction_enter.connect(interaction_enter)
	player.interaction_exit.connect(interaction_exit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if body:
		change_position(body)

func interaction_enter(command:String, body_:Node2D):
	body = body_
	animation.play('pop_up')

func interaction_exit(command:String, body_:Node2D):
	body = null
	animation.play('pop_out')
	

func change_position(body:Node2D):
	var world_pos = body.global_position + Vector2(0, -15).rotated(camera.rotation)
	var screen_pos = body.get_canvas_transform() * world_pos
	global_position = screen_pos
