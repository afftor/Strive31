extends Panel

var array


func show_(temparray):
	self.visible = true
	array = temparray
	$Tree.clear()
#warning-ignore:unused_variable
	var root = $Tree.create_item()
	for i in array:
		var item = $Tree.create_item()
		item.set_text(0, i)
		if typeof(i) == TYPE_STRING:
			item.set_editable(0,true)
		item.set_metadata(0, i)



func _on_closearray_pressed():
	self.visible = false


func _on_deletearray_pressed():
	if $Tree.get_selected() != null:
		array.erase($Tree.get_selected().get_metadata(0))
		show_(array)


func _on_addnewarray_pressed():
	array.append("NewEntry")
	show_(array)


func _on_Tree_item_edited():
	array[array.find($Tree.get_edited().get_metadata(0))] = $Tree.get_edited().get_text(0)
	#array[$Tree.get_selected().]#.#$Tree.get_selected().get_text()
