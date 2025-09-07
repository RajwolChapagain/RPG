extends Control

@export var character_name: String
@export var portrait: Texture2D
@export var equipped_items: Array[Item]

var activated_slots = 2
const MAX_SLOTS = 4

func _ready() -> void:
	for i in range(MAX_SLOTS):
		if i < activated_slots:
			%SlotContainer.get_child(i).activate()
