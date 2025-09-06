extends Resource
class_name Item

@export var name: String
@export var type: ItemType
@export var stats: Array[StatModifier]
	
enum ItemType { EQUIPPABLE, CONSUMABLE }
