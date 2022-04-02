extends Node2D


onready var bounds = $Bounds
onready var entryways = $Entryways

func toddler_within_bounds(toddler : Node) -> bool:
	return bounds.overlaps_area(toddler)
	

func entryway_by_name(name : String) -> Position2D:
	for entryway in entryways.get_children():
		if entryway.name == name:
			return entryway
	return null
