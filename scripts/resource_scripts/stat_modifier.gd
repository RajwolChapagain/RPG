extends Resource
class_name StatModifier

@export_enum('attack_damage', 'max_hp', 'hp', 'dodge', 'accuracy', 'crit', 'defence') var stat_name: String
@export_enum('+', '-', '*', '/') var modification: String
@export var percentage: bool = false
@export var amount: float

func _init(new_stat_name = 'attack_damage', new_modification = '+', new_percentage = false, new_amount = 10.0) -> void:
	self.stat_name = new_stat_name
	self.modification = new_modification
	self.percentage = new_percentage
	self.amount = new_amount
