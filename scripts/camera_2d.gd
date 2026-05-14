extends Camera2D

@onready var subject
@onready var rotation_speed:float = -0.01
@onready var roaming_angle:float = 0.0

var rotating:bool = false

func _physics_process(delta: float) -> void:
	position = subject.position
	if subject is CarController:
		rotation = lerp_angle(rotation, subject.rotation + PI/2, 0.05)
		zoom = lerp(zoom, Vector2(1,1), 0.1)
	else:
		rotation = lerp_angle(rotation, roaming_angle, 0.05)
		zoom = lerp(zoom, Vector2(1.2,1.2), 0.1)
	
func _input(event):
	# Start rotating with Right Click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		rotating = event.pressed
		
	# Rotate camera based on mouse movement
	if event is InputEventMouseMotion and rotating:
		roaming_angle -= event.relative.x * rotation_speed

func change_subject():
	subject = get_tree().get_first_node_in_group('InControl')

func _ready() -> void:
	change_subject()
