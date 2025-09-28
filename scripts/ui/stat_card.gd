extends Control
class_name StatCard

@export var stats: BaseStats:
	get:
		return stats
	set(value):
		if value != null:
			stats = value
			call_deferred('initialize_ui')
			
@export var portraits: PortraitDatabase

func initialize_ui() -> void:
	%Portrait.texture = portraits.get_portrait(stats.name)
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
				label_text += ability.resource_path
				if j != len(stats.abilities) - 1:
					label_text += ', '
				j += 1
		else:
			label_text = str(stats.get(stat_name))
			
		%StatValues.get_child(i).text = label_text
		i += 1
		
func get_character_name() -> String:
	return stats.name
