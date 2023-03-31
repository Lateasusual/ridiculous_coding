@tool
extends Node2D

var destroy = false
var last_key = ""
var pitch_increase = 0
var sound = true
var blips = true
var color_counter = 0


func _ready():
	if sound:
		$AudioStreamPlayer.pitch_scale = 1.0 + pitch_increase * 0.01
		$AudioStreamPlayer.play()
	if blips:
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("default")
		$AnimationPlayer.play("default")
		$Particles2D.emitting = true
	
	$Timer.start()
	$Label.text = last_key
	# Blue Pink White Pink Blue White
	var colors = [Color("#5BCEFA"), Color("#F5A9B8"), Color("white"), Color("#F5A9B8"), Color("#5BCEFA"), Color("white")]
	# $Label.modulate = Color(randf_range(0,2), randf_range(0,2), randf_range(0,2))
	$Label.modulate = colors[color_counter % 6]
	
func _on_Timer_timeout():
	if destroy:
		queue_free()
