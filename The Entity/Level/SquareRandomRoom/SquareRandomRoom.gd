extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum WALLS {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

func open_tiles(tile_map : TileMap):
	tile_map.set_collision_layer_bit(1, false)
	tile_map.set_collision_mask_bit(0, false)
	tile_map.hide()

func open(dir : int):
	match(dir):
		WALLS.UP:
			open_tiles($ExitBlockers/Up)
		WALLS.RIGHT:
			open_tiles($ExitBlockers/Right)
		WALLS.LEFT:
			open_tiles($ExitBlockers/Left)
		WALLS.DOWN:
			open_tiles($ExitBlockers/Down)
