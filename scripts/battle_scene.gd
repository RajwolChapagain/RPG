extends Node

@export var character_spacing = 30
@export var player_character_stats : Array[BaseStats]= []
@export var enemy_stats : Array[BaseStats]= []
@export var ability_button: PackedScene
@export var MAIN_MENU_SCENE: PackedScene
var battler_player = preload("res://scenes/battler_player.tscn")
var battler_enemy = preload("res://scenes/battler_enemy.tscn")
var player_characters: Array[Battler] = []
var enemies: Array[Battler] = []
var active_index = 0
var first_attacker_index = 0
var players_turn = true
var alive_player_count: int
var alive_enemy_count: int
var num_attacked: int = 0
var camera_shaking := false
var camera_shake_time_left: float = 0.0
var battle_ongoing: bool = true
var battle_won: bool = false

@export var win_text: String = "Battle Won! :)"
@export var lose_text: String = "Battle Lost! :("

signal battle_ended

func initialize_battle(init_player_stats: Array[BaseStats], init_enemy_stats: Array[BaseStats], init_first_attacker_index: int = 0) -> void:
	self.player_character_stats = init_player_stats
	self.enemy_stats = init_enemy_stats
	self.first_attacker_index = init_first_attacker_index
	
func _ready() -> void:
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
		
# Precondition: new_index points to an alive battler
func update_active_battler(new_index):
	if players_turn:
		if num_attacked != 0: # Mark last attacking player inactive if turn didn't just start
			player_characters[active_index].mark_inactive()
		
		if battle_ongoing:
			player_characters[new_index].mark_active()
		
	active_index = new_index
	
func on_player_battler_died(player_name: String) -> void:
	alive_player_count -= 1
	if player_name == 'Magda':
		var rachelle_is_dead = true
		
		for player_character_stat in player_character_stats:
			if player_character_stat.name == 'Rachelle' and player_character_stat.hp > 0:
				rachelle_is_dead = false
				
		if rachelle_is_dead:
			end_battle(false)
	elif player_name == 'Rachelle':
		var magda_is_dead = true
		
		for player_character_stat in player_character_stats:
			if player_character_stat.name == 'Magda' and player_character_stat.hp > 0:
				magda_is_dead = false
				
		if magda_is_dead:
			end_battle(false)
	
func on_enemy_battler_died(_enemy_name: String) -> void:
	alive_enemy_count -= 1
	if alive_enemy_count == 0:
		end_battle(true)
	
func grab_focus_with_attack_button() -> void:
	%AttackButton.grab_focus()
	
#region initialization
func spawn_players() -> void:
	for i in range(len(player_character_stats)):
		var player_character = battler_player.instantiate()
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
		var enemy = battler_enemy.instantiate()
		enemy.stats = enemy_stats[i]
		enemy.position = Vector2($EnemyStart.position.x + ( -(len(enemy_stats) - 1) * int(character_spacing / 2.0)) + i * character_spacing, $EnemyStart.position.y)
		enemy.is_player = false
		enemies.append(enemy)
		call_deferred("add_child", enemy)
		
	connect_enemy_animation_started_signal()
	connect_enemy_animation_finished_signal()
	connect_enemy_battler_died_signal()
	
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
		advance_turn()
		
func on_enemy_animation_finished(animation: StringName) -> void:
	if animation == "attack":
		advance_turn()
		
func on_enemy_animation_started(animation: StringName) -> void:
	if animation == "attack":
		pass
		
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
	
#endregion initialization

#region turntaking
func advance_turn() -> void:
	# Tick effects down for all battlers
	for battler: Battler in (player_characters + enemies):
		battler.TICK_EFFECTS_DOWN()
		
	num_attacked += 1
	if players_turn:
		if num_attacked == alive_player_count:
			end_player_turn()
			return
		
		var next_player_index = active_index
		for i in range(len(player_characters)):
			next_player_index = (next_player_index + 1) % len(player_characters)
			if player_characters[next_player_index].stats.hp != 0:
				break
			
		update_active_battler(next_player_index)
	else:
		if num_attacked == alive_enemy_count:
			end_enemy_turn()
			return
		
		var next_alive_enemy_index = active_index + 1
		for i in range(next_alive_enemy_index, len(enemies)):
			if enemies[next_alive_enemy_index].is_alive:
				break
			next_alive_enemy_index += 1
		
		update_active_battler(next_alive_enemy_index)
		call_deferred('attack_random_player') # Call deferred so that if more code is added to advance_turn after
											  # this else statement in the future, advance_turn finishes
											  # execution before attack_random_player is called
	
func end_player_turn() -> void:
	num_attacked = 0
	player_characters[active_index].mark_inactive()
	players_turn = false
	
	var first_alive_enemy_index = -1
	for enemy in enemies:
		if enemy.is_alive:
			first_alive_enemy_index += 1
			break
		first_alive_enemy_index += 1
		
	assert(first_alive_enemy_index != -1)
	
	update_active_battler(first_alive_enemy_index)
	disable_attack_button()
	attack_random_player()

func end_enemy_turn() -> void:
	num_attacked = 0

	players_turn = true
	for i in range(len(player_characters)):
		if player_characters[first_attacker_index].stats.hp != 0:
			break
		first_attacker_index = (first_attacker_index + 1) % len(player_characters)
	update_active_battler(first_attacker_index)
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
		
	for battler: Battler in get_resonant_battlers():
		player_characters[active_index].attack(battler)
		
	await get_tree().process_frame
	enable_attack_button()
	
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
	for battler: Battler in resonant_battlers:
		var copied_ability: Ability = ability.duplicate()
		add_child(copied_ability)
		copied_ability.execute(player_characters[active_index], battler)
		await copied_ability.ability_finished_execution
		
	advance_turn()
	enable_abilities_button()
	enable_attack_button()
	
### Enemy Attacking ###

# Precondition: active_index points to an alive enemy
func attack_random_player() -> void:
	# Check to prevent attacking after primary player characters have died
	if not battle_ongoing:
		return
		
	if not enemies[active_index].is_alive:
		return
		
	var is_player_hit = enemies[active_index].attack(get_alive_players().pick_random())
	if is_player_hit:
		shake_camera(0.8, 0.15)
	
	for battler: Battler in get_resonant_battlers():
		enemies[active_index].attack(battler)
		
#endregion attacking

func end_battle(won: bool) -> void:
	battle_ongoing = false
	disable_attack_button()
	disable_abilities_button()
	if won:
		MusicManager.play_music('victory', false)
		%ResultAnnouncementLabel.text = win_text
		battle_won = true
	else:
		%ResultAnnouncementLabel.text = lose_text
	%ResultAnnouncementLabel.visible = true
	%ResultAnnouncementLabel/AnimationPlayer.play("fade_in")

func _on_abilities_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%PlayerInfos.visible = false
		create_abilities_list()
	else:
		destroy_abilities_list()
		%PlayerInfos.visible = true

func create_abilities_list() -> void:
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
	await player_characters[active_index].play_ability_animation()

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
	if anim_name == "fade_in":
		battle_ended.emit(player_character_stats, battle_won)
		%BattleCam.enabled = false
		GameManager.disable_party_camera_smoothing()

func shake_camera(magnitude: float, duration: float) -> void:
	if camera_shaking:
		camera_shake_time_left += duration
		return 
		
	camera_shaking = true
	camera_shake_time_left += duration
	var original_pos = %BattleCam.global_position
	while camera_shake_time_left >= 0:
		%BattleCam.global_position = original_pos + Vector2(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude))
		await get_tree().process_frame
		camera_shake_time_left -= get_process_delta_time()
	
	%BattleCam.global_position = original_pos
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
	
#endregion helpers
