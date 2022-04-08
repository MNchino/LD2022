extends Path2D

var bullet_template = preload("res://Entity/Bullet/BulletPathFollower.tscn")
var bullet_amount = 24
export(float) var speed : float  = 0
export(Vector2) var dir : Vector2  = Vector2(0,0)
var spin_speed = 0.2

func _ready():
	for k in range(bullet_amount):
		var i = bullet_template.instance()
		add_child(i)
		i.unit_offset = float(k)/bullet_amount

func _physics_process(_delta):
	position += dir*speed*_delta
	for k in get_children():
		if k.is_in_group('bullet_follower'):
			k.unit_offset = fposmod(k.unit_offset + _delta*spin_speed, 1)

func _process(_delta):
	rotation_degrees = rad2deg(dir.angle())
	
func set_base_angle(base_angle, min_h = 0, max_h = 1):
	for k in get_children():
		if k.is_in_group('bullet_follower'):
			k.get_node('Bullet').set_base_angle(base_angle, min_h, max_h)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
