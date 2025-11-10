extends Resource
class_name Item

@export var name: String
@export var type: ItemType
@export var stats: Array[StatModifier]
@export var abilities: Array[PackedScene]

enum ItemType { EQUIPPABLE, CONSUMABLE }

func _init(new_name = "Default Item", new_type = ItemType.EQUIPPABLE, new_stats: Array[StatModifier] = [], new_abilities: Array[PackedScene] = []) -> void:
	self.name = new_name
	self.type = new_type
	self.stats = new_stats
	self.abilities = new_abilities
	
func _to_string() -> String:
	return name

func get_stats_as_string() -> String:
	var out = ''
	var num_stats = len(stats)
	for i in range(num_stats):
		var stat_modifier: StatModifier = stats[i]
		out += stat_modifier.modification
		out += str(stat_modifier.amount)
		if stat_modifier.percentage:
			out += '%'
		out += ' %s' % stat_modifier.stat_name
		if i != num_stats - 1:
			out += ' | '
			
	for ability: PackedScene in abilities:
		out += ' << %s >> ' % str(ability.resource_path)
		
	return out
