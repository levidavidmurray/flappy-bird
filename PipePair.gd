extends RigidBody2D


var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	print(name)

func _on_VisibilityNotifier2D_screen_exited():
	print("%s exited screen!" % name)
	self.queue_free()

# func _on_PipeCollector_area_shape_exited(area_id, area, area_shape, local_shape):
# 	print("local_shape %s" % area.name)
# 	print("%s destroyed!" % name)
# 	self.queue_free()
