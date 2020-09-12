extends Node

# before mainmenu.gd _ready() is called, generally in _init(), entries can be added to variables.list
# Examples for adding file scoped variables from other files:
#		variables.list['NewCategory'] = {
#			variablename = {descript = "Explain effect of variable", min = 1, max = 100, object = self}
#		}
#		variables.list['ExistingCategory']['variablename'] = {descript = "Explain effect of variable", min = 1, max = 100, object = self}
#
# 'variablename' can also be specified as 'path.to.variablename', where the path starts at 'object'(not apart of path) and passes through objects, arrays, and/or dictionaries with a period between each index
# 'min' and 'max' are optional recommendations about the range of values for the variable
# 'minSize' and 'maxSize' are optional limits for the number of elements in an array, dictionaries cannot change size
# 'object' is necessary if the variable is located in an object besides the singleton 'variables'
#
# try to give new entries unique categories or variable names to avoid confusion and collisions with other entries
# this mod currently supports the following types: int, float, bool, array, dictionary
# arrays and dictionaries must contain only a single non-container type and must not be empty (dictionary keys are not included in this count)
# variables containing null will be reported as not found

var tree
var treeitems = []
var panel
var resetbutton

var arraypanel
var arraytree
var arrayaddbutton
var arrayremovebutton

var selectedarrayitem
var selectedarrayref

var redText = ColorN("red").lightened(0.2)
var blueText = ColorN('blue').lightened(0.4)

func _init():
	filterVarList()
	loadFileData()
	createInterface()

func getObjVar(obj, varPath):
	varPath = varPath.split('.', false)
	for i in range(0, varPath.size()):
		if typeof(obj) in [TYPE_OBJECT,TYPE_DICTIONARY]:
			obj = obj.get(varPath[i])
		elif typeof(obj) == TYPE_ARRAY:
			var temp = varPath[i].to_int()
			if temp > 0 && temp < obj.size():
				obj = obj[temp]
			else:
				return null
		else:
			return null
	return obj


func setObjVar(value, obj, varPath):
	varPath = varPath.split('.', false)
	for i in range(0, varPath.size()-1):
		if typeof(obj) in [TYPE_OBJECT,TYPE_DICTIONARY]:
			obj = obj.get(varPath[i])
		elif typeof(obj) == TYPE_ARRAY:
			var temp = varPath[i].to_int()
			if temp > 0 && temp < obj.size():
				obj = obj[temp]
			else:
				return false
		else:
			return false
	if typeof(obj) in [TYPE_OBJECT,TYPE_DICTIONARY]:
		obj[ varPath[ varPath.size()-1 ]] = value
	elif typeof(obj) == TYPE_ARRAY:
		var temp =  varPath[ varPath.size()-1 ].to_int()
		if temp >= 0 && temp < obj.size():
			obj[temp] = value
		else:
			return false
	else:
		return false
	return true

# most types compare contents, but dictionaries are defaultly compared by reference, thus they need special handling
func equals(val1, val2):
	if typeof(val1) == TYPE_DICTIONARY && typeof(val2) == TYPE_DICTIONARY:
		return val1.hash() == val2.hash()
	else:
		return val1 == val2

# check that each variable is accessible and store initial values
func filterVarList():
	for cat in variables.list:
		var refCat = variables.list[cat]
		var value
		var types
		for i in refCat:
			var refDict = refCat[i]
			# if 'object' is not provided, use variables.gd
			if !refDict.has('object'):
				refDict.object = variables
			# this can happen if 'object' is defined before the object has finished init (i.e., using identifiers 'globals' or 'variables' inside their own init)
			elif refDict.object == null:
				print("Constants: cannot find variable ", i, " in null object")
				continue
			#check object for variable name
			value = getObjVar(refDict.object, i)
			types = getVarTypes(value)
			if types != null:
				refDict.types = types
				if types[0] in containerTypes:
					refDict.old = value.duplicate()
				else:
					refDict.old = value
			elif value == null:
				if refDict.object.get('script'):
					print("Constants: cannot find variable ", i, " in ", str(refDict.object.get('script').get('resource_path')))
				else:
					print("Constants: cannot find variable ", i, " in given object")
				refDict.object = null
			else:
				print("Constants: variable ", i, " has incompatible type.")
				refDict.object = null


var baseTypes = [TYPE_INT, TYPE_BOOL, TYPE_REAL]
var containerTypes = [TYPE_ARRAY, TYPE_DICTIONARY]

# checks that the type of the variable and any contained values fits supported types
# returns null if not supported, [type] for baseTypes, [containerType, storedType] for containers
func getVarTypes(value):
	if typeof(value) in baseTypes:
		return [typeof(value)]
	if typeof(value) == TYPE_ARRAY:
		var types = []
		for i in value:
			if !typeof(i) in types:
				if !types.empty():
					return null
				types.append(typeof(i))
		if !types.empty() && types[0] in baseTypes:
			return [TYPE_ARRAY, types[0]]
	elif typeof(value) == TYPE_DICTIONARY:
		var types = []
		for i in value.values():
			if !typeof(i) in types:
				if !types.empty():
					return null
				types.append(typeof(i))
		if !types.empty() && types[0] in baseTypes:
			return [TYPE_DICTIONARY, types[0]]
	return null

# load text from file, else create new file
func loadFileData():
	var modfolder = globals.modfolder + "Constants/"
	var file = File.new()
	var text = ''
	if file.file_exists(modfolder +"storedvariables"):
		var result = file.open(modfolder +"storedvariables", File.READ)
		if result == OK:
			text = file.get_as_text()
			file.close()
		else:
			globals.printErrorCode("Constants: opening file 'storedvariables'", result)
	else:
		var result = file.open(modfolder +"storedvariables", File.WRITE)
		if result == OK:
			file.store_line(text)
			file.close()
		else:
			globals.printErrorCode("Constants: creating file 'storedvariables'", result)

	#if no text to parse
	if text.length() <= 1:
		return

	# parse values from text and put them into variables
	var fileValues = {}
	#if json styled text
	if text[0] == '{':
		fileValues = parse_json(text)
		for fileCat in fileValues:
			var listCat = variables.list.get(fileCat)
			if listCat == null:
				continue
			for i in fileValues[fileCat]:
				if listCat.has(i) && listCat[i].object != null:
					var types = listCat[i].types
					var newValue = fileValues[fileCat][i]
					if types[0] == TYPE_INT: # json does not store ints only floats, so conversion is needed
						newValue = int(newValue)
					elif types[0] == TYPE_ARRAY && types[1] == TYPE_INT:
						for j in range(0, newValue.size()):
							newValue[j] = int(newValue[j])
					elif types[0] == TYPE_DICTIONARY && types[1] == TYPE_INT:
						for j in newValue:
							newValue[j] = int(newValue[j])
					setObjVar( newValue, listCat[i].object, i)
	#else assume previous version's custom style text
	else:
		fileValues = text.split("|")
		for i in fileValues:
			if i.length() < 2:
				continue
			var temp = i.split("=")
			var first = temp[0]
			for listCat in variables.list.values():
				if !listCat.has(first):
					continue
				if listCat[first].object != null:
					var refObj = listCat[first].object
					if typeof( refObj[first] ) == TYPE_BOOL:
						refObj[first] = bool( parse_json(temp[1]) )
					elif typeof( refObj[first] ) == TYPE_ARRAY:
						refObj[first] = Array( parse_json(temp[1]) )
					else:
						refObj[first] = float( parse_json(temp[1]) )
				break


func createInterface():
	panel = Panel.new()
	panel.rect_size = Vector2(750, 750)
	panel.hide()

	tree = Tree.new()
	panel.add_child(tree)
	tree.rect_size = Vector2(720, 680)
	tree.rect_position = Vector2(15, 15)
	tree.hide_root = true
	tree.columns = 2
	tree.set_column_min_width(0, 300)
	tree.set_column_min_width(1, 60)
	tree.connect('item_selected',self,'columnpressed')
	tree.connect('item_edited',self,'valuechanged')
	
	resetbutton = Button.new()
	resetbutton.text = 'Reset Selected'
	resetbutton.hint_tooltip = "Select a changed variable to enable reset."
	resetbutton.connect('pressed', self, 'resetVar')
	resetbutton.disabled = true
	panel.add_child(resetbutton)
	resetbutton.rect_position = Vector2(300, 700)

	var closebutton = Button.new()
	closebutton.text = 'Close'
	closebutton.connect('pressed', self, 'closepanel')
	panel.add_child(closebutton)
	closebutton.rect_position = Vector2(550, 700)

	#Array handling
	arraypanel = Panel.new()
	arraypanel.hide()
	arraypanel.rect_size = Vector2(450, 500)
	arraypanel.rect_position = Vector2(750, 75)

	arraytree = Tree.new()
	arraypanel.add_child(arraytree)
	arraytree.rect_size = Vector2(420, 430)
	arraytree.rect_position = Vector2(15, 15)
	arraytree.hide_root = true
	arraytree.columns = 2
	arraytree.set_column_min_width(0, 200)
	arraytree.set_column_min_width(1, 100)
	arraytree.connect("item_selected",self,'arrayselected')
	arraytree.connect("item_edited",self,'arrayitemedited')

	arrayaddbutton = Button.new()
	arrayaddbutton.text = 'Add'
	arraypanel.add_child(arrayaddbutton)
	arrayaddbutton.rect_position = Vector2(200, 450)
	arrayaddbutton.hint_tooltip = "Add new element"
	arrayaddbutton.connect("pressed", self, 'addnewarrayitem')
	
	arrayremovebutton = Button.new()
	arrayremovebutton.text = 'Remove'
	arraypanel.add_child(arrayremovebutton)
	arrayremovebutton.hint_tooltip = "Delete selected element"
	arrayremovebutton.rect_position = Vector2(270, 450)
	arrayremovebutton.connect("pressed", self, 'removeitemarray')
	
	var arrayclosebutton = Button.new()
	arrayclosebutton.text = 'close'
	arraypanel.add_child(arrayclosebutton)
	arrayclosebutton.rect_position = Vector2(50, 450)
	arrayclosebutton.connect("pressed", self, 'closearray')
	
	# add gui to mainmenu
	if globals.get_tree().get_current_scene().name == 'mainscreen':
		var newbutton = Button.new()
		newbutton.text = 'Constants'
		newbutton.rect_size = Vector2(130, 50)
		newbutton.connect("pressed",self,'show')
		var nodeTexture = globals.get_tree().get_current_scene().get_node("TextureFrame")
		nodeTexture.add_child_below_node(nodeTexture.get_node("Panel"),newbutton)
		nodeTexture.add_child(panel)
		nodeTexture.add_child(arraypanel)
		nodeTexture.get_node("Panel").rect_size.y += 50
		newbutton.rect_position = Vector2(205,370)


func arrayselected():
	checkArraySize()


func arrayitemedited():
	var item = arraytree.get_selected()
	var ref = selectedarrayitem.get_meta('ref')
	var value
	if ref.types[1] == TYPE_BOOL:
		value = item.is_checked(1)
	elif ref.types[1] == TYPE_REAL:
		value = float(item.get_text(1))
	elif ref.types[1] == TYPE_INT:
		value = int(item.get_text(1))
	selectedarrayref[item.get_meta('index')] = value
	setArrayItemColor(item)
	updateArray()

func updateArray():
	selectedarrayitem.set_text(1, str(selectedarrayref))
	setItemColor(selectedarrayitem, selectedarrayref)
	updateReset(selectedarrayitem.get_meta('ref'), selectedarrayref)

func setArrayItemColor(item):
	var index = item.get_meta('index')
	var value = selectedarrayref[index]
	var ref = selectedarrayitem.get_meta('ref')
	item.set_tooltip(1, shortTooltip(value))
	item.set_tooltip(0, ref.get('descript',"No description"))

	var oldValid
	if ref.types[0] == TYPE_ARRAY:
		oldValid = index < ref.old.size()
	else: # if ref.types[0] == TYPE_DICTIONARY:
		oldValid = ref.old.has(index)
	if oldValid && ref.old[index] == value:
		item.clear_custom_color(0)
	else:
		var limits = [ref.get('min','-'), ref.get('max','+')]
		if (typeof(limits[0]) == TYPE_STRING || limits[0] <= value) && (typeof(limits[1]) == TYPE_STRING || limits[1] >= value):
			item.set_custom_color(0, blueText)
		else:
			item.set_custom_color(0, redText)
			item.set_tooltip(0, item.get_tooltip(0) + "\nOutside of recommended range" + str(limits))
	
func addnewarrayitem():
	var item = arraytree.get_selected()
	var index = selectedarrayref.size()
	if item != null:
		index = item.get_meta('index') + 1
	selectedarrayref.insert(index, 0)
	var nextItem = createArrayItem(index, selectedarrayitem.get_meta('ref').types[1], 0, index).get_next()
	while nextItem != null:
		nextItem.set_text( 0, str(nextItem.get_meta('index')+1))
		nextItem.set_meta( 'index', (nextItem.get_meta('index')+1))
		setArrayItemColor(nextItem)
		nextItem = nextItem.get_next()
	updateArray()
	checkArraySize()

func removeitemarray():
	var item = arraytree.get_selected()
	if item == null:
		return
	selectedarrayref.remove(item.get_meta('index'))
	var nextItem = item.get_next()
	while nextItem != null:
		nextItem.set_text( 0, str(nextItem.get_meta('index')-1))
		nextItem.set_meta( 'index', (nextItem.get_meta('index')-1))
		setArrayItemColor(nextItem)
		nextItem = nextItem.get_next()
	if item.get_next() != null:
		item.get_next().select(arraytree.get_selected_column())
	elif item.get_prev() != null:
		item.get_prev().select(arraytree.get_selected_column())
	else:
		item.deselect(arraytree.get_selected_column())
	item.get_parent().remove_child(item)
	updateArray()
	checkArraySize()
	
func closearray():
	arraypanel.hide()
	arraytree.clear()
	
func openarray(item):
	arraytree.clear()
	selectedarrayitem = item
	var name = item.get_text(0)
	var ref = item.get_meta('ref')
	selectedarrayref = getObjVar( ref.object, name)
	var root = arraytree.create_item()
	var innerType = ref.types[1]
	if ref.types[0] == TYPE_ARRAY:
		for i in range(0, selectedarrayref.size()):
			createArrayItem(i, innerType, selectedarrayref[i])
	else: # if ref.types[0] == TYPE_DICTIONARY:
		for i in selectedarrayref:
			createArrayItem(i, innerType, selectedarrayref[i])
	checkArraySize()
	arraypanel.show()

func createArrayItem(arrayIndex, innerType, value, itemIndex=-1):
	var newitem = arraytree.create_item(arraytree.get_root(), itemIndex)
	newitem.set_text(0, str(arrayIndex))
	newitem.set_meta('index', arrayIndex)
	if selectedarrayitem.get_meta('ref').types[1] == TYPE_BOOL:
		newitem.set_cell_mode(1,1)
		newitem.set_checked(1, bool(value))
	else:
		newitem.set_text(1, str(value))
	newitem.set_editable(1, true)
	setArrayItemColor(newitem)
	return newitem

func checkArraySize():
	var ref = selectedarrayitem.get_meta('ref')
	if arraytree.get_selected() == null:
		arrayaddbutton.hint_tooltip = "Add new element at end"
	else:
		arrayaddbutton.hint_tooltip = "Add new element after selected value"
	if ref.types[0] == TYPE_ARRAY:
		arrayaddbutton.disabled = selectedarrayref.size() >= ref.get('maxSize', 1000)
		arrayremovebutton.disabled = arraytree.get_selected() == null || selectedarrayref.size() <= max(ref.get('minSize', 0), 0)
	else: # if ref.types[0] == TYPE_DICTIONARY:
		arrayaddbutton.disabled = true
		arrayremovebutton.disabled = true

func resetVar():
	resetbutton.hint_tooltip = "Select a changed variable to enable reset."
	resetbutton.disabled = true
	var item = tree.get_selected()
	var name = item.get_text(0)
	var ref = item.get_meta('ref')
	if ref.types[0] == TYPE_BOOL:
		item.set_checked(1, ref.old)
	else:
		item.set_text(1,str(ref.old))
	item.clear_custom_color(0)
	if ref.types[0] in containerTypes:
		setObjVar( ref.old.duplicate(), ref.object, name)
	else:
		setObjVar( ref.old, ref.object, name)
	if arraypanel.visible:
		openarray(selectedarrayitem)


func show():
	panel.show()
	tree.clear()
	treeitems.clear()
	var root = tree.create_item()
	for cat in variables.list:
		var refCat = variables.list[cat]
		var newcat = tree.create_item(root)
		newcat.set_text(0,cat)
		for i in refCat:
			var refVar = refCat[i]
			if refVar.object == null:
				continue
			var value = getObjVar( refVar.object, i)
			var newitem = tree.create_item(newcat)
			newitem.set_text(0,i)
			newitem.set_text(1,str(value))
			newitem.set_meta('ref', refVar)
			setItemColor(newitem, value)
			if refVar.types[0] in containerTypes:
				newitem.set_editable(1, false)
			else:
				if refVar.types[0] == TYPE_BOOL:
					newitem.set_cell_mode(1,1)
					newitem.set_checked(1, value)
				newitem.set_editable(1, true)
			treeitems.append(newitem)

func columnpressed():
	var item = tree.get_selected()
	if item.has_meta('ref'):
		var ref = item.get_meta('ref')
		var name = item.get_text(0)
		updateReset(ref, getObjVar( ref.object, name))
		if tree.get_selected_column() == 1:
			if ref.types[0] in containerTypes:
				openarray(item)
			else:
				closearray()
		elif item != selectedarrayitem:
			closearray()
	else:
		item.collapsed = !item.collapsed
		item.deselect(0)

func valuechanged():
	var item = tree.get_selected()
	var ref = item.get_meta('ref')
	var value
	if ref.types[0] == TYPE_BOOL:
		value = item.is_checked(1)
	elif ref.types[0] == TYPE_REAL:
		value = float(item.get_text(1))
	elif ref.types[0] == TYPE_INT:
		value = int(item.get_text(1))
	setObjVar( value, ref.object, item.get_text(0))
	setItemColor(item, value)
	updateReset(ref, value)

func shortTooltip(value):
	var text = str(value)
	if text.length() > 60:
		text = text.left(60) + "..."
	return text

func updateReset(ref, value):
	if equals(ref.old, value):
		resetbutton.disabled = true
		resetbutton.hint_tooltip = "Select a changed variable to enable reset."
	else:
		resetbutton.disabled = false
		resetbutton.hint_tooltip = "Reset to default: " + shortTooltip(ref.old)

func setItemColor(item, value):
	var ref = item.get_meta('ref')
	item.set_tooltip(0, ref.get('descript',"No description"))
	item.set_tooltip(1, shortTooltip(value))
	if equals(ref.old, value):
		item.clear_custom_color(0)
	else:
		var limits = [ref.get('min','-'), ref.get('max','+')]
		var isCorrect = true
		if ref.types[0] == TYPE_ARRAY:
			for i in value:
				if (typeof(limits[0]) != TYPE_STRING && limits[0] > i) || (typeof(limits[1]) != TYPE_STRING && limits[1] < i):
					isCorrect = false
					break
		elif ref.types[0] == TYPE_DICTIONARY:
			for i in value.values():
				if (typeof(limits[0]) != TYPE_STRING && limits[0] > i) || (typeof(limits[1]) != TYPE_STRING && limits[1] < i):
					isCorrect = false
					break
		elif ref.types[0] != TYPE_BOOL:
			isCorrect = (typeof(limits[0]) == TYPE_STRING || limits[0] <= value) && (typeof(limits[1]) == TYPE_STRING || limits[1] >= value)

		if isCorrect:
			item.set_custom_color(0, blueText)
		else:
			item.set_custom_color(0, redText)
			item.set_tooltip(0, item.get_tooltip(0) + "\nOutside of recommended range" + str(limits))

func closepanel():
	storechangeddata()
	panel.hide()
	arraypanel.hide()
	tree.clear()
	treeitems.clear()
	arraytree.clear()

func storechangeddata():
	var text = ''
	var values = {}
	for i in treeitems:
		var name = i.get_text(0)
		var cat = i.get_parent().get_text(0)
		var newVal = getObjVar( i.get_meta('ref').object, name)
		if !equals(i.get_meta('ref').old, newVal):
			if !values.has(cat):
				values[cat] = {}
			values[cat][name] = newVal

	var file = File.new()
	var result = file.open(globals.modfolder + "Constants/storedvariables", File.WRITE)
	if result == OK:
		file.store_line(to_json(values))
		file.close()
	else:
		globals.printErrorCode("Constants: writing file 'storedvariables'", result)
