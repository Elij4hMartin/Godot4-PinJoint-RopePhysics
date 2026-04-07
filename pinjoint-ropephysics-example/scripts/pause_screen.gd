extends CanvasLayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# pause if player releases the cursor
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		get_tree().paused = true
		visible = true

func _on_button_pressed() -> void:
	# unpause if player presses the button
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	visible = false
