extends Area2D
class_name Hurtbox

###########################	
##	Created by	: Chino
##	Created		: SEP 20 2021
##	Description	: Receives damage from Hitboxes
###########################	

signal on_damagers_changed

var hitboxes : Array = [] #Things to apply damage to each frame


func _on_Hurtbox_area_entered(hitbox):
	hitboxes.push_back(hitbox)
	emit_signal("on_damagers_changed", hitboxes, {"added": hitbox, "removed" : null})


func _on_Hurtbox_area_exited(hitbox):
	var has_hitbox = hitboxes.has(hitbox)
	if has_hitbox:
		hitboxes.erase(hitbox)
	emit_signal("on_damagers_changed", hitboxes, {"added": null, "removed": hitbox})
