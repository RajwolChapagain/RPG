extends HFlowContainer

@export var max_points: int = 5
@export var points: int = 2
@export var ability_point_scene: PackedScene = load("res://scenes/ability_point.tscn")

var ability_points = []

func _ready() -> void:
	for i in range(max_points):
		var ability_point = ability_point_scene.instantiate()
		add_child(ability_point)
		ability_points.append(ability_point)
	
	play_activate_animation(0, points)
	
func increase_points(value: int) -> void:
	var old_points = points
	points += value
	points = clampi(points, 0, max_points)
	play_activate_animation(old_points, points - old_points)

func decrease_points(value: int) -> void:
	var old_points = points
	points -= value
	points = clampi(points, 0, max_points)
	play_deactivate_animation(points, old_points - points)

func play_activate_animation(start_index: int, count: int) -> void:
	for i in range(start_index, start_index + count):
		ability_points[i].get_node("AnimationPlayer").play("activate")

func play_deactivate_animation(start_index, count: int) -> void:
	for i in range(start_index, start_index + count):
		ability_points[i].get_node("AnimationPlayer").play("deactivate")
