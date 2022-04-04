extends Node2D


onready var congratulations_message = $CongratulationsMessage
onready var whoopsie_message = $WhoopsieMessage
onready var numbers = $Numbers
onready var modal = $Modal


func display_congratulations_message(dead_toddlers: String):
	modal.visible = true
	congratulations_message.visible = true
	numbers.visible = true
	numbers.play(dead_toddlers)


func display_whoopsie_message():
	modal.visible = true
	whoopsie_message.visible = true
