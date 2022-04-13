extends Area2D

var can_knock = true
var body = null
var active = false
var time_before_active = 1

func _physics_process(delta):
	if active:
		if can_knock && body != null && is_instance_valid(body):
			print("can", body)
			body.knock_back(get_parent().moving_dir)
			can_knock = false
			$Debuff.start()
	else:
		time_before_active -= delta
		if time_before_active <= 0:
			active = true

func _on_BrambleTrigger_body_entered(_body):
	body = _body
	can_knock = true
	print("reentered")

func _on_Debuff_timeout():
	can_knock = true

func _on_BrambleTrigger_body_exited(body):
	print("exiting body")
	body = null
	can_knock = false
	$Debuff.stop()
