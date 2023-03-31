@tool
extends Node2D

var destroy = false
var last_key = ""
var sound = true

func _ready():
	if sound:
		$AudioStreamPlayer.play()
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("default")
	$AnimatedSprite.rotation = randf_range(0.0, PI)
	$AnimatedSprite.scale = Vector2(1.0, 1.0) * randf_range(0.5, 1.0)
	
	$AnimationPlayer.play("default")
	$Timer.start()
	$Label.text = last_key
	$Label.modulate = Color(rand_range(0,2), rand_range(0,2), rand_range(0,2))

func _on_Timer_timeout():
	if destroy:
		queue_free()
