extends Node2D


onready var map = $Map
onready var toddlers = $Toddlers
onready var roaming_toddler_timer = $RoamingToddlerTimer
onready var game_over_timer = $GameOverTimer
onready var teacher = $Teacher
onready var restart_button = $RestartButton
onready var bus = $Bus
onready var music = $TitleMusic
onready var game_over_sound = $GameOverSound

var game_over = false
var dead_toddlers = 0
var amount_of_toddlers = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	amount_of_toddlers = toddlers.get_child_count()
	start_roaming_toddler_timer()
	connect_to_toddlers()


func _on_RoamingToddlerTimer_timeout():
	for toddler in toddlers.get_children():
		if not toddler.walking_to_target and map.rooms_with_toddler(toddler):
			route_toddler_to_room(toddlers.get_children()[randi() % toddlers.get_children().size()])
			break
	start_roaming_toddler_timer()


func route_toddler_to_room(toddler):
	if not toddler.walking_to_target:
		var rooms_with_toddler = map.rooms_with_toddler(toddler)
		if rooms_with_toddler:
			var current_room = rooms_with_toddler[0]
			var path = []
			if rooms_with_toddler.size() > 1:
				path.append(current_room.get_node("Entryways").get_node(rooms_with_toddler[1].name).position + current_room.position)
			var rooms = map.list_of_rooms()
			var room = rooms[randi() % rooms.size()]
			while room.name == current_room.name:
				room = rooms[randi() % rooms.size()]
			
			toddler.receive_path_to_target(map.find_path_between_rooms(current_room, room, path, []))


func connect_to_toddlers():
	for toddler in toddlers.get_children():
		toddler.connect("kill_me", self, "_on_Toddler_kill_me")
		toddler.connect("path_me_to_outlet", self, "_on_Toddler_path_me_to_outlet")
		toddler.connect("i_am_dead", self, "_on_Toddler_i_am_dead")


func start_roaming_toddler_timer():
	roaming_toddler_timer.start(rand_range(3, 5))


func game_over():
	for toddler in toddlers.get_children():
		toddler.disable()
	teacher.set_process(false)
	bus.disable()
	music.stop()
	game_over_sound.play()
	
	var alive_toddlers = amount_of_toddlers - dead_toddlers
	if teacher.dead:
		restart_button.text = "Whoopsie! You didn't look both ways! Press to restart!"
	elif alive_toddlers == 0:
		restart_button.text = "Oh no! All the kids died! Press to restart!"
	else:
		restart_button.text = "Congratulations! You saved %s kids! Press to restart!" % alive_toddlers
	restart_button.visible = true


func _on_Toddler_kill_me(source):
	source.receive_path_to_target(map.path_to_hazard_near_toddler(source))


func _on_Toddler_i_am_dead(source):
	print("toddler %s died" % source.id)
	dead_toddlers += 1
	if dead_toddlers >= amount_of_toddlers:
		game_over()


func _on_Toddler_path_me_to_outlet(source):
	source.receive_path_to_target(map.path_to_outlet(source))


func _on_Teacher_let_down_toddler(toddler, let_down_position):
	toddlers.add_child(toddler)
	toddler.position = let_down_position


func _on_GameOverTimer_timeout():
	game_over()


func _on_RestartButton_pressed():
	get_tree().reload_current_scene()


func _on_Teacher_i_am_dead():
	game_over()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().change_scene("res://scenes/game/TitleScreen.tscn")
