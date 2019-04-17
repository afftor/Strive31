extends Node

var state
var location = 'mansion'
var filter = ''

var categories = {everything = true, potion = false, ingredient = false, gear = false, supply = false}
onready var itemgrid = get_node("ScrollContainer/GridContainer")

var merchantitems = []

func _ready():
	
	
	for i in get_tree().get_nodes_in_group("invcategory"):
		i.connect("pressed",self,'selectcategory',[i])
	
#	open()



func selectcategory(button):
	if button.get_name() == 'everything':
		for i in get_tree().get_nodes_in_group('invcategory'):
			i.set_pressed(i == button)
	else:
		categories.everything = false
		get_node("everything").set_pressed(false)
	for i in categories:
		categories[i] = get_node(i).is_pressed()
	categoryitems()

func categoryitems():
	for i in get_node("ScrollContainer/GridContainer/").get_children() + $ScrollContainer2/GridContainer.get_children():
		if (categories.everything == true && i.get_name() != 'Button' ) || (i.has_meta('category') && i.get_meta("category") != 'dummy' && categories[i.get_meta('category')] == true):
			i.visible = true
		else:
			i.visible = false


func open(place = 'mansion', part = 'inventory', keepslave = false):
	
	location = place
	state = part
	updateitems()
	calculateweight()
	get_node("mode").set_normal_texture(modetextures[state])
	self.visible = true

func updateitems():
	clearitems()
	if state == 'inventory':
		itemsinventory()
	elif state == 'backpack':
		itemsbackpack()
	itemsshop()
	$gold.text = str(globals.resources.gold)
	categoryitems()

var modetextures = {inventory = load("res://files/buttons/inventory/12_chest.png"), backpack = load("res://files/buttons/inventory/13_bag.png")}

func _on_mode_pressed():
	if state == 'inventory':
		open('mansion','backpack',true)
	else:
		open('mansion','inventory',true)
	get_node("mode").set_normal_texture(modetextures[state])

func clearitems():
	for i in itemgrid.get_children():
		if i.get_name() != "Button":
			i.visible = false
			i.queue_free()
	itemgrid.rect_size = itemgrid.rect_min_size


func itemsinventory():
	
	var button
	var array = []
	var tempitem
	
	for i in globals.itemdict.values():
		if i.amount < 1 || i.type in ['gear','dummy'] || (filter != '' && (i.name.findn(filter) < 0 && i.description.findn(filter) < 0)):
			continue
		elif i.type == 'quest':
			continue
		array.append(i)
	array.sort_custom(globals.items,'sortitems')
	
	for i in array:
		button = get_node("ScrollContainer/GridContainer/Button").duplicate()
		button.visible = true
		var price = getcost(i, 'sell')
		button.get_node('number').set_text(str(i.amount))
		button.get_node("price").text = str(price)
		button.get_node("Label").set_text(i.name)
		button.get_node("info").connect("pressed",self,'info',[button])
		button.get_node("sell").connect("pressed",self,'sellitem',[button])
		button.connect("mouse_entered", globals, 'itemtooltip', [i])
		button.connect("mouse_exited", globals, 'itemtooltiphide')
		button.set_meta('item', i)
		button.set_meta("price",price)
		button.set_meta("number", i.amount)
		button.set_meta("category", i.type)
		if i.icon != null:
			button.get_node("icon").set_texture(i.icon)
		itemgrid.add_child(button)
	array.clear()
		
	for i in globals.state.unstackables.values():
		if (i.owner != null && str(i.owner) != 'backpack') && globals.state.findslave(i.owner) == null && str(i.owner) != globals.player.id:
			i.owner = null
		if i.owner != null || (filter != '' && (i.name.findn(filter) < 0 && i.description.findn(filter) < 0)):
			continue
		var entryexists = false
		for k in array:
			if k.size() > 0 && k[0].code == i.code && k[0].name == i.name && str(k[0].effects) == str(i.effects) :
				k.append(i)
				entryexists = true
				break
		if entryexists == false:
			array.append([])
			array[array.size()-1].append(i)
		
	for i in array:
		button = get_node("ScrollContainer/GridContainer/Button").duplicate()
		button.visible = true
		var price = getcost(i[0], 'sell')
		button.get_node('number').set_text(str(i.size()))
		button.get_node("Label").set_text(i[0].name)
		button.get_node("info").connect("pressed",self,'info',[button])
		button.get_node("price").text = str(price)
		button.get_node("sell").connect("pressed",self,'sellitem',[button])
		button.set_meta('item', i[0])
		button.set_meta("itemarray", i)
		button.connect("mouse_entered", globals, 'itemtooltip', [i[0]])
		button.connect("mouse_exited", globals, 'itemtooltiphide')
		button.set_meta("number", i.size())
		button.set_meta("category", 'gear')
		button.set_meta("price", price)
		if i[0].enchant != '':
			button.get_node("Label").set('custom_colors/font_color', Color(0,0.5,0))
		elif i[0].enchant == 'unique':
			button.get_node("Label").set('custom_colors/font_color', Color(0.6,0.4,0))
		if i[0].icon != null:
			button.get_node("icon").set_texture(load(i[0].icon))
		itemgrid.add_child(button)

func itemsbackpack():
	var itemgrid = get_node("ScrollContainer/GridContainer")
	var button
	var array = []
	var items = false
	var tempitem
	for i in globals.state.backpack.stackables:
		tempitem = globals.itemdict[i]
		if tempitem.type == 'quest' || (filter != '' && (tempitem.name.findn(filter) < 0 && tempitem.description.findn(filter) < 0)):
			continue
		var price = getcost(i, 'sell')
		button = get_node("ScrollContainer/GridContainer/Button").duplicate()
		get_node("ScrollContainer/GridContainer").add_child(button)
		button.visible = true
		button.get_node("Label").set_text(tempitem.name)
		button.get_node("info").connect("pressed",self,'info',[button])
		button.get_node("number").set_text(str(globals.state.backpack.stackables[i]))
		button.connect("mouse_entered", globals, 'itemtooltip', [tempitem])
		button.connect("mouse_exited", globals, 'itemtooltiphide')
		button.get_node("price").text = str(price)
		button.get_node("sell").connect("pressed",self,'sellitem',[button])
		button.set_meta("price", price)
		if tempitem.icon != null:
			button.get_node("icon").set_texture(tempitem.icon)
		button.set_meta("item", tempitem)
		button.set_meta("category", tempitem.type)
	array.clear()
	for i in globals.state.unstackables.values():
		if (i.owner != null && str(i.owner) != 'backpack') && globals.state.findslave(i.owner) == null && str(i.owner) != globals.player.id:
			i.owner = null
		if str(i.owner) != 'backpack' || (filter != '' && (i.name.findn(filter) < 0 && i.description.findn(filter) < 0)):
			continue
		var entryexists = false
		for k in array:
			if k.size() > 0 && k[0].code == i.code && k[0].name == i.name && str(k[0].effects) == str(i.effects) :
				k.append(i)
				entryexists = true
				break
		if entryexists == false:
			array.append([])
			array[array.size()-1].append(i)
	
	for i in array:
		var price = getcost(i[0], 'sell')
		button = get_node("ScrollContainer/GridContainer/Button").duplicate()
		button.visible = true
		button.get_node('number').set_text(str(i.size()))
		button.get_node("Label").set_text(i[0].name)
		button.get_node("info").connect("pressed",self,'info',[button])
		button.get_node("price").text = str(price)
		button.set_meta("price", price)
		button.get_node("sell").connect("pressed",self,'sellitem',[button])
		button.connect("mouse_entered", globals, 'itemtooltip', [i[0]])
		button.connect("mouse_exited", globals, 'itemtooltiphide')
		button.set_meta('item', i[0])
		button.set_meta("itemarray", i)
		button.set_meta("number", i.size())
		button.set_meta("category", 'gear')
		if i[0].enchant != '':
			button.get_node("Label").set('custom_colors/font_color', Color(0,0.5,0))
		if i[0].icon != null:
			button.get_node("icon").set_texture(load(i[0].icon))
		get_node("ScrollContainer/GridContainer").add_child(button)

func itemsshop():
	var shop = merchantitems
	for i in $ScrollContainer2/GridContainer.get_children():
		if i.get_name() != "Button":
			i.visible = false
			i.queue_free()
	
	for i in shop:
		var item = globals.itemdict[i]
		item = globals.itemdict[i]
		if item.code.find('teleport') >= 0 && item.code != 'teleportseal':
			var temp = item.code.replace('teleport', '')
			if temp == globals.state.location || globals.state.portals[temp].enabled == true:
				continue
		elif item.has('obtainreqs') && !globals.evaluate(item.obtainreqs):
			continue
		var newbutton = $ScrollContainer2/GridContainer/Button.duplicate()
		var price = getcost(item, 'buy')
		$ScrollContainer2/GridContainer.add_child(newbutton)
		newbutton.visible = true
		newbutton.get_node("price").set_text(str(price))
		newbutton.get_node('Label').set_text(item.name)
		newbutton.get_node("buy").connect("pressed",self,'buyitem',[newbutton])
		newbutton.set_meta("price", price)
		newbutton.connect("mouse_entered", globals, 'itemtooltip', [item])
		newbutton.connect("mouse_exited", globals, 'itemtooltiphide')
		newbutton.set_meta("category", item.type)
		if typeof(item.icon) == TYPE_STRING:
			newbutton.get_node("icon").set_texture(load(item.icon))
		else:
			newbutton.get_node("icon").set_texture(item.icon)
		newbutton.set_meta('item', item)
		newbutton.get_node("info").connect("pressed",self,'info',[newbutton])
		#newbutton.connect('pressed',self,'selectshopitem', [newbutton])


func getcost(item, mode):
	var cost = 0
	if mode == 'buy':
		cost = item.cost
	else:
		var merchant = false
		for i in globals.state.playergroup:
			if globals.state.findslave(i).spec == 'merchant':
				merchant = true
		if typeof(item) == TYPE_STRING:
			item = globals.itemdict[item]
		if globals.itemdict[item.code].type != 'gear':
			cost = item.cost*variables.sellingitempricemod
			if merchant == true:
				cost *= 1.25
			if item.type == 'potion' && globals.state.spec == "Alchemist":
				cost *= 2
		else:
			var itemtype = globals.itemdict[item.code]
			cost = itemtype.cost*variables.sellingitempricemod
			if item.has('enchant') && item.enchant != '':
				cost = cost*variables.enchantitemprice
	return round(cost)


func info(button):
	get_node("iteminfo/RichTextLabel").set_bbcode(globals.itemdescription(button.get_meta('item')))
	get_node("iteminfo/TextureFrame").set_texture(button.get_node('icon').get_texture())
	get_node("iteminfo").popup()


func calculateweight():
	var weight = globals.state.calculateweight()
	get_node("weightmeter/Label").set_text("Weight: " + str(weight.currentweight) + '/' + str(weight.maxweight))
	get_node("weightmeter").set_value((weight.currentweight*10/max(weight.maxweight,1)*10))


func _on_iteminfo_input_event( ev ):
	if ev.is_action("LMB") && ev.is_pressed():
		get_node("iteminfo").visible = false

func _on_inventoryclose_pressed():
	globals.main.get_node("outside").shoppanelclosecheck()
	filter = ''
	$search.text = ''
	self.visible = false



func sellitem(button):
	var item = button.get_meta('item')
	var gold = button.get_meta('price')
	globals.resources.gold += gold
	if state == 'inventory' or (item.has('owner') && item.owner != null):
		if item.has('id'):
			var itemarray = button.get_meta('itemarray')
			var tempitem = itemarray[itemarray.size()-1]
			globals.state.unstackables.erase(tempitem.id)
			itemarray.erase(tempitem)
			button.get_node('number').set_text(str(itemarray.size()))
			if itemarray.size() <= 0:
				button.visible = false
				button.queue_free()
			calculateweight()
		else:
			item.amount -= 1
			button.get_node('number').set_text(str(item.amount))
			if item.amount <= 0:
				button.visible = false
				button.queue_free()
	elif state == 'backpack':
		globals.state.backpack.stackables[item.code] -= 1
		if globals.state.backpack.stackables.has(item.code):
			button.get_node('number').set_text(str(globals.state.backpack.stackables[item.code]))
		else:
			button.visible = false
			button.queue_free()
		calculateweight()
	$gold.text = str(globals.resources.gold)

func buyitem(button):
	var text = ''
	var item = button.get_meta('item')
	text += "You will purchase [color=green]" + item.name + "[/color] for " + str(getcost(item, 'buy')) + " gold per piece. "
	selecteditem = button
	$amountselect.popup()
	$amountselect/RichTextLabel.bbcode_text = text

var selecteditem

func _on_confirm_pressed():
	var amount = $amountselect/SpinBox.value
	var price = selecteditem.get_meta('price')
	var item = selecteditem.get_meta('item')
	if amount*price > globals.resources.gold:
		globals.main.infotext("Not enough gold",'red')
		return
	if state == 'backpack' && item.has('weight') && globals.state.calculateweight().currentweight + amount*item.weight > globals.state.calculateweight().maxweight:
		globals.main.infotext("Not enough carry capacity",'red')
		return
	elif state == 'backpack' && (item.code == 'food' || (item.code.find('teleport') >= 0 && item.code != 'teleportseal')):
		globals.main.infotext("This item can't be purchased for backpack",'red')
		return
	if item.type != 'gear':
		if state != 'backpack':
			item.amount += amount
		else:
			if globals.state.backpack.stackables.has(item.code):
				globals.state.backpack.stackables[item.code] += amount
			else:
				globals.state.backpack.stackables[item.code] = amount
	else:
		var counter = amount
		while counter >= 1:
			var tmpitem = globals.items.createunstackable(item.code)
			if state != 'backpack':
				globals.state.unstackables[str(tmpitem.id)] = tmpitem
			else:
				globals.state.unstackables[str(tmpitem.id)] = tmpitem
				tmpitem.owner = 'backpack'
			counter -= 1
			globals.main.infotext("Obtained: " + item.name, 'green')
	if item.code in ['food'] || item.type == 'quest':
		globals.items.call(item.effect, item)
	elif item.code.find('teleport') >= 0 && item.code != 'teleportseal':
		globals.items.call(item.effect, item)
		selecteditem = null
	else:
		globals.resources.gold -= price*amount
	clearitems()
	if state == 'inventory':
		itemsinventory()
	elif state == 'backpack':
		itemsbackpack()
	categoryitems()
	$gold.text = str(globals.resources.gold)
	$amountselect.visible = false

func _on_cancel_pressed():
	$amountselect.visible = false




func _on_search_text_changed(new_text):
	filter = new_text
	clearitems()
	if state != 'backpack':
		itemsinventory()
	else:
		itemsbackpack()


func _on_add5_pressed():
	if $amountselect/SpinBox.value == 1:
		$amountselect/SpinBox.value = 0
	$amountselect/SpinBox.value += 5


func _on_add10_pressed():
	if $amountselect/SpinBox.value == 1:
		$amountselect/SpinBox.value = 0
	$amountselect/SpinBox.value += 10


func _on_addmax_pressed():
	$amountselect/SpinBox.value = 99
