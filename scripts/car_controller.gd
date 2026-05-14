class_name CarController extends RigidBody2D

@export var IN_CONTROL:bool = true
@export var WHEEL_BASE:float = 70.0
@export var STEERING_ANGLE:float = 15.0
@export var ENGINE_POWER:float = 700.0 # Increased for RigidBody mass
@export var BRAKING:float = -450.0
@export var MAX_SPEED:float = 300.0
@export var MAX_REVERSE_SPEED:float = 250.0
@export var SLIP_SPEED = 400.0  
@export var TRACTION_FAST = 0.05  
@export var TRACTION_SLOW = 0.4 

@onready var sprite = $StackedSprite
#@onready var smokeL = $SmokeL
#@onready var smokeR = $SmokeR
#@onready var sparks = $Sparks

var steer_angle:float = 0.0
var acceleration:Vector2 = Vector2.ZERO
var turn:int = 0
var heading:Vector2 = Vector2.ZERO

func _ready():
	# RigidBody setup for top-down driving
	gravity_scale = 0.0 
	linear_damp = 1.0 # Replaces your manual friction for simple cases
	angular_damp = 5.0

func _physics_process(delta: float) -> void:
	get_input()
	# Sprite sync now uses global_transform since RigidBody handles its own position
	sprite.sprite_rotation = rotation_degrees
	
	if self.is_in_group('InControl'):
		if Input.is_action_just_pressed('interact'):
			print('wleo')
			leave_vehicle()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Best practice: apply movement forces inside _integrate_forces for RigidBodies
	if self.is_in_group('InControl'):
		var current_velocity = state.linear_velocity
		heading = transform.x
		
		# Calculate Steering & Traction
		var traction = TRACTION_SLOW
		if current_velocity.length() > SLIP_SPEED:
			traction = TRACTION_FAST
		
		# Determine new direction based on wheel positions
		var rear_wheel = position - heading * WHEEL_BASE / 2.0
		var front_wheel = position + heading * WHEEL_BASE / 2.0
		
		rear_wheel += current_velocity * state.step
		front_wheel += current_velocity.rotated(steer_angle) * state.step
		var new_heading = (front_wheel - rear_wheel).normalized()
		
		# Apply Traction (adjusting velocity directly in state)
		var d = new_heading.dot(current_velocity.normalized())
		if d > 0:
			state.linear_velocity = current_velocity.lerp(new_heading * min(current_velocity.length(), MAX_SPEED), traction)
		elif d < 0:
			state.linear_velocity = -new_heading * min(current_velocity.length(), MAX_REVERSE_SPEED)
		
		# Update Rotation to match heading
		state.angular_velocity = 0 # Prevent unwanted spinning
		rotation = new_heading.angle()

		# Apply Engine Power/Brakes
		
	apply_central_force(acceleration)

func leave_vehicle():
	for nodes in get_tree().get_nodes_in_group("InControl"):
		nodes.remove_from_group("InControl")
	
	var player:Player = get_tree().current_scene.get_node('Player')
	print(player != null)
	if player:
		player.position = position + Vector2(0,-10).rotated(rotation)
		player.show()
		player.interaction_hitbox.disabled = false
		player.hitbox.disabled = false
		
		player.add_to_group('InControl')
		var camera = get_viewport().get_camera_2d()
		camera.change_subject()
		camera.roaming_angle = camera.rotation

func get_input():
	if self.is_in_group('InControl'):
		turn = Input.get_axis("steer_left", "steer_right")
		steer_angle = turn * deg_to_rad(STEERING_ANGLE)

		acceleration = Vector2.ZERO
		if Input.is_action_pressed("accelerate"):
			acceleration = heading * ENGINE_POWER
		elif Input.is_action_pressed("brake"):
			acceleration = heading * BRAKING
