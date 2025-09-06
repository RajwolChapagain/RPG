extends Resource
class_name StatModifier

@export_enum("attack_damage", "max_hp", "hp") var stat_name: String
@export_enum("add", "subtract", "multiply", "divide") var modification: String
@export var percentage: bool
@export var amount: float
