extends Sprite2D

var tween
var has_picked_up = false

func _ready():
	pass

func _on_area_2d_area_entered(area):
	has_picked_up = true
	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "position", position - Vector2(0, 50), .5).set_ease(tween.EASE_OUT).set_trans(tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, .8).set_ease(tween.EASE_OUT).set_trans(tween.TRANS_CUBIC)
