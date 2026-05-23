extends Control
class_name StatCard

@export var portrait: TextureRect

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
	var stat_names = ['name', 'hp', 'max_hp', 'attack_damage', 'defence', 'dodge', 'accuracy', 'crit', 'ap_per_attack', 'ap_slots' , 'abilities']
	
	for stat_name in stat_names:
		var label_text = ''
		
		if stat_name == 'abilities':
			var j = 0
			for ability in stats.abilities:
				var temp_ability = ability.instantiate()
				label_text += '- ' + temp_ability.ability_name
				if j != len(stats.abilities) - 1:
					label_text += '\n'
				j += 1
				temp_ability.queue_free()
		else:
			label_text = str(stats.get(stat_name))
			
		if stat_name == 'name':
			%NameLabel.text = label_text
		elif stat_name == 'hp':
			%HPLabel.text = label_text
		elif stat_name == 'max_hp':
			%MAXLabel.text = label_text
		elif stat_name == 'attack_damage':
			%ATKLabel.text = label_text
		elif stat_name == 'defence':
			%DEFLabel.text = label_text
		elif stat_name == 'dodge':
			%EVALabel.text = label_text
		elif stat_name == 'accuracy':
			%ACCLabel.text = label_text
		elif stat_name == 'crit':
			%CRTLabel.text = label_text
		elif stat_name == 'ap_per_attack':
			%APLabel.text = label_text
		elif stat_name == 'ap_slots':
			%APSlotsLabel.text = label_text
		elif stat_name == 'abilities':
			%AbilitiesLabel.text = label_text
			
func get_character_name() -> String:
	return stats.name
