class_name ButtonSound
extends Node

@export var focus_sfx_title: String = 'focus'

func _ready() -> void:
	if get_parent() is not Button:
		push_error('Error: ButtonSound is not parented to Button type')
	else:
		get_parent().focus_entered.connect(on_button_focus_entered)
		
func on_button_focus_entered() -> void:
	UisfxManager.play_sfx(focus_sfx_title)
