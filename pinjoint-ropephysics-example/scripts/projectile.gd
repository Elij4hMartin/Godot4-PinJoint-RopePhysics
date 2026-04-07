extends RigidBody3D

@export var timeout = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(4.0).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(0.0, 0.0, 0.0), 1)
	await get_tree().create_timer(1.0).timeout
	queue_free()
