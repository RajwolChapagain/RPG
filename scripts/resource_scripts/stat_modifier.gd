extends Resource
class_name StatModifier

@export_enum('attack_damage', 'max_hp', 'hp', 'dodge', 'accuracy', 'crit', 'defence') var stat_name: String
@export_enum('+', '-', '*', '/') var modification: String
@export var percentage: bool
@export var amount: float
var abilities: Array[PackedScene]

func _init(stat_name = 'attack_damage', modification = '+', percentage = true, amount = 10.0, abilities: Array[PackedScene] = []) -> void:
	self.stat_name = stat_name
	self.modification = modification
	self.percentage = percentage
	self.amount = amount
	self.abilities = abilities
