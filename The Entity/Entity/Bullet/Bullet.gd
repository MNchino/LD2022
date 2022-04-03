extends KinematicBody2D

var speed : float  = 0
var dir : Vector2  = Vector2(0,0)
var parried : bool = false
var parried_location : Vector2 = Vector2(0,0)

func _physics_process(delta):
	if parried:
		global_position = lerp(parried_location, get_parent().global_position,1 - $HomingTime.time_left/$HomingTime.wait_time)
		dir = (get_parent().global_position - global_position).normalized()
	else:
		move_and_slide(dir*speed)

func _process(delta):
	$Light2D.rotation_degrees = rad2deg(dir.angle()) - 90

func _on_ParrySwitcher_area_entered(area):
	parried = true
	parried_location = global_position;
	$ParryHitbox/CollisionShape2D.set_deferred("disabled", false)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Light2D.color = "#ffffff"
	$HomingTime.start()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_ParryHitbox_tree_exiting():
	queue_free()
