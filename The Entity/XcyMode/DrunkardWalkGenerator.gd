extends "res://Level/SquareRandomRoom/DrunkardWalkGenerator.gd"

var room_template_2 = preload("res://XcyMode/AlternateSquareRandomRoom.tscn")
var xcy_max_rooms = 2

func _init():
	room_template = room_template_2
	max_rooms = xcy_max_rooms
