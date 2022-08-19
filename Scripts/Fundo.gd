extends Node2D


func _ready() -> void:
	pass
	
	
func _process(delta: float) -> void:
	if (!$FundoVideo.is_playing()):
		$FundoVideo.play()
