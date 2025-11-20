extends Node

var party
var inventory_manager

func get_alive_players() -> Array[Player]:
	if party != null:
		return party.get_players()
	else:
		push_warning('Warning: Party was not declared in the scene tree. Returning empty array.')
		return []

func set_party(new_party) -> void:
	self.party = new_party

func set_inventory_manager(new_inventory_manager) -> void:
	self.inventory_manager = new_inventory_manager
	
func increase_available_inventory_slots() -> void:
	assert(inventory_manager != null)
	inventory_manager.increase_slots()
	
func crystalize_stat(stats: BaseStats) -> Item:
	var item = Item.new("%s's Essence" % stats.name, Item.ItemType.CONSUMABLE, [], stats.abilities)
	var stat_names = ['attack_damage', 'max_hp', 'dodge', 'accuracy', 'crit', 'defence', 'ap_per_attack']
	
	for stat_name in stat_names:
		item.stats.append(StatModifier.new(stat_name, '+', false, stats.get(stat_name)))
		
	return item

func make_player_consume_item(player_name: String, item: Item) -> void:
	for player: Player in party.get_players():
		if player.stats.name == player_name:
			player.consume_item(item)

func add_items_to_inventory(items: Array[Item]) -> void:
	assert(inventory_manager != null)
	for item in items:
		inventory_manager.add_item(item)
		
func is_alive(player_name: String) -> bool:
	return player_name.to_lower() in get_alive_players().map(func (player): return player.stats.name.to_lower())

func remove_character_inventory(player_name: String) -> void:
	inventory_manager.remove_character_inventory(player_name)
	
func drop_player_essence(player_stats: BaseStats) -> void:
	var items: Array[Item] = []
	items.append(crystalize_stat(player_stats))
	ItemDropManager.drop_items(items)

func enable_party_camera_smoothing() -> void:
	assert(party != null)
	party.enable_camera_smoothing()
	
