
extends Node
############### Laboratory

var labperson

func _on_lab_pressed(person = null):
	var main = get_tree().get_current_scene()
	var labassist
	if person != null:
		person.work = 'labassist'
	for i in globals.slaves:
		if i.work == 'labassist':
			labassist = i
	var text = "Your basement laboratory is set and functioning. Rows of books and manuscripts can be found on your work table and shelves. Restricting and enhancing equipment kept clean and working at the far walls. "
	if labassist == null:
		main.background_set('lab')
		if OS.get_name() != 'HTML5':
			yield(main, 'animfinished')
		main.hide_everything()
		get_node("labstart").set_disabled(true)
		get_node("chooseassist").set_text("Choose Assistant")
		text = text + "\n[color=yellow]You need to assign a Lab Assistant before you can conduct any modifications. [/color]"
	else:
		main.background_set('lab')
		if OS.get_name() != 'HTML5':
			yield(main, 'animfinished')
		main.hide_everything()
		labassist.work = 'labassist'
		get_node("chooseassist").set_text("Unassign Assistant")
		get_node("labstart").set_disabled(false)
		text = text + labassist.dictionary("\n[color=aqua]$name[/color] is taking care of the lab and its residents. ")
	self.visible = true
	get_node("labinfo").set_bbcode(text)
	
	if globals.state.tutorial.lab == false:
		get_tree().get_current_scene().get_node("tutorialnode").lab()

func _on_chooseassist_pressed():
	if get_node("chooseassist").get_text() == ("Choose Assistant"):
		get_tree().get_current_scene().selectslavelist(false,'_on_lab_pressed',self)
	else:
		for i in globals.slaves:
			if i.work == 'labassist':
				i.work = 'rest'
		_on_lab_pressed()

func _on_labselectself_pressed():
	labperson = globals.player
	_on_labstart_pressed()
	_on_labstart_pressed(globals.player)
	get_node("labmodpanel/labselect").set_text('Deselect')



func _on_labstart_pressed(selected = null):
	for i in get_node("labmodpanel/ScrollContainer/primalmodlist").get_children():
		i.set_pressed(false)
	var text = ''
	labperson = selected
	var person = labperson
	var labassist
	for i in globals.slaves:
		if i.work == 'labassist':
			labassist = i
	get_node("labmodpanel").visible = true
	if selected == null:
		get_node("labmodpanel/labselect").set_text('Select Subject')
		for i in get_node("labmodpanel/ScrollContainer1/secondarymodlist").get_children():
			if i != get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp"):
				i.visible = false
				i.queue_free()
		get_node("labmodpanel/labconfirm").set_disabled(true)
		for i in get_node("labmodpanel/ScrollContainer/primalmodlist").get_children():
			i.set_disabled(true)
	elif labassist == person:
		for i in get_node("labmodpanel/ScrollContainer1/secondarymodlist").get_children():
			if i != get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp"):
				i.visible = false
				i.queue_free()
		get_node("labmodpanel/labselect").set_text('Deselect')
		get_node("labmodpanel/labconfirm").set_disabled(true)
		text = text + person.dictionary("You can't conduct modifications on $name as $he is your current assistant.")
		for i in get_node("labmodpanel/ScrollContainer/primalmodlist").get_children():
			i.set_disabled(true)
	else:
		get_node("labmodpanel/labselect").set_text('Deselect')
		for i in get_node("labmodpanel/ScrollContainer/primalmodlist").get_children():
			i.set_disabled(false)
	if person != null:
		if person.tail == "snake tail" || person.tail == 'tentacles' || person.tail == 'horse' || person.tail == 'spider abdomen':
			get_node("labmodpanel/ScrollContainer/primalmodlist/tail").visible = false
		else:
			get_node("labmodpanel/ScrollContainer/primalmodlist/tail").visible = true
		if person.skin == 'jelly':
			get_node("labmodpanel/ScrollContainer/primalmodlist/skin").visible = false
		else:
			get_node("labmodpanel/ScrollContainer/primalmodlist/skin").visible = true
	if globals.state.mansionupgrades.mansionlab < 2:
		$labmodpanel/ScrollContainer/primalmodlist/traitremove.disabled = true
		$labmodpanel/ScrollContainer/primalmodlist/traitremove.hint_tooltip = 'Requires Laboratory Upgrade 2'
	else:
		$labmodpanel/ScrollContainer/primalmodlist/traitremove.disabled = false
		$labmodpanel/ScrollContainer/primalmodlist/traitremove.hint_tooltip = ''
	get_node("labmodpanel/modificationtext").set_bbcode(text)


func _on_labcancel_pressed():
	labperson = null
	get_node("labmodpanel").visible = false

func _on_labselect_pressed():
	if get_node("labmodpanel/labselect").get_text() == 'Select Subject':
		get_tree().get_current_scene().selectslavelist(true,'_on_labstart_pressed',self,"person.work != 'labassist' && person.race != 'Slime'",true)
	else:
		labperson = null
		_on_labstart_pressed()
		get_node("labmodpanel/labselect").set_text('Select Subject')

var horns = {
type = 'cosmetics',
description = '',
options =  ['none','short', 'long_straight', 'curved'],
target = 'horns',
price = {mana = 50, gold = 200},
items = {magicessenceing = 1, taintedessenceing = 3},
time = 2
}
var ears = {
type = 'cosmetics',
description = '',
options =  ['human','pointy','short_furry','long_pointy_furry','long_round_furry','long_droopy_furry','feathery','fins'],
target = 'ears',
price = {mana = 40, gold = 200},
items = {natureessenceing = 2},
time = 3
}
var tail = {
type = 'cosmetics',
description = '',
options = ['none','demon','dragon', 'scruffy', 'bird', 'cat', 'fox', 'wolf', 'bunny', 'racoon','fish'],
target = 'tail',
price = {mana = 65, gold = 300},
items = {bestialessenceing = 3},
time = 5
}
var wings = {
type = 'cosmetics',
description = '',
options = ['none', 'insect','feathered_black', 'feathered_white', 'feathered_brown', 'leather_black', 'leather_red'],
target = 'wings',
price = {mana = 80, gold = 350},
items = {bestialessenceing = 2, magicessenceing = 4},
time = 7
}
var skin = {
type = 'cosmetics',
description = '',
options =['pale', 'fair', 'olive', 'tan', 'brown','dark','blue','pale blue','green', 'red', 'purple', 'teal'],
target = 'skin',
price = {mana = 50, gold = 250},
items = {magicessenceing = 2},
time = 5
}
var traitremove = {
code = 'traitremove',
type = 'custom',
description = '',
options =[''],
target = 'skin',
data = {
price = {mana = 50, gold = 100}, items = {claritypot = 1}, time = 3},
}
var penis = {
code = 'penis',
type = 'custom',
description = '',
options = [''],
target = '',
data = {
grow = {price = {mana = 100, gold = 250}, items = {majoruspot = 1}, time = 3},
remove = {price = {mana = 50, gold = 150}, items = {taintedessenceing = 2}, time = 4},
humanshape = {price = {mana = 40, gold = 200}, items = {magicessenceing = 2}, time = 3},
felineshape = {price = {mana = 60, gold = 300}, items = {bestialessenceing = 2}, time = 4},
canineshape = {price = {mana = 60, gold = 350}, items = {bestialessenceing = 2}, time = 4},
equineshape = {price = {mana = 60, gold = 400}, items = {bestialessenceing = 2}, time = 6},
pussy = {price = {mana = 50, gold = 300}, items = {natureessenceing = 2, fluidsubstanceing = 2}, time = 5},
removepussy = {price = {mana = 50, gold = 300}, items = {taintedessenceing = 2}, time = 4},
},
}

var balls = {
code = 'balls',
type = 'custom',
description = '',
options = [''],
target = '',
data = {
grow = {price = {mana = 75, gold = 250}, items = {majoruspot = 1}, time = 3},
remove = {price = {mana = 50, gold = 150}, items = {taintedessenceing = 2}, time = 4},},
}
var tits = {
code = 'tits',
type = 'custom',
description = '',
options = [''],
target = 'titssize',
data = {
developtits = {price = {mana = 120, gold = 500}, items = {maturingpot = 2}, time = 6},
reversetits = {price = {mana = 60, gold = 300}, items = {youthingpot = 1}, time = 4},
addnipples = {price = {mana = 40, gold = 200}, items = {natureessenceing = 2, bestialessenceing = 2}, time = 2},
removenipples = {price = {mana = 25, gold = 200}, items = {taintedessenceing = 2}, time = 2},
maximizenipples = {price = {mana = 100, gold = 500}, items = {natureessenceing = 5, bestialessenceing = 5}, time = 5},
minimizenipples = {price = {mana = 50, gold = 200}, items = {taintedessenceing = 5}, time = 5},
hollownipples = {price = {mana = 100, gold = 400}, items = {natureessenceing = 2, fluidsubstanceing = 2, magicessenceing = 2}, time = 7}
},
}
var mods = {
code = 'mod',
type = 'custom',
description = '',
options = [''],
target = '',
data = {
tongue = {price = {mana = 75, gold = 250}, items = {natureessenceing = 3, magicessenceing = 1}, time = 3},
fur = {price = {mana = 100, gold = 250}, items = {natureessenceing = 2, magicessenceing = 2}, time = 6},
scales = {price = {mana = 100, gold = 250}, items = {natureessenceing = 2, magicessenceing = 2}, time = 6},
hearing = {price = {mana = 50, gold = 150}, items = {bestialessenceing = 1, magicessenceing = 1}, time = 4},
"str" : {price = {mana = 75, gold = 200}, items = {bestialessenceing = 2, magicessenceing = 2}, time = 5},
"agi" : {price = {mana = 75, gold = 200}, items = {bestialessenceing = 2, natureessenceing = 2}, time = 5},
"beauty" : {price = {mana = 50, gold = 300}, items = {magicessenceing = 2, natureessenceing = 2, beautypot = 1}, time = 5},
},}
var eyecolor = {
code = 'eyecolor',
type = 'custom',
description = '',
options = [''],
data = {target = 'eyecolor',
price = {mana = 40, gold = 100},
items = {natureessenceing = 1},
time = 2}
}

func labbuttonselected(string):
	var person = labperson
	get_node("labmodpanel/modificationtext").set_bbcode('')
	var dict = {'horns' : horns, 'ears':ears, 'tail':tail,'wings' : wings, 'skin':skin, 'eyecolor': eyecolor, 'penis':penis, 'tits':tits, 'balls':balls, 'mods':mods, 'traitremove':traitremove}
	for i in get_node("labmodpanel/ScrollContainer/primalmodlist").get_children():
		if i.get_name() != string && i.is_pressed() == true:
			i.set_pressed(false)
	for i in get_node("labmodpanel/ScrollContainer1/secondarymodlist").get_children():
		if i != get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp"):
			i.queue_free()
			i.visible = false
	if dict[string].type == 'custom':
		var newbutton
		if dict[string].code == 'penis':
			if person.penis != 'none' && person.vagina != 'none':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Remove')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'remove'])
				newbutton.set_meta('effect', 'remove')
			if person.penis != 'none' && person.penistype != 'human':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Shape: Normal')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'humanshape'])
				newbutton.set_meta('effect', 'humanshape')
			if person.penis != 'none' && person.penistype != 'feline':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Shape: Feline')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'felineshape'])
				newbutton.set_meta('effect', 'felineshape')
			if person.penis != 'none' && person.penistype != 'canine':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Shape: Canine')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'canineshape'])
				newbutton.set_meta('effect', 'canineshape')
			if person.penis != 'none' && person.penistype != 'equine':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Shape: Equine')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'equineshape'])
				newbutton.set_meta('effect', 'equineshape')
			if person.penis == 'none':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Grow')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'grow'])
				newbutton.set_meta('effect', 'grow')
			if person.vagina == 'none' || person.preg.has_womb == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Female genitals')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'pussy'])
				newbutton.set_meta('effect', 'pussy')
			if person.vagina != 'none':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Remove Vagina')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'removepussy'])
				newbutton.set_meta('effect', 'removepussy')
		elif dict[string].code == 'tits':
			if person.titsextra >= 1 && person.titsextra <= 4&& person.titsextradeveloped == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Develop nipples')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'developtits'])
				newbutton.set_meta('effect', 'developtits')
			elif person.titsextra >= 1:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Remove nipples')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'reversetits'])
				newbutton.set_meta('effect', 'reversetits')
			if person.titsextra < 4:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Add nipples')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'addnipples'])
				newbutton.set_meta('effect', 'addnipples')
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Maximize nipples')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'maximizenipples'])
				newbutton.set_meta('effect', 'maximizenipples')
			if person.titsextra > 0:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Remove nipples')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'removenipples'])
				newbutton.set_meta('effect', 'removenipples')
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Minimize nipples')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'minimizenipples'])
				newbutton.set_meta('effect', 'minimizenipples')
			if globals.sizearray.find(person.titssize) >= 3 && person.mods.has('hollownipples') == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Hollow nipples')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'hollownipples'])
				newbutton.set_meta('effect', 'hollownipples')
		elif dict[string].code == 'balls':
			if person.balls == 'none':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Grow')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'grow'])
				newbutton.set_meta('effect', 'grow')
			if person.balls != 'none':
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Remove')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'remove'])
				newbutton.set_meta('effect', 'remove')
		elif dict[string].code == 'mod':
			if person.skincov == 'full_body_fur' && person.mods.has('augmentfur') == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Enhanced fur')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'fur'])
				newbutton.set_meta('effect', 'fur')
			if person.mods.has('augmenttongue') == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Elongated tongue')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'tongue'])
				newbutton.set_meta('effect', 'tongue')
			if person.skincov == 'scales' && person.mods.has('augmentscales') == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Enhanced scales')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'scales'])
				newbutton.set_meta('effect', 'scales')
			if person.mods.has('augmenthearing') == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Enhanced hearing')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'hearing'])
				newbutton.set_meta('effect', 'hearing')
			if person.mods.has('augmentstr') == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Enhanced muscles')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'str'])
				newbutton.set_meta('effect', 'str')
			if person.mods.has('augmentagi') == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Enhanced reflexes')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'agi'])
				newbutton.set_meta('effect', 'agi')
			if person.mods.has('augmentbeauty') == false:
				newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
				newbutton.visible = true
				newbutton.set_text('Improve appearance')
				get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
				newbutton.connect("pressed",self,'customenh', [dict[string],'beauty'])
				newbutton.set_meta('effect', 'beauty')
		elif dict[string].code == 'traitremove':
			globals.main.traitpanelshow(labperson,'clearphys')
		elif dict[string].code == 'eyecolor':
			globals.main.seteyecolor(labperson)
		return

	for i in dict[string].options:
		var newbutton = get_node("labmodpanel/ScrollContainer1/secondarymodlist/buttontemp").duplicate()
		newbutton.visible = true
		newbutton.set_text(i.capitalize())
		get_node("labmodpanel/ScrollContainer1/secondarymodlist").add_child(newbutton)
		newbutton.connect("pressed",self,'modchosen', [dict[string], string, i])

func text_changed(changedtext = '', dict = {}, string = '', selected = ''):
	get_node("labmodpanel/modificationtext").set_bbcode()
	var person = labperson
	var allow = true
	var assist
	for i in globals.slaves:
		if i.work == 'labassist':
			assist = i
	var modification = str2var(var2str(dict))
	

func modchosen(dict= {}, string = '', selected=''):
	var person = labperson
	var text = ''
	var allow = true
	var assist
	for i in globals.slaves:
		if i.work == 'labassist':
			assist = i
	var modification = str2var(var2str(dict))
	if modification.type == 'cosmetics':
		get_node("labmodpanel/labconfirm").set_disabled(true)
		for i in get_node("labmodpanel/ScrollContainer1/secondarymodlist").get_children():
			if globals.decapitalize(i.get_text()) != selected:
				i.set_pressed(false) 
		if person[modification.target] == selected:
			allow = false
			text = "$names already possess " + selected.capitalize().replace('None', 'no') + ' ' +  string + '.'
		else:
			text = "Change $name's " + string + ' to ' + selected.capitalize() + '? Currently $he has ' + person[string].capitalize().replace('None', 'no') + ' ' + string + '. \nRequirements: \n' 
			for i in modification.price:
				modification.price[i] = round(modification.price[i]/(1+assist.wit/200.0))
				if person == globals.player:
					modification.price[i] = modification.price[i]*2
				if globals.resources[i] >= modification.price[i]:
					text = text + '[color=yellow]'+str(i) + '[/color] - [color=green]' + str(modification.price[i]) + '[/color], \n'
				else:
					allow = false
					text = text + '[color=yellow]' + str(i) + '[/color] - [color=red]' + str(modification.price[i]) + '[/color], \n'
			for i in modification.items:
				modification.items[i] = round(modification.items[i]/(1+assist.wit/200.0))
				if person == globals.player:
					modification.items[i] = modification.items[i]*2
				var item = globals.itemdict[i]
				if item.amount >= modification.items[i]:
					text = text + item.name + ' - [color=green]' + str(modification.items[i]) + '[/color], \n'
				else:
					allow = false
					text = text + item.name + ' - [color=red]' + str(modification.items[i]) + '[/color], \n'
			modification.time = max(round(modification.time/(1+assist.smaf/20.0)),1)
			if person == globals.player:
				modification.time = 0
			text = text + 'Required time - ' + str(modification.time) + globals.fastif(modification.time == 1, ' day',' days')+'. ' 
	
	if allow == true:
		get_node("labmodpanel/labconfirm").set_meta('data', modification)
		get_node("labmodpanel/labconfirm").set_meta('effect', selected)
		get_node("labmodpanel/labconfirm").set_disabled(false)
	else:
		get_node("labmodpanel/labconfirm").set_disabled(true)
	if person == globals.player:
		text = text.replace("has", "have")
		get_node("labmodpanel/modificationtext").set_bbcode(person.dictionaryplayer(text))
	else:
		get_node("labmodpanel/modificationtext").set_bbcode(person.dictionary(text))

func customenh(dict, action):
	var person = labperson
	var text = ''
	var allow = true
	var assist
	for i in globals.slaves:
		if i.work == 'labassist':
			assist = i
	var modification = str2var(var2str(dict))
	get_node("labmodpanel/labconfirm").set_disabled(true)
	
	for i in get_node("labmodpanel/ScrollContainer1/secondarymodlist").get_children():
		if i.has_meta('effect') == true:
			if i.get_meta('effect') != action:
				i.set_pressed(false) 
	
	if modification.code == 'penis' && action == 'grow':
		text = "$name's clit will be turned into a fully functional, fertile human penis. Semen will be produced by miniscule innards.\n\nRequirements: "
	elif modification.code == 'penis' && action == 'remove':
		text = "$name's penis will be magically reverted into a clitoris.\n\nRequirements:"
	elif modification.code == 'penis' && action == 'humanshape':
		text = "$name's cock will be changed to human shape. \n\nRequirements:"
	elif modification.code == 'penis' && action == 'felineshape':
		text = "$name's cock will be changed to feline shape, fitted with small barbs. \n\nRequirements:"
	elif modification.code == 'penis' && action == 'canineshape':
		text = "$name's cock will be changed to canine shape, with a sizeable knot at the base. \n\nRequirements:"
	elif modification.code == 'penis' && action == 'equineshape':
		text = "$name's cock will be changed to equine shape, with a blunt tip and flared head. \n\nRequirements:"
	elif modification.code == 'penis' && action == 'pussy':
		if person.vagina == 'none':
			text = "$name will obtain a fully functional vagina capable of pregnancy. \n\nRequirements:"
		else:
			text = "$name's womb will be restored and capable of pregnancy again. \n\nRequirements:"
	elif modification.code == 'penis' && action == 'removepussy':
		text = "$name's female genitals and reproduction system will be removed. \n\nRequirements"
	elif modification.code == 'tits' && action == 'developtits':
		text = "$name's additional rudimentary nipples will be developed into full-functional mammaries. \n\nRequirements:"
	elif modification.code == 'tits' && action == 'reversetits':
		text = "$name's secondary tits will be reverted back to rudimentary nipples. \n\nRequirements:"
	elif modification.code == 'tits' && action == 'addnipples':
		text = "$name's chest will be augmented with an additional pair of nipples.\n\nRequirements:"
	elif modification.code == 'tits' && action == 'removenipples':
		text = "A pair of secondary nipples will be removed from $name's chest. \n\nRequirements:"
	elif modification.code == 'tits' && action == 'maximizenipples':
		text = "$name's chest and stomach will be modified to hold 4 pairs of additional nipples. \n\nRequirements:"
	elif modification.code == 'tits' && action == 'minimizenipples':
		text = "All but one pair of $his original nipples will be removed from $name's chest. \n\nRequirements:"
	elif modification.code == 'tits' && action == 'hollownipples':
		text = "$name's nipples will be altered to be more elastic and sensitive, with the breasts hollow inside allowing $him to receive pleasure from penetration. \n\nRequirements:"
	elif modification.code == 'balls' && action == 'grow':
		text = "$name will grow a pair of small testicles. \n\nRequirements:"
	elif modification.code == 'balls' && action == 'remove':
		text = "$name will have $his testicles moved inside his body cavity, hiding them from sight (does not impact fertility). \n\nRequirements:"
	elif modification.code == 'mod' && action == 'fur':
		text = "$name's fur will be magically augmented to provide better protection. \n\nRequirements:"
	elif modification.code == 'mod' && action == 'scale':
		text = "$name's scales will be magically augmented to provide better protection. \n\nRequirements:"
	elif modification.code == 'mod' && action == 'tongue':
		text = "$name's tongue will be elongated allowing better performance during oral sex. \n\nRequirements:"
	elif modification.code == 'mod' && action == 'hearing':
		text = "$name's hearing will be magically augmented and will raise $his awareness. \n\nRequirements:"
	elif modification.code == 'mod' && action == 'str':
		text = "Due to magical augmentation, $name's muscles will have more room for growth. (increases maximum strength by 2) \n\nRequirements:"
	elif modification.code == 'mod' && action == 'agi':
		text = "Due to magical augmentation, $name's flexibility will have more room for growth. (increases maximum agility by 2) \n\nRequirements:"
	elif modification.code == 'mod' && action == 'beauty':
		text = "$name's visual appearance will be improved by correcting flaws and problematic parts. (inceases basic beauty, can only be used once per servant) \n\nRequirements:"
	
	
	
	for i in modification.data[action].price:
		modification.data[action].price[i] = round(modification.data[action].price[i]/(1+assist.wit/200.0))
		if person == globals.player:
			modification.data[action].price[i] = modification.data[action].price[i]*2
		if globals.resources[i] >= modification.data[action].price[i]:
			text = text + str(i) + ' - [color=green]' + str(modification.data[action].price[i]) + '[/color], \n'
		else:
			allow = false
			text = text + str(i) + ' - [color=red]' + str(modification.data[action].price[i]) + '[/color], \n'
	for i in modification.data[action].items:
		modification.data[action].items[i] = round(modification.data[action].items[i]/(1+assist.wit/200.0))
		if person == globals.player:
			modification.data[action].items[i] = modification.data[action].items[i]*2
		var item = globals.itemdict[i]
		if item.amount >= modification.data[action].items[i]:
			text = text + item.name + ' - [color=green]' + str(modification.data[action].items[i]) + '[/color], \n'
		else:
			allow = false
			text = text + item.name + ' - [color=red]' + str(modification.data[action].items[i]) + '[/color], \n'
	modification.data[action].time = max(round(modification.data[action].time/(1+assist.smaf*4)),1)
	if person == globals.player:
		modification.data[action].time = 0
	text = text + 'Required time - ' + str(modification.data[action].time) + globals.fastif(modification.data[action].time == 1, ' day',' days')+'. ' 
	
	if allow == true:
		get_node("labmodpanel/labconfirm").set_meta('data', modification)
		get_node("labmodpanel/labconfirm").set_meta('effect', action)
		get_node("labmodpanel/labconfirm").set_disabled(false)
	else:
		get_node("labmodpanel/labconfirm").set_disabled(true)
	if person == globals.player:
		get_node("labmodpanel/modificationtext").set_bbcode(person.dictionaryplayer(text))
	else:
		get_node("labmodpanel/modificationtext").set_bbcode(person.dictionary(text))



func _on_labconfirm_pressed():
	var person = labperson
	var assist
	for i in globals.slaves:
		if i.work == 'labassist':
			assist = i
	var operation = get_node("labmodpanel/labconfirm").get_meta('data')
	var result = get_node("labmodpanel/labconfirm").get_meta('effect')
	person.metrics.mods += 1
	if operation.type == 'cosmetics':
		person[operation.target] = result
		get_tree().get_current_scene().rebuild_slave_list()
		get_node("labmodpanel").visible = false
		person.away.duration = operation.time
		person.away.at = 'lab'
		person.stress += rand_range(70,95) - person.loyal/3
		person.health -= rand_range(person.stats.health_max/8,person.stats.health_max/4)
		for i in operation.price:
			globals.resources[i] -= operation.price[i]
		for i in operation.items:
			var item = globals.itemdict[i]
			item.amount -= operation.items[i]
	elif operation.type == 'custom' && operation.code == 'penis':
		if result == 'grow':
			person.penis = 'small'
			person.penistype = 'human'
		elif result == 'remove':
			person.penis = 'none'
		elif result == 'humanshape':
			person.penistype = 'human'
		elif result == 'felineshape':
			person.penistype = 'feline'
		elif result == 'canineshape':
			person.penistype = 'canine'
		elif result == 'equineshape':
			person.penistype = 'equine'
		elif result == 'pussy':
			person.vagina = 'normal'
			person.vagvirgin = false
			person.preg.has_womb = true
		elif result == 'removepussy':
			person.vagina = 'none'
			person.vagvirgin = false
			person.preg.has_womb = false
		person.checksex()
	elif operation.type == 'custom' && operation.code == 'tits':
		if result == 'developtits':
			person.titsextradeveloped = true
		elif result == 'reversetits':
			person.titsextradeveloped = false
		elif result == 'addnipples':
			person.titsextra += 1
		elif result == 'removenipples':
			person.titsextra -= 1
		elif result == 'maximizenipples':
			person.titsextra = 4
		elif result == 'minimizenipples':
			person.titsextra = 0
		elif result == 'hollownipples':
			person.mods['hollownipples'] = 'hollownipples'
	elif operation.type == 'custom' && operation.code == 'balls':
		if result == 'grow':
			person.balls = 'small'
		elif result == 'remove':
			person.balls = 'none'
	elif operation.type == 'custom' && operation.code == 'mod':
		if result == 'fur':
			person.mods['augmentfur'] = 'augmentfur'
			person.add_effect(globals.effectdict.augmentfur)
		elif result == 'tongue':
			person.mods['augmenttongue'] = 'augmenttongue'
		elif result == 'scales':
			person.mods['augmentscales'] = 'augmentscales'
			person.add_effect(globals.effectdict.augmentscales)
		elif result == 'str':
			person.mods['augmentstr'] = 'augmentstr'
			person.add_effect(globals.effectdict.augmentstr)
		elif result == 'agi':
			person.mods['augmentagi'] = 'augmentagi'
			person.add_effect(globals.effectdict.augmentagi)
		elif result == 'hearing':
			person.mods['augmenthearing'] = 'augmenthearing'
		elif result == 'beauty':
			person.mods['augmentbeauty'] = 'augmentbeauty'
			if person.beautybase < 60:
				person.beautybase += 30
			else:
				person.beautybase += 20
	if operation.type == 'custom':
		person.away.duration = operation.data[result].time
		person.away.at = 'lab'
		person.stress += rand_range(70,95) - person.loyal/3
		person.health -= rand_range(person.stats.health_max/8,person.stats.health_max/4)
		for i in operation.data[result].price:
			globals.resources[i] -= operation.data[result].price[i]
		for i in operation.data[result].items:
			var item = globals.itemdict[i]
			item.amount -= operation.data[result].items[i]
	
	labperson = null
	get_tree().get_current_scene().rebuild_slave_list()
	get_node("labmodpanel").visible = false




