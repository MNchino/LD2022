extends Node2D

var secondframe : bool = false
var xcy_frames = preload("res://Sprite/Player/XcyFrames.tres")
var hidden = false

func _ready():
	GameState.connect("player_spawned", self, 'hide_body_from_light')
	GameState.camera.target = self
	$PlayerSprite.play()
	$Audio/DeadHit.play()
	GameState.freeze(0.2)
	if get_tree().get_current_scene().name == "XcyPlayspace":
		$PlayerSprite.frames = xcy_frames
		
func hide_body_from_light(_player):
	if GameState.is_snow_mode && !hidden:
		$PlayerSprite.material = null
		$PlayerSprite.light_mask = 1
		$PlayerSprite.z_as_relative = 0
		$PlayerSprite.z_index = 0
		hidden = true
		call_deferred("reparent",self)
		
func reparent(node):
	var target_new_parent = get_tree().get_nodes_in_group('sortyboy')[0]
	var temp_pos = node.global_position
	node.get_parent().remove_child(node) # error here  
	target_new_parent.add_child(node)
	node.global_position = temp_pos
	
func _process(_delta):
	if $PlayerSprite.frame == 0:
		$PlayerSprite.position.x = rand_range(-1,1)
	else:
		$PlayerSprite.position.x = 0
		if !secondframe:
			secondframe = true
			$Audio/DeadBump.play()

func _on_FinishedDying_timeout():
	GameState.start_death_gui()

func set_xflip(flip : bool):
	$PlayerSprite.flip_h = flip

func drown_sprite():
	$PlayerSprite.animation = "Drown"
