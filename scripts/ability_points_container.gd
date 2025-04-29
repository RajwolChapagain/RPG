extends HFlowContainer

@export var max_points: int = 5
@export var points: int = 2
@export var ability_point_scene: PackedScene = load("res://scenes/ability_point.tscn")

func _ready() -> void:
	for i in range(max_points):
		var ability_point = ability_point_scene.instantiate()
		add_child(ability_point)
