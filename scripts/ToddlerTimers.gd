extends Node2D

signal timeout


func start_timer(timer, seconds):
	get_node(timer).start(seconds)


func stop_timer(timer):
	get_node(timer).stop()


func stop_all_timers():
	for timer in get_children():
		timer.stop()


func start_default_suicidal_thoughts_timer():
	get_node("SuicidalThoughtsTimer").start(rand_range(10, 30))


func start_default_hunger_timer():
	get_node("HungerTimer").start(rand_range(10, 180))


func start_default_poop_timer():
	get_node("PoopTimer").start(rand_range(30, 60))


func start_default_dysentry_timer():
	get_node("DysentryTimer").start(30)


func start_default_eating_timer():
	get_node("EatingTimer").start(2)


func _on_RotationTimer_timeout():
	emit_signal("timeout", "RotationTimer")


func _on_WalkingTimer_timeout():
	emit_signal("timeout", "WalkingTimer")


func _on_WaitTimer_timeout():
	emit_signal("timeout", "WaitTimer")


func _on_SuicidalThoughtsTimer_timeout():
	emit_signal("timeout", "SuicidalThoughtsTimer")


func _on_HungerTimer_timeout():
	emit_signal("timeout", "HungerTimer")


func _on_StarvationTimer_timeout():
	emit_signal("timeout", "StarvationTimer")


func _on_PoopTimer_timeout():
	print("sending poop timer signal")
	emit_signal("timeout", "PoopTimer")


func _on_DysentryTimer_timeout():
	emit_signal("timeout", "DysentryTimer")


func _on_ScissorTimer_timeout():
	emit_signal("timeout", "ScissorTimer")


func _on_EatingTimer_timeout():
	emit_signal("timeout", "EatingTimer")
