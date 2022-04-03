extends Node2D


onready var bounds = $Bounds
onready var entryways = $Entryways
onready var item_source = $ItemSource

func toddler_within_bounds(toddler : Node) -> bool:
	return bounds.overlaps_area(toddler)
	

func entryway_by_name(name : String) -> Position2D:
	for entryway in entryways.get_children():
		if entryway.name == name:
			return entryway
	return null


func _on_Hazards_area_entered(area):
	area.get_parent().kill()


func _on_ItemSource_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	area.get_parent().receive_hazardous_object(item_source.shape_owner_get_owner(local_shape_index).name)
