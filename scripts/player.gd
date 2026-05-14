class_name Player extends CharacterBody2D
@export var WALKING_SPEED:float = 15.0

@onready var interaction:Area2D = $Interaction
@onready var interaction_hitbox:CollisionShape2D = $Interaction/CollisionShape2D
@onready var hitbox:CollisionShape2D = $CollisionShape2D

signal interaction_enter(name:String, obj:Node2D)
signal interaction_exit(name:String, obj:Node2D)

var movement:Vector2 = Vector2.ZERO

func player_input() -> void :
	if self.is_in_group('InControl'):
		movement = Input.get_vector("steer_left", "steer_right", "accelerate", "brake").normalized()
		velocity = movement.rotated(get_viewport().get_camera_2d().rotation) * WALKING_SPEED
		
		if interaction.has_overlapping_bodies() and Input.is_action_just_pressed("interact"):
			for body in interaction.get_overlapping_bodies():
				if body is CarController:
					ride_vehicle(body)
					break



func _physics_process(delta: float) -> void:
	player_input()
	move_and_slide()
	$StackedSprite.sprite_rotation

func can_interact(body:Node2D) -> bool:
	return body is CarController

func ride_vehicle(vehicle:CarController) -> void :
	for nodes in get_tree().get_nodes_in_group("InControl"):
		nodes.remove_from_group("InControl")
	
	hide()
	hitbox.disabled = true
	interaction_hitbox.disabled = true
	
	vehicle.add_to_group('InControl')
	get_viewport().get_camera_2d().change_subject()


func _on_interaction_body_entered(body: Node2D) -> void:
	if can_interact(body):
		if body is CarController:
			interaction_enter.emit('Enter', body)


func _on_interaction_body_exited(body: Node2D) -> void:
	if can_interact(body):
		if body is CarController:
			interaction_exit.emit('Enter', body)
