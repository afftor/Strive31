extends Control

func _input(event):
	if self.is_visible_in_tree() == false || !(event is InputEventKey) || event.is_echo() == true || event.is_pressed() == false  || globals.main.get_node("screenchange").visible:
		return
	var anythingvisible = false
	for i in get_tree().get_nodes_in_group("blockmaininput"):
		if i.is_visible_in_tree() == true && i != self:
			anythingvisible = true
			break
	if anythingvisible == true:
		return



	if str(event.as_text().replace("Kp ",'')) in str(range(1,9)):
		var key = int(event.as_text())
		if $buttonscroll/buttoncontainer.get_children().size() >= key+1 && $buttonscroll/buttoncontainer.get_child(key).is_disabled() == false:
			$buttonscroll/buttoncontainer.get_child(key).emit_signal("pressed")