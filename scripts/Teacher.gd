extends KinematicBody2D


export (int) var speed = 100
var velocity = Vector2()
var is_holding = false
var held_toddler = null

onready var pickup_box = $PickupBox
onready var animatedSprite = $AnimatedSprite

signal let_down_toddler

func _process(delta):
		get_input()
		velocity = move_and_collide(velocity*delta)


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
	if is_holding:
		held_toddler.let_down()
		remove_child(held_toddler)
		emit_signal("let_down_toddler", held_toddler, position)
		is_holding = false
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
				is_holding = true
				break


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
