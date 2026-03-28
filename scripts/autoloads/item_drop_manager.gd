extends Node

@export var item_button_scene: PackedScene
@export var items_and_rarities: Dictionary[Item, Rarity]
@onready var rarity_bucketed_items: Dictionary[Rarity, Array] = get_rarity_bucketed_items()

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY, MYTHICAL}

# Effective rates: COMMON 55%, UNCOMMON 30%, RARE 12%, LEGENDARY 2.5%, MYTHICAL 0.5%
const RARITY_THRESHOLDS: Dictionary[Rarity, float] = {
	Rarity.COMMON:    55.0,
	Rarity.UNCOMMON:  85.0,
	Rarity.RARE:      97.0,
	Rarity.LEGENDARY: 99.5,
	Rarity.MYTHICAL:  100.0,
}

func drop_items(items: Array[Item]) -> void:
	GameManager.add_items_to_inventory(items)
	display_items(items)
	call_deferred('pause_game')
	
func drop_item_by_name(item_name: String) -> void:
	for item: Item in items_and_rarities:
		if str(item) == item_name:
			drop_items([item])
			return
	
	printerr('Could not drop item with name %s' % item_name)
	
func drop_random_items(rarity_modifier: float = 0.0, item_count: int = 1) -> void:
	var items: Array[Item] = []
	
	for i in range(item_count):
		var roll: float = clampf(randf_range(0.0, 100.0) + rarity_modifier, 0.0, 100.0)
		
		var selected_rarity: Rarity = Rarity.MYTHICAL
		for rarity: Rarity in RARITY_THRESHOLDS:
			if roll < RARITY_THRESHOLDS[rarity]:
				selected_rarity = rarity
				break
				
		items.append(rarity_bucketed_items[selected_rarity].pick_random())
			
	drop_items(items)

func get_rarity_bucketed_items() -> Dictionary[Rarity, Array]:
	var buckets: Dictionary[Rarity, Array] = {}

	for item: Item in items_and_rarities:
		var rarity: Rarity = items_and_rarities[item]
		buckets.get_or_add(rarity, [])
		buckets[rarity].append(item)
		
	return buckets

func display_items(items: Array[Item]) -> void:
	for i in range(len(items)):
		var item_button: ItemButton = item_button_scene.instantiate()
		item_button.initialize(items[i], 1)
		%ItemsContainer.add_child(item_button)
		if %ItemsContainer.get_child_count() == 1:
			item_button.grab_focus()
			item_button.focus_neighbor_top = %ConfirmButton.get_path()
		
	%ItemDropPanel.visible = true
	
func _on_confirm_button_pressed() -> void:
	%ItemDropPanel.visible = false
	while %ItemsContainer.get_child_count() != 0:
		%ItemsContainer.remove_child(%ItemsContainer.get_child(0))
	get_tree().paused = false
	GameManager.enable_party_camera_smoothing()

func pause_game() -> void:
	get_tree().paused = true
	
