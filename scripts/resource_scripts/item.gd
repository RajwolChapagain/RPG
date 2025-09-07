extends Resource
class_name Item

@export var name: String
@export var type: ItemType
@export var stats: Array[StatModifier]
	
enum ItemType { EQUIPPABLE, CONSUMABLE }

func _init(name = "Default Item", type = ItemType.EQUIPPABLE, stats: Array[StatModifier] = []) -> void:
	self.name = name
	self.type = type
	self.stats = stats
	
func _to_string() -> String:
	return name
