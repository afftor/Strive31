extends Label

func animatetext(text, node):
	self.text = str(text)
	rect_position = node.rect_position
	$AnimationPlayer.play("fade")
	get_parent().emit_signal("textshown")