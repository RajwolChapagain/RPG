class_name ItemStatsPanel
extends Panel

@export var current_item: Item

func _ready() -> void:
	if current_item != null:
		populate()
		await get_tree().process_frame
		reset_size()
		size.x = %MarginContainer.get_combined_minimum_size().x
		
		await get_tree().process_frame
		size.y = %MarginContainer.get_combined_minimum_size().y
		
func populate() -> void:
	%TypeLabel.text = 'Type: %s' % Item.ItemType.keys()[current_item.type]
	
	var num_stats = len(current_item.stats)
	for i in range(num_stats):
		var stat_modifier: StatModifier = current_item.stats[i]

		var out = ''
		out += stat_modifier.modification
		out += str(stat_modifier.amount as int)
		if stat_modifier.percentage:
			out += '%'
			
		var stat_name = stat_modifier.stat_name
		
		if stat_name == 'ap_slots':
			%APSlotsRow.visible = true
			%APSlotsLabel.text = out
			continue
		
		if stat_name == 'hp':
			out += ' HP'
		elif stat_name == 'max_hp':
			out += ' MAX'
		elif stat_name == 'attack_damage':
			out += ' ATK'
		elif stat_name == 'defence':
			out += ' DEF'
		elif stat_name == 'dodge':
			out += ' EVA'
		elif stat_name == 'accuracy':
			out += ' ACC'
		elif stat_name == 'crit':
			out += ' CRT'
		elif stat_name == 'ap_per_attack':
			out += ' AP'

		var label: Label = Label.new()
		label.text = out
		label.add_theme_font_size_override('font_size', 6)
		%HFlowContainer.add_child(label)
		
	if len(current_item.abilities) != 0:
		%AbilitiesColumn.visible = true
		
	var abilities_text = ''
	var i = 0
	for ability: PackedScene in current_item.abilities:
		var temp_ability = ability.instantiate()
		abilities_text += '- %s' % temp_ability.ability_name
		temp_ability.queue_free()
		if i != len(current_item.abilities) - 1:
			abilities_text += '\n'
	
	%AbilitiesLabel.text = abilities_text
