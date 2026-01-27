@tool
extends TileMapLayer

@export var grass_placeholder_atlas_coord: Vector2i
@export var dirt_placeholder_atlas_coord: Vector2i

const NEIGHBORS = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
const NEIGHBORS_TO_ATLAS_COORD = {
		Vector4(TileType.Grass, TileType.Grass, TileType.Grass, TileType.Grass): Vector2i(2, 1), # All corners
		Vector4(TileType.Dirt, TileType.Dirt, TileType.Dirt, TileType.Grass): Vector2i(1, 3) , # Outer bottom-right corner
		Vector4(TileType.Dirt, TileType.Dirt, TileType.Grass, TileType.Dirt): Vector2i(0, 0) , # Outer bottom-left corner
		Vector4(TileType.Dirt, TileType.Grass, TileType.Dirt, TileType.Dirt): Vector2i(0, 2) , # Outer top-right corner
		Vector4(TileType.Grass, TileType.Dirt, TileType.Dirt, TileType.Dirt): Vector2i(3, 3) , # Outer top-left corner
		Vector4(TileType.Dirt, TileType.Grass, TileType.Dirt, TileType.Grass): Vector2i(1, 0) , # Right edge
		Vector4(TileType.Grass, TileType.Dirt, TileType.Grass, TileType.Dirt): Vector2i(3, 2) , # Left edge
		Vector4(TileType.Dirt, TileType.Dirt, TileType.Grass, TileType.Grass): Vector2i(3, 0) , # Bottom edge
		Vector4(TileType.Grass, TileType.Grass, TileType.Dirt, TileType.Dirt): Vector2i(1, 2) , # Top edge
		Vector4(TileType.Dirt, TileType.Grass, TileType.Grass, TileType.Grass): Vector2i(1, 1) , # Inner bottom-right corner
		Vector4(TileType.Grass, TileType.Dirt, TileType.Grass, TileType.Grass): Vector2i(2, 0) , # Inner bottom-left corner
		Vector4(TileType.Grass, TileType.Grass, TileType.Dirt, TileType.Grass): Vector2i(2, 2) , # Inner top-right corner
		Vector4(TileType.Grass, TileType.Grass, TileType.Grass, TileType.Dirt): Vector2i(3, 1) , # Inner top-left corner
		Vector4(TileType.Dirt, TileType.Grass, TileType.Grass, TileType.Dirt): Vector2i(2, 3) , # Bottom-left top-right corners
		Vector4(TileType.Grass, TileType.Dirt, TileType.Dirt, TileType.Grass): Vector2i(0, 1) , # Top-left down-right corners
		Vector4(TileType.Dirt, TileType.Dirt, TileType.Dirt, TileType.Dirt): Vector2i(0, 3) , # No corners
 }

enum TileType { None, Grass, Dirt }

func _ready() -> void:
	for coord: Vector2i in get_used_cells():
		set_display_tile(coord)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		remove_deleted_display_tiles()
		for coord: Vector2i in get_used_cells():
			set_display_tile(coord)
			
func set_tile(coords: Vector2i, atlas_coords: Vector2i) -> void:
	set_cell(coords, 0, atlas_coords, 0)
	set_display_tile(coords)
	
func set_display_tile(pos: Vector2i) -> void:
	for neighbor in NEIGHBORS:
		var new_pos = pos + neighbor
		%DisplayGrid.set_cell(new_pos, 2, calculate_display_tile(new_pos))
	
func remove_deleted_display_tiles() -> void:
	var used_world_cells = get_used_cells()
	for coord: Vector2i in %DisplayGrid.get_used_cells():
		for neighbor: Vector2i in NEIGHBORS:
			var world_neighbor_pos = coord - neighbor
			if world_neighbor_pos not in used_world_cells:
				%DisplayGrid.erase_cell(coord)
		
func calculate_display_tile(coords: Vector2i) -> Vector2i:
	var bot_right = get_world_tile(coords - NEIGHBORS[0])
	var bot_left = get_world_tile(coords - NEIGHBORS[1])
	var top_right = get_world_tile(coords - NEIGHBORS[2])
	var top_left = get_world_tile(coords - NEIGHBORS[3])
	
	return NEIGHBORS_TO_ATLAS_COORD[Vector4(top_left, top_right, bot_left, bot_right)]

func get_world_tile(coords: Vector2i) -> TileType:
	var atlas_coord = get_cell_atlas_coords(coords)
	
	if (atlas_coord == grass_placeholder_atlas_coord):
		return TileType.Grass
	else:
		return TileType.Dirt
