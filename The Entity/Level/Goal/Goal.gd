extends Area2D

func _on_Goal_body_entered(body):
	GameState.finish_game(body)
