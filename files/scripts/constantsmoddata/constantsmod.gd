extends Node

var tree
var treeitems = []
var panel
var oldvariables = {}
var arraypanel
var arraysubtree

var selectedarray
var selectedarrayposition


var modfolder = globals.modfolder + 'Constants/'



func _init():
	for i in variables.list:
		oldvariables[i] = variables[i]
	var file = File.new()
	var text = str()
	if !file.file_exists(modfolder +"storedvariables"): #makes info.txt to store mod description
		file.open(modfolder +"storedvariables", File.WRITE)
		file.store_line(text)
		file.close()
	else:
		file.open(modfolder +"storedvariables", File.READ)
		text = file.get_as_text()
		file.close()
	
	
	#Check and overwrite this mod if updated
	var config = ConfigFile.new()
	config.load(modfolder + 'data.ini')
	var installer = load("res://files/constmodinstal.gd").new()
	if config.get_value('main', 'modversion') != installer.modversion:
		installer.run(true)
	
	var array = []
	if text.length() > 1:
		array = text.split("|")
	for i in array:
		if i.length() < 2:
			continue
		var temp = i.split("=")
		if typeof(variables[temp[0]]) == TYPE_BOOL:
			variables[temp[0]] = bool(temp[1])
		elif typeof(variables[temp[0]]) == TYPE_ARRAY:
			var temparray = temp[1].replace('[','').replace(']','').split(', ')
			variables[temp[0]] = Array(temparray)
		else:
			variables[temp[0]] = float(temp[1])
	
	var newpanel = Panel.new()
	newpanel.rect_size = Vector2(750,750)
	panel = newpanel
	panel.hide()
	var temptree = Tree.new()
	newpanel.add_child(temptree)
	tree = temptree
	tree.rect_size = Vector2(730,680)
	tree.rect_position = Vector2(15,10)
	tree.hide_root = true
	tree.connect('item_selected',self,'columnpressed')
	tree.connect('item_edited',self,'valuechanged')
	
	#Array handling
	arraypanel = Panel.new()
	arraypanel.visible = false
	arraypanel.rect_size = Vector2(350,400)
	arraypanel.rect_position = Vector2(400, 200)
	arraysubtree = Tree.new()
	arraysubtree.hide_root = true
	arraypanel.add_child(arraysubtree)
	arraysubtree.rect_size = Vector2(300,300)
	arraysubtree.rect_position = Vector2(15,10)
	arraysubtree.connect("item_activated",self,'arrayactivate')
	arraysubtree.connect("item_edited",self,'arrayitemedited')
	var addnewbutton = Button.new()
	addnewbutton.text = 'Add'
	arraypanel.add_child(addnewbutton)
	addnewbutton.rect_position = Vector2(10, 350)
	addnewbutton.hint_tooltip = "Add new element"
	addnewbutton.connect("pressed", self, 'addnewarrayitem')
	
	var removebutton = Button.new()
	removebutton.text = 'Remove'
	arraypanel.add_child(removebutton)
	removebutton.hint_tooltip = "Delete selected element"
	removebutton.rect_position = Vector2(125, 350)
	removebutton.connect("pressed", self, 'removeitemarray')
	
	var arrayclosebutton = Button.new()
	arrayclosebutton.text = 'close'
	arraypanel.add_child(arrayclosebutton)
	arrayclosebutton.rect_position = Vector2(250, 350)
	arrayclosebutton.connect("pressed", self, 'closearray')
	
	
	if globals.get_tree().get_current_scene().name == 'mainscreen':
		var newbutton = Button.new()
		newbutton.text = 'Constants'
		newbutton.rect_size = Vector2(130, 50)
		newbutton.connect("pressed",self,'show')
		globals.get_tree().get_current_scene().get_node("TextureFrame").add_child_below_node(globals.get_tree().get_current_scene().get_node("TextureFrame/Panel"),newbutton)
		globals.get_tree().get_current_scene().get_node("TextureFrame").add_child(panel)
		globals.get_tree().get_current_scene().get_node("TextureFrame").add_child(arraypanel)
		globals.get_tree().get_current_scene().get_node("TextureFrame/Panel").rect_size.y += 50
		newbutton.rect_position = Vector2(205,370)
	var closebutton = Button.new()
	closebutton.text = 'Close'
	closebutton.connect('pressed', self, 'closepanel')
	newpanel.add_child(closebutton)
	closebutton.rect_position = Vector2(350, 700)

func arrayactivate():
	arraysubtree.get_selected().set_editable(0, true)
	selectedarrayposition = selectedarray.find(arraysubtree.get_selected().get_text(0))

func arrayitemedited():
	selectedarray[selectedarrayposition] = arraysubtree.get_selected().get_text(0)
	openarray(selectedarray)
	
func addnewarrayitem():
	selectedarray += ['new item']
	openarray(selectedarray)

func removeitemarray():
	if arraysubtree.get_selected() != null:
		selectedarray.erase(arraysubtree.get_selected().get_text(0))
		openarray(selectedarray)
	
func closearray():
	var item = tree.get_selected()
	item.set_text(1, str(selectedarray))
	arraypanel.hide()
	
	
	
func openarray(variable):
	arraypanel.show()
	arraysubtree.clear()
	selectedarray = variable.duplicate()
	var root = arraysubtree.create_item()
	for i in variable:
		var newitem = arraysubtree.create_item()
		newitem.set_text(0, str(i))


func show():
	panel.show()
	tree.clear()
	treeitems.clear()
	var root = tree.create_item()
	tree.columns = 2
	root.set_text(0,'Constants')
	for i in variables.list:
		var newitem = tree.create_item()
		newitem.set_text(0,i)
		newitem.set_text(1,str(variables.get(i)))
		newitem.set_meta('varname', i)
		newitem.set_meta('var',variables[i])
		newitem.set_meta('type', typeof(variables[i]))
		if variables.list[i].has('descript'):
			newitem.set_tooltip(0,variables.list[i].descript)
		if typeof(variables[i]) == TYPE_BOOL:
			newitem.set_cell_mode(1,1)
			newitem.set_checked(1, variables[i])
			newitem.set_editable(1, true)
		treeitems.append(newitem)
	
	tree.set_column_min_width(0, 10)

func columnpressed():
	if tree.get_selected_column() == 1:
		var item = tree.get_selected()
		var meta = item.get_meta('var')
		if typeof(meta) == TYPE_STRING or typeof(meta) == TYPE_INT or typeof(meta) == TYPE_REAL:
			item.set_editable(tree.get_selected_column(), true)
		elif typeof(meta) == TYPE_ARRAY:
			openarray(meta)

func valuechanged():
	var item = tree.get_selected()
	var name = item.get_meta('varname')
	var type = item.get_meta('type')
	if type == 1:
		variables[name] = item.is_checked(1)
	else:
		variables[name] = float(item.get_text(1))

func closepanel():
	storechangeddata()
	panel.hide()

func storechangeddata():
	var text = ''
	for i in treeitems:
		var name = i.get_meta('varname')
		var type = i.get_meta('type')
		var newval = i.get_text(1)
		if type == TYPE_ARRAY && str(oldvariables[name]) != newval:
			if text != '':
				text += '|'
			text += name + '=' + str(newval)
			continue
		if newval == '':
			if oldvariables[name] != i.is_checked(1):
				if text != '':
					text += '|'
				newval = int(i.is_checked(1))
		if type != TYPE_ARRAY && float(oldvariables[name]) != float(newval):
			if text != '':
				text += '|'
			text += name + '=' + str(newval)
	var file = File.new()
	file.open(modfolder +"storedvariables", File.WRITE)
	file.store_line(text)
	file.close()
