extends Area2D

@export_file('*.csv') var dialogue_file_path: String
@export var dialogue_start_line_number: int

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_character"):
		call_deferred('disable_interactivity')
		DialogueManager.load_dialogue(dialogue_file_path, dialogue_start_line_number, self)

func start_interaction_cooldown_timer() -> void:
	%InteractionCooldownTimer.start()
	
func _on_interaction_cooldown_timer_timeout() -> void:
	enable_interactivity()
	
func enable_interactivity():
	monitoring = true

func disable_interactivity():
	monitoring = false
