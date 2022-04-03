extends KinematicBody2D

signal request_path_to_other_room()
signal request_path_to_hazard()

onready var rotation_timer = $RotationTimer
onready var walking_timer = $WalkingTimer
onready var target_timer = $TargetTimer
onready var wait_timer = $WaitTimer
onready var animated_sprite = $AnimatedSprite

export var id : int

var rotation_speed = PI
var rotation_direction = 0
var speed = 100
var direction = rotation
var velocity = Vector2.ZERO

var walking = false
var walking_to_target = false
var walking_to_hazard = false
var dead = false
var waiting = false

var targets : Array
var target : Vector2

func _ready():
	animated_sprite.play("default")
	randomize()
	_on_RotationTimer_timeout()
	_on_WalkingTimer_timeout()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not dead and not waiting:
		if walking_to_target or walking_to_hazard:
			walk_towards_target(delta)
		else:
			idle(delta)
	set_animation()


func set_animation():
	if not waiting and (walking or walking_to_hazard or walking_to_target):
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			if velocity.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")
	else:
		animated_sprite.play("default")


func idle(delta):
	direction = fmod(direction + (rotation_speed * delta * rotation_direction) + (PI*2), PI*2)
	if walking:
		velocity = Vector2.UP.rotated(direction) * speed
		move_and_collide(velocity * delta)


func walk_towards_target(delta):
	direction = fmod(position.angle_to_point(target) + (PI*1.5), PI*2)
	velocity = Vector2.UP.rotated(direction) * speed * delta
	var distance_to_target = position.distance_to(target)
	var new_position = position + velocity
	var distance_to_new_position = position.distance_to(new_position)
	if distance_to_target < distance_to_new_position:
		position = target
		if targets.size() == 0:
			if walking_to_hazard:
				dead = true
			walking_to_target = false
			walking_to_hazard = false
		else:
			target = targets.pop_front()
	else:
		move_and_collide(velocity)


func _on_RotationTimer_timeout():
	rotation_direction = rand_range(-1, 1)
	rotation_speed = PI + rand_range(0, PI/2)
	rotation_timer.start(rand_range(0.5, 2))


func _on_WalkingTimer_timeout():
	walking = not walking
	speed = rand_range(25, 50)
	if walking:
		walking_timer.start(rand_range(2, 4))
	else:
		walking_timer.start(rand_range(1, 3))


func receive_path_to_room(received_targets : Array):
	targets = received_targets
	target = targets.pop_front()
	walking_to_target = true
	

func receive_path_to_hazard(received_targets : Array):
	targets = received_targets
	target = targets.pop_front()
	walking_to_hazard = true


func _on_WaitTimer_timeout():
	waiting = false
