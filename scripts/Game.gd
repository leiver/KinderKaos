extends Node2D


onready var map = $Map
onready var toddlers = $Toddlers
onready var roaming_toddler_timer = $RoamingToddlerTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	start_roaming_toddler_timer()
	connect_to_toddlers()


func _on_RoamingToddlerTimer_timeout():
	route_toddler_to_room(toddlers.get_children()[randi() % toddlers.get_children().size()])
	start_roaming_toddler_timer()


func route_toddler_to_room(toddler):
	var rooms_with_toddler = map.rooms_with_toddler(toddler)
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


func start_roaming_toddler_timer():
	roaming_toddler_timer.start(rand_range(3, 8))


func _on_Toddler_kill_me(source):
	source.receive_path_to_target(map.path_to_hazard_near_toddler(source))


func _on_Teacher_let_down_toddler(toddler, let_down_position):
	toddlers.add_child(toddler)
	toddler.position = let_down_position
