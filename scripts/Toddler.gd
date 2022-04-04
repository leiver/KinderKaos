extends KinematicBody2D

signal kill_me
signal path_me_to_outlet
signal i_am_dead

onready var timers = $ToddlerTimers
onready var animated_sprite = null
onready var hunger_bubble = $SpeechBubbles/HungerBubble
onready var poop_bubble = $SpeechBubbles/PoopBubble
onready var fork_bubble = $SpeechBubbles/ForkBubble
onready var scissor_bubble = $SpeechBubbles/ScissorBubble
onready var speech_bubbles = $SpeechBubbles
onready var eating_sound = $SFX/EatingSound
onready var shocked_sound = $SFX/ShockedSound
onready var battered_sound = $SFX/BatteredSound

export var id : int

var rotation_speed = PI
var rotation_direction = 0
var speed = 100
var direction = rotation
var velocity = Vector2.ZERO

var walking = false
var walking_to_target = false
var dead = false
var death_reason = null
var waiting = false
var hungry_or_poopy_diaper = false
var hungry = false
var poopy_diaper = false
var going_to_hazardouds_object = false
var holding_hazardous_object = false
var holding_fork = false
var holding_scissor = false
var being_held = false
var eating = false
var getting_shocked = false

var targets : Array
var target : Vector2

func _ready():
	animated_sprite = get_node("ToddlerVariations").get_child(randi()%7)
	animated_sprite.visible = true
	animated_sprite.play("default")
	randomize()
	handle_rotation_timer_timeout()
	handle_walking_timer_timeout()
	timers.start_default_suicidal_thoughts_timer()
	timers.start_default_hunger_timer()


func disable():
	set_process(false)
	timers.stop_all_timers()
	if not dead:
		animated_sprite.play("default")
	for speech_bubble in speech_bubbles.get_children():
		speech_bubble.visible = false


func _process(delta):
	if not dead and not waiting and not being_held:
		if walking_to_target:
			walk_towards_target(delta)
		else:
			idle(delta)
	set_animation()


func set_animation():
	if dead:
		if getting_shocked:
			animated_sprite.play("getting_shocked")
		else:
			animated_sprite.play(death_reason)
	elif eating:
		animated_sprite.play("eating")
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
	direction = fmod(direction + ((rotation_speed + (int(holding_scissor) * (PI/2))) * delta * rotation_direction) + (PI*2), PI*2)
	if walking or holding_scissor:
		velocity = Vector2.UP.rotated(direction) * (speed + (int(holding_scissor) * 50))
		move_and_slide(velocity)


func walk_towards_target(delta):
	direction = fmod(position.angle_to_point(target) + (PI*1.5), PI*2)
	velocity = Vector2.UP.rotated(direction) * speed
	var distance_to_target = position.distance_to(target)
	if distance_to_target < position.distance_to(position + (velocity * delta)):
		position = target
		if targets.size() == 0:
			walking_to_target = false
		else:
			target = targets.pop_front()
			timers.start_timer("WaitTimer", 0.5)
			waiting = true
	else:
		move_and_slide(velocity)


func receive_path_to_target(received_targets : Array):
	if received_targets.size() > 0 and not walking_to_target and not holding_scissor:
		targets = received_targets
		target = targets.pop_front()
		walking_to_target = true


func receive_path_to_hazard(received_targets : Array):
	if received_targets.size() > 0 and not going_to_hazardouds_object and not holding_hazardous_object:
		targets = received_targets
		target = targets.pop_front()
		walking_to_target = true


func kill(reason):
	if not dead:
		if reason == "shocked":
			shocked_sound.play()
		else:
			battered_sound.play()
		death_reason = reason
		dead = true
		hungry = false
		hungry_or_poopy_diaper = false
		holding_hazardous_object = false
		disable_timers()
		for speech_bubble in speech_bubbles.get_children():
			speech_bubble.visible = false
		emit_signal("i_am_dead", self)


func picked_up():
	going_to_hazardouds_object = false
	being_held = true
	walking_to_target = false


func let_down():
	being_held = false


func feed():
	eating = true
	waiting = true
	hunger_bubble.visible = false
	timers.start_default_eating_timer()
	timers.stop_timer("StarvationTimer")
	eating_sound.play()


func clean_diaper():
	hungry_or_poopy_diaper = false
	poopy_diaper = false
	timers.stop_timer("DysentryTimer")
	poop_bubble.visible = false
	timers.start_default_hunger_timer()


func receive_hazardous_object(hazardous_object):
	if not hungry_or_poopy_diaper and going_to_hazardouds_object:
		going_to_hazardouds_object = false
		holding_hazardous_object = true
		walking_to_target = false
		if hazardous_object == "Fork":
			emit_signal("path_me_to_outlet", self)
			fork_bubble.visible = true
			holding_fork = true
		elif hazardous_object == "Scissors":
			scissor_bubble.visible = true
			holding_scissor = true
			timers.start_timer("ScissorTimer", rand_range(10, 20))


func remove_hazardous_object():
	if holding_hazardous_object:
		holding_hazardous_object = false
		holding_scissor = false
		holding_fork = false
		fork_bubble.visible = false
		scissor_bubble.visible = false
		walking_to_target = false
		timers.stop_timer("ScissorTimer")
		


func _on_Area2D_area_entered(area):
	if area.name == "Outlet" and holding_fork:
		getting_shocked = true
		kill("shocked")
		timers.start_default_shocked_timer()
		


func _on_ToddlerTimers_timeout(timer):
	if timer == "StarvationTimer":
		kill("starved")
	
	if timer == "DysentryTimer":
		kill("poisoned")
	
	if timer == "ScissorTimer":
		kill("battered")
	
	elif timer == "PoopTimer":
		if holding_hazardous_object or going_to_hazardouds_object:
			timers.start_timer("PoopTimer", 10)
		else:
			hungry_or_poopy_diaper = true
			poopy_diaper = true
			poop_bubble.visible = true
			timers.start_default_dysentry_timer()
	
	elif timer == "HungerTimer":
		if holding_hazardous_object or going_to_hazardouds_object:
			timers.start_timer("HungerTimer", 10)
		else:
			hungry_or_poopy_diaper = true
			hungry = true
			hunger_bubble.visible = true
			timers.start_timer("StarvationTimer", 30)
	
	elif timer == "SuicidalThoughtsTimer":
		if not going_to_hazardouds_object and not holding_hazardous_object and not being_held:
			emit_signal("kill_me", self)
		timers.start_default_suicidal_thoughts_timer()
	
	elif timer == "WaitTimer":
		waiting = false
	
	elif timer == "WalkingTimer":
		handle_walking_timer_timeout()
	
	elif timer == "RotationTimer":
		handle_rotation_timer_timeout()
	
	elif timer == "EatingTimer":
		eating = false
		waiting = false
		hungry_or_poopy_diaper = false
		hungry = false
		timers.start_default_poop_timer()
	
	elif timer == "ShockedTimer":
		getting_shocked = false


func handle_rotation_timer_timeout():
	rotation_direction = rand_range(-1, 1)
	rotation_speed = PI + rand_range(0, PI/2)
	timers.start_timer("RotationTimer", rand_range(0.5, 2 - (1.5 * int(holding_scissor))))


func handle_walking_timer_timeout():
	walking = not walking
	speed = rand_range(25, 50)
	if walking:
		timers.start_timer("WalkingTimer", rand_range(2, 4))
	else:
		timers.start_timer("WalkingTimer", rand_range(1, 3))


func disable_timers():
	timers.stop_all_timers()
