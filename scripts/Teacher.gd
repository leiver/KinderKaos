extends KinematicBody2D


export (int) var speed = 100
var velocity = Vector2()
var is_holding_toddler = false
var is_holding_cookie = false
var held_toddler = null
var dead = false

onready var pickup_box = $PickupBox
onready var animatedSprite = $AnimatedSprite
onready var cookieSprite = $Cookie

signal i_am_dead
signal let_down_toddler

func _process(delta):
		if not dead:
			get_input()
			velocity = move_and_slide(velocity)


func get_input():
		velocity = Vector2()
		if Input.is_action_just_pressed("ui_accept"):
			handle_pick_up()
		var collision_shape_x = 0.5
		var collision_shape_y = 0
		if Input.is_action_pressed("ui_down"):
			collision_shape_y = 17
			velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			collision_shape_y = -20
			velocity.y -= 1
		if Input.is_action_pressed("ui_right"):
			collision_shape_x = 22
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			collision_shape_x = -22
			velocity.x -= 1
		pickup_box.get_node("CollisionShape2D").position = Vector2(collision_shape_x, collision_shape_y)
		set_animation()
		velocity = velocity.normalized() * speed


func handle_pick_up():
	if is_holding_toddler:
		if held_toddler.poopy_diaper:
			for area in pickup_box.get_overlapping_areas():
				if "ChangingTable" == area.name:
					held_toddler.clean_diaper()
					return
		held_toddler.let_down()
		remove_child(held_toddler)
		emit_signal("let_down_toddler", held_toddler, position)
		is_holding_toddler = false
	elif is_holding_cookie:
		for area in pickup_box.get_overlapping_areas():
			if "Toddler" in area.get_parent().name and area.get_parent().hungry:
				area.get_parent().feed()
		cookieSprite.visible = false
		is_holding_cookie = false
	else:
		var overlapping_areas = pickup_box.get_overlapping_areas()
		var area_to_pick = null
		var closest_distance = -1
		for area in overlapping_areas:
			if "Toddler" in area.get_parent().name or "CookieJar" == area.name:
				var distance_from_sweetspot = (pickup_box.position + position).distance_to(area.get_parent().position + area.position)
				if area_to_pick == null or closest_distance > distance_from_sweetspot:
					area_to_pick = area
					closest_distance = distance_from_sweetspot
		if area_to_pick != null:
			if "Toddler" in area_to_pick.get_parent().name:
				var toddler = area_to_pick.get_parent()
				toddler.get_parent().remove_child(toddler)
				add_child(toddler)
				held_toddler = toddler
				toddler.position = Vector2(0, 25)
				toddler.picked_up()
				is_holding_toddler = true
			elif "CookieJar" == area_to_pick.name:
				is_holding_cookie = true
				cookieSprite.visible = true


func kill():
	dead = true
	animatedSprite.play("dead")
	emit_signal("i_am_dead")

func set_animation():
	if velocity.x == 0 and velocity.y == 0:
		animatedSprite.play("default")
	elif velocity.x == 0:
		if velocity.y > 0:
			animatedSprite.play("walk_down")
		else:
			animatedSprite.play("walk_up")
	elif velocity.x > 0:
		animatedSprite.play("walk_right")
	else:
		animatedSprite.play("walk_left")
