extends Node2D


onready var toddler_area = $Toddler/Area2D
onready var toddler = $Toddler
onready var map = $Map

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Toddler_request_path_to_other_room():
	var current_room = map.room_from_toddler(toddler_area)
	print(current_room)
	var rooms = map.list_of_rooms()
	var room = rooms[randi() % rooms.size()]
	while room.name == current_room.name:
		room = rooms[randi() % rooms.size()]
	
	toddler.receive_path_to_room(map.find_path_between_rooms(current_room, room, [], []))
	


func _on_Toddler_request_path_to_hazard():
	pass # Replace with function body.
