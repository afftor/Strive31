extends VBoxContainer

func can_drop_data(pos, data):
	return true


func drop_data(pos, data):
	data.get_parent().remove_child(data)
	add_child(data)
	#queue_sort()

func add_string(string):
	var new_child = get_child(0).duplicate()
	new_child.visible = true
	new_child.full_string = string
	new_child.text = string.substr(string.find_last('/')+1, string.length() - string.find_last('/'))
	add_child(new_child)
