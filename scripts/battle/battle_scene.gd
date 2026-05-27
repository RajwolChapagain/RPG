extends Node

@export var character_spacing = 30
@export var player_character_stats : Array[BaseStats]= []
@export var enemy_stats : Array[BaseStats]= []
@export var ability_button: PackedScene
@export var MAIN_MENU_SCENE: PackedScene
var battler_scene = preload("res://scenes/battle/battler.tscn")
var player_characters: Array[Battler] = []
var enemies: Array[Battler] = []
var attackers_this_turn: Array[int] = []
var active_index = 0
var first_attacker_index = 0
var players_turn = true
var alive_player_count: int
var alive_enemy_count: int
var camera_shaking := false
var camera_shake_time_left: float = 0.0
var battle_ongoing: bool = true
var battle_won: bool = false
var enemy_hook: String = ''

@export_category('Hook variables')
@export var nahas_parts: Array[BaseStats]
@export_file('*.csv') var nahas_split_dialogue_file: String
@export var eel_parts: Array[BaseStats]
@export var niall_injured: Array[BaseStats]
@export var niall_parts: Array[BaseStats]
@export var niall_hurt_sprite: Texture2D

signal battle_ended

func initialize_battle(init_player_stats: Array[BaseStats], init_enemy_stats: Array[BaseStats], init_first_attacker_index: int = 0) -> void:
	self.player_character_stats = init_player_stats
	self.enemy_stats = init_enemy_stats
	self.first_attacker_index = init_first_attacker_index
	
func _ready() -> void:
	initialize_ability_points()
	%AbilityPointsContainer.INITIALIZE()
	%AttackButton.grab_focus()
	spawn_players()
	spawn_enemies()
	alive_player_count = len(player_characters)
	alive_enemy_count = len(enemies)
	initialize_ui()
	
func _process(delta: float) -> void:
	update_ui(delta)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed('skip_battle'):
		end_battle(true)
	if event.is_action_pressed('pause'):
		if $TargetSelect.IS_ACTIVE():
			$TargetSelect.DEACTIVATE()
			enable_attack_button()
			get_viewport().set_input_as_handled()

func set_battle_screen(screen: Texture2D) -> void:
	%BattleScreen.texture = screen

func make_level_2_background_visible() -> void:
	%DualGridLevel2.visible = true
	
func update_ui(delta) -> void:
	var hp_bar_speed = 100
	var epsilon = 1
	var health_fields = [%HealthBarP1, %HealthBarP2, %HealthBarP3, %HealthBarP4]
	for i in range(len(player_characters)):
		if abs(health_fields[i].value - player_characters[i].stats.hp) > epsilon:
			if health_fields[i].value < player_characters[i].stats.hp:
				health_fields[i].value += delta * hp_bar_speed
			else:
				health_fields[i].value -= delta * hp_bar_speed
		else:
			health_fields[i].value = player_characters[i].stats.hp
				
	var hp_labels = [%HPLabel1, %HPLabel2, %HPLabel3, %HPLabel4]
	for i in range(len(player_characters)):
		var string = str(int(health_fields[i].value)) + "/" + str(player_characters[i].stats.max_hp)
		hp_labels[i].text = string
	
func on_player_battler_died(player_name: String) -> void:
	alive_player_count -= 1
	if (player_name == 'Rachelle' and GameManager.route == SaveInfo.routes.RACHELLE_ROUTE) or \
		(player_name == 'Magda' and GameManager.route == SaveInfo.routes.MAGDA_ROUTE):
		end_battle(false)
	
func on_enemy_battler_died(_enemy_name: String) -> void:
	alive_enemy_count -= 1
	if alive_enemy_count == 0:
		if enemy_hook == '':
			end_battle(true)
		else:
			var callable_hook = Callable(self, enemy_hook)
			if callable_hook.is_valid():
				callable_hook.call()
			else:
				printerr('Error: Hook %s not found in battle_scene' % enemy_hook)
				end_battle(true)
				
func grab_focus_with_attack_button() -> void:
	if not %AttackButton.disabled:
		%AttackButton.grab_focus()
	else: # In the middle of an abilty like Clairvoyance
		for child in get_children():
			if child is Clairvoyance:
				child.GRAB_FOCUS()
				return
	
#region initialization
func spawn_players() -> void:
	for i in range(len(player_character_stats)):
		var player_character = battler_scene.instantiate()
		player_character.stats = player_character_stats[i]
		player_character.position = Vector2($PlayerStart.position.x +  ( -(len(player_character_stats) - 1) * int(character_spacing / 2.0)) + i * character_spacing , $PlayerStart.position.y)
		player_character.is_player = true
		player_characters.append(player_character)
		call_deferred("add_child", player_character)
		
	connect_player_animation_finished_signal()
	connect_player_battler_died_signal()
	call_deferred('update_active_battler', first_attacker_index) # Deferred because update_active_battler tries to mark
																 # player as active, which attempts to create a tween 
																 # in player battler for sliding but get_tree() returns
																 # null because the scene tree hasn't been created yet

func spawn_enemies() -> void:
	for i in range(len(enemy_stats)):
		var enemy = battler_scene.instantiate()
		enemy.stats = enemy_stats[i]
		enemy.position = Vector2($EnemyStart.position.x + ( -(len(enemy_stats) - 1) * int(character_spacing / 2.0)) + i * character_spacing, $EnemyStart.position.y)
		enemy.is_player = false
		enemies.append(enemy)
		call_deferred("add_child", enemy)
		
	connect_enemy_animation_started_signal()
	connect_enemy_animation_finished_signal()
	connect_enemy_battler_died_signal()
	
#region unused_signals
func connect_player_animation_finished_signal() -> void:
	for character in player_characters:
		character.get_node("AnimationTree").animation_finished.connect(on_player_animation_finished)

func connect_enemy_animation_started_signal() -> void:
	for enemy in enemies:
		enemy.get_node("AnimationTree").animation_started.connect(on_enemy_animation_started)
		
func connect_enemy_animation_finished_signal() -> void:
	for enemy in enemies:
		enemy.get_node("AnimationTree").animation_finished.connect(on_enemy_animation_finished)
		
func on_player_animation_finished(animation: StringName) -> void:
	if animation == "attack":
		pass
		
func on_enemy_animation_finished(animation: StringName) -> void:
	if animation == "attack":
		pass
		
func on_enemy_animation_started(animation: StringName) -> void:
	if animation == "attack":
		pass
#endregion

func connect_player_battler_died_signal() -> void:
	for character in player_characters:
		character.battler_died.connect(on_player_battler_died)
		
func connect_enemy_battler_died_signal() -> void:
	for enemy in enemies:
		enemy.battler_died.connect(on_enemy_battler_died)
		
func initialize_ui() -> void:
	var info_fields = [%P1Info, %P2Info, %P3Info, %P4Info]
	for i in range(len(player_characters), 4):
		info_fields[i].visible = false
		
	initialize_ui_names()
	initialize_hp_bar()
	
func initialize_ui_names() -> void:
	var name_fields = [%NameLabelP1, %NameLabelP2, %NameLabelP3, %NameLabelP4]
	for i in range(len(player_characters)):
		name_fields[i].text = player_characters[i].stats.name
		
func initialize_hp_bar() -> void:
	var hp_bars = [%HealthBarP1, %HealthBarP2, %HealthBarP3, %HealthBarP4]
	for i in range(len(player_characters)):
		hp_bars[i].max_value = player_characters[i].stats.max_hp
		hp_bars[i].value = player_characters[i].stats.hp
	
	# Initialize hp labels
	var hp_labels = [%HPLabel1, %HPLabel2, %HPLabel3, %HPLabel4]
	for i in range(len(player_characters)):
		var string = str(player_characters[i].stats.hp) + "/" + str(player_characters[i].stats.max_hp)
		hp_labels[i].text = string
	
func initialize_ability_points() -> void:
	for stats: BaseStats in player_character_stats:
		%AbilityPointsContainer.max_points += stats.ap_slots
	
#endregion initialization

#region turntaking
# Precondition: new_index points to an alive battler
func update_active_battler(new_index):
	if new_index == -1: # All stunned
		if players_turn:
			end_player_turn()
		else:
			end_enemy_turn()
		return
			
	if players_turn:
		if len(attackers_this_turn) != 0:# Mark last attacking player inactive if turn didn't just start
			await player_characters[active_index].mark_inactive()
		
		if battle_ongoing:
			await player_characters[new_index].mark_active()
		
	active_index = new_index
		
func advance_turn() -> void:
	handle_status_effects()
	if players_turn:
		advance_player_turn()
	else:
		advance_enemy_turn()
		
func advance_player_turn() -> void:
	var next_player_index = get_next_alive_index((active_index + 1) % len(player_characters), player_characters)
				
	if player_characters[next_player_index].get_instance_id() in attackers_this_turn:
		end_player_turn()
		return
		
	update_active_battler(next_player_index)
	enable_attack_button()

func advance_enemy_turn() -> void:
	var next_alive_enemy_index = get_next_alive_index((active_index + 1) % len(enemies), enemies)
	if enemies[next_alive_enemy_index].get_instance_id() in attackers_this_turn:
		end_enemy_turn()
		return
		
	update_active_battler(next_alive_enemy_index)
	attack_random_player()

func handle_status_effects() -> void:
	# Tick effects down for all battlers and apply poison damage
	for battler: Battler in (player_characters + enemies):
		for effect: StatusEffect in battler.status_effects:
			if effect.effect_name == 'Poisoned':
				battler.take_raw_damage(10)
				
		battler.TICK_EFFECTS_DOWN()
	
func end_player_turn() -> void:
	attackers_this_turn.clear()
	await player_characters[active_index].mark_inactive()
	players_turn = false
	
	var next_enemy_index = get_next_alive_index(0, enemies)
	update_active_battler(next_enemy_index)
	if next_enemy_index == -1:
		return
	disable_attack_button()
	attack_random_player()

func end_enemy_turn() -> void:
	attackers_this_turn.clear()
	players_turn = true
	if first_attacker_index == -1:
		first_attacker_index = 0
	first_attacker_index = get_next_alive_index(first_attacker_index, player_characters)
	update_active_battler(first_attacker_index)
	if first_attacker_index == -1:
		return
	enable_attack_button()
	
#endregion turntaking

#region attacking

### Player Attacking ###

func _on_attack_button_button_down() -> void:
	if not players_turn or $TargetSelect.IS_ACTIVE():
		return

	%AbilitiesButton.set_pressed(false)

	$TargetSelect.SET_TARGETS(get_alive_enemies()) 
	$TargetSelect.ACTIVATE(attack_enemy)
	disable_attack_button()

func attack_enemy(enemy) -> void:
	var is_enemy_hit = player_characters[active_index].attack(enemy)
	if is_enemy_hit:
		%AbilityPointsContainer.increase_points(player_characters[active_index].stats.ap_per_attack)
		shake_camera(1, 0.2)
		Input.start_joy_vibration(0, 0.5, 0.8, 0.15)
		
	for battler: Battler in get_resonant_battlers():
		player_characters[active_index].attack(battler)
	
	attackers_this_turn.append(player_characters[active_index].get_instance_id())
	
	await get_tree().process_frame
	advance_turn()
	
func enable_attack_button() -> void:
	if not battle_ongoing:
		return
	%AttackButton.disabled = false
	%AttackButton.set_focus_mode(Control.FOCUS_ALL)
	%AttackButton.grab_focus()
	
func disable_attack_button() -> void:
	%AttackButton.disabled = true
	%AttackButton.set_focus_mode(Control.FOCUS_NONE)

func enable_abilities_button() -> void:
	if not battle_ongoing:
		return
		
	if get_node_or_null("%AbilitiesButton") == null:
		return
		
	%AbilitiesButton.disabled = false
	%AbilitiesButton.set_focus_mode(Control.FOCUS_ALL)
	%AttackButton.set_focus_mode(Control.FOCUS_ALL)
	%AttackButton.grab_focus()

func disable_abilities_button() -> void:
	%AbilitiesButton.disabled = true
	%AbilitiesButton.set_focus_mode(Control.FOCUS_NONE)
	
func on_ability_finished_execution(ability: Ability, resonant_battlers: Array[Battler]) -> void:
	# Check for resonance on resonant battlers
	var copied_ability: Ability = ability
	for battler: Battler in resonant_battlers:
		if not battler.is_alive:
			continue
		copied_ability = copied_ability.duplicate()
		add_child(copied_ability)
		copied_ability.execute(player_characters[active_index], battler)
		await copied_ability.ability_finished_execution
		
	attackers_this_turn.append(player_characters[active_index].get_instance_id())
	advance_turn()
	enable_abilities_button()
	enable_attack_button()
	
### Enemy Attacking ###

# Precondition: active_index points to an alive enemy
func attack_random_player() -> void:
	# Check to prevent attacking after primary player characters have died
	if not battle_ongoing:
		return
		
	var attacking_enemy = enemies[active_index]
	if not attacking_enemy.is_alive:
		return
		
	const ABILITY_USE_CHANCE = 0.25
	
	await attacking_enemy.slide(Vector2.DOWN)
	if not attacking_enemy.stats.abilities.is_empty() and randf() < ABILITY_USE_CHANCE and not is_battler_suppressed(attacking_enemy):
		var ability: Ability = attacking_enemy.stats.abilities.pick_random().instantiate()
		await attacking_enemy.play_ability_animation(ability.ability_name)
		add_child(ability)
		ability.execute(attacking_enemy, get_alive_players().pick_random())
		await ability.ability_finished_execution
		for battler: Battler in get_resonant_battlers():
			var resonated_ability: Ability = attacking_enemy.stats.abilities.pick_random().instantiate()
			add_child(resonated_ability)
			resonated_ability.execute(attacking_enemy, battler)
		
		attackers_this_turn.append(attacking_enemy.get_instance_id())
	else:
		await get_tree().create_timer(0.1).timeout
		var is_player_hit = attacking_enemy.attack(get_alive_players().pick_random())
		if is_player_hit:
			shake_camera(0.8, 0.15)
	
		for battler: Battler in get_resonant_battlers():
			attacking_enemy.attack(battler)
		attackers_this_turn.append(attacking_enemy.get_instance_id())
	
	await get_tree().create_timer(0.2).timeout
	if attacking_enemy != null: # Specifically for Nahas, who gets freed up immediately after dying
		await attacking_enemy.slide(Vector2.UP)
		
	advance_turn()

#endregion attacking

func end_battle(won: bool) -> void:
	battle_ongoing = false
	disable_attack_button()
	disable_abilities_button()
	%ResultAnnouncementLabel.visible = true
	if won:
		MusicManager.play_music('victory', false)
		%ResultAnnouncementLabel/AnimationPlayer.play("victory")
		battle_won = true
	else:
		MusicManager.play_music('defeat', false)
		%ResultAnnouncementLabel/AnimationPlayer.play("defeat")

func _on_abilities_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%PlayerInfos.visible = false
		create_abilities_list()
	else:
		destroy_abilities_list()
		%PlayerInfos.visible = true

func create_abilities_list() -> void:
	if is_battler_suppressed(player_characters[active_index]):
		%AbilitiesContainer.visible = true
		return
		
	for index in range(len(player_characters[active_index].stats.abilities)):
		var ability_scene = player_characters[active_index].stats.abilities[index]
		var ability: Ability = ability_scene.instantiate()
		var button: AbilityButton = ability_button.instantiate()
		button.set_ability(ability)
		button.ability_selected.connect(on_ability_selected)
		if ability.cost > %AbilityPointsContainer.points:
			button.disable_button()
			
		%AbilitiesContainer.add_child(button)
		
		# Set looping navigation
		if index == len(player_characters[active_index].stats.abilities) - 1:
			button.focus_neighbor_bottom = %AbilitiesContainer.get_child(0).get_path()
			%AbilitiesContainer.get_child(0).focus_neighbor_top = button.get_path()
	
	%AbilitiesContainer.visible = true
	%AbilitiesContainer.get_child(0).grab_focus()
	
func destroy_abilities_list() -> void:
	%AbilitiesContainer.visible = false
	while %AbilitiesContainer.get_child_count() != 0:
		%AbilitiesContainer.remove_child(%AbilitiesContainer.get_child(0))
	
func on_ability_selected(ability: Ability) -> void:
	destroy_abilities_list()
	await player_characters[active_index].play_ability_animation(ability.ability_name, ability.owner_character)

	%AbilityPointsContainer.decrease_points(ability.cost)
	
	# Binding the result of get_resonant_battlers() here is crucial as opposed to calling
	# get_resonant_battlers() inside of on_ability_finished_execution() because if the
	# ability being executed applies resonance, then storing the result of get_resonant_battlers()
	# and binding it here prevents double application of resonance as opposed to the other approach
	ability.ability_finished_execution.connect(on_ability_finished_execution.bind(ability, get_resonant_battlers()))
	%AbilitiesButton.set_pressed(false)
	%PlayerInfos.visible = true
	disable_attack_button()
	
	$TargetSelect.SET_TARGETS(get_alive_enemies() + get_alive_players()) 
	$TargetSelect.ACTIVATE(execute_ability_on_target.bind(ability))

func execute_ability_on_target(target: Battler, ability: Ability) -> void:
	add_child(ability)
	ability.execute(player_characters[active_index], target)

func _on_result_label_animation_finished(anim_name: StringName) -> void:
	if anim_name == "victory" or anim_name == "defeat":
		battle_ended.emit(player_character_stats, battle_won)
		%BattleCam.enabled = false
		GameManager.disable_party_camera_smoothing()

func shake_camera(magnitude: float, duration: float) -> void:
	if camera_shaking:
		camera_shake_time_left += duration
		return 
		
	camera_shaking = true
	camera_shake_time_left += duration
	var canvas_layer = BattleManager.get_node('CanvasLayer')
	while camera_shake_time_left >= 0:
		canvas_layer.offset = Vector2(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude))
		await get_tree().process_frame
		camera_shake_time_left -= get_process_delta_time()
	
	canvas_layer.offset = Vector2.ZERO
	camera_shake_time_left = 0.0
	camera_shaking = false

#region helpers
func get_alive_enemies() -> Array[Battler]:
	var alive_enemies: Array[Battler] = []
	for enemy: Battler in enemies:
		if enemy.is_alive:
			alive_enemies.append(enemy)
			
	return alive_enemies

func get_alive_players() -> Array[Battler]:
	var alive_players: Array[Battler] = []
	for player: Battler in player_characters:
		if player.is_alive:
			alive_players.append(player)
	
	return alive_players

func get_resonant_battlers() -> Array[Battler]:
	var resonant_battlers: Array[Battler] = []
	for battler: Battler in (player_characters + enemies):			
		if not battler.is_alive:
			continue
		for effect: StatusEffect in battler.status_effects:
			if effect.effect_name == 'Resonant':
				resonant_battlers.append(battler)
				break # No need to check further effects for this battler
	
	return resonant_battlers
	
func get_next_alive_index(start_index: int, battler_array: Array[Battler]) -> int:
	for i in range(len(battler_array)):
		if battler_array[start_index].is_alive and not is_battler_stunned(battler_array[start_index]):
			return start_index
		
		start_index += 1
		start_index %= len(battler_array)
		
	return -1

func is_battler_stunned(battler: Battler) -> bool:
	for effect: StatusEffect in battler.status_effects:
		if effect.effect_name == 'Stunned':
			return true
			
	return false
	
func is_battler_suppressed(battler: Battler) -> bool:
	for effect: StatusEffect in battler.status_effects:
		if effect.effect_name == 'Suppressed':
			return true
			
	return false
	
func update_player_hps():
	for stats: BaseStats in player_character_stats:
		for player: Player in GameManager.get_alive_players():
			if player.stats.name == stats.name:
				player.stats.hp = stats.hp
				
#endregion helpers

#region hooks

func on_nahas_death() -> void:
	enemies[0].queue_free()
	enemies.clear()
	enemy_stats = nahas_parts
	character_spacing = 50
	spawn_enemies()
	alive_enemy_count = len(enemies)
	enemy_hook = ''
	update_player_hps() # So that if_dead_go_to check functions correctly
	DialogueManager.load_dialogue(nahas_split_dialogue_file)

func on_eel_death() -> void:
	enemies[0].queue_free()
	enemies.clear()
	enemy_stats = eel_parts
	character_spacing = 64
	spawn_enemies()
	alive_enemy_count = len(enemies)
	enemy_hook = ''
	
func on_niall_death() -> void:
	enemies[0].queue_free()
	enemies.clear()
	enemy_stats = niall_injured
	character_spacing = 0
	spawn_enemies()
	alive_enemy_count = len(enemies)
	enemy_hook = 'on_niall_injured_death'
	
func on_niall_injured_death() -> void:
	var niall_pos = enemies[0].global_position
	enemies[0].queue_free()
	var sprite = Sprite2D.new()
	sprite.texture = niall_hurt_sprite
	add_child(sprite)
	sprite.global_position = niall_pos
	enemies.clear()
	enemy_stats = niall_parts
	character_spacing = 36
	spawn_enemies()
	alive_enemy_count = len(enemies)
	enemy_hook = ''
	
#endregion
