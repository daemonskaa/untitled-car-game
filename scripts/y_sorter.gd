@tool
class_name YSorter extends Node2D
# Custom Y-Sorting that works with camera rotation

@export var update_interval: float = 0.05

var _timer: float = 0.0

func _ready() -> void:
	_apply_sorting()

func _process(delta: float) -> void:
	_timer += delta
	_apply_sorting()

func _apply_sorting() -> void:
	var cam: Camera2D = get_viewport().get_camera_2d()
	if not cam:
		#push_warning("YSorter: No camera found.")
		return
	
	# sort individual nodes
	for node in get_tree().get_nodes_in_group("YSorted"):
		if node is CanvasItem and is_instance_valid(node) and node.is_inside_tree():
			var canvas_item: CanvasItem = node as CanvasItem
			var screen_pos: Vector2 = cam.get_canvas_transform() * canvas_item.global_position
			canvas_item.z_index = max(int(screen_pos.y), 0)
