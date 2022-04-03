extends KinematicBody2D


export (int) var speed = 100
var velocity = Vector2()
var is_holding = false
onready var animatedSprite = $AnimatedSprite


func _physics_process(delta):
		get_input()
		velocity = move_and_collide(velocity*delta)


func get_input():
		velocity = Vector2()
		if Input.is_action_pressed("ui_right"):
				animatedSprite.play("walk_right")
				velocity.x += 1
		elif Input.is_action_pressed("ui_left"):
				animatedSprite.play("walk_left")
				velocity.x -= 1
		elif Input.is_action_pressed("ui_down"):
				animatedSprite.play("walk_down")
				velocity.y += 1
		elif Input.is_action_pressed("ui_up"):
				animatedSprite.play("walk_up")
				velocity.y -= 1
		else:
				animatedSprite.play("default")
		velocity = velocity.normalized() * speed
