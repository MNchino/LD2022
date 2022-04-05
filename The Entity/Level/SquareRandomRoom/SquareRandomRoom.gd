extends Node2D

var goal_template = preload("res://Level/RoomLayouts/GoalCenter.tscn")
var spawn_template = preload("res://Level/RoomLayouts/SpawnCenter.tscn")
var left_blockers = [preload("res://Level/RoomLayouts/LeftBlocker1.tscn"),preload("res://Level/RoomLayouts/LeftBlocker2.tscn"),preload("res://Level/RoomLayouts/LeftBlocker3.tscn"),preload("res://Level/RoomLayouts/LeftBlocker4.tscn"),preload("res://Level/RoomLayouts/LeftBlocker5.tscn")]
var right_blockers = [preload("res://Level/RoomLayouts/RightBlocker2.tscn"), preload("res://Level/RoomLayouts/RightBlocker1.tscn")]
var up_blockers = [preload("res://Level/RoomLayouts/UpBlocker1.tscn"),preload("res://Level/RoomLayouts/UpBlocker2.tscn"),preload("res://Level/RoomLayouts/UpBlocker3.tscn"),]
var down_blockers = [preload("res://Level/RoomLayouts/DownBlocker1.tscn"), preload("res://Level/RoomLayouts/DownBlocker2.tscn")]
var centers = [preload("res://Level/RoomLayouts/Center1.tscn"),preload("res://Level/RoomLayouts/Center2.tscn"),preload("res://Level/RoomLayouts/Center3.tscn"),preload("res://Level/RoomLayouts/Center4.tscn"),preload("res://Level/RoomLayouts/Center5.tscn")]

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum WALLS {
	UP,
	RIGHT,
	DOWN,
	LEFT
}
var center_set = false
	
func block_left():
	spawn_blocker(left_blockers)
	
func block_right():
	spawn_blocker(right_blockers)
	
func block_down():
#	var i = spawn_blocker()
#	for child in i.get_children():
#		turn_tilemap(child)
	spawn_blocker(down_blockers)
			
			
func block_up():
	spawn_blocker(up_blockers)
	
func spawn_blocker(blockers_array):
	var blocker_to_use = blockers_array[randi()%blockers_array.size()]
	var i = blocker_to_use.instance()
	add_child(i)
	return i
	
func set_center_if_unset():
	if !center_set:
		spawn_blocker(centers)

func open(dir : int):
	match(dir):
		WALLS.UP:
			block_down()
			block_left()
			block_right()
		WALLS.RIGHT:
			block_down()
			block_left()
			block_up()
		WALLS.LEFT:
			block_down()
			block_right()
			block_up()
		WALLS.DOWN:
			block_left()
			block_right()
			block_up()
			
func set_as_goal_room():
	var i = goal_template.instance()
	add_child(i)
	center_set = true
	
func set_as_spawn_room():
	var i = spawn_template.instance()
	add_child(i)
	center_set = true
