@abstract 
class_name Ability extends Node

@export var ability_name: String
@export_multiline var description: String
@export var cost: int

# To be emitted by inherited ability classes at the end of execute function
signal ability_finished_execution

@abstract func execute(_caster: Battler, target: Battler) -> void
