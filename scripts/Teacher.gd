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
		if Input.is_action_pressed("ui_down"):
				pickup_box.get_node("CollisionShape2D").position = Vector2(1.5, 27)
				velocity.y += 1
		if Input.is_action_pressed("ui_up"):
				pickup_box.get_node("CollisionShape2D").position = Vector2(1.5, -15)
				velocity.y -= 1
		if Input.is_action_pressed("ui_right"):
				pickup_box.get_node("CollisionShape2D").position = Vector2(23, 0)
				velocity.x += 1
		if Input.is_action_pressed("ui_left"):
				pickup_box.get_node("CollisionShape2D").position = Vector2(-23, 0)
				velocity.x -= 1
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
		for area in overlapping_areas:
			if "Toddler" in area.get_parent().name:
				var toddler = area.get_parent()
				toddler.get_parent().remove_child(toddler)
				add_child(toddler)
				held_toddler = toddler
				toddler.position = Vector2(0, 25)
				toddler.picked_up()
				is_holding_toddler = true
				break
			elif "CookieJar" == area.name:
				is_holding_cookie = true
				cookieSprite.visible = true
				break


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
