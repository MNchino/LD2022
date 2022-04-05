extends Node2D

var goal_template = preload("res://Level/RoomLayouts/GoalCenter.tscn")
var spawn_template = preload("res://Level/RoomLayouts/SpawnCenter.tscn")
var left_blockers = [preload("res://Level/RoomLayouts/LeftBlocker1.tscn"),preload("res://Level/RoomLayouts/LeftBlocker2.tscn"),preload("res://Level/RoomLayouts/LeftBlocker3.tscn"),preload("res://Level/RoomLayouts/LeftBlocker4.tscn"),preload("res://Level/RoomLayouts/LeftBlocker5.tscn")]
var right_blockers = [
	preload("res://Level/RoomLayouts/RightBlocker2.tscn"), 
	preload("res://Level/RoomLayouts/RightBlocker1.tscn"),
	preload("res://Level/RoomLayouts/RightBlocker3.tscn"),
	preload("res://Level/RoomLayouts/RightBlocker4.tscn"),
	preload("res://Level/RoomLayouts/RightBlocker5.tscn")
]
var up_blockers = [preload("res://Level/RoomLayouts/UpBlocker1.tscn"),preload("res://Level/RoomLayouts/UpBlocker2.tscn"),preload("res://Level/RoomLayouts/UpBlocker3.tscn"),]
var down_blockers = [
	preload("res://Level/RoomLayouts/DownBlocker1.tscn"), 
	preload("res://Level/RoomLayouts/DownBlocker2.tscn"),
	preload("res://Level/RoomLayouts/BottomBlocker3.tscn"),
	preload("res://Level/RoomLayouts/BottomBlocker4.tscn"),
	preload("res://Level/RoomLayouts/BottomBlocker5.tscn")
]
var centers = [
	preload("res://Level/RoomLayouts/Center1.tscn"),
	preload("res://Level/RoomLayouts/Center2.tscn"),
	preload("res://Level/RoomLayouts/Center3.tscn"),
	preload("res://Level/RoomLayouts/Center4.tscn"),
	preload("res://Level/RoomLayouts/Center5.tscn"),
	preload("res://Level/RoomLayouts/Center6.tscn"),
	preload("res://Level/RoomLayouts/Center7.tscn"),
	preload("res://Level/RoomLayouts/Center8.tscn"),
	preload("res://Level/RoomLayouts/Center9.tscn"),
	preload("res://Level/RoomLayouts/Center10.tscn")
]
var left = null
var right = null
var up = null
var down = null
var is_travelled = false

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

func _ready():
	block_down()
	block_left()
	block_up()
	block_right()
	
func block_left():
	left = spawn_blocker(left_blockers)
	
func block_right():
	right = spawn_blocker(right_blockers)
	
func block_down():
	down = spawn_blocker(down_blockers)
			
			
func block_up():
	up = spawn_blocker(up_blockers)
	
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
			up.queue_free()
		WALLS.RIGHT:
			right.queue_free()
		WALLS.LEFT:
			left.queue_free()
		WALLS.DOWN:
			down.queue_free()
			
func set_as_goal_room():
	var i = goal_template.instance()
	add_child(i)
	center_set = true
	
func set_as_spawn_room():
	var i = spawn_template.instance()
	add_child(i)
	center_set = true

func _on_Area2D_body_entered(_body):
	if !is_travelled:
		GameState.travelled_rooms += 1
		is_travelled = true
		print("entered", GameState.travelled_rooms, "of", GameState.num_rooms)
