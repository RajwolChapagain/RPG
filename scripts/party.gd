extends Node2D

@export var character_scenes: Array[PackedScene]

var party_members = []

func _ready() -> void:
	for scene in character_scenes:
		var character = scene.instantiate()
		add_child(character)
		party_members.append(character)
