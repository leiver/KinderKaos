extends Node2D


onready var bounds = $Bounds


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func toddler_within_bounds(toddler : Node) -> bool:
	return bounds.overlaps_area(toddler)
