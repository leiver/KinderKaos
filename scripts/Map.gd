extends Node2D


onready var rooms = $Rooms


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func list_of_rooms() -> Array:
	return rooms.get_children()


func room_by_name(name : String) -> Room:
	return rooms.get_node(name)


func room_from_toddler(toddler : Node) -> Node:
	for child in rooms.get_children():
		if child.toddler_within_bounds(toddler):
			return child
	return null


func find_path_between_rooms(current : Node, destination : Node, path : Array, parsed_rooms : Array) -> Array:
	var parsed_rooms_copy = [] + parsed_rooms
	parsed_rooms_copy.append(current)
	for entryway in current.get_node("Entryways").get_children():
		var connecting_room = room_by_name(entryway.name)
		if not parsed_rooms_copy.has(connecting_room):
			var continued_path = [] + path
			continued_path.append(entryway.position + current.position)
			continued_path.append(connecting_room.entryway_by_name(current.name).position + connecting_room.position)
			continued_path.append(connecting_room.get_node("Center").position + connecting_room.position)
			if connecting_room == destination:
				print(parsed_rooms_copy)
				return continued_path
			var returned_path = find_path_between_rooms(connecting_room, destination, continued_path, parsed_rooms_copy)
			if returned_path.size() > 0:
				return returned_path
	return []
