@tool
extends Node2D

var destroy = false
var last_key = ""
var sound = true
var color_counter = 0

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
	var colors = [Color("#5BCEFA"), Color("#F5A9B8"), Color("white"), Color("#F5A9B8"), Color("#5BCEFA"), Color("white")]
	# $Label.modulate = Color(randf_range(0,2), randf_range(0,2), randf_range(0,2))
	$Label.modulate = colors[color_counter % 6] 

func _on_Timer_timeout():
	if destroy:
		queue_free()
