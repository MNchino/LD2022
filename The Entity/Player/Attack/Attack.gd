extends Node2D

func _on_DestructionTimer_timeout():
	queue_free()
