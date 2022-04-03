extends KinematicBody2D

signal kill_me
signal path_me_to_outlet

onready var rotation_timer = $Timers/RotationTimer
onready var walking_timer = $Timers/WalkingTimer
onready var wait_timer = $Timers/WaitTimer
onready var suicidal_thoughts_timer = $Timers/SuicidalThoughtsTimer
onready var hunger_timer = $Timers/HungerTimer
onready var starvation_timer = $Timers/StarvationTimer
onready var poop_timer = $Timers/PoopTimer
onready var dysentry_timer = $Timers/DysentryTimer
onready var timers = $Timers
onready var animated_sprite = $AnimatedSprite
onready var hunger_bubble = $SpeechBubbles/HungerBubble
onready var poop_bubble = $SpeechBubbles/PoopBubble
onready var fork_bubble = $SpeechBubbles/ForkBubble
onready var speech_bubbles = $SpeechBubbles

export var id : int

var rotation_speed = PI
var rotation_direction = 0
var speed = 100
var direction = rotation
var velocity = Vector2.ZERO

var walking = false
var walking_to_target = false
var dead = false
var waiting = false
var hungry_or_poopy_diaper = false
var hungry = false
var poopy_diaper = false
var holding_hazardous_object = false
var holding_fork = false
var being_held = false

var targets : Array
var target : Vector2

func _ready():
	animated_sprite.play("default")
	randomize()
	_on_RotationTimer_timeout()
	_on_WalkingTimer_timeout()
	start_suicidal_thoughts_timer()
	start_hunger_timer()


func _process(delta):
	if not dead and not waiting and not being_held:
		if walking_to_target:
			walk_towards_target(delta)
		else:
			idle(delta)
	set_animation()


func set_animation():
	if dead:
		animated_sprite.play("dead")
	elif being_held:
		animated_sprite.play("picked_up")
	elif not waiting and (walking or walking_to_target):
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
	if distance_to_target < position.distance_to(position + velocity):
		position = target
		if targets.size() == 0:
			walking_to_target = false
		else:
			target = targets.pop_front()
			wait_timer.start(0.5)
			waiting = true
	else:
		move_and_collide(velocity)


func receive_path_to_target(received_targets : Array):
	if received_targets.size() > 0 and not walking_to_target:
		targets = received_targets
		target = targets.pop_front()
		walking_to_target = true


func disable_timers():
	for timer in timers.get_children():
		timer.stop()


func kill():
	dead = true
	hungry = false
	hungry_or_poopy_diaper = false
	holding_hazardous_object = false
	disable_timers()
	for speech_bubble in speech_bubbles.get_children():
		speech_bubble.visible = false


func picked_up():
	holding_hazardous_object = false
	fork_bubble.visible = false
	being_held = true
	suicidal_thoughts_timer.stop()
	walking_to_target = false


func let_down():
	being_held = false
	suicidal_thoughts_timer.start(3)


func feed():
	hungry_or_poopy_diaper = false
	hungry = false
	starvation_timer.stop()
	hunger_bubble.visible = false
	start_poop_timer()


func clean_diaper():
	hungry_or_poopy_diaper = false
	poopy_diaper = false
	dysentry_timer.stop()
	poop_bubble.visible = false
	start_hunger_timer()


func receive_hazardous_object(hazardous_object):
	if not hungry_or_poopy_diaper:
		holding_hazardous_object = true
		if hazardous_object == "Fork":
			walking_to_target = false
			emit_signal("path_me_to_outlet", self)
			fork_bubble.visible = true
			holding_fork = true


func start_suicidal_thoughts_timer():
	suicidal_thoughts_timer.start(rand_range(10, 30))


func start_hunger_timer():
	hunger_timer.start(rand_range(10, 60))


func start_poop_timer():
	poop_timer.start(rand_range(10, 60))


func start_dysentry_timer():
	dysentry_timer.start(60)


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


func _on_WaitTimer_timeout():
	waiting = false


func _on_SuicidalThoughtsTimer_timeout():
	if not walking_to_target:
		emit_signal("kill_me", self)
		start_suicidal_thoughts_timer()


func _on_HungerTimer_timeout():
	if holding_hazardous_object:
		start_hunger_timer()
	else:
		hungry_or_poopy_diaper = true
		hungry = true
		hunger_bubble.visible = true
		starvation_timer.start(30)


func _on_StarvationTimer_timeout():
	kill()


func _on_PoopTimer_timeout():
	if holding_hazardous_object:
		start_poop_timer()
	else:
		hungry_or_poopy_diaper = true
		poopy_diaper = true
		poop_bubble.visible = true
		start_dysentry_timer()


func _on_DysentryTimer_timeout():
	kill()


func _on_Area2D_area_entered(area):
	if area.name == "Outlet" and holding_fork:
		kill()
