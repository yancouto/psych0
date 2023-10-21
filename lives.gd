extends Label

var cur_lives := -1

func update_lives() -> void:
	var lives: int = get_node('../Player').lives
	if lives != cur_lives:
		cur_lives = lives
		text = "Lives: %d" % lives

func _ready() -> void:
	update_lives()

func _process(_dt: float) -> void:
	update_lives()
