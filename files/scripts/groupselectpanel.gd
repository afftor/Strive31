extends Panel

func show():
	var newbutton
	var group
	var text = ''
	get_parent().checkplayergroup()
	get_parent()._on_mansion_pressed()
	if OS.get_name() != 'HTML5' && globals.rules.fadinganimation == true:
		yield(get_parent(), 'animfinished')
	self.visible = true
	for i in get_node("grouppanel/ScrollContainer/VBoxContainer").get_children():
		if i != get_node("grouppanel/ScrollContainer/VBoxContainer/Button"):
			i.visible = false
			i.queue_free()
	for person in globals.slaves:
		if person.away.at == 'hidden':
			continue
		newbutton = get_node("grouppanel/ScrollContainer/VBoxContainer/Button").duplicate()
		get_node("grouppanel/ScrollContainer/VBoxContainer").add_child(newbutton)
		newbutton.visible = true
		newbutton.set_text(person.name_long() + ' ' + person.race)
		if globals.state.playergroup.has(str(person.id)):
			newbutton.set_pressed(true)
		elif globals.state.playergroup.size() >= 3 || person.energy <= 10 || person.stress >= 80 || person.loyal + person.obed < 90 || person.sleep == 'jail' || person.away.duration != 0:
			newbutton.set_disabled(true)
		newbutton.connect("pressed",self,'addtogroup',[person, newbutton])
	if globals.state.playergroup.size() <= 0:
		text = 'You have no assigned followers'
	else:
		text = 'You will be accompanied by:\n'
	for i in globals.state.playergroup:
		group = globals.state.findslave(i)
		text = text + group.name_long() + ', ' + group.race +', Level: ' +  str(group.level) + ', Health: '+str(round(group.health)) + ", Energy: "+ str(round(group.energy))+  '\n'
	get_node("grouppanel/grouplabel").set_bbcode(text)
	#updateitemsinventory()
	#updateitemsbackpack()
	#calculateweight()


func calculateweight():
	var weight = globals.state.calculateweight()
	get_node("grouppanel/weightmeter/Label").set_text("Weight: " + str(weight.currentweight) + '/' + str(weight.maxweight))
	get_node("grouppanel/weightmeter").set_val((weight.currentweight*10/max(weight.maxweight,1)*10))
	if weight.overload == true:
		get_node("grouppanel/closegroup").set_tooltip("Reduce carry weight before proceeding")
		get_node("grouppanel/closegroup").set_disabled(true)
	else:
		get_node("grouppanel/closegroup").set_tooltip("")
		get_node("grouppanel/closegroup").set_disabled(false)

func addtogroup(person, button):
	if button.is_pressed() == true:
		globals.state.playergroup.append(person.id)
	else:
		globals.state.playergroup.remove(globals.state.playergroup.find(person.id))
	show()

func _on_closegroup_pressed():
	self.visible = false
	get_parent()._on_mansion_pressed()

