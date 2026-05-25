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

@export_group('Labels')
@export var name_label: Label
@export var hp_label: Label
@export var max_label: Label
@export var atk_label: Label
@export var def_label: Label
@export var crt_label: Label
@export var eva_label: Label
@export var acc_label: Label
@export var ap_label: Label
@export var ap_slots_label: Label
@export var abilities_label: Label

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
			name_label.text = label_text
		elif stat_name == 'hp':
			hp_label.text = label_text
		elif stat_name == 'max_hp':
			max_label.text = label_text
		elif stat_name == 'attack_damage':
			atk_label.text = label_text
		elif stat_name == 'defence':
			def_label.text = label_text
		elif stat_name == 'dodge':
			eva_label.text = label_text
		elif stat_name == 'accuracy':
			acc_label.text = label_text
		elif stat_name == 'crit':
			crt_label.text = label_text
		elif stat_name == 'ap_per_attack':
			ap_label.text = label_text
		elif stat_name == 'ap_slots':
			ap_slots_label.text = label_text
		elif stat_name == 'abilities':
			abilities_label.text = label_text
			
func get_character_name() -> String:
	return stats.name
