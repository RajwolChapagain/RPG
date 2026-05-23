extends Node

@export var current_level_number: int = 0
@export var character_selection_screen: PackedScene
@export var levels: Array[PackedScene]
@export var party_scene: PackedScene
@export var character_name_to_scene: Dictionary[String, PackedScene]

var current_level: Level = null
var party: Party = null
var transitioning: bool = false

func _ready() -> void:
	call_deferred('load_level', current_level_number)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		if current_level_number == 0 or transitioning:
			get_viewport().set_input_as_handled()
			
func load_level(level: int) -> void:
	if current_level != null:
		if level == 2 or level == 3:
			transitioning = true
			party.disable_all_player_movement()
			party.disable_cycling()
			MusicManager.play_music('saved', false)
			await play_shroud_animation()
		current_level.queue_free()
	
	if level == 0:
		load_character_selection_screen()
		return
	elif level == 1:
		GameManager.disable_party_camera_smoothing() # So that camera snaps into position before 
											 		 # 		DialogueManger freezes the game at the start of level 1
		
	current_level = levels[level - 1].instantiate()
	await get_tree().process_frame # Otherwise, the next line encounters "Can't flush queries error"
	add_child(current_level)
	current_level.initialize_party_position(party)
	move_child(current_level, 0)
	current_level.level_completed.connect(on_level_completed)
	if level == 2 or level == 3:
		await play_unshroud_animation()
		party.enable_all_player_movement()
		party.enable_cycling()
		transitioning = false

	GameManager.current_level = current_level_number
	
func load_next_level() -> void:
	current_level_number += 1
	await load_level(current_level_number)

func on_level_completed(_level_count: int) -> void:
	if _level_count == 2:
		_on_pause_menu_main_menu_button_pressed()
		print("hwerew")
		return
	await load_next_level()
	%AnimationPlayer.play('saving')
	await %AnimationPlayer.animation_finished
	save_data()

func load_character_selection_screen() -> void:
	var character_selection = character_selection_screen.instantiate()
	add_child(character_selection)
	character_selection.characters_selected.connect(on_characters_selected)
	
func on_characters_selected(names: Array[String]) -> void:
	initialize_party(names)
	set_route(names)
	%PauseMenu.initialize_inventory()
	load_next_level()

func initialize_party(names: Array[String]) -> void:
	party = party_scene.instantiate()
	var character_scenes: Array[PackedScene] = []
	for char_name in names:
		character_scenes.append(character_name_to_scene[char_name].duplicate_deep(Resource.DEEP_DUPLICATE_ALL))
	party.initialize_character_scenes(character_scenes)
	add_child(party)

func set_route(names: Array[String]) -> void:
	if 'Rachelle' not in names:
		GameManager.route = SaveInfo.routes.MAGDA_ROUTE
	else:
		GameManager.route = SaveInfo.routes.RACHELLE_ROUTE
	
func initialize_inventory(inventory_items: Array[Item]) -> void:
	GameManager.add_items_to_inventory(inventory_items)

func activate_item_slots(count: int) -> void:
	for i in range(count-1):
		GameManager.increase_available_inventory_slots()
	
func initialize_character_stats(character_stats: Dictionary[String, BaseStats]) -> void:
	for player: Player in party.get_players():
		player.stats = character_stats[player.stats.name]

func initialize_equipped_items(equipped_items: Dictionary[String, Array]) -> void:
	for player: Player in party.get_players():
		if player.stats.name not in equipped_items:
			continue
		var item_array: Array[Item] = []
		for item: Item in equipped_items[player.stats.name]:
			item_array.append(item)
		player.equipped_items = item_array
	%PauseMenu.initialize_inventory()

func save_data() -> void:
	var save: SaveInfo = SaveInfo.new()
	save.level_number = current_level_number
	for player: Player in party.get_players():
		save.party_member_names.append(player.stats.name)
		save.character_stats[player.stats.name] = player.stats.duplicate(true)
		save.equipped_items[player.stats.name] = player.equipped_items
	save.inventory_items = %PauseMenu.get_inventory_items()
	save.route = GameManager.route
	save.saved_screenshot = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
	save.date_time = Time.get_datetime_dict_from_system()
	SaveManager.save_to_current_slot(save)

func _on_pause_menu_main_menu_button_pressed() -> void:
	if BattleManager.active_battle_scene != null:
		BattleManager.active_battle_scene.queue_free()
		
	var main_menu = load("res://scenes/ui/title/main_menu.tscn").instantiate()
	get_tree().root.add_child(main_menu)
	main_menu.quick_switch_to_main()
	queue_free()
	
func play_shroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate, 1), 9).set_ease(Tween.EASE_IN)
	await tween.finished
	
func play_unshroud_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(%Shroud, 'modulate', Color(%Shroud.modulate, 0), 1).set_ease(Tween.EASE_OUT)
	await tween.finished
