extends Path2D

var bullet_template = preload("res://Entity/Bullet/BulletPathFollower.tscn")
var bullet_amount = 24
export(float) var speed : float  = 0
export(Vector2) var dir : Vector2  = Vector2(0,0)
var spin_speed = 0.2
var base_grow_time = .5
var grow_time = base_grow_time
var growing = true
var base_point_positions = []
var target_point_positions = []
var time = 0

func _ready():
	var new_curve = Curve2D.new()
	for k in range(curve.get_point_count()):
		var pos = curve.get_point_position(k)
		target_point_positions.push_back(pos)
		var new_pos = Vector2(pos.x/10.0,pos.y/10.0)
		base_point_positions.push_back(new_pos)
		new_curve.add_point(new_pos,curve.get_point_in(k), curve.get_point_out(k), k)
	curve = new_curve
	
	for k in range(bullet_amount):
		var i = bullet_template.instance()
		add_child(i)
		i.disable_visibility_delete()
		i.unit_offset = float(k)/bullet_amount

func _physics_process(_delta):
	time += _delta
	grow_time = max(0, grow_time - _delta)
	if growing:
		if grow_time == 0:
			growing = false
		var percent = 1 - grow_time/base_grow_time
		for k in range(curve.get_point_count()):
			curve.set_point_position(k, lerp(base_point_positions[k], target_point_positions[k], percent))
	
	position += dir*speed*_delta
	var ki = 0
	for k in get_children():
		if k.is_in_group('bullet_follower'):
			k.unit_offset = fposmod(float(ki)/bullet_amount + time*spin_speed, 1)
			ki += 1
	rotation_degrees = rad2deg(dir.angle())
	
func set_base_angle(base_angle, min_h = 0, max_h = 1):
	for k in get_children():
		if k.is_in_group('bullet_follower'):
			k.get_node('Bullet').set_base_angle(base_angle, min_h, max_h)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
