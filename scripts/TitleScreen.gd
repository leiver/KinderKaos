extends Node2D

onready var music = $Music
onready var yay_sound = $YaaySound
onready var teacher_chasing_toddler = $TeacherChasingToddler
onready var chase_timer = $ChaseTimer
onready var teach_and_toddler_original_pos

var teach_and_toddler_goal_x = -102
var teach_and_toddler_speed = 150

var starting = false
var teach_and_toddler_moving = false


func _ready():
	teach_and_toddler_original_pos = teacher_chasing_toddler.position


func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and not starting:
		starting = true
		yay_sound.play()
		music.stop()
	
	if teach_and_toddler_moving:
		teacher_chasing_toddler.position.x -= teach_and_toddler_speed * delta
		if teacher_chasing_toddler.position.x < teach_and_toddler_goal_x:
			teach_and_toddler_moving = false
			teacher_chasing_toddler.position = teach_and_toddler_original_pos
			chase_timer.start(5)


func _on_YaaySound_finished():
	get_tree().change_scene("res://scenes/game/Game.tscn")


func _on_ChaseTimer_timeout():
	teach_and_toddler_moving = true
