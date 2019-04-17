extends Button
var full_string = "NULL"
func get_drag_data(pos):
	var cpb = duplicate()
	cpb.rect_size = Vector2(50, 50)
	set_drag_preview(cpb)
	return self

func can_drop_data(pos, data):
	if data == self:
		return false
	return true

func drop_data(pos, data):
	get_parent().drop_data(pos, data)

func _ready():
	if(text == ""):
		visible = false