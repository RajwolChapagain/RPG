extends Resource
class_name Item

@export var name: String
@export var type: ItemType
@export var stats: Array[StatModifier]
@export var abilities: Array[PackedScene]

enum ItemType { EQUIPPABLE, CONSUMABLE }

func _init(name = "Default Item", type = ItemType.EQUIPPABLE, stats: Array[StatModifier] = [], abilities: Array[PackedScene] = []) -> void:
	self.name = name
	self.type = type
	self.stats = stats
	self.abilities = abilities
	
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
