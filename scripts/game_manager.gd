extends Node

var party
var inventory_manager

func get_alive_players() -> Array[Player]:
	if party != null:
		return party.get_players()
	else:
		push_warning('Warning: Party was not declared in the scene tree. Returning empty array.')
		return []

func set_party(party) -> void:
	self.party = party

func set_inventory_manager(inventory_manager) -> void:
	self.inventory_manager = inventory_manager
	
func increase_available_inventory_slots() -> void:
	assert(inventory_manager != null)
	inventory_manager.increase_slots()

func queue_player_for_purging(player_name: String) -> void:
	for player in party.get_players():
		if player.stats.name == player_name:
			player.stats.hp = 0
			inventory_manager.remove_character_inventory(player_name)
			inventory_manager.add_item(crystalize_stat(player.get_modified_stats()))
	
func crystalize_stat(stats: BaseStats) -> Item:
	var item = Item.new("%s's Essence" % stats.name, Item.ItemType.CONSUMABLE, [], stats.abilities)
	var stat_names = ['attack_damage', 'max_hp', 'dodge', 'accuracy', 'crit', 'defence']
	
	for stat_name in stat_names:
		item.stats.append(StatModifier.new(stat_name, '+', false, stats.get(stat_name)))
		
	return item

func make_player_consume_item(player_name: String, item: Item) -> void:
	for player: Player in party.get_players():
		if player.stats.name == player_name:
			player.consume_item(item)
