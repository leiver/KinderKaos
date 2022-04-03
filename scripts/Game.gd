extends Node2D


onready var map = $Map
onready var toddlers = $Toddlers
onready var roaming_toddler_timer = $RoamingToddlerTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	start_roaming_toddler_timer()


func _on_RoamingToddlerTimer_timeout():
	route_toddler_to_room(toddlers.get_children()[randi() % toddlers.get_children().size()])
	start_roaming_toddler_timer()


func route_toddler_to_room(toddler):
	var current_room = map.room_from_toddler(toddler.get_node("Area2D"))
	var rooms = map.list_of_rooms()
	var room = rooms[randi() % rooms.size()]
	while room.name == current_room.name:
		room = rooms[randi() % rooms.size()]
	
	toddler.receive_path_to_room(map.find_path_between_rooms(current_room, room, [], []))


func start_roaming_toddler_timer():
	roaming_toddler_timer.start(rand_range(3, 8))
