extends Area2D

func _ready():
	$DestructionTimer.start()

func _on_DestructionTimer_timeout():
	queue_free()
