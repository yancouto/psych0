extends Label

var cur_slowmo := -1

func update_slowmo() -> void:
	var slowmo: float = %BulletTime.secs_left
	if slowmo != cur_slowmo:
		cur_slowmo = slowmo
		text = "Slowmo: %.1fs" % slowmo

func _ready() -> void:
	update_slowmo()

func _process(_dt: float) -> void:
	update_slowmo()
