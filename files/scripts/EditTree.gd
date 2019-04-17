extends Tree
var dict



func show_(type = 'races'):
	if type == 'races':
		dict = globals.racefile.races
	elif type == 'bodyparts':
		dict = globals.description.descriptions
	buildtree()
	set_column_min_width(1, 4)


func buildtree():
	clear()
#warning-ignore:unused_variable
	var root = create_item()
	for i in dict:
		var line = create_item()
		line.set_text(0,i)
		line.set_metadata(0, i)
		if globals.description.descriptions.has(i):
			line.add_button(0, load("res://files/buttons/levelup.png"))
		for j in dict[i]:
			var nextline = create_item(line)
			if globals.description.descriptions.has(j):
				nextline.add_button(0, load("res://files/buttons/levelup.png"))
			nextline.set_text(0,j)
			nextline.set_text(1,str(dict[i][j]))
			if typeof(dict[i][j]) == TYPE_STRING:
				nextline.set_editable(1, true)
			elif typeof(dict[i][j]) == TYPE_ARRAY:
				nextline.add_button(1, load("res://files/buttons/levelup.png"))
				nextline.set_metadata(1, dict[i][j])
		line.collapsed = true




#warning-ignore:unused_argument
func _on_edittree_button_pressed(item, column, id):
	if column == 0:
		if globals.description.descriptions.has(item.get_text(0)):
			show_("bodyparts")
	elif column == 1:
		get_parent().editarray(item.get_metadata(column))


func _on_edittree_item_selected():
	allow_reselect = false
	get_selected().collapsed = !get_selected().collapsed
	allow_reselect = true


