extends Node2D


onready var rooms = $Rooms


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func list_of_rooms() -> Array:
	return rooms.get_children()


func room_by_name(name : String) -> Room:
	return rooms.get_node(name)


func rooms_with_toddler(toddler : Node) -> Array:
	var result = []
	for child in rooms.get_children():
		if child.toddler_within_bounds(toddler.get_node("Area2D")):
			result.append(child)
	return result


func path_to_hazard_near_toddler(toddler : Node) -> Array:
	for room in rooms_with_toddler(toddler):
		var hazards_in_room = room.get_node("Hazards").get_children()
		if not toddler.hungry_or_poopy_diaper:
			hazards_in_room.append_array(room.get_node("ItemSource").get_children())
		if hazards_in_room.size() > 0:
			var random_hazard_in_room = hazards_in_room[randi() % hazards_in_room.size()]
			if random_hazard_in_room.get_parent().name == "ItemSource":
				toddler.going_to_hazardouds_object = true
			var random_point_in_hazard = random_hazard_in_room.position + Vector2(rand_range(-10, 10), rand_range(-10, 10))
			return [room.position + room.get_node("Center").position, room.position + random_point_in_hazard]
	return []


func path_to_outlet(toddler : Node) -> Array:
	var path = find_path_between_rooms(rooms.get_node("KitchenRoom"), rooms.get_node("LivingRoom"), [], [])
	var outlet_position = rooms.get_node("LivingRoom").position + rooms.get_node("LivingRoom").get_node("Outlet").position
	var random_point_in_outlet = outlet_position + Vector2(rand_range(-10, 10), rand_range(-10, 10))
	path.append(random_point_in_outlet)
	return path


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
				return continued_path
			var returned_path = find_path_between_rooms(connecting_room, destination, continued_path, parsed_rooms_copy)
			if returned_path.size() > 0:
				return returned_path
	return []
