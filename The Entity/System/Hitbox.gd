extends Area2D
class_name Hitbox

###########################	
##	Created by	: Chino
##	Created		: SEP 20 2021
##	Description	: Damages overlapping hurtboxes
###########################	

export var damage : float = 0
export var life : float = -1 setget set_life # Life of hitbox (In seconds)

func _ready():
	set_life(life)
	
# Set the bounds of the hitbox using Rect2 (global pos)
func set_global_rect(rect : Rect2):
	var new_shape : RectangleShape2D = RectangleShape2D.new()
	new_shape.extents = rect.size*0.5;
	$CollisionShape2D.global_position = rect.position + new_shape.extents
	$CollisionShape2D.shape = new_shape

func set_life(new_life : float):
	life = new_life
	if (life >= 0):
#		Add a timer to count down to destroy
		var _timer : Timer = Timer.new()
		_timer.connect("timeout", self, "_on_life_timer_timeout")
		_timer.autostart = true
		_timer.wait_time = life
		add_child(_timer)

func _on_Hitbox_area_entered(area):
#	TODO if ever needed (Hurtboxes usually take care of damage calc)
	pass

func _on_Hitbox_area_exited(area):
#	TODO if ever needed (Hurtboxes usually take care of damage calc)
	pass

func _on_life_timer_timeout():
	queue_free()
