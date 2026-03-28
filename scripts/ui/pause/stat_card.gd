extends Control
class_name StatCard

@export var portrait: TextureRect
@export var stat_values: Control

@export var stats: BaseStats:
	get:
		return stats
	set(value):
		if value != null:
			stats = value
			call_deferred('initialize_ui')

@export_group('Portraits')
@export var portrait_dictionary: Dictionary[String, Texture2D]

func initialize_ui() -> void:
	var character_name = stats.name.to_lower()
	if character_name not in portrait_dictionary:
		portrait_dictionary[character_name] = stats.battle_sprite
		
	portrait.texture = portrait_dictionary[character_name]
	update_stats_ui()
	
func update_stats_ui() -> void:
	var stat_names = ['name', 'hp', 'attack_damage', 'defence', 'dodge', 'accuracy', 'crit', 'ap_per_attack', 'abilities']
	
	var i = 0
	for stat_name in stat_names:
		var label_text = ''
		
		if stat_name == 'hp':
			label_text = '%s/%s' % [str(stats.hp), str(stats.max_hp)]
		elif stat_name == 'abilities':
			var j = 0
			for ability in stats.abilities:
				var temp_ability = ability.instantiate()
				label_text += temp_ability.ability_name
				if j != len(stats.abilities) - 1:
					label_text += ', '
				j += 1
				temp_ability.queue_free()
		else:
			label_text = str(stats.get(stat_name))
			
		stat_values.get_child(i).text = label_text
		i += 1
		
func get_character_name() -> String:
	return stats.name
