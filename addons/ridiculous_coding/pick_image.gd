@tool
extends TextureRect

var images = [
	"res://addons/ridiculous_coding/images/bg_image.png",
	"res://addons/ridiculous_coding/images/72593797_p0.png",
	# "res://addons/ridiculous_coding/images/bingle.png",
	"res://addons/ridiculous_coding/images/lain.webp",
	"res://addons/ridiculous_coding/images/maid.png",
	"res://addons/ridiculous_coding/images/92968690_p0_master1200.png"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.texture = load(images[randi() % len(images)])
