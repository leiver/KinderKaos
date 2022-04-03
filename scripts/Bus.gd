extends KinematicBody2D


onready var animated_sprite = $AnimatedSprite
onready var driving_timer = $DrivingTimer

var original_position = Vector2(0, 0)
var drive_to = Vector2(0,0)
var driving = false
var drive_speed = 300

func _ready():
	driving_timer.start(10)
	animated_sprite.play("default")
	original_position = Vector2(position.x, position.y)
	drive_to = Vector2(position.x + 2000, position.y)


func _process(delta):
	if driving:
		position = position.move_toward(drive_to, delta * drive_speed)
		if position == drive_to:
			position = original_position
			driving = false
			driving_timer.start(10)
			


func _on_Area2D_area_entered(area):
	if "Toddler" in area.get_parent().name:
		area.get_parent().kill()


func _on_DrivingTimer_timeout():
	driving = true
