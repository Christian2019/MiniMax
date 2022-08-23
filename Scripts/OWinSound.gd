extends AudioStreamPlayer2D


func _ready() -> void:
	pass


func _on_Stop_timeout() -> void:
	get_parent().get_node("OWinSound").stop()
