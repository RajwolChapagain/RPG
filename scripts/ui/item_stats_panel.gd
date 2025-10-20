class_name ItemStatsPanel
extends Control

@export var current_item: Item

func _ready() -> void:
	if current_item != null:
		populate_label()
		
func populate_label() -> void:
	var out = ''
	out += 'Type: %s\n' % Item.ItemType.keys()[current_item.type]
	
	var num_stats = len(current_item.stats)
	for i in range(num_stats):
		var stat_modifier: StatModifier = current_item.stats[i]
		out += stat_modifier.modification
		out += str(stat_modifier.amount)
		if stat_modifier.percentage:
			out += '%'
		out += ' %s' % stat_modifier.stat_name
		out += '\n'
		
	if len(current_item.abilities) != 0:
		out += 'Abilities: '
		
	var i = 0
	for ability: PackedScene in current_item.abilities:
		var temp_ability = ability.instantiate()
		out += temp_ability.ability_name
		if i != len(current_item.abilities) - 1:
			out += ', '
		i += 1
		temp_ability.queue_free()
	
	%Label.text = out
