### Mansion - Main
extends Control

var corejobs = ['rest','forage','hunt','cooking','library','nurse','maid','storewimborn','artistwimborn','assistwimborn','whorewimborn','escortwimborn','fucktoywimborn', 'lumberer', 'ffprostitution','guardian', 'research', 'slavecatcher','fucktoy']

var test = File.new()
var testslaverace = globals.allracesarray
var testslaveage = 'random'
var testslavegender = 'male'
var testslaveorigin = ['slave','poor','commoner','rich','noble']
var currentslave = 0 setget currentslave_set
var selectedslave = -1
var texture = null
var startcombatzone = "darkness"
var nameportallocation
var enddayprocess = false
onready var maintext = '' setget maintext_set, maintext_get
onready var exploration = get_node("explorationnode")
onready var slavepanel = get_node("MainScreen/slave_tab")
onready var outside = $outside

onready var tween = $Tween

onready var minimap = $outside/minimappanel/map/Control

signal animfinished


var checkforevents = false
var debug = false

#QMod - Variables
onready var mansionStaff = get_node("joblist").mansionStaff

func _ready():
	get_node("music").set_meta('currentsong', 'none')
	if OS.get_executable_path() == 'C:\\Users\\1\\Desktop\\godot\\Godot_v3.1.1-stable_win64.exe':
		globals.developmode = true
		debug = true
		get_node("startcombat").show()
		get_node("new slave button").show()
		get_node("debug").show()
	if !globals.state.tutorialcomplete:
		rebuildrepeatablequests()
	globals.main = self
	globals.items.main = self
	globals.mainscreen = 'mansion'
	globals.resources.panel = get_node("ResourcePanel")
	globals.events.textnode = globals.questtext
	if debug == true && globals.player.unique != 'player':
		globals.player.name = ''
		globals.player = globals.newslave('Human', 'teen', 'male')
		globals.player.ability.append('escape')
		globals.player.ability.append('heal')
		globals.player.abilityactive.append('escape')
		globals.player.abilityactive.append('mindread')
		globals.state.supporter = true
		for i in globals.gallery.charactergallery.values():
			i.unlocked = true
			i.nakedunlocked = true
			for k in i.scenes:
				k.unlocked = true
		_on_new_slave_button_pressed()
	rebuild_slave_list()
	globals.player.consent = true
	globals.spells.main = get_tree().get_current_scene()
	get_node("birthpanel/raise/childpanel/child").connect('pressed', self, 'babyage', ['child'])
	get_node("birthpanel/raise/childpanel/teen").connect('pressed', self, 'babyage', ['teen'])
	get_node("birthpanel/raise/childpanel/adult").connect('pressed', self, 'babyage', ['adult'])
	#exploration
	get_node("explorationnode").buttoncontainer = get_node("outside/buttonpanel/outsidebuttoncontainer")
	get_node("explorationnode").button = get_node("outside/buttonpanel/outsidebuttoncontainer/buttontemplate")
	get_node("explorationnode").main = self
	get_node("explorationnode").outside = get_node('outside')
	globals.events.outside = get_node("outside")
	globals.resources.update()
	
	for i in get_tree().get_nodes_in_group("invcategories"):
		i.connect("pressed",self,"selectcategory",[i])
	
	for i in get_tree().get_nodes_in_group("mansionbuttons"):
		i.connect("pressed",self,i.get_name())
	
	for i in get_tree().get_nodes_in_group("spellbookcategory"):
		i.connect("pressed",self,'spellbookcategory',[i])
	
	if globals.state.tutorialcomplete == false && globals.resources.day == 1:
		get_node("tutorialnode").starttutorial()
		globals.state.tutorialcomplete = true
	
	if globals.showalisegreet == true:
		alisegreet()
	elif globals.gameloaded == true:
		infotext("Game Loaded.",'green')
	
	for i in ['sstr','sagi','smaf','send']:
		get(i).get_node('Control').connect('mouse_entered', self, 'stattooltip',[i])
		get(i).get_node('Control').connect('mouse_exited', globals, 'hidetooltip')
		get(i).get_node('Button').connect("pressed",self,'statup', [i])
	
	$MainScreen/mansion/selfinspect/relativespanel/relativestext.connect("meta_hover_started",self,'relativeshover')
	$MainScreen/mansion/selfinspect/relativespanel/relativestext.connect("meta_hover_ended",globals, 'slavetooltiphide')
	$MainScreen/mansion/selfinspect/relativespanel/relativestext.connect("meta_clicked",self, "relativesselected")
	
	$MainScreen/mansion/mansioninfo.connect("meta_hover_started",self,'slavehover')
	$MainScreen/mansion/mansioninfo.connect("meta_hover_ended",globals, 'slavetooltiphide')
	$MainScreen/mansion/mansioninfo.connect("meta_clicked",self, "slaveclicked")
	
	$outside/textpanel/outsidetextbox.connect("meta_hover_started",self,'slavehover')
	$outside/textpanelexplore/outsidetextbox2.connect("meta_hover_started",self,'slavehover')
	$outside/textpanel/outsidetextbox.connect("meta_hover_ended",globals, 'slavetooltiphide')
	$outside/textpanelexplore/outsidetextbox2.connect("meta_hover_ended",globals, 'slavetooltiphide')
	
	$MainScreen/mansion/selfinspect/Contraception.connect("pressed", self, 'contraceptiontoggle')
	
	if variables.oldemily == true:
		for i in ["emilyhappy", "emilynormal","emily2normal","emily2happy","emily2worried","emilynakedhappy","emilynakedneutral"]:
			globals.spritedict[i] = globals.spritedict['old'+ i]
		globals.characters.characters.Emily.imageportait = "res://files/images/emily/oldemilyportrait.png"
	
	
	for i in [$sexselect/managerypanel/dogplus, $sexselect/managerypanel/dogminus, $sexselect/managerypanel/horseplus, $sexselect/managerypanel/horseminus]:
		i.connect("pressed", self, 'animalforsex', [i])
	if get_node("FinishDayPanel/FinishDayScreen/Global Report").get_bbcode().empty():
		get_node("Navigation/endlog").disabled = true
	_on_mansion_pressed()
	#startending()

var sexanimals = {dog = 0, horse = 0}


func _process(delta):
	$screenchange.visible = (float($screenchange.modulate.a) > 0)
	if self.checkforevents == true && !$screenchange.visible:
		for i in get_tree().get_nodes_in_group("blocknextdayevents"):
			if i.is_visible_in_tree():
				return
		checkforevents = false
		nextdayevents()
	for i in get_tree().get_nodes_in_group("messages"):
		if i.modulate.a > 0:
			i.modulate.a = (i.modulate.a - delta)
	
	if shaking == true && _timer >= 0:
		var shake_amount = 10
		$Camera2D.set_offset(Vector2(rand_range(-1.0, 1.0) * shake_amount, rand_range(-1.0, 1.0) * shake_amount))
		_timer -= delta
	elif shaking == true && _timer < 0:
		$Camera2D.set_offset(Vector2(0,0))
		shaking = false
		_timer = 0.0
	
	if musicfading == true && get_node("music").get_volume_db() != 0 && get_node("music").playing:
		get_node("music").set_volume_db(get_node('music').get_volume_db() - delta*20)
		if get_node("music").get_volume_db() <= 0:
			musicfading = false
			get_node("music").set_volume_db(0)
			musicvalue = $music.get_playback_position()
			get_node("music").playing = false
	if musicraising == true && get_node("music").volume_db < globals.rules.musicvol && get_node("music").playing:
		get_node("music").set_volume_db(get_node('music').get_volume_db() + delta*20)
		if get_node("music").get_volume_db() >= globals.rules.musicvol:
			musicraising = false
			get_node("music").set_volume_db(globals.rules.musicvol)

var shaking = false
var _timer = 0.0

func shake(duration):
	shaking = true
	_timer = duration


var musicfading = false
var musicraising = false
var musicvalue = 0

func maintext_set(value):
	var wild = $explorationnode.zones[$explorationnode.currentzone.code].combat == true
	$outside/textpanel.visible = !wild
	$outside/exploreprogress.visible = wild
	$outside/textpanelexplore.visible = wild
	$outside/textpanel/outsidetextbox.bbcode_text = value
	$outside/textpanelexplore/outsidetextbox2.bbcode_text = value


func maintext_get():
	var wild = $explorationnode.zones[$explorationnode.currentzone.code].combat == true
	var text = ''
	if wild == false:
		text = $outside/textpanel/outsidetextbox.bbcode_text
	else:
		text = $outside/textpanelexplore/outsidetextbox2.bbcode_text
	return text

func currentslave_set(value):
	currentslave = value
	globals.items.person = globals.slaves[currentslave]
	globals.spells.person = globals.slaves[currentslave]

func _input(event):
	var anythingvisible = false
	for i in get_tree().get_nodes_in_group("blockmaininput"):
		if i.is_visible_in_tree() == true:
			anythingvisible = true
			break
	if event.is_echo() == true || event.is_pressed() == false || anythingvisible:
		if event.is_action_pressed("escape") == true && get_node("tutorialnode").visible == true:
			get_node("tutorialnode").close()
		return
	if event.is_action_pressed("escape") == true && $ResourcePanel/menu.visible == true && $ResourcePanel/menu.disabled == false:
		if get_node("FinishDayPanel").is_visible_in_tree():
			get_node("FinishDayPanel").hide()
			return
		if !get_node("menucontrol").is_visible_in_tree():
			_on_menu_pressed()
		else:
			if get_node("menucontrol/menupanel/SavePanel").is_visible_in_tree():
				get_node("menucontrol/menupanel/SavePanel").hide()
			_on_closemenu_pressed()
	
	if get_focus_owner() == get_node("MainScreen/mansion/selfinspect/defaultMasterNoun") && get_node("MainScreen").is_visible_in_tree():
		return
	if event.is_action_pressed("F") && get_node("Navigation/end").is_visible_in_tree():
		_on_end_pressed()
	elif event.is_action_pressed("Q") && get_node("MainScreen").is_visible_in_tree():
		mansion()
	elif event.is_action_pressed("W") && get_node("MainScreen").is_visible_in_tree():
		jail()
	elif event.is_action_pressed("E") && get_node("MainScreen").is_visible_in_tree():
		libraryopen()
	elif event.is_action_pressed("A") && get_node("MainScreen").is_visible_in_tree() && !get_node("Navigation/alchemy").is_disabled():
		alchemy()
	elif event.is_action_pressed("S") && get_node("MainScreen").is_visible_in_tree() && !get_node("Navigation/laboratory").is_disabled():
		laboratory()
	elif event.is_action_pressed("Z") && get_node("MainScreen").is_visible_in_tree() && !get_node("Navigation/farm").is_disabled():
		farm()
	elif event.is_action_pressed("X") && get_node("MainScreen").is_visible_in_tree() && !$MainScreen/mansion/portals.is_disabled():
		portals()
	elif event.is_action_pressed("C") && get_node("MainScreen").is_visible_in_tree():
		leave()
	elif event.is_action_pressed("B") && get_node("MainScreen").is_visible_in_tree():
		_on_inventory_pressed()
	elif event.is_action_pressed("R") && get_node("MainScreen").is_visible_in_tree():
		_on_personal_pressed()
	elif event.is_action_pressed("V") && get_node("MainScreen").is_visible_in_tree():
		_on_combatgroup_pressed()
	elif event.is_action_pressed("L") && get_node("MainScreen").is_visible_in_tree():
		_on_questlog_pressed()

func clearscreen():
	$Navigation.visible = false
	$MainScreen.visible = false
	$charlistcontrol.visible = false
	#$FinishDayPanel.visible = false



func slavehover(meta):
	var tempslave
	if meta.find('person') >= 0:
		tempslave = slavearray[int(meta.replace('person',''))]
	elif meta.find('id') >= 0:
		tempslave = globals.state.findslave(meta.replace('id',''))
	globals.slavetooltip(tempslave)

func slaveclicked(meta):
	var tempslave
	if meta.find('person') >= 0:
		tempslave = slavearray[int(meta.replace('person',''))]
	elif meta.find('id') >= 0:
		tempslave = globals.state.findslave(meta.replace('id',''))
	globals.slavetooltiphide()
	globals.openslave(tempslave)

func sound(value):
	$soundeffect.set_volume_db(globals.rules.soundvol)
	if globals.rules.soundvol > 0:
		$soundeffect.stream = globals.sounddict[value]
		$soundeffect.playing = true
		$soundeffect.autoplay = false

func startending():
	var name = globals.player.name + " - Main Quest Completed"
	var scene = load("res://files/ending.tscn").instance()
	close_dialogue()
	animationfade(3)
	
	yield(self, 'animfinished')
	scene.add_to_group('blockmaininput')
	scene.add_to_group('blockoutsideinput')
	add_child_below_node($tooltip, scene)
	scene.launch()
	music_set('ending')
	if globals.developmode == false:
		globals.save_game('user://saves/'+name)
	if globals.state.decisions.has('hadekeep'):
		globals.slaves = globals.characters.create("Melissa")
	globals.state.mainquestcomplete = true


func _on_new_slave_button_pressed():
	
	globals.resources.day = 2
	for i in globals.state.tutorial:
		globals.state.tutorial[i] = true
	#music_set('mansion')
	get_node("music").play(100)
	#globals.state.capturedgroup.append(globals.newslave(testslaverace[rand_range(0,testslaverace.size())], testslaveage, testslavegender, testslaveorigin[rand_range(0,testslaveorigin.size())]))
	var person = globals.newslave(testslaverace[rand_range(0,testslaverace.size())], testslaveage, testslavegender, testslaveorigin[rand_range(0,testslaveorigin.size())])
	person.obed += 100
	person.loyal += 100
	person.xp += 9990
	person.consent = false
	person.lust = 100
	person.spec = 'merchant'
	globals.connectrelatives(globals.player, person, 'sibling')
	globals.impregnation(person, globals.player)

	person.attention = 70
	person.skillpoints = 100
	for i in ['conf','cour','charm','wit']:
		person[i] = 100
	person.ability.append('heavystike')
	for i in globals.state.portals.values():
		i.enabled = true
	for i in globals.spelldict.values():
		i.learned = true
	for i in globals.itemdict.values():
		if !i.type in ['gear','dummy']:
			i.amount += 10
	globals.itemdict.zoebook.amount = 0
	for i in ['armorchain','weaponaynerisrapier','clothpet','clothkimono','underwearlacy','armortentacle','accamuletemerald','accamuletemerald','clothtentacle']:
		var tmpitem = globals.items.createunstackable(i)
		globals.state.unstackables[str(tmpitem.id)] = tmpitem
		globals.items.enchantrand(tmpitem)
	globals.slaves = person
	person.unique = 'startslave'
	globals.player.stats.agi_mod = 5
	person.stats.health_cur = 100
	globals.state.reputation.wimborn = 41
	globals.state.sidequests.ivran = 'potionreceived'
	globals.state.mansionupgrades.mansionnursery = 1
	globals.state.mansionupgrades.mansionkennels = 1
	globals.player.ability.append("leechingstrike")
	globals.player.ability.append('heal')
	#globals.player.stats.maf_cur = 3
	globals.state.branding = 2
	globals.resources.gold += 5000
	globals.resources.food += 1000
	globals.resources.mana += 5
	globals.player.energy += 100
	globals.player.xp += 50
	globals.resources.upgradepoints += 100
	globals.state.mainquest = 0
	#globals.state.sidequests.ayda = 15
	globals.state.sidequests.emily = 14
	#globals.state.decisions.append('')
	globals.state.rank = 3
	#globals.state.plotsceneseen = ['garthorscene','hade1','hade2','frostfordscene']#,'slaverguild']
	globals.resources.mana = 200
	globals.state.farm = 3
	globals.state.mansionupgrades.mansionlab = 1
	globals.state.mansionupgrades.mansionalchemy = 1
	globals.state.mansionupgrades.mansionparlor = 1
	globals.state.backpack.stackables.teleportseal = 2
	globals.state.reputation.frostford = 50
	globals.state.condition -= 100
	globals.state.decisions = ['tishaemilytricked','chloebrothel','ivrantaken','goodroute','mainquestelves']
	#globals.player.relations.a = 1
	#globals.player.relations.b = globals.player.relations.get('b', 0) + 2\
	#buildtestcombatgroup()
	if true:
		for i in globals.characters.characters:
			person = globals.characters.create(i)
			globals.addrelations(globals.slaves[0], person, -800)
			person.loyal = 100
			person.health = 20
			person.stress = 0
			person.obed = 100
			person.lust = 0
			person.consent = true
			person.asser = 100
			person.lewdness = 100
			person.attention = 100
			person.learningpoints = 50
			globals.slaves = person
	#globals.events.zoepassitems()

func buildtestcombatgroup():
	var x = 3
	var array = [globals.player]
	while x > 0:
		var person = globals.newslave(testslaverace[rand_range(0,testslaverace.size())], testslaveage, testslavegender, testslaveorigin[rand_range(0,testslaveorigin.size())])
		globals.slaves = person
		x -= 1
		array.append(person)
	for i in array:
		i.level = 25
		i.mods['augmentscales'] = 'augmentscales'
		i.add_effect(globals.effectdict.augmentscales)
		i.mods['augmentstr'] = 'augmentstr'
		i.add_effect(globals.effectdict.augmentstr)
		i.mods['augmentagi'] = 'augmentagi'
		i.add_effect(globals.effectdict.augmentagi)
		i.mods['augmenthearing'] = 'augmenthearing'
		for k in ['str','agi','maf','end']:
			i.stats[k + '_base'] = i.stats[k+"_max"]
		if i != globals.player:
			globals.state.playergroup.append(i.id)
		for k in ['armorrogue','weaponelvensword','accamuletemerald']:
			var tmpitem = globals.items.createunstackable(k)
			globals.state.unstackables[str(tmpitem.id)] = tmpitem
			globals.items.enchantrand(tmpitem)
			globals.items.equipitem(tmpitem.id, i)
		i.health = i.stats.health_max
		i.energy = i.stats.energy_max
		for k in globals.abilities.abilitydict.values():
			if i.ability.has(k.code) || k.learnable == false:
				continue
			i.ability.append(k.code)


func mansion():
	_on_mansion_pressed()

func jail():
	_on_jailbutton_pressed()

func libraryopen():
	_on_library_pressed()

func alchemy():
	_on_alchemy_pressed()

func laboratory():
	get_node("MainScreen/mansion/labpanel")._on_lab_pressed()

func farm():
	_on_farm_pressed()

func portals():
	_on_portals_pressed()

func leave():
	get_node("outside")._on_leave_pressed()

func _on_combatgroup_pressed():
	get_node("groupselectnode").show()



func getridof():
	var person = globals.slaves[get_tree().get_current_scene().currentslave]
	person.removefrommansion()
	if get_node("dialogue").is_visible_in_tree() && $MainScreen/slave_tab.is_visible_in_tree():
		close_dialogue()
	rebuild_slave_list()
	if get_node("MainScreen").visible:
		_on_nobutton_pressed()
		_on_mansion_pressed()

var showprisoners = false
var listinstance = load("res://files/listline.tscn")

func rebuild_slave_list():
	var node
	var size = 0
	var person
	var clear = find_node('slave_list').get_children()
	var personlist = get_node("charlistcontrol/CharList/scroll_list/slave_list")
	var prison = 0
	var prisonlabel = get_node("charlistcontrol/CharList/scroll_list/slave_list/prisonlabel")
	for i in clear:
		if i != prisonlabel:
			i.queue_free()
			i.hide()
	while globals.slaves.size() > size:
		person = globals.slaves[size]
		if person.sleep != 'jail' && person.sleep != 'farm' && person.away.duration == 0:
			node = listinstance.instance()
			node.set_meta('id', person.id)
			node.set_meta('pos', size)
			personlist.add_child(node)
			var text = person.name_long()
			if person.xp >= 100:
				text = text + "(+)"
			node.find_node('name').set_text(text)
			node.find_node('name').connect("mouse_entered", globals, 'slavetooltip', [person])
			node.find_node('name').connect("mouse_exited", globals, 'slavetooltiphide')
			node.get_node('slavename/name').connect('pressed', self, 'openslavetab', [person])
			node.find_node('health').set_normal_texture(person.health_icon())
			node.find_node('healthvalue').set_text(str(round(person.health)))
			node.find_node('obedience').set_normal_texture(person.obed_icon())
			node.find_node('stress').set_normal_texture(person.stress_icon())
			if person.imageportait != null:
				node.find_node('portait').show()
				node.find_node('portait').set_texture(globals.loadimage(person.imageportait))
#			else:
#				node.find_node('portait').hide()
		elif person.sleep == 'jail':
			prison += 1
		size += 1
	if prison >= 1:
		prisonlabel.show()
		personlist.move_child(prisonlabel, get_node("charlistcontrol/CharList/scroll_list/slave_list").get_children().size()-1)
	else:
		prisonlabel.hide()
	
	if showprisoners == false && prison >= 1:
		var label = Label.new()
		label.set_text("Your jail holds "+str(prison)+ " prisoner(s). ")
		personlist.add_child(label)
	else:
		size = 0
		for i in globals.slaves:
			person = i
			if person.sleep == 'jail' && person.away.duration == 0:
				node = load("res://files/listline.tscn").instance()
				node.set_meta('id', person.id)
				node.set_meta('pos', size)
				personlist.add_child(node)
				node.find_node('name').set_text(person.name_long())
				node.find_node('name').connect("mouse_entered", globals, 'slavetooltip', [person])
				node.find_node('name').connect("mouse_exited", globals, 'slavetooltiphide')
				node.get_node('slavename/name').connect('pressed', self, 'openslavetab', [person])
				node.find_node('health').set_normal_texture(person.health_icon())
				node.find_node('healthvalue').set_text(str(round(person.health)))
				node.find_node('obedience').set_normal_texture(person.obed_icon())
				node.find_node('stress').set_normal_texture(person.stress_icon())
				if person.imageportait != null:
					node.find_node('portait').show()
					node.find_node('portait').set_texture(globals.loadimage(person.imageportait))
				else:
					node.find_node('portait').hide()
			size += 1
	for person in globals.slaves:
		if person.sleep == 'farm':
			var label = Label.new()
			label.set_text(person.name_long() + ' is assigned to your farm.')
			get_node("charlistcontrol/CharList/scroll_list/slave_list").add_child(label)
	
	
	
	for i in globals.slaves:
		person = i
		if person.away.duration != 0 && person.away.at != 'hidden':
			var label = Label.new()
			label.set('font', load('res://mainfont.tres'))
			label.set_autowrap(true)
			if person.away.at == 'in labor':
				label.set_text(person.name_long() + ' will be resting after labor for '+ str(person.away.duration))
			elif person.away.at == 'training':
				label.set_text(person.name_long() + ' will be undergoing training for '+ str(person.away.duration))
			elif person.away.at == 'nurture':
				label.set_text(person.name_long() + ' will be undergoing nurturing for '+ str(person.away.duration))
			elif person.away.at == 'growing':
				label.set_text(person.name_long() + ' will keep maturing for '+ str(person.away.duration))
			elif person.away.at == 'lab':
				label.set_text(person.name_long() + ' will be undergoing modification for '+ str(person.away.duration))
			elif person.away.at == 'rest':
				label.set_text(person.name_long() + ' will be taking a rest for '+ str(person.away.duration))
			else:
				label.set_text(person.name_long() + ' will be unavailable for '+ str(person.away.duration))
			if person.away.duration == 1:
				label.set_text(label.get_text() + ' day.')
			else:
				label.set_text(label.get_text() + ' days.')
			get_node("charlistcontrol/CharList/scroll_list/slave_list").add_child(label)
	
	get_node("charlistcontrol/CharList/res_number").set_bbcode('[center]Residents: ' + str(globals.slaves.size())+'[/center]')
	get_node("ResourcePanel/population").set_text(str(globals.slavecount()))
	_on_orderbutton_pressed()

func openslavetab(person):
	currentslave = globals.slaves.find(person)
	get_tree().get_current_scene().hide_everything()
	$MainScreen/slave_tab.slavetabopen()

func _on_prisonbutton_pressed():
	showprisoners = !showprisoners
	rebuild_slave_list()

func _on_end_pressed():
	if globals.state.mainquest == 41:
		popup("You can't afford to wait. You must go to the Mage's Order.")
		return
	enddayprocess = true
	
	
	var text = ''
	var temp = ''
	var poorcondition = false
	var person
	var count
	var chef
	var jailer
	var headgirl
	var labassist
	var farmmanager
	var workdict
	var text0 = get_node("FinishDayPanel/FinishDayScreen/Global Report")
	var text1 = get_node("FinishDayPanel/FinishDayScreen/Job Report")
	var text2 = get_node("FinishDayPanel/FinishDayScreen/Secondary Report")
	var start_gold = globals.resources.gold
	var start_food = globals.resources.food
	var start_mana = globals.resources.mana
	var deads_array = []
	var gold_consumption = 0
	var lacksupply = false
	var results = 'normal'
	_on_mansion_pressed()
	#if OS.get_name() != 'HTML5':
	yield(self, 'animfinished')
	for i in range(globals.slaves.size()):
		if globals.slaves[i].away.duration == 0:
			if globals.slaves[i].work == 'cooking':
				chef = globals.slaves[i]
			elif globals.slaves[i].work == 'jailer':
				jailer = globals.slaves[i]
			elif globals.slaves[i].work == 'headgirl':
				headgirl = globals.slaves[i]
			elif globals.slaves[i].work == 'labassist':
				labassist = globals.slaves[i]
			elif globals.slaves[i].work == 'farmmanager':
				farmmanager = globals.slaves[i]
	
	globals.resources.day += 1
	text0.set_bbcode('')
	text1.set_bbcode('')
	text2.set_bbcode('')
	count = 0
	
	if globals.player.preg.duration >= 1:
		globals.player.preg.duration += 1
		if globals.player.preg.duration == floor(variables.pregduration/6):
			text0.set_bbcode(text0.get_bbcode() + "[color=yellow]You feel morning sickness. It seems you are pregnant. [/color]\n")
	
	for person in globals.slaves:
		if person.away.duration == 0:
			if person.bodyshape == 'shortstack':
				globals.state.condition = -0.65
			elif person.race in ['Lamia','Arachna','Centaur', 'Harpy', 'Scylla']:
				globals.state.condition = -1.8
			elif person.race.find('Beastkin') >= 0:
				globals.state.condition = -1.3
			else:
				globals.state.condition = -1.0
	
	for person in globals.slaves:
		person.metrics.ownership += 1
		var handcuffs = false
		for i in person.gear.values():
			if i != null && globals.state.unstackables.has(i):
				var tempitem = globals.state.unstackables[i]
				if tempitem.code in ['acchandcuffs']:
					handcuffs = true
		text = ''
		
		var jobRestore = person.work
		var slavehealing = person.send * 0.03 + 0.02
		if person.away.duration == 0: ## Sequence for all present slaves
			
			for i in person.relations:
				if person.relations[i] > 500:
					person.relations[i] -= 15
				elif person.relations[i] < -500:
					person.relations[i] += 15
			
			if person.sleep != 'jail' && person.sleep != 'farm':
				if person.work in corejobs:
					
					if person.work != 'rest' && person.energy < 30:
						person.work = 'rest'

					for i in globals.slaves:
						if i.away.duration == 0 && i.work == person.work && i != person:
							globals.addrelations(person, i, 0)
							if randf() < 0.25 + abs(person.relations[i.id])/2000:
								var badchance = 0
								if person.relations[i.id] > 600:
									badchance = 15
								elif person.relations[i.id] > 0:
									badchance = 33
								elif person.relations[i.id] > -200:
									badchance = 55
								elif person.relations[i.id] > -500:
									badchance = 70
								else:
									badchance = 80
								if randf() * 100 < badchance:
									globals.addrelations(person, i, -rand_range(25,50))
									text2.bbcode_text += person.dictionary("[color=yellow]$name has gotten into a minor quarrel with ") + i.dictionary('$name.[/color]\n')
								else:
									globals.addrelations(person, i, rand_range(25,50))
									var temptext = ''
									if person.work == 'rest':
										temptext = person.dictionary("[color=yellow]$name has been resting together with ") + i.dictionary('$name and their relationship improved.[/color]\n')
									else:
										temptext = person.dictionary("[color=yellow]$name has been working together with ") + i.dictionary('$name and their relationship improved.[/color]\n')
									text2.bbcode_text += temptext
								#Calculate relations
								
#							if person.relations[i.id] < 0 || i.relations[person.id] < -200:
#								globals.addrelations(person, i, (rand_range(-10,-20)))
#							else:
#								globals.addrelations(person, i, (rand_range(10,20)))
					
					if person.work == 'rest':
						if jobRestore != 'rest':
							text = "$name had no energy to fulfill $his duty and had to take a rest. \n"
						else:
							text = '$name has spent most of the day relaxing.\n'
						slavehealing += 0.15
						person.stress -= 20
					else:
						workdict = globals.jobs.call(person.work, person)
						if workdict.has('dead') && workdict.dead == true:
							deads_array.append({number = count, reason = workdict.text})
							continue
						if person.traits.has("Clumsy") && get_node("MainScreen/slave_tab").jobdict[person.work].tags.has("physical"):
							if workdict.has('gold') && workdict.gold > 0:
								workdict.gold *= 0.7
							if workdict.has('food'):
								workdict.food *= 0.7
						if person.traits.has("Hard Worker") && !get_node("MainScreen/slave_tab").jobdict[person.work].tags.has("sex"):
							if workdict.has('gold') && workdict.gold > 0:
								workdict.gold *= 1.15
						for i in globals.state.reputation:
							if get_node("MainScreen/slave_tab").jobdict[person.work].tags.find(i) >= 0:
								if globals.state.reputation[i] < -10 && randf() < 0.33:
									person.obed -= max(abs(globals.state.reputation[i])*2 - person.loyal/6,0)
									person.loyal -= rand_range(1,3)
									text += "[color=#ff4949]$name has been influenced by local townfolk, which is hostile towards you. [/color]\n"
								elif globals.state.reputation[i] > 10 && randf() < 0.2:
									person.obed += abs(globals.state.reputation[i])
									person.loyal += rand_range(1,3)
									text += "[color=green]$name has been influenced by local townfolk, which is loyal towards you. [/color]\n"
						text += workdict.text
						if person.spec == 'housekeeper' && person.work in ['rest','cooking','library','nurse','maid','headgirl','farmmanager','labassist','jailer']:
							globals.state.condition += (5.5 + (person.sagi+person.send)*6)/2
							text2.bbcode_text += person.dictionary("$name has managed to clean the mansion a bit while being around. \n")
						if workdict.has("gold"):
							globals.resources.gold += workdict.gold
							if workdict.gold > 0:
								person.metrics.goldearn += workdict.gold
						if workdict.has("food"):
							globals.resources.food += workdict.food
							person.metrics.foodearn += workdict.food
			text1.set_bbcode(text1.get_bbcode()+person.dictionary(text))
			######## Counting food
			for i in person.effects.values():
				if i.has('duration') && i.code != 'captured':
					if person.race != 'Dark Elf' || randf() > 0.5:
						i.duration -= 1
					if i.duration <= 0:
						person.add_effect(i, true)
				elif i.code == 'captured':
					i.duration -= 1
					if person.sleep == 'jail' && globals.state.mansionupgrades.jailincenses == 1 && randf() >= 0.5:
						i.duration -= 1
					if person.brand != 'none':
						i.duration -= 1
					if i.duration <= 0:
						if i.code == 'captured':
							text0.set_bbcode(text0.get_bbcode() + person.dictionary('$name grew accustomed to your ownership.\n'))
						person.add_effect(i, true)
				if i.has("ondayend"):
					globals.effects.call(i.ondayend, person)
			var consumption = variables.basefoodconsumption
			if chef != null:
				consumption = max(3, consumption - (chef.sagi + (chef.wit/20))/2)
				if chef.race == 'Scylla':
					consumption = max(3, consumption - 1)
			if person.traits.has("Small Eater"):
				consumption = consumption/3
			if globals.resources.food >= consumption:
				person.loyal += rand_range(0,1)
				person.obed += person.loyal/5 - (person.cour+person.conf)/10
				globals.resources.food -= consumption
			else:
				person.stress += 20
				person.health -= rand_range(person.stats.health_max/6,person.stats.health_max/4)
				person.obed -= max(35 - person.loyal/3,10)
				if person.health < 1:
					text = person.dictionary('[color=#ff4949]$name has died of starvation.[/color]\n')
					deads_array.append({number = count, reason = text})
			if person.obed < 25 && person.cour >= 50 && person.rules.silence == false && person.traits.find('Mute') < 0 && person.sleep != 'jail' && person.sleep != 'farm' && person.brand != 'advanced'&& rand_range(0,1) > 0.5:
				text0.set_bbcode(text0.get_bbcode()+person.dictionary('$name dares to openly show $his disrespect towards you and instigates other servants. \n'))
				for ii in globals.slaves:
					if ii != person && ii.loyal < 30 && ii.traits.find('Loner') < 0:
						ii.obed += -(person.charm/3)
			if person.obed < 50 && person.loyal < 25 && person.sleep != 'jail'&& person.sleep != 'farm'&& person.brand != 'advanced':
				if randf() < 0.3 && globals.resources.food > 34:
					text0.set_bbcode(text0.get_bbcode()+person.dictionary('You notice that some of your food is gone.\n'))
					globals.resources.food -= rand_range(35,70)
				elif randf() < 0.3 && globals.resources.gold > 19:
					text0.set_bbcode(text0.get_bbcode()+person.dictionary('You notice that some of your gold is missing.\n'))
					globals.resources.gold -= rand_range(20,40)
			if person.obed < 25 && person.sleep != 'jail' && person.sleep != 'farm' && person.tags.has('noescape') == false:
				var escape = 0
				var stay = 0
				if person.brand == 'none':
					escape = person.cour/3+person.wit/3+person.stress/2
					stay = person.loyal*2+person.obed
				else:
					escape = person.cour/4+person.stress/4
					stay = person.loyal*2+person.obed+person.wit/5
				
				if globals.state.mansionupgrades.mansionkennels == 1:
					escape *= 0.8
				if escape > stay:
					if handcuffs == false:
						var temptext = person.dictionary('[color=#ff4949]$name has escaped during the night![/color]\n')
						deads_array.append({number = count, reason = temptext})
					else:
						text0.set_bbcode(text0.get_bbcode()+person.dictionary('[color=#ff4949]$name attempted to escape during the night but being handcuffed slowed them down and they were quickly discovered![/color]\n'))
			#Races
			if person.race == 'Orc':
				slavehealing += 0.15
			elif person.race == 'Slime':
				person.toxicity = 0
			#Traits
			if person.traits.has("Uncivilized"):
				for i in globals.slaves:
					if i.spec == 'tamer' && (i.work == person.work || i.work in ['rest','headgirl','jailer']) && i.away.duration == 0 && i.obed > 60:
						person.obed += 30
						person.loyal += 5
						if randf() < 0.1:
							person.trait_remove("Uncivilized")
							text0.set_bbcode(text0.get_bbcode() + i.dictionary("[color=green]$name managed to lift ") + person.dictionary("$name out of $his wild behavior and turn into a socially functioning person.[/color]\n "))
			if person.traits.has("Infirm"):
				slavehealing = slavehealing/3
			if person.attention < 150 && person.sleep != 'your':
				person.attention += rand_range(5,7)
			if person.traits.has("Clingy") && person.loyal >= 15 && person.attention > 40 && randf() > 0.5:
				person.obed -= rand_range(10,30)
				person.loyal -= rand_range(1,5)
				text0.set_bbcode(text0.get_bbcode() + person.dictionary("[color=yellow]$name is annoyed by you paying no attention to $him. [/color]\n"))
			if person.traits.has('Pliable'):
				if person.loyal >= 60:
					person.trait_remove('Pliable')
					person.add_trait('Devoted')
					text0.set_bbcode(text0.get_bbcode() + person.dictionary('[color=green]$name has become Devoted. $His willpower strengthened.[/color]\n'))
				elif person.lewdness >= 60:
					person.trait_remove('Pliable')
					person.add_trait('Slutty')
					text0.set_bbcode(text0.get_bbcode() + person.dictionary('[color=green]$name has become Slutty. $His willpower strengthened.[/color]\n'))
			if person.traits.has("Scoundrel"):
				globals.resources.gold += 15
				text1.set_bbcode(text1.get_bbcode() + person.dictionary('[color=green]$name has brought some additional gold by the end of day.[/color]\n'))
			if person.traits.has("Authority") && person.obed >= 95:
				for i in globals.slaves:
					if i.away.duration == 0 && i != person:
						i.obed += 5
			if person.traits.has("Mentor"):
				for i in globals.slaves:
					if i.away.duration == 0 && i != person && i.level < 3:
						i.xp += 5
			if person.traits.has("Experimenter") && randf() >= 0.8:
				var array = []
				for i in globals.itemdict.values():
					if i.type == 'potion':
						array.append(i.code)
				array = globals.itemdict[array[randi()%array.size()]]
				array.amount += 1
				text0.bbcode_text += person.dictionary("$name has produced [color=aqua]1 " + array.name + '[/color]\n')
			#Rules and clothes effect
			if person.rules.contraception == true:
				if !person.effects.has("contraceptive"):
					if globals.resources.gold >= 5:
						globals.resources.gold -= 5
						person.add_effect(globals.effectdict.contraceptive)
						gold_consumption += 5
					else:
						text0.set_bbcode(text0.get_bbcode()+person.dictionary("[color=#ff4949]You could't afford to provide $name with contraceptives.[/color]\n"))
			if person.rules.aphrodisiac == true:
				var value
				if person.spec != 'housekeeper':
					value = 8
				else:
					value = 4
				if globals.resources.gold >= value:
					globals.resources.gold -= value
					person.lust += rand_range(10,15)
					gold_consumption += value
				else:
					text0.set_bbcode(text0.get_bbcode()+person.dictionary("[color=#ff4949]You could't supply $name's food with aphrodisiac.[/color]\n"))
			if person.rules.silence == true:
				if person.cour > 40:
					person.cour += -rand_range(3,5)
				person.obed += rand_range(5,10)
			if person.rules.pet == true:
				if person.conf > 25:
					person.conf -= rand_range(5,10)
				if person.charm > 25:
					person.charm -= rand_range(4,8)
				person.obed += rand_range(8,15)
			if person.rules.nudity == true:
				person.lust += rand_range(5,10)
				if person.lewdness < 40 && !person.traits.has("Pervert") && !person.traits.has("Sex-crazed"):
					person.stress += rand_range(5,10)
			for i in person.gear.values():
				if i != null && globals.state.unstackables.has(i):
					var tempitem = globals.state.unstackables[i]
					globals.items.person = person
					for k in tempitem.effects:
						if k.type == 'onendday':
							if k.has('effectvalue'):
								text2.bbcode_text += person.dictionary(globals.items.call(k.effect, k.effectvalue))
							else:
								text2.set_bbcode(text2.get_bbcode() + person.dictionary(globals.items.call(k.effect, person)))
			if person.fear > 0:
				var fearreduction = 10 + person.conf/20
				if person.brand != 'none':
					fearreduction /= 2
				if person.sleep == 'jail':
					fearreduction -= fearreduction*0.3
				if person.fear - fearreduction > 0:
					person.obed += 20
					person.fear -= fearreduction
				else:
					person.obed += 20 - abs(person.fear - fearreduction)*1.5
					text2.bbcode_text += person.dictionary("[color=yellow]$name seems no longer to be afraid of you.[/color]\n")
					person.fear = 0
			if person.toxicity > 0:
				if person.toxicity > 35 && randf() > 0.65:
					person.stress += rand_range(10,15)
					person.health -= rand_range(10,15)
					text2.set_bbcode(text2.get_bbcode() + person.dictionary("$name suffers from magical toxicity.\n"))
				if person.toxicity > 60 && randf() > 0.75:
					globals.spells.person = person
					text0.set_bbcode(text0.get_bbcode()+globals.spells.mutate(person.toxicity/30, true) + "\n\n")
				person.toxicity -= rand_range(1,5)
			
			
			if person.stress >= 33 && randf() <= 0.3:
				if randf() >= 0.5:
					person.obed -= (person.stress - 33)/2
				else:
					person.energy -= rand_range(15,30)
				#text0.bbcode_text += person.dictionary("[color=#ff4949]$name suffers from stress [/color]")
			
			if person.stress >= 66 && randf() <= 0.3:
				if randf() >= 0.5:
					person.loyal -= rand_range(5,10)
				else:
					person.health -= person.stats.health_max/7
			
			if person.stress >= 99:
				person.mentalbreakdown()
			
			
			if person.race == 'Fairy':
				person.stress -= rand_range(10,20)
			else:
				person.stress -= rand_range(5,10)
			
			#sleep conditions
			if person.lust < 25 || person.traits.has('Sex-crazed'):
				person.lust += round(rand_range(3,6))
			if person.sleep == 'communal' && globals.count_sleepers()['communal'] > globals.state.mansionupgrades.mansioncommunal:
				person.stress += rand_range(5,15)
				slavehealing -= 0.1
				text2.set_bbcode(text2.get_bbcode() + person.dictionary('$name suffers from communal room being overcrowded.\n'))
			elif person.sleep == 'communal':
				person.stress -= rand_range(5,10)
				person.energy += rand_range(20,30)+ person.send*6
			elif person.sleep == 'personal':
				person.stress -= rand_range(10,15)
				slavehealing += 0.1
				person.energy += rand_range(40,50)+ person.send*6
				text2.set_bbcode(text2.get_bbcode() + person.dictionary('$name sleeps in a private room, which helps $him heal faster and provides some stress relief.\n'))
				if person.lust >= 50 && person.rules.masturbation == false && person.tags.find('nosex') < 0:
					person.lust -= rand_range(30,40)
					person.lastsexday = globals.resources.day
					text2.set_bbcode(text2.get_bbcode() + person.dictionary('In an attempt to calm $his lust, $he spent some time busying $himself in feverish masturbation, making use of $his private room.\n'))
			elif person.sleep == 'your':
				person.loyal += rand_range(1,4)
				person.energy += rand_range(25,45)+ person.send*6
				for i in globals.slaves:
					if i.sleep == 'your' && i != person:
						globals.addrelations(person, i, 0)
						if (person.relations[i.id] <= 200 && !person.traits.has("Fickle")) || person.traits.has("Monogamous"):
							globals.addrelations(person, i, -rand_range(50,100))
						else:
							globals.addrelations(person, i, rand_range(15,30))
				if person.loyal > 30:
					person.stress -= person.loyal/7
				if person.lust > 40 && person.consent && person.vagvirgin == false && person.tags.find('nosex') < 0:
					text2.set_bbcode(text2.get_bbcode() + person.dictionary('$name went down on you being unable to calm $his lust.\n'))
					person.lust -= rand_range(15,25)
					person.metrics.sex += 1
					person.lastsexday = globals.resources.day
					globals.resources.mana += 2
					globals.impregnation(person, globals.player)
				else:
					text2.set_bbcode(text2.get_bbcode() + person.dictionary('$name keeps you company at night and you grew closer.\n'))
			elif person.sleep == 'jail':
				person.metrics.jail += 1
				person.obed += 25 - person.conf/6
				person.energy += rand_range(20,30) + person.send*6
				if person.stress > 66:
					person.stress -= rand_range(5,10)
				else:
					if globals.state.mansionupgrades.jailtreatment == 0:
						person.stress += person.conf/10
			if person.lust >= 90 && person.rules.masturbation == true && !person.traits.has('Sex-crazed') && (rand_range(0,10)>7 || person.effects.has('stimulated')) && globals.resources.day - person.lastsexday >= 5:
				person.add_trait('Sex-crazed')
				text0.set_bbcode(text0.get_bbcode() + person.dictionary("[color=yellow]Left greatly excited and prohibited from masturbating, $name desperate state led $him to become insanely obsessed with sex.[/color]\n"))
			elif person.lust >= 75 && globals.resources.day - person.lastsexday >= 5:
				person.stress += rand_range(10,15)
				person.obed -= rand_range(10,20)
				text0.bbcode_text += person.dictionary("[color=red]$name is suffering from unquenched lust.[/color]\n")
			
			person.health += slavehealing * person.stats.health_max
			
			if person.skillpoints < 0:
				person.skillpoints = 0
			if person.preg.duration > 0:
				person.preg.duration += 1
				if person.health < 20 && rand_range(0,100) > person.health*2:
					text0.set_bbcode(text0.get_bbcode()+person.dictionary('[color=#ff4949]Due to poor health condition, $name had a miscarriage and lost $his child.[/color]\n'))
					person.preg.baby = null
					person.preg.duration = 0
					person.stress += rand_range(35,50)
				if person.race == 'Goblin':
					if person.preg.duration > variables.pregduration/6:
						person.lactation = true
						if headgirl != null:
							if person.preg.duration == floor(variables.pregduration/5):
								text0.set_bbcode(text0.get_bbcode() + headgirl.dictionary('[color=yellow]$name reports, that ') + person.dictionary('$name appears to be pregnant. [/color]\n'))
							elif person.preg.duration == floor(variables.pregduration/2.7):
								text0.set_bbcode(text0.get_bbcode() + headgirl.dictionary('[color=yellow]$name reports, that ') + person.dictionary('$name will likely give birth soon. [/color]\n'))
				else:
					if person.preg.duration > variables.pregduration/3:
						person.lactation = true
						if headgirl != null:
							if person.preg.duration == floor(variables.pregduration/2.5):
								text0.set_bbcode(text0.get_bbcode() + headgirl.dictionary('[color=yellow]$name reports, that ') + person.dictionary('$name appears to be pregnant. [/color]\n'))
							elif person.preg.duration == floor(variables.pregduration/1.3):
								text0.set_bbcode(text0.get_bbcode() + headgirl.dictionary('[color=yellow]$name reports, that ') + person.dictionary('$name will likely give birth soon. [/color]\n'))
				if randf() < 0.4:
					person.stress += rand_range(15,20)
			if person.away.duration == 0 && !person.sleep in ['jail','farm']:
				var personluxury = person.calculateluxury()
				var luxurycheck = person.countluxury()
				var luxury = luxurycheck.luxury
				gold_consumption += luxurycheck.goldspent
				if luxurycheck.nosupply == true:
					lacksupply = true
				if !person.traits.has("Grateful") && luxury < personluxury && person.metrics.ownership - person.metrics.jail > 7:
					person.loyal -= (personluxury - luxury)/2.5
					person.obed -= (personluxury - luxury)
					text0.set_bbcode(text0.get_bbcode() + person.dictionary("[color=#ff4949]$name appears to be rather unhappy about quality of $his life and demands better living conditions from you. [/color]\n"))
		elif person.away.duration > 0:
			person.away.duration -= 1
			if person.away.duration == 0 && person.away.at == 'lab' && person.health < 5:
				var temptext = "$name has not survived the laboratory operation due to poor health."
				deads_array.append({number = count, reason = temptext})
			else:
				if person.away.duration == 0:
					person.away.at = ''
					text0.set_bbcode(text0.get_bbcode() + person.dictionary("$name returned to the mansion and went back to $his duty. \n"))
				for i in person.effects.values():
					if i.has('duration') && i.code != 'captured':
						if person.race != 'Dark Elf' || randf() > 0.5:
							i.duration -= 1
						if i.duration <= 0:
							person.add_effect(i, true)
					elif i.code == 'captured':
						if i.duration <= 0:
							if i.code == 'captured':
								text0.set_bbcode(text0.get_bbcode() + person.dictionary('$name grew accustomed to your ownership.\n'))
							person.add_effect(i, true)
					if i.has("ondayend"):
						globals.effects.call(i.ondayend, person)
		person.work = jobRestore
		count+=1
	if headgirl != null && globals.state.headgirlbehavior != 'none':
		var headgirlconf = headgirl.conf
		if headgirl.spec == 'executor':
			headgirlconf = max(100, headgirl.conf)
		for i in globals.slaves:
			if i != headgirl && i.traits.find('Loner') < 0 && i.away.duration < 1 && i.sleep != 'jail' && i.sleep != 'farm':
				headgirl.xp += 3
				globals.addrelations(i, headgirl, 15)
				if i.obed < 65 && globals.state.headgirlbehavior == 'strict':
					var obedbase = i.obed
					i.fear += max(0,(-(i.cour/15) + headgirlconf/7))
					if rand_range(0,100) < headgirlconf - i.conf / 4:
						i.obed += rand_range(3,5) + headgirlconf/15
					i.stress += rand_range(5,10)
					if i.obed <= obedbase:
						globals.addrelations(i, headgirl, -40)
						text0.set_bbcode(text0.get_bbcode() + i.dictionary('$name was acting frivolously. ') + headgirl.dictionary('$name tried to put ') + i.dictionary("$him in place, but failed to make any impact.\n\n"))
					else:
						text0.set_bbcode(text0.get_bbcode() + i.dictionary('$name was acting frivolously, but ') + headgirl.dictionary('$name managed to make ') + i.dictionary("$him submit to your authority and slightly improve $his behavior.\n\n"))
				elif globals.state.headgirlbehavior == 'kind':
					if rand_range(0,100) < headgirl.charm:
						i.obed += rand_range(3,5) + headgirl.charm/15
					i.stress -= (headgirl.charm/6)
	if jailer != null:
		var jailerconf = jailer.conf
		if jailer.spec == 'executor':
			jailerconf = max(100, jailer.conf)
		for person in globals.slaves:
			if person.sleep == 'jail':
				jailer.xp += 5
				if person.obed < 80:
					globals.addrelations(person, jailer, 25)
				person.health += round(jailer.wit/10)
				person.obed += round(jailer.charm/8)
				if person.effects.has('captured') == true && jailerconf-30 >= rand_range(0,100):
					person.effects.captured.duration -= 1
	if farmmanager != null:
		var farmconf = farmmanager.conf
		if farmmanager.spec == 'executor':
			farmconf = max(100, farmmanager.conf)
		for person in globals.slaves:
			if person.sleep == 'farm':
				var production = 0
				if person.obed < 75:
					globals.addrelations(person, farmmanager, rand_range(-25,-40))
				else:
					globals.addrelations(person, farmmanager, rand_range(25,40))
				if person.work == 'cow' && person.titssize != 'masculine':
					production = rand_range(0,15) + 18*globals.sizearray.find(person.titssize)
					if person.titsextradeveloped == true:
						production = production + production * (0.33 * person.titsextra)
					if person.race == 'Taurus':
						production = production*1.2
				elif person.work == 'hen':
					production = rand_range(50,100)
					if person.vagina != 'none':
						production = production + 50
					if person.race == 'Harpy':
						production = production*1.2
				production = production * (0.4 + farmmanager.wit * 0.004 + farmconf * 0.002)
				if globals.state.mansionupgrades.farmtreatment == 0:
					person.stress += 30 - (0.25*farmmanager.charm)
				if person.farmoutcome == false:
					globals.resources.food += production
					person.metrics.foodearn += round(production)
					text1.set_bbcode(text1.get_bbcode()+person.dictionary('$name produced ') + str(round(production))+ ' units worth of food.\n')
				else:
					globals.resources.gold += round(production/2)
					person.metrics.goldearn += round(production/2)
					text1.set_bbcode(text1.get_bbcode()+person.dictionary('$name produced valuables worth of ') + str(round(production/2))+ ' gold.\n')
				if globals.state.mansionupgrades.farmmana > 0 && randf() <= 0.33:
					globals.resources.mana += round(rand_range(1,3))
					text1.bbcode_text += person.dictionary("A small amount of mana has been gathered from $name.\n")
	#####          Dirtiness
	if globals.state.condition <= 40:
		for person in globals.slaves:
			if person.away.duration != 0:
				continue
			if globals.state.condition >= 30 && randf() >= 0.7:
				person.stress += rand_range(5,15)
				person.obed += -rand_range(15,20)
				text0.set_bbcode(text0.get_bbcode() + person.dictionary("[color=yellow]$name was distressed by mansion's poor condition. [/color]\n"))
			elif globals.state.condition >= 15 && randf() >= 0.5:
				person.stress += rand_range(10,20)
				person.obed += -rand_range(15,35)
				text0.set_bbcode(text0.get_bbcode() + person.dictionary("[color=yellow]$name was distressed by mansion's poor condition. [/color]\n"))

			elif globals.state.condition < 15 && randf() >= 0.4:
				person.stress += rand_range(15,25)
				person.health -= rand_range(5,10)
				text0.set_bbcode(text0.get_bbcode() + person.dictionary("[color=#ff4949]Mansion's terrible condition causes $name a lot of stress and impacted $his health. [/color]\n"))
	#####          Outside Events
	
	
	for i in globals.guildslaves:
		for person in globals.guildslaves[i]:
			count = 0
			if randf() < 0.2:
				globals.guildslaves[i].remove(count)
			count += 1
		if globals.guildslaves[i].size() < 4:
			get_node("outside").newslaveinguild(1, i)
		if globals.guildslaves[i].size() < 6 && randf() > 0.25:
			get_node("outside").newslaveinguild(1, i)
	
	
	if globals.state.sebastianorder.duration > 0:
		globals.state.sebastianorder.duration -= 1
		if globals.state.sebastianorder.duration == 0:
			text0.set_bbcode(text0.get_bbcode() + "[color=green]Sebastian should have your order ready by this time. [/color]\n")
	globals.state.groupsex = true
	
	var consumption = variables.basefoodconsumption
	if chef != null:
		consumption = max(3, consumption - (chef.sagi + (chef.wit/20))/2)
		if chef.race == 'Scylla':
			consumption = max(3, consumption - 1)
	if globals.resources.food >= consumption:
		globals.resources.food -= consumption
	else:
		if globals.resources.gold < 20:
			get_node("gameover").show()
			get_node("gameover/Panel/text").set_bbcode("[center]With no food and money your mansion falls in chaos. \nGame over.[/center]")
		else:
			globals.resources.gold -= 20
			text0.set_bbcode(text0.get_bbcode()+ "[color=#ff4949]You have no food in the mansion and left dining at town, paying 20 gold in process.[/color]\n")
	
	for i in globals.state.repeatables:
		for ii in globals.state.repeatables[i]:
			var removed = false
			if ii.time >= 0 && ii.taken == true:
				ii.time -= 1
			elif randf() < 0.1 && ii.taken == false:
				removed = true
				globals.state.repeatables[i].remove(globals.state.repeatables[i].find(ii))
			if ii.time < 0:
				removed = true
				text0.set_bbcode(text0.get_bbcode() + '[color=#ff4949]You have failed to complete your quest at ' + ii.location.capitalize() +'.[/color]\n')
				globals.state.repeatables[i].remove(globals.state.repeatables[i].find(ii))
	
	if int(globals.resources.day)%5 == 0.0:
		rebuildrepeatablequests()
	
	if globals.player.xp >= 100:
		globals.player.xp -= 100
		globals.player.value += 1
		globals.player.skillpoints += 1
		text0.set_bbcode(text0.get_bbcode() + '[color=green]You have leveled up and earned an additional skillpoint. [/color]\n')
	globals.player.health += 50
	globals.player.energy += 100
	
	for i in globals.player.effects.values():
		if i.has("ondayend") && i.code.find("animalistic") >= 0:
			globals.effects.call(i.ondayend, globals.player)
		if i.has('duration') && i.code != "contraceptive":
			i.duration -= 1
			if i.duration <= 0:
				globals.player.add_effect(i, true)
	
	if globals.state.mansionupgrades.foodpreservation == 0 && globals.resources.food >= globals.resources.foodcaparray[globals.state.mansionupgrades.foodcapacity]*0.80:
		globals.resources.food -= globals.resources.food*0.03
		text0.set_bbcode(text0.get_bbcode() + '[color=yellow]Some of your food reserves have spoiled.[/color]\n')
	
	#####         Results
	if start_gold < globals.resources.gold:
		results = 'good'
		text = 'Your residents earned [color=yellow]' + str(globals.resources.gold - start_gold) + '[/color] gold by the end of day. \n'
	elif start_gold == globals.resources.gold:
		results = 'med'
		text = "By the end of day your gold reserve didn't change. "
	else:
		results = 'bad'
		text = "By the end of day your gold reserve shrunk by [color=yellow]" + str(start_gold - globals.resources.gold) + "[/color] pieces. "
	if start_food > globals.resources.food:
		text = text + 'Your food storage shrank by [color=aqua]' + str(start_food - globals.resources.food) + '[/color] units of food.\n'
	else:
		text = text + 'Your food storage grew by [color=aqua]' + str(globals.resources.food - start_food) + '[/color] units of food.\n'
	text0.set_bbcode(text0.get_bbcode() + text)
	globals.state.sexactions = ceil(globals.player.send/2.0) + variables.basesexactions
	globals.state.nonsexactions = ceil(globals.player.send/2.0) + variables.basenonsexactions
	if deads_array.size() > 0:
		results = 'worst'
		deads_array.invert()
		for i in deads_array:
			globals.slaves.remove(i.number)
			text0.set_bbcode(text0.get_bbcode() + i.reason + '\n')
	text0.set_bbcode(text0.get_bbcode()+ "[color=yellow]" +str(round(gold_consumption))+'[/color] gold was used for various tasks.\n'  )
	get_node("FinishDayPanel/FinishDayScreen").set_current_tab(0)
	aliseresults = results
	if lacksupply == true:
		text0.set_bbcode(text0.get_bbcode()+"[color=#ff4949]You have expended your supplies and some of the actions couldn't be finished. [/color]\n")
	get_node("Navigation/endlog").disabled = false
	nextdayevents()

var aliseresults

func nextdayevents():
	get_node("FinishDayPanel").hide()
	var player = globals.player
	if player.preg.duration > variables.pregduration && player.preg.baby != null:
		childbirth(player)
		checkforevents = true
		return
	for i in globals.slaves:
		if i.preg.baby != null && (i.preg.duration > variables.pregduration || (i.race == 'Goblin' && i.preg.duration > variables.pregduration/2)):
			if i.race == 'Goblin':
				i.away.duration = 2
			else:
				i.away.duration = 3
			i.away.at = 'in labor'
			childbirth(i)
			checkforevents = true
			return
	
	#QMod - Insert for new event system
#	var place = {region = 'any', area = 'mansion', location = 'foyer'}
#	var placeEffects = globals.events.call_events(place, 'schedule')
#	if placeEffects.hasEvent:
#		checkforevents = true
#		return
#
	#Old scheduled event system
	for i in globals.state.upcomingevents.duplicate():
		if $scene.is_visible_in_tree() == true:
			break
		i.duration -= 1
		if i.duration <= 0:
			var text = globals.events.call(i.code)
			globals.state.upcomingevents.erase(i)
			if text != null:
				get_node("FinishDayPanel/FinishDayScreen/Global Report").set_bbcode(get_node("FinishDayPanel/FinishDayScreen/Global Report").get_bbcode() + text)
			else:
				checkforevents = true
				return
	globals.state.dailyeventcountdown -= 1
	if globals.state.dailyeventcountdown <= 0 && !$scene.is_visible_in_tree() && !$dialogue.is_visible_in_tree():
		var event
		event = launchrandomevent()
		if event != null:
			globals.state.dailyeventcountdown = rand_range(5,10)
			get_node("dailyevents").show()
			get_node("dailyevents").currentevent = event
			get_node("dailyevents").call(event)
			dailyeventhappend = true
			checkforevents = true
			return
	if globals.state.sandbox == false && globals.state.mainquest < 42 && !$scene.is_visible_in_tree() && !$dialogue.is_visible_in_tree():
		
		if globals.state.mainquest >= 16 && !globals.state.plotsceneseen.has('garthorscene') &&!$scene.is_visible_in_tree() && !$dialogue.is_visible_in_tree():
			globals.events.garthorscene()
			globals.state.plotsceneseen.append('garthorscene')
			checkforevents = true
			return
		elif globals.state.mainquest >= 18 && !globals.state.plotsceneseen.has('hade1') &&!$scene.is_visible_in_tree() && !$dialogue.is_visible_in_tree():
			globals.events.hadescene1()
			globals.state.plotsceneseen.append('hade1')
			checkforevents = true
			return
		elif globals.state.mainquest >= 24 && !globals.state.plotsceneseen.has('hade2') &&!$scene.is_visible_in_tree() && !$dialogue.is_visible_in_tree():
			globals.events.hadescene2()
			globals.state.plotsceneseen.append('hade2')
			checkforevents = true
			return
		elif globals.state.mainquest >= 27 && !globals.state.plotsceneseen.has('slaverguild') &&!$scene.is_visible_in_tree() && !$dialogue.is_visible_in_tree():
			globals.events.slaverguild()
			globals.state.plotsceneseen.append('slaverguild')
			checkforevents = true
			return
		elif globals.state.mainquest >= 36 && !globals.state.plotsceneseen.has('frostfordscene') &&!$scene.is_visible_in_tree() && !$dialogue.is_visible_in_tree():
			globals.events.frostfordscene()
			globals.state.plotsceneseen.append('frostfordscene')
			checkforevents = true
			return
		
		elif globals.state.mainquest >= 40 && !globals.state.plotsceneseen.has('hademelissa') &&!$scene.is_visible_in_tree() && !$dialogue.is_visible_in_tree():
			globals.events.hademelissa()
			globals.state.plotsceneseen.append('hademelissa')
			checkforevents = true
			return
	if globals.itemdict.zoebook.amount >= 1 && globals.state.sidequests.zoe == 3 && randf() >= 0.5:
		globals.events.zoebookevent()
		checkforevents = true
		return
	startnewday()

var dailyeventhappend = false

func launchrandomevent():
	var rval
	var personlist = []
	for i in globals.slaves:
		if i.away.duration == 0 && i.sleep != 'jail' && i.sleep != 'farm' && i.attention >= 50:
			personlist.append(i)
	while personlist.size() > 0:
		var number = floor(rand_range(0,personlist.size()))
		if personlist[number].attention >= rand_range(30,150):
			get_node("dailyevents").person = personlist[number]
			rval = get_node("dailyevents").getrandomevent(personlist[number])
			#rval = $dailyevents.getfixedevent('assaultevent')
			personlist[number].attention = 0
			break
		else:
			personlist.remove(number)
	return rval


var alisesprite = {
good = ['happy1','happy2',"wink1",'wink2','side'],
med = ["neutral",'side'],
bad = ["neutral",'side'],
worst = ["neutral"]
}
var alisetext = {
good = ['Nice job! Income is currently on the rise!', 'Great work, $name, We are currently getting wealthier!', 'Things are doing well, $name!', 'If we keep gaining like this, could I get a vacation one day?', 'Another great day, high-five!', 'Remarkable work! Income outlook at this time is positive.', 'A well known artist once stated, "Making money is art and working is art and business is the best art."', 'They say money talks... what does yours say?', 'We are doing great!  Please keep this up $name!'],
med = ['We might need to start making money soon.', 'Things are steady... but should be better financially', "Well we aren't losing money... but we aren't really gaining any either", 'We have added next to nothing to our coffers.  We need a stronger income.', 'I believe it is about time we gain some money.', 'Time waits for no man, neither does good commerce.'],
bad = ['We are losing money $name!', 'Things are not going too well.', 'We should do something about this cash loss.', 'Oh dear! We are bleeding gold.', 'This funding loss needs to be addressed.', 'You must be scaring the gold away, it is disappearing!', 'A financial analysis of assets states a net loss by my calculations.', '$name, do something about this funding leak before you end up poor!', 'Did I miss a memo as to why there is a loss in funds?'],
worst = ["Well... looks like we lost one of our workers. Don't let that to discourage you though!", "So we lost a worker... Let's move on and fix issues for the future.", 'This is an unfortunate situation', "The outlook is unfavorable, let's change that!", "It's just one bad day out of how many other days.", "Don't get discouraged, learn from these failures and fix the issues.", 'I am very sorry about your bad day, let us proceed to fix this.']
}

func alisebuild(state):
	get_node("FinishDayPanel/alise").show()
	if globals.resources.gold > 5000 && state in ['bad','med']:
		state = 'good'
	
	var truesprite = alisesprite[state][rand_range(0,alisesprite[state].size())]
	var showtext = globals.player.dictionary(alisetext[state][rand_range(0,alisetext[state].size())])
	if state == 'good':
		showtext = '[color=#19ec1c]' + showtext + '[/color]'
	elif state == 'med':
		showtext = '[color=yellow]' + showtext + '[/color]'
	elif state in ['bad','worst']:
		showtext = '[color=#ff4949]' + showtext + '[/color]'
	get_node("FinishDayPanel/alise/speech/RichTextLabel").set_bbcode(showtext)
	get_node("tutorialnode").buildbody(get_node("FinishDayPanel/alise"), truesprite)

func alisehide():
	get_node("FinishDayPanel/alise").hide()


var thread = Thread.new()

func startnewday():
	rebuild_slave_list()
	get_node("FinishDayPanel").show()
	if thread.is_active():
		thread.wait_to_finish()
	autosave()
	if globals.rules.enddayalise == 0:
		alisebuild(aliseresults)
	elif globals.rules.enddayalise == 1 && dailyeventhappend:
		alisebuild(aliseresults)
		dailyeventhappend = false
	else:
		alisehide()
	_on_mansion_pressed()
	
	enddayprocess = false
#	if globals.state.supporter == false && int(globals.resources.day)%100 == 0:
#		get_node("sellout").show()


func autosave():
	var counter = 3
	var savegame = File.new()
	var dir = Directory.new()
	if dir.dir_exists("user://saves") == false:
		dir.make_dir("user://saves")
	var filearray = globals.dir_contents()
	var path = 'user://saves/'
	if filearray.has(path+"autosave2"):
		dir.rename(path+'autosave2',path+'autosave3')
		if globals.savelist.has(path + 'autosave2'):
			globals.savelist[path+'autosave3'] = globals.savelist[path + 'autosave2']
		else:
			globals.savelist[path+'autosave3'] = globals.savelistentry(path+'autosave3')
	if filearray.has(path+"autosave1"):
		dir.rename(path+'autosave1',path+'autosave2')
		if globals.savelist.has(path + 'autosave1'):
			globals.savelist[path+'autosave2'] = globals.savelist[path + 'autosave1']
		else:
			globals.savelist[path+'autosave2'] = globals.savelistentry(path+'autosave2')
	
	thread.start(globals,"save_game",'user://saves/autosave1')




func rebuildrepeatablequests():
	var rand
	var town
	var count
	var array = []
	for i in globals.state.repeatables:
		array = []
		count = 0
		for ii in globals.state.repeatables[i]:
			if ii.taken == false:
				array.append(count)
			count += 1
		array.invert()
		for ii in array:
			globals.state.repeatables[i].remove(ii)
		rand = rand_range(0,2)
		if i == 'wimbornslaveguild':
			town = 'wimborn'
		elif i == 'gornslaveguild':
			town = 'gorn'
		elif i == 'frostfordslaveguild':
			town = 'frostford'
		while rand > 0:
			globals.repeatables.generatequest(town, 'easy')
			rand -= 1
		rand = rand_range(0,2)
		while rand > 0:
			globals.repeatables.generatequest(town, 'medium')
			rand -= 1
		rand = rand_range(0,1)
		while rand > 0:
			globals.repeatables.generatequest(town, 'hard')
			rand -= 1



func _on_FinishDayCloseButton_pressed():
	get_node("FinishDayPanel").hide()

#####GUI ELEMENTS

func popup(text):
	get_node("popupmessage").popup()
	get_node("popupmessage/popupmessagetext").set_bbcode(globals.player.dictionary(text))


func _on_popupmessagetext_meta_clicked( meta ):
	if meta == 'patreon':
		OS.shell_open('https://www.patreon.com/maverik')

var spritedict = globals.spritedict
onready var nodedict = {pos1 = get_node("dialogue/charactersprite1"), pos2 = get_node("dialogue/charactersprite2")}

func dialogue(showclose, destination, dialogtext, dialogbuttons = null, sprites = null, background = null): #for arrays: 0 - boolean to show close button or not. 1 - node to return connection back. 2 - text to show 3+ - arrays of buttons and functions in those
	var text = get_node("dialogue/dialoguetext")
	var buttons = $dialogue/buttonscroll/buttoncontainer
	var closebutton
	var newbutton
	var counter = 1
	get_node("dialogue/blockinput").hide()
	get_node("dialogue/background").set_texture(null)
	if background != null:
		get_node("dialogue/background").set_texture(globals.backgrounds[background])
	if !get_node("dialogue").visible:
		get_node("dialogue").visible = true
		nodeunfade($dialogue, 0.4)
		#get_node("dialogue/AnimationPlayer").play("fading")
	text.set_bbcode('')
	for i in buttons.get_children():
		if i.name != "Button":
			i.hide()
			i.queue_free()
	if dialogtext == "":
		dialogtext = var2str(dialogtext)
	if showclose == true:
		closebutton = true
	else:
		closebutton = false
	text.set_bbcode(globals.player.dictionary(dialogtext))
	if dialogbuttons != null:
		counter = 1
		for i in dialogbuttons:
			call("dialoguebuttons", dialogbuttons[counter-1], destination, counter)
			counter += 1
	if closebutton == true:
		newbutton = $dialogue/buttonscroll/buttoncontainer/Button.duplicate()
		newbutton.show()
		newbutton.set_text('Close')
		newbutton.connect('pressed',self,'close_dialogue')
		newbutton.get_node("Label").set_text(str(counter))
		buttons.add_child(newbutton)
	
	var sprite1 = false
	var sprite2 = false
	
	if sprites != null && globals.rules.spritesindialogues == true:
		for i in sprites:
			if !spritedict.has(i[0]) && globals.loadimage(i[0]) == null:
				continue
			else:
				if spritedict.has(i[0]):
					if i.size() > 2 && (i[2] != 'opac' || spritedict[i[0]] != nodedict[i[1]].get_texture()):
						tweenopac(nodedict[i[1]])
					nodedict[i[1]].set_texture(spritedict[i[0]])
				else:
					if i.size() > 2 && (i[2] != 'opac' || globals.loadimage(i[0]) != nodedict[i[1]].get_texture()):
						tweenopac(nodedict[i[1]])
					nodedict[i[1]].set_texture(globals.loadimage(i[0]))
				if i[1] == 'pos1': sprite1 = true
				if i[1] == 'pos2': sprite2 = true
	if sprite1 == false: nodedict.pos1.set_texture(null)
	if sprite2 == false: nodedict.pos2.set_texture(null)

func tweenopac(node):
	var tween = $Tween
	tween.interpolate_property(node, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func dialoguebuttons(array, destination, counter):
	var newbutton = $dialogue/buttonscroll/buttoncontainer/Button.duplicate()
	newbutton.get_node("Label").set_text(str(counter))
	newbutton.show()
	if typeof(array) == TYPE_DICTIONARY:
		newbutton.set_text(array.text) #QMod - Handles args = [var1, var2, ...]
		if array.has('args'):
			if typeof(array.args) == TYPE_ARRAY:
				newbutton.connect("pressed", destination, array.function, array.args)
			else:
				newbutton.connect("pressed", destination, array.function, [array.args])
		else:
			newbutton.connect("pressed", destination, array.function)
		if array.has('disabled') && array.disabled == true:
			newbutton.set_disabled(true)
		if array.has('tooltip'):
			newbutton.set_tooltip(array.tooltip)
	else:
		newbutton.set_text(array[0])
		if array.size() < 3:
			newbutton.connect('pressed',destination,array[1])
		else:
			newbutton.connect('pressed',destination,array[1],[array[2]])
	$dialogue/buttonscroll/buttoncontainer.add_child(newbutton)

func close_dialogue(mode = 'normal'):

	nodefade($dialogue, 0.4)
	get_node("dialogue/blockinput").show()
	if mode != 'instant':
		yield(tween, 'tween_completed')
	get_node("dialogue").hide()
	for i in nodedict.values():
		i.set_texture(null)


var savedtrack


func scene(target, image, scenetext, scenebuttons = null):
	if !get_node("scene").visible:
		get_node("scene").visible = true
		nodeunfade($scene, 0.4)
		#get_node("scene/AnimationPlayer").play("fading")
	get_node("scene").show()
	get_node("infotext").hide()
	get_node("scene/Panel/sceneeffects").set_texture(null)
	
	if globals.scenes.has(image):
		get_node("scene/Panel/scenepicture").set_normal_texture(globals.scenes[image])
	else:
		$scene/Panel/scenepicture.set_normal_texture(null)
	get_node("scene/textpanel/scenetext").set_bbcode(globals.player.dictionary(scenetext))
	get_node("scene/resources/gold").set_text(str(globals.resources.gold))
	get_node("scene/resources/food").set_text(str(globals.resources.food))
	get_node("scene/resources/mana").set_text(str(globals.resources.mana))
	get_node("scene/resources/energy").set_text(str(globals.player.energy))
	if !(image in ['finale', 'finale2']):
		savedtrack = $music.get_meta("currentsong")
		music_set("intimate")
	for i in $scene/buttonscroll/buttoncontainer.get_children():
		if i.get_name() != 'Button':
			i.hide()
			i.queue_free()
	var counter = 1
	for i in scenebuttons:
		newbuttonscene(i, target, counter)
		counter += 1

func newbuttonscene(button, target, counter):
	var newbutton = $scene/buttonscroll/buttoncontainer/Button.duplicate()
	$scene/buttonscroll/buttoncontainer.add_child(newbutton)
	newbutton.show()
	newbutton.set_text(button.text)
	newbutton.get_node("Label").set_text(str(counter))
	if button.has('args'):
		if typeof(button['args']) == TYPE_ARRAY: #QMod - Tweaked to handle arg array
			newbutton.connect("pressed", target, button.function , button.args)
		else:
			newbutton.connect("pressed", target, button.function , [button.args])
	else:
		newbutton.connect("pressed", target, button.function)

func _on_scenepicture_pressed():
	if get_node("scene/Panel/scenepicture").is_pressed():
		get_node("scene/Panel/scenepicture").set_size(get_node("scene/Panel/Panel2").get_size())
		$scene/Panel/scenepicture.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		get_node("scene/Panel/coverpanel").hide()
	else:
		get_node("scene/Panel/scenepicture").set_size(get_node("scene/Panel").get_size())
		$scene/Panel/scenepicture.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
		get_node("scene/Panel/coverpanel").show()

func closescene():
	#get_node("scene/AnimationPlayer").play_backwards("fading")
	nodefade($scene, 0.4)
	get_node("infotext").show()
	if $music.stream == globals.musicdict.intimate:
		music_set(savedtrack)
	if globals.rules.fadinganimation == true:
		yield(tween, 'tween_completed')
	get_node("scene").hide()

func _on_menu_pressed():
	#music_set('pause')
	get_node("menucontrol").popup()

func _on_closemenu_pressed():
	#music_set('start')
	get_node("menucontrol").hide()

func _on_closegamebuttonm_pressed():
	yesnopopup("Are you leaving us?", "quit")


func quit():
	get_tree().quit()

func _on_savebutton_pressed():
	get_node("menucontrol/menupanel/SavePanel").show()

func _on_optionsbutton_pressed():
	get_node("options").show()
	get_node("menucontrol").hide()


func _on_mainmenubutton_pressed():
	yesnopopup('Exit to main menu? Make sure to save', 'mainmenu')

func mainmenu():
	get_tree().change_scene("res://files/mainmenu.scn")


func _on_cancelsaveload_pressed():
	get_node("menucontrol/menupanel/SavePanel").hide()

var yesbutton = {target = null, function = null}

func yesnopopup(text, yesfunc, target = self):
	if yesbutton.target != null && get_node("yesnopopup/HBoxContainer/yesbutton").is_connected("pressed",yesbutton.target, yesbutton.function):
		get_node("yesnopopup/HBoxContainer/yesbutton").disconnect("pressed",yesbutton.target,yesbutton.function)
	get_node("yesnopopup/HBoxContainer/yesbutton").connect('pressed',target,yesfunc,[],4)
	yesbutton.target = target
	yesbutton.function = yesfunc
	get_node("yesnopopup/Label").set_bbcode(text)
	get_node("yesnopopup").popup()


func _on_yesbutton_pressed():
	get_node("yesnopopup").hide()


func _on_nobutton_pressed():
	get_node("yesnopopup").hide()

##### Saveload

var savefilename = 'user://saves/autosave'

func _on_SavePanel_visibility_changed():
	if get_node("menucontrol/menupanel/SavePanel").visible == false:
		return
	var node
	var pressedsave
	var moddedtext
	for i in get_node("menucontrol/menupanel/SavePanel/ScrollContainer/savelist").get_children():
		if i != get_node("menucontrol/menupanel/SavePanel/ScrollContainer/savelist/Button"):
			i.hide()
			i.queue_free()
	var dir = Directory.new()
	if dir.dir_exists("user://saves") == false:
		dir.make_dir("user://saves")
	var savefiles = globals.dir_contents()
	for i in globals.savelist.duplicate():
		if savefiles.find(i) < 0:
			globals.savelist.erase(i)
	pressedsave = get_node("menucontrol/menupanel/SavePanel//saveline").text
	for i in savefiles:
		node = get_node("menucontrol/menupanel/SavePanel/ScrollContainer/savelist/Button").duplicate()
		node.show()
		if globals.savelist.has(i):
			if globals.savelist[i].has('date'):
				node.get_node("date").set_text(globals.savelist[i].date)
			node.get_node("name").set_text(i.replacen("user://saves/",''))
		else:
			node.get_node("name").set_text(i.replacen("user://saves/",''))
		get_node("menucontrol/menupanel/SavePanel/ScrollContainer/savelist").add_child(node)
		node.set_meta("name", i)
		node.connect('pressed', self, 'loadchosen', [node])



func loadchosen(node):
	var savename = node.get_meta('name')
	var text
	savefilename = savename
	for i in $menucontrol/menupanel/SavePanel/ScrollContainer/savelist.get_children():
		i.pressed = (i== node)
	get_node("menucontrol/menupanel/SavePanel/saveline").set_text(savefilename.replacen("user://saves/",''))
	if globals.savelist.has(savename):
		if globals.savelist[savename].has('portrait') && globals.loadimage(globals.savelist[savename].portrait):
			$menucontrol/menupanel/SavePanel/saveimage.set_texture(globals.loadimage(globals.savelist[savename].portrait))
		else:
			$menucontrol/menupanel/SavePanel/saveimage.set_texture(null)
		text = globals.savelist[savename].name
	else:
		text = "This save has no info stored."
		$menucontrol/menupanel/SavePanel/saveimage.set_texture(null)
	$menucontrol/menupanel/SavePanel/RichTextLabel.bbcode_text = text
	#_on_SavePanel_visibility_changed()

func _on_deletebutton_pressed():
	var dir = Directory.new()
	if dir.file_exists(savefilename):
		yesnopopup('Delete this file?', 'deletefile')
	else:
		popup('No file with such name')

func deletefile():
	var dir = Directory.new()
	if dir.dir_exists("user://saves") == false:
		dir.make_dir("user://saves")
	dir.remove(savefilename)
	_on_nobutton_pressed()
	_on_SavePanel_visibility_changed()


func _on_loadbutton_pressed():
	if Directory.new().file_exists(savefilename):
		yesnopopup('Load this file?', 'loadfile')
	else:
		popup('No file with such name')

func loadfile():
	if thread.is_active():
		thread.wait_to_finish()
	globals.load_game(savefilename)
	_on_SavePanel_visibility_changed()
	get_node("menucontrol").hide()
	get_node("music").playing = true
	

func _on_saveline_text_changed( text ):
	savefilename = "user://saves/" + text

func _on_savefilebutton_pressed():
	var dir = Directory.new()
	if dir.file_exists(savefilename) == true:
		yesnopopup('This file already exists. Overwrite?', 'savefile')
	else:
		savefile()

func savefile():
	globals.save_game(savefilename)
	_on_SavePanel_visibility_changed()
	_on_nobutton_pressed()
	get_node("menucontrol/menupanel/SavePanel").hide()
	get_node("menucontrol").hide()
	music_set('mansion')


func _on_saveloadfolder_pressed():
	var temp = OS.get_user_data_dir()
	OS.shell_open('file://'+temp + '/saves')


func hide_everything():
	for i in get_tree().get_nodes_in_group("mansioncontrols"):
		i.hide()
	get_node("MainScreen/mansion/jailpanel").hide()
	get_node("MainScreen/slave_tab").hide()
	get_node("MainScreen/mansion/alchemypanel").hide()
	get_node("MainScreen/mansion/mansioninfo").hide()
	get_node("MainScreen/mansion/labpanel").hide()
	get_node("MainScreen/mansion/labpanel/labmodpanel").hide()
	get_node("MainScreen/mansion/librarypanel").hide()
	get_node("MainScreen/mansion/farmpanel").hide()
	get_node("MainScreen/mansion/selfinspect").hide()
	get_node("MainScreen/mansion/portalspanel").hide()
	get_node("MainScreen/mansion/upgradespanel").hide()
	globals.hidetooltip()

var background setget background_set, background_get

func background_set(text, forcefade = false):
	if globals.rules.fadinganimation == true:
		if get_node("TextureFrame").get_texture() != globals.backgrounds[text] || forcefade == true:
			animationfade()
			yield(self, "animfinished")
	texture = globals.backgrounds[text]
	get_node("TextureFrame").set_texture(texture)
	yield(get_tree(), "idle_frame")
	emit_signal('animfinished')

func background_get():
	return 

func backgroundinstant(text):
	get_node("TextureFrame").set_texture(globals.backgrounds[text])

func fadefinished():
	emit_signal("animfinished")

func animationfade(value = 0.4, duration = 0.05):
	nodeunfade($screenchange, value)
	tween.interpolate_callback(self,value,'fadefinished')
	nodefade($screenchange, value, value+duration)



var musicdict = globals.musicdict
var musicvolume = 0


func music_set(text):
	var music = get_node("music")
	if music.is_playing() == false && globals.rules.musicvol > 0:
		music.playing = true
	if text == 'stop':
		musicfading = true
		return
	elif text == 'pause':
		musicfading = true
		return
	elif text == 'start':
		musicraising = true
		music.play(musicvalue)
		return
	if globals.rules.musicvol == 0 || (music.get_meta("currentsong") == text && music.playing == true):
		return
	var path = ''
	var array = []
	musicraising = true
	music.set_autoplay(true)
	if text == 'combat':
		array = ['combat1', 'combat3']
		path = musicdict[array[rand_range(0,array.size())]]
	elif text == 'mansion':
		music.set_autoplay(false)
		array = ['mansion1','mansion2','mansion3','mansion4']
		path = musicdict[array[rand_range(0,array.size())]]
	else:
		path = musicdict[text]
	music.set_meta('currentsong', text)
	music.set_stream(path)
	music.play(0)
	music.set_volume_db(globals.rules.musicvol)


func _on_music_finished():
	if get_node("music").get_meta("currentsong") == 'mansion':
		get_node("music").set_meta("currentsong", 'over')
		music_set("mansion")
	elif get_node("music").get_meta("currentsong") == 'combat':
		get_node("music").set_meta("currentsong", 'over')
		music_set("combat")
	else:
		music_set(get_node("music").get_meta("currentsong"))



func _on_mansionbutton_pressed():
	_on_mansion_pressed()

var selftexture = load("res://files/buttons/mainscreen/53(2).png")

func _on_mansion_pressed():
	var text = ''
	background_set('mansion')
	yield(self, 'animfinished')
	hide_everything()
	for i in get_tree().get_nodes_in_group("mansioncontrols"):
		i.show()
	get_node("outside/slavesellpanel").hide()
	get_node("outside/slavebuypanel").hide()
	get_node("outside/slaveguildquestpanel").hide()
	get_node("outside/slaveservicepanel").hide()
	get_node("outside").hide()
	get_node("hideui").hide()
	get_node("charlistcontrol").show()
	get_node("MainScreen").show()
	get_node("Navigation").show()
	$ResourcePanel.show()
	get_node("ResourcePanel/menu").disabled = false
	get_node("ResourcePanel/helpglossary").disabled = false
	get_node("MainScreen/mansion/sexbutton").set_disabled(globals.state.sexactions < 1 && globals.state.nonsexactions < 1)
	if globals.player.imageportait != null && globals.loadimage(globals.player.imageportait):
		$Navigation/personal/TextureRect.texture = globals.loadimage(globals.player.imageportait)
	else:
		$Navigation/personal/TextureRect.texture = selftexture
	$ResourcePanel/clean.set_text(str(round(globals.state.condition)) + '%')
	
	build_mansion_info()
	
	
	if globals.state.farm >= 3:
		get_node("Navigation/farm").set_disabled(false)
	else:
		get_node("Navigation/farm").set_disabled(true)
	if globals.state.mansionupgrades.mansionlab > 0:
		get_node("Navigation/laboratory").set_disabled(false)
	else:
		get_node("Navigation/laboratory").set_disabled(true)
	music_set('mansion')
	if globals.state.sidequests.emily == 3:
		globals.events.emilymansion()
	if globals.state.capturedgroup.size() > 0:
		var array = []
		var nojailcells = false
		for i in globals.state.capturedgroup:
			array.append(i)
		for i in array:
			for k in i.gear.values():
				if k != null:
					globals.items.unequipitem(k, i, true)
			globals.slaves = i
			if globals.count_sleepers().jail < globals.state.mansionupgrades.jailcapacity:
				i.sleep = 'jail'
			else:
				nojailcells = true
			globals.state.capturedgroup.erase(i)
		text = "You have assigned your captives to the mansion. " + globals.fastif(nojailcells, '[color=yellow]You are out of free jail cells and some captives were assigned to the living room.[/color]', '')
		popup(text)
	rebuild_slave_list()

var colordict = {high = '[color=green]', med = '[color=yellow]', low = '[color=#ff4949]'}
var statedict = {
	health = {high = 'Healthy', med = 'Injured', low = 'Wounded'},
	energy = {high = 'Lively', med = 'Tired', low = 'Wasted'},
	stress = {high = "Content", med = 'Stressed', low = "On verge"}
}


func build_mansion_info():
	var textnode = get_node("MainScreen/mansion/mansioninfo")
	var text
	textnode.show()
	var sleepers = globals.count_sleepers()
	var unassigned = "[color=yellow]Unassigned[/color]"
	text = 'You are at your mansion, which is located near [color=aqua]'+ globals.state.location.capitalize()+'[/color].\n\n'
	
	if globals.state.condition <= 20:
		text += 'Mansion is [color=#ff4949]in a complete mess[/color].'
	elif globals.state.condition <= 40:
		text += 'Mansion is [color=#FFA500]very dirty[/color].'
	elif globals.state.condition <= 60:
		text += 'Mansion is [color=yellow]quite unclean[/color].'
	elif globals.state.condition <= 80:
		text += 'Mansion is [color=lime]passably clean[/color].'
	else:
		text += 'Mansion is [color=green]immaculate[/color].'
	
	text += '\n\nYou have '
	if sleepers.communal > globals.state.mansionupgrades.mansioncommunal:
		text += colordict.low
	elif sleepers.communal == globals.state.mansionupgrades.mansioncommunal:
		text += colordict.med
	else:
		text += colordict.high
	text += str(sleepers.communal) + "/" + str(globals.state.mansionupgrades.mansioncommunal) +  '[/color] beds in the communal room\n'
	
	text += 'You have ' + globals.fastif(sleepers.personal >= globals.state.mansionupgrades.mansionpersonal, '[color=yellow]', '[color=green]') + str(sleepers.personal) + "/" + str(globals.state.mansionupgrades.mansionpersonal) + '[/color] ' + globals.fastif(globals.state.mansionupgrades.mansionpersonal > 1, 'personal rooms', 'personal room')+ ' available for living\nYour bed can fit ' +globals.fastif(sleepers['your_bed'] >= globals.state.mansionupgrades.mansionbed, '[color=yellow]', '[color=green]') + str(sleepers.your_bed) + "/" + str(globals.state.mansionupgrades.mansionbed) + '[/color] ' +  globals.fastif(globals.state.mansionupgrades.mansionpersonal > 1, 'persons', 'person')+' besides you.'
	
	text += '\n\nYour jail has ' + globals.fastif(sleepers.jail >= globals.state.mansionupgrades.jailcapacity, '[color=yellow]', '[color=green]') +str(sleepers.jail) + "/" + str(globals.state.mansionupgrades.jailcapacity) +'[/color] cells. \n'
	if globals.state.farm >= 3:
		text += "Your farm holds " + globals.fastif(sleepers.farm >= variables.resident_farm_limit[globals.state.mansionupgrades.farmcapacity], '[color=yellow]', '[color=green]') +str(sleepers.farm) + "/" + str(variables.resident_farm_limit[globals.state.mansionupgrades.farmcapacity]) +'[/color] booths for cattle. \n'
	
	var jobdict = {headgirl = null, jailer = null, farmmanager = null, cooking = null, nurse = null, labassist = null}
	
	for i in globals.slaves:
		if jobdict.has(i.work):
			jobdict[i.work] = i
	
	if globals.slaves.size() >= 8:
		text += "\nHeadgirl: "
		if jobdict.headgirl == null:
			text += unassigned
		else:
			text += "[color=aqua][url=id" + jobdict.headgirl.id + "]" + jobdict.headgirl.name_short() + "[/url][/color]"
	
	text += "\nJailer: "
	if jobdict.jailer == null:
		text += unassigned
	else:
		text += "[color=aqua][url=id" + jobdict.jailer.id + "]" + jobdict.jailer.name_short() + "[/url][/color]"
	
	if globals.state.farm >= 3:
		text += "\nFarm Manager: "
		if jobdict.farmmanager == null:
			text += unassigned
		else:
			text += "[color=aqua][url=id" + jobdict.farmmanager.id + "]" + jobdict.farmmanager.name_short() + "[/url][/color]"
	
	text += "\n------------------------------------------"
	
	text += "\nChef: "
	if jobdict.cooking == null:
		text += unassigned
	else:
		text += "[color=aqua][url=id" + jobdict.cooking.id + "]" + jobdict.cooking.name_short() + "[/url][/color]"
	text += "\nNurse: "
	if jobdict.nurse == null:
		text += unassigned
	else:
		text += "[color=aqua][url=id" + jobdict.nurse.id + "]" + jobdict.nurse.name_short() + "[/url][/color]"
	
	if globals.state.mansionupgrades.mansionlab > 0:
		text += "\nLab Assistant: "
		if jobdict.labassist == null:
			text += unassigned
		else:
			text += "[color=aqua][url=id" + jobdict.labassist.id + "]" + jobdict.labassist.name_short() + "[/url][/color]"
	
	text += "\n\nCombat Group:\n"
	var counter = 0
	if globals.state.playergroup.size() <= 0:
		text = text + 'Nobody is assigned to follow you.'
	else:
		slavearray.clear()
		for i in globals.state.playergroup.duplicate():
			var person = globals.state.findslave(i)
			if person != null:
				slavearray.append(person)
				text += person.dictionary('[url=person' + str(counter) + '][color=aqua]$name[/color][/url]: ') 
				var value
				if float(person.stats.health_cur)/person.stats.health_max > 0.75: 
					value = 'high'
				elif float(person.stats.health_cur)/person.stats.health_max > 0.4:
					value = 'med'
				else:
					value = 'low'
				text += colordict[value] + statedict.health[value] + "[/color], "
				if float(person.stats.energy_cur)/person.stats.energy_max > 0.5: 
					value = 'high'
				elif float(person.stats.energy_cur)/person.stats.energy_max > 0.2:
					value = 'med'
				else:
					value = 'low'
				text += colordict[value] + statedict.energy[value] + "[/color], "
				
				if person.stress < 50: 
					value = 'high'
				elif person.stress < 880:
					value = 'med'
				else:
					value = 'low'
				text += colordict[value] + statedict.stress[value] + "[/color]\n"
				
				
				counter += 1
			else:
				globals.state.playergroup.erase(i)
	
	
	
	textnode.set_bbcode(text)
	
	if (globals.slaves.size() >= 8 && jobdict.headgirl != null) || globals.developmode == true:
		get_node("charlistcontrol/slavelist").show()
	else:
		get_node("charlistcontrol/slavelist").hide()



#jail settings

func _on_jailbutton_pressed():
	background_set('jail')
	yield(self, 'animfinished')
	hide_everything()
	get_node("MainScreen/mansion/jailpanel").show()
	if globals.state.tutorial.jail == false:
		get_node("tutorialnode").jail()

func _on_jailpanel_visibility_changed():
	var temp = ''
	var text = ''
	var count = 0
	var prisoners = []
	var jailer
	
	for i in get_node("MainScreen/mansion/jailpanel/ScrollContainer/prisonerlist").get_children():
		i.hide()
		i.queue_free()
	
	if get_node("MainScreen/mansion/jailpanel").visible == false:
		return
	for i in globals.slaves:
		if i.sleep == 'jail' && i.away.duration == 0:
			temp = temp + i.name
			prisoners.append(i)
			var button = Button.new()
			var node = get_node("MainScreen/mansion/jailpanel/ScrollContainer/prisonerlist")
			node.add_child(button)
			button.set_text(i.name_long())
			button.set_name(str(count))
			button.connect('pressed', self, 'prisonertab', [count])
		if i.work == 'jailer' && i.away.duration == 0:
			jailer = i
		count += 1
	if temp == '':
		text = 'You have no prisoners at this moment.'
	else:
		text = 'You have '+str(prisoners.size()) + ' prisoner(s).\nYou have ' + str(globals.state.mansionupgrades.jailcapacity-prisoners.size()) + ' free cell(s).\nPrisoners can be disciplined at "Interactions" with abuse setting. '
	if globals.state.mansionupgrades.jailincenses:
		text += "\n[color=green]Your jail is decently furnished and tiled. [/color]"
	if globals.state.mansionupgrades.jailincenses:
		text += "\n[color=green]You can smell soft burning incenses in the air.[/color]"
	if jailer == null:
		text = text + '\nYou have no assigned jailer.'
	else:
		text = text + jailer.dictionary('\n$name is assigned as jailer.')
	
	
	get_node("MainScreen/mansion/jailpanel/jailtext").set_bbcode(text)

func _on_jailsettingspanel_visibility_changed(inputslave = null):
	var jailer = inputslave
	for i in globals.slaves:
		if i.work == 'jailer':
			jailer = i
	var text = ''
	if jailer == null:
		text = 'You have no assigned jailer. '
		get_node("MainScreen/mansion/jailpanel/jailsettings/jailsettingspanel/jailerchange").set_text('Change')
	else:
		text = 'Your current jailer is - ' + jailer.name_long()
		jailer.work = 'jailer'
		get_node("MainScreen/mansion/jailpanel/jailsettings/jailsettingspanel/jailerchange").set_text('Unassign')
	get_node("MainScreen/mansion/jailpanel/jailsettings/jailsettingspanel/currentjailertext").set_bbcode(text)
	if globals.slaves.size() < 1:
		get_node("MainScreen/mansion/jailpanel/jailsettings/jailsettingspanel/jailerchange").set_disabled(true)
	else:
		get_node("MainScreen/mansion/jailpanel/jailsettings/jailsettingspanel/jailerchange").set_disabled(false)
	_on_jailpanel_visibility_changed()

func prisonertab(number):
	self.currentslave = number
	get_node("MainScreen/slave_tab").tab = 'prison'
	get_node("MainScreen/slave_tab").slavetabopen()

func _on_jailerchange_pressed():
	if get_node("MainScreen/mansion/jailpanel/jailsettings/jailsettingspanel/jailerchange").get_text() != 'Unassign':
		selectslavelist(false, '_on_jailsettingspanel_visibility_changed', self, 'globals.currentslave.loyal >= 20 && globals.currentslave.conf >= 50')
	else:
		for i in globals.slaves:
			if i.work == 'jailer':
				i.work = 'rest'
		_on_jailsettingspanel_visibility_changed()


func _on_jailsettings_pressed():
	get_node("MainScreen/mansion/jailpanel/jailsettings/jailsettingspanel").show()

func _on_jailerclose_pressed():
	get_node("MainScreen/mansion/jailpanel/jailsettings/jailsettingspanel").hide()

var potselected

func _on_alchemy_pressed():
	background_set('alchemy' + str(globals.state.mansionupgrades.mansionalchemy))
	yield(self, 'animfinished')
	hide_everything()
	get_node("MainScreen/mansion/alchemypanel").show()
	if globals.state.tutorial.alchemy == false:
		get_node("tutorialnode").alchemy()
	if globals.state.sidequests.chloe == 8 && globals.state.mansionupgrades.mansionalchemy >= 1:
		globals.events.chloealchemy()
	potselected = null
	var potlist = get_node("MainScreen/mansion/alchemypanel/ScrollContainer/selectpotionlist")
	var potline = get_node("MainScreen/mansion/alchemypanel/ScrollContainer/selectpotionlist/selectpotionline")
	var maintext = get_node("MainScreen/mansion/alchemypanel/alchemytext")
	if globals.state.mansionupgrades.mansionalchemy == 0:
		maintext.set_bbcode("Your alchemy room lacks sufficient tools to craft your own potions. You have to unlock it from [color=yellow]Mansion Upgrades[/color] first.")
		for i in get_node("MainScreen/mansion/alchemypanel").get_children():
			i.hide()
		maintext.show()
		return
	else:
		get_node("MainScreen/mansion/alchemypanel/alchemytext").set_bbcode("This is your alchemy room. Chemistry equipment is ready to use and shelves contain your fresh ingredients.")
		get_node("MainScreen/mansion/alchemypanel/potdescription").set_bbcode('')
		for i in get_node("MainScreen/mansion/alchemypanel").get_children():
			i.show()
	for i in potlist.get_children():
		if i != potline:
			i.hide()
			i.queue_free()
	var array = []
	for i in globals.itemdict.values():
		if i.recipe != '' && globals.evaluate(i.reqs):
			array.append(i)
	array.sort_custom(globals.items,'sortitems')
	for i in array:
		var newpotline = potline.duplicate()
		potlist.add_child(newpotline)
		if i.icon != null:
			newpotline.get_node("potbutton/icon").set_texture(i.icon)
		newpotline.show()
		newpotline.get_node("potnumber").set_text(str(i.amount))
		newpotline.get_node("potbutton").set_text(i.name)
		newpotline.get_node("potbutton").connect('pressed', self, 'brewlistpressed', [i])
		newpotline.set_name(i.name)
	alchemyclear()
	get_node("MainScreen/mansion/alchemypanel/brewbutton").set_disabled(true)

func alchemyclear():
	get_node("MainScreen/mansion/alchemypanel/Panel 2").hide()
	get_node("MainScreen/mansion/alchemypanel/Label").hide()
	get_node("MainScreen/mansion/alchemypanel/Label1").hide()
	for i in get_node("MainScreen/mansion/alchemypanel/VBoxContainer").get_children():
		if i.get_name() != 'Panel':
			i.hide()
			i.queue_free()
	

func brewlistpressed(potion):
	potselected = potion
	var counter = get_node("MainScreen/mansion/alchemypanel/brewcounter").get_value()
	var text = ''
	var recipedict = {}
	var brewable = true
	recipedict = globals.items[potion.recipe]
	var array = []
	for i in recipedict:
		array.append(i)
	array.sort_custom(globals.items,'sortbytype')
	alchemyclear()
	if potselected.icon != null:
		get_node("MainScreen/mansion/alchemypanel/Panel 2").show()
		get_node("MainScreen/mansion/alchemypanel/Panel 2/bigicon").set_texture(potselected.icon)
	get_node("MainScreen/mansion/alchemypanel/Label").show()
	get_node("MainScreen/mansion/alchemypanel/Label1").show()
	for i in array:
		var item = globals.itemdict[i]
		var newpanel = get_node("MainScreen/mansion/alchemypanel/VBoxContainer/Panel").duplicate()
		get_node("MainScreen/mansion/alchemypanel/VBoxContainer/").add_child(newpanel)
		newpanel.show()
		newpanel.get_node("icon").set_texture(item.icon)
		newpanel.get_node("icon").connect("mouse_entered",globals, 'showtooltip', [item.description])
		newpanel.get_node("icon").connect("mouse_exited",globals, 'hidetooltip')
		newpanel.get_node('name').set_text(item.name)
		newpanel.get_node("number").set_text(str(recipedict[i]*counter))
		newpanel.get_node("totalnumber").set_text(str(item.amount))
		if item.amount < recipedict[i]*counter:
			newpanel.get_node("totalnumber").set('custom_colors/font_color', Color(1,0.29,0.29))
			brewable = false
	text = text + '\n[center][color=aqua]'+ potselected.name + '[/color][/center]\n' + '' + potselected.description + '\n'
	for i in get_tree().get_nodes_in_group('alchemypot'):
		if i.get_text() != potion.name && i.is_pressed() == true:
			i.set_pressed(false)
	get_node("MainScreen/mansion/alchemypanel/potdescription").set_bbcode(text)
	if counter == 0:
		brewable = false
	if brewable == false:
		get_node("MainScreen/mansion/alchemypanel/brewbutton").set_disabled(true)
	else:
		get_node("MainScreen/mansion/alchemypanel/brewbutton").set_disabled(false)


func _on_brewbutton_pressed():
	if potselected == null:
		return
	var counter = get_node("MainScreen/mansion/alchemypanel/brewcounter").get_value()
	while counter > 0:
		counter -= 1
		globals.items.recipemake(potselected)
	brewlistpressed(potselected)
	_on_alchemy_pressed()
	get_node("MainScreen/mansion/alchemypanel/brewbutton").set_disabled(true)

func _on_brewcounter_value_changed( value ):
	if potselected != null:
		brewlistpressed(potselected)

func chloealchemy():
	globals.events.chloealchemy()

var loredict = globals.dictionary.loredict

func _on_library_pressed():
	if globals.state.mansionupgrades.mansionlibrary == 0:
		background_set('library1')
	else:
		background_set('library2')
	yield(self, 'animfinished')
	hide_everything()
	get_node("MainScreen/mansion/librarypanel").show()
	var text = ''
	if globals.state.mansionupgrades.mansionlibrary == 0:
		text = "Tucked away in a large room off the main passage in the mansion is the library. Bookshelves line every wall leaving only spaces for long narrow windows and the door. The shelves are mostly empty a few scarce books from your days studying you've brought with you. "
	else:
		text = "Tucked away in a large room off the main passage in the mansion is the library. Bookshelves line every wall leaving only spaces for long narrow windows and the door. Your collection of books grew bigger since your earlier days, and you are fairly proud of it."
	var list = get_node("MainScreen/mansion/librarypanel/TextureFrame/ScrollContainer/VBoxContainer")
	for i in list.get_children():
		if i.get_name() != "Button":
			i.hide()
			i.queue_free()
	
	var array = []
	for i in loredict.values():
		if globals.evaluate(i.reqs) == false:
			continue
		var newbutton = get_node("MainScreen/mansion/librarypanel/TextureFrame/ScrollContainer/VBoxContainer/Button").duplicate()
		list.add_child(newbutton)
		newbutton.show()
		newbutton.set_text(i.name)
		newbutton.set_meta('lore', i)
		newbutton.connect('pressed',self,'lorebutton', [i])
	
	var personarray = []
	for person in globals.slaves:
		if person.work == 'library':
			personarray.append(person)
	if personarray.size() > 0:
		text += '\n\nYou can see '
		for i in personarray:
			text += i.dictionary('$name')
			if i != personarray.back() && personarray.find(i) != personarray.size()-2:
				text += ', '
			elif personarray.find(i) == personarray.size()-2:
				text += ' and '
		text += " studying here."
	get_node("MainScreen/mansion/librarypanel/libraryinfo").set_bbcode(text)

func lorebutton(lore):
	for i in get_node("MainScreen/mansion/librarypanel/TextureFrame/ScrollContainer/VBoxContainer").get_children():
		if i.get_name() != 'Button' && i.get_meta('lore') != lore:
			i.set_pressed(false)
		else:
			i.set_pressed(true)
	sound('page')
	get_node("MainScreen/mansion/librarypanel/TextureFrame/librarytext").set_bbcode(lore.text)
	get_node("MainScreen/mansion/librarypanel/TextureFrame/librarytext").get_v_scroll().set_value(0)

func _on_lorebutton_pressed():
	get_node("MainScreen/mansion/librarypanel/TextureFrame").show()

func _on_libraryclose_pressed():
	get_node("MainScreen/mansion/librarypanel/TextureFrame").hide()
###########QUEST LOG

func _on_questlog_pressed():
	get_node("questnode").popup()


func _on_questsclosebutton_pressed():
	get_node("questnode").hide()

var mainquestdict = {
'0' : "You should try joining Mage Order in town to get access to better stuff and start your career.",
'1' : "Old chancellor at Mage Order wants me to bring him a girl before I can join. She must be: \nFemale;\nHuman; \nAverage look (40) or better; \nHigh obedience; \n\nI can probably take a look at Slavers's Guild or explore outsides. ",
'2' : "Visit Mage Order again and seek for further promotions.",
'3' : "Melissa from Mage Order wants you to bring them captured Fairy. ",
'3.1' : "Melissa from Mage Order wants you to bring them captured Fairy, I should be able to find them in far forests around Wimborn. ",
'4' : "Return to Melissa for further information.",
'5' : "Melissa told you to find Sebastian at the market and get her 'delivery'.",
'6' : "Acquire alchemical station, brew Elixir of Youth and return it to Melissa.",
'7' : "Visit Melissa for your next task.",
'8' : "Set up a Laboratory through Mansion Upgrades tab. Then return to Melissa.",
'9' : "Return to Melissa.",
'10': "Bring Melissa a Taurus girl with huge lactating tits. Size can be altered with certain potions. ",
'11': "Visit Melissa for your next mission. ",
'12': "Melissa told you to travel to Gorn and find the Orc named Garthor. ",
'13': "Garthor from Gorn ordered you to capture and bring Dark Elf Ivran who you can find at Gorn's outskirts.",
'14': "Wait for next day until returning to Garthor. ",
'15': "Return to Garthor and decide what should be done with Ivran. ",
'16': "Return back to Melissa for your next task. ",
'17': "Get to the Amberguard through the Deep Elven Grove. ",
'18': "Get to the Tunnel Entrance which lays after the Amber Road. ",
'19': "Search through Amberguard for a way to get into Tunnel Entrance. ",
'20': "Purchase the information from stranger in Amberguard. ",
'21': "Locate Witch's Hut at the Amber Road. ",
'22': "Ask Shuriya in the Hut near Amber Road how to get into tunnels",
'23': "Bring 2 slaves to the Shuriya: an elf and a drow. ",
'24': "Search through Undercity ruins for any remaining documents. ",
'25': "Return to Melissa with your findings. ",
'26': "Visit Melissa for your next assignement. ",
'27': "Visit Capital. ",
'28': "Visit Frostford's City Hall. ",
'28.1': "Investigate suspicious hunting grounds at Frostford's outskirts. ",
'29': "Report back to Theron about your findings. ",
'30': "Decide on the solution for Frostford's issue. ",
'31': "Let Theron know about Zoe's decision.",
'32': "Return to Zoe while having total 500 units of food, 15 Nature Essences and 5 Fluid Substances.",
'33': "Return to Theron.",
'34': "Return to Theron.",
'35': "Return to Theron.",
'36': "Visit Melissa",
'37': "Visit Garthor at Gorn",
'38': "Search for Ayda at her shop",
'39': "Search for Ayda at Gorn's Mountain region",
'40': "Return to Wimborn's Mage Order",
'41': "Return to Wimborn's Mage Order",
'42': "Main story quest Finished"
}
var chloequestdict = {
'3':"Chloe from Shaliq wants you to get 25 mana and visit her to trade it for a spell.",
'5':"Visit Chloe in the Shaliq.",
'6':"Chloe seems to be missing from her hut. You should try looking for her in the woods.",
'7':"Check on Chloe's condition in Shaliq. ",
'8':"Chloe asked you to brew an antidote for her. ",
'9':"Return with potion to [color=green]Chloe in Shaliq[/color].",
}
var caliquestdict = {
'12':"Talk to Cali about her parents",
'13':"Talk to Cali",
'14':"Ask around Wimborn for potential clues of Cali's origins",
'15':"Get information from Jason in Wimborn's Bar",
'16':"Pay up rest of the cash to the Jason for information",
'17':"Search Shaliq village in the Wimborn forest for clues",
'18':"Search forest bandits for clues",
'19':"Defeat bandits in camp in Wimborn forest",
'20':"Return to Shaliq for reward",
'21':"Return to Shaliq for reward",
'22':"Talk to Cali",
'23':"Locate slavers camp in Wimborn outskirts",
'24':"Locate slavers camp in Wimborn outskirts",
'25':"Locate bandit responsible for Cali's kidnap",
'26':"Locate Cali's house in Eerie woods"
}
var emilyquestdict = {
'12':"Search for Tisha at the Wimborn's Mage Order",
'13':"Search for suspicious person at the backstreets",
'14':"Your investigation tells you Tisha might be at Gorn.",
'15':"Get Tisha out of Gorn's Slavers Guild",
}
var yrisquestdict = {
"1":"Accept Yris's challenge at Gorn's bar",
"2":"Find a way to win Yris's challenge at Gorn's bar. Perhaps, some potion might provide an option",
"3":"Talk to Yris at Gorn's Bar",
"4":"Find a way to secure your bet with Yris. Perhaps, some alchemist might shine some light upon your findings. You'll also need 1000 gold and 1 Deterrent potion.",
"5":"Beat Yris at her challenge at Gorn's Bar. You'll also need to bring 1000 gold and Deterrent potion. ",
}
var zoequestdict = {
"5":"Deliver to Zoe 10 Teleport Seals, 5 Magic Essences, 5 Tainted Essences.",
	
}
var aydaquestdict = {
	"5": "Visit Ayda at her shop in Gorn",
	"7": "Visit Ayda's shop to find out more about her",
	"8": "Find an Ice Brandy for Ayda",
	"9": "Talk to Ayda",
	"10": "Visit Ayda's shop to find out what else you can do for her",
	"11": "Find book ‘Fairies and Their Many Uses’",
	"12": "Talk to Ayda",
	"13": "Visit Ayda's shop",
	"14": "Find the Ayda's necklace around Gorn.",
	"15": "Talk to Ayda",
}
var questtype = {slaverequest = 'Slave Request'}
var selectedrepeatable

func _on_questnode_visibility_changed():
	if get_node("questnode").visible == false:
		return
	var maintext = get_node("questnode/TabContainer/Main Quest/mainquesttext")
	var sidetext = get_node("questnode/TabContainer/Side Quests/sidequesttext")
	var repeattext = get_node("questnode/TabContainer/Repeatable Quests/repetablequesttext")
	maintext.set_bbcode(mainquestdict[str(globals.state.mainquest)])
	sidetext.set_bbcode('')
	repeattext.set_bbcode('')
	#sidequests
	if globals.state.sidequests.brothel == 1:
		sidetext.set_bbcode(sidetext.get_bbcode() + "—To let your slaves work at prostitution, you'll have to bring [color=green]Elf girl[/color] to the brothel. \n\n")
	if globals.state.farm == 2:
		sidetext.set_bbcode(sidetext.get_bbcode()+ "—Sebastian proposed you to purchase to set up your own human farm for 1000 gold.\n\n")
	if chloequestdict.has(str(globals.state.sidequests.chloe)):
		sidetext.set_bbcode(sidetext.get_bbcode() + "—"+ chloequestdict[str(globals.state.sidequests.chloe)]+"\n\n")
	if caliquestdict.has(str(globals.state.sidequests.cali)):
		sidetext.set_bbcode(sidetext.get_bbcode() + "—"+ caliquestdict[str(globals.state.sidequests.cali)]+"\n\n")
	if emilyquestdict.has(str(globals.state.sidequests.emily)):
		sidetext.set_bbcode(sidetext.get_bbcode() + "—"+ emilyquestdict[str(globals.state.sidequests.emily)]+"\n\n")
	if yrisquestdict.has(str(globals.state.sidequests.yris)):
		sidetext.set_bbcode(sidetext.get_bbcode() + "—"+ yrisquestdict[str(globals.state.sidequests.yris)]+"\n\n")
	if aydaquestdict.has(str(globals.state.sidequests.ayda)):
		sidetext.set_bbcode(sidetext.get_bbcode() + "—"+ aydaquestdict[str(globals.state.sidequests.ayda)]+"\n\n")
	if zoequestdict.has(str(globals.state.sidequests.zoe)):
		sidetext.set_bbcode(sidetext.get_bbcode() + "—"+ zoequestdict[str(globals.state.sidequests.zoe)]+"\n\n")
	#repeatables
	for i in get_node("questnode/TabContainer/Repeatable Quests/ScrollContainer/VBoxContainer").get_children():
		if i != get_node("questnode/TabContainer/Repeatable Quests/ScrollContainer/VBoxContainer/Button"):
			i.hide()
			i.queue_free()
	selectedrepeatable = null
	get_node("questnode/TabContainer/Repeatable Quests/questforfeit").set_disabled(true)
	for i in globals.state.repeatables:
		for ii in globals.state.repeatables[i]:
			if ii.taken == true:
				var newbutton = get_node("questnode/TabContainer/Repeatable Quests/ScrollContainer/VBoxContainer/Button").duplicate()
				get_node("questnode/TabContainer/Repeatable Quests/ScrollContainer/VBoxContainer").add_child(newbutton)
				newbutton.show()
				newbutton.set_text(ii.location.capitalize() + ' - ' + questtype[ii.type])
				newbutton.connect("pressed",self,'repeatableselect', [ii])
				newbutton.set_meta('quest', ii)
	
	
	if sidetext.get_bbcode() == '':
		sidetext.set_bbcode('You have no active sidequests.')
	if get_node("questnode/TabContainer/Repeatable Quests/ScrollContainer/VBoxContainer").get_children().size() <= 1:
		repeattext.set_bbcode('You have no active repeatable quests.')
	else:
		repeattext.set_bbcode('Choose repeatable quest to see detailed info.')

func repeatableselect(quest):
	selectedrepeatable = quest
	get_node("questnode/TabContainer/Repeatable Quests/questforfeit").set_disabled(false)
	var text = ''
	for i in get_node("questnode/TabContainer/Repeatable Quests/ScrollContainer/VBoxContainer").get_children():
		if i.has_meta('quest') == true:
			if i.get_meta('quest') != quest && i.is_pressed() == true:
				i.set_pressed(false)
	text = get_node("outside").slavequesttext(quest)
	text = text.replace('Time Limit:', 'Time Remained:')
	get_node("questnode/TabContainer/Repeatable Quests/repetablequesttext").set_bbcode(text)

func _on_questforfeit_pressed():
	if selectedrepeatable != null:
		yesnopopup("Cancel this quest?", 'removequest')

func removequest():
	for i in globals.state.repeatables:
		for ii in globals.state.repeatables[i]:
			if ii == selectedrepeatable:
				globals.state.repeatables[i].remove(globals.state.repeatables[i].find(ii))
	get_node("menucontrol/yesnopopup").hide()
	_on_questnode_visibility_changed()

var spellscategory = 'control'
var spellbookimages = {
control = load("res://files/buttons/book/control.png"),
offensive = load("res://files/buttons/book/offensive.png"),
defensive = load("res://files/buttons/book/defensive.png"),
utility = load("res://files/buttons/book/utility.png"),
}

func _on_spellbook_pressed():
	get_node("spellbooknode").popup()
	sound('page')
	var spelllist = get_node("spellbooknode/spellbooklist/ScrollContainer/spellist")
	var spellbutton = get_node("spellbooknode/spellbooklist/ScrollContainer/spellist/spellbutton")
	get_node("spellbooknode/spellbooklist").set_texture(spellbookimages[spellscategory])
	for i in spelllist.get_children():
		if i != spellbutton:
			i.hide()
			i.queue_free()
	var array = []
	for i in globals.spelldict.values():
		array.append(i)
	array.sort_custom(globals.spells,'sortspells')
	get_node("spellbooknode/spellbooklist/spelldescription").set_bbcode('')
	for i in array:
		if i.learned == true && i.type == spellscategory:
			var newbutton = spellbutton.duplicate()
			spelllist.add_child(newbutton)
			newbutton.set_text(i.name)
			newbutton.show()
			newbutton.connect('pressed',self,'spellbookselected',[i])
	#get_node("screenchange/AnimationPlayer").play("fadetoblack")

func spellbookselected(spell):
	var text = ''
	sound('page')
	for i in get_tree().get_nodes_in_group("spellbutton"):
		if i.get_text() != spell.name: i.set_pressed(false)
	text = '[center]'+ spell.name + '[/center]\n\n' + spell.description + '\n\nType: ' + spell.type.capitalize() + '\n\nMana: ' + str(globals.spells.spellcost(spell))
	if spell.combat == true:
		text += '\n\nCan be used in combat'
	get_node("spellbooknode/spellbooklist/spelldescription").set_bbcode(text)

func spellbookcategory(button):
	spellscategory = button.get_name()
	_on_spellbook_pressed()

func _on_spellbookclose_pressed():
	get_node("spellbooknode").hide()


func _on_debug_pressed():
	get_node("options").show()
	get_node("options")._on_cheats_pressed()

var baby

func childbirth(person):
	person.metrics.birth += 1
	get_node("birthpanel").show()
	baby = globals.state.findbaby(person.preg.baby)
	var text = ''
	person.preg.duration = 0
	person.preg.baby = null
	person.preg.fertility = 5


	if globals.state.mansionupgrades.mansionnursery == 1:
		if globals.player == person:
			text = person.dictionary('You gave birth to a ')
		else:
			text = person.dictionary('$name gave birth to a ')
		text += baby.dictionary('healthy $race $child. ') + globals.description.getBabyDescription(baby)
		if globals.state.rank < 2:
			get_node("birthpanel/raise").set_disabled(true)
			text = text + "\nSadly, you can't allow to raise it, as your guild rank is too low. "
		else:
			text = text + "\nWould you like to send it to another dimension to accelerate its growth? This will cost you 500 gold. "
			if globals.resources.gold >= 500:
				get_node("birthpanel/raise").set_disabled(false)
			else:
				get_node("birthpanel/raise").set_disabled(true)
	else:
		if globals.player == person:
			text = person.dictionary("You've had to use town's hospital to give birth to your child. Sadly, you can't keep it without Nursery Room and had to give it away.")
		else:
			text = person.dictionary("$name had to use town's hospital to give birth to your child. Sadly, you can't keep it without Nursery Room and had to give it away.")
		get_node("birthpanel/raise").set_disabled(true)
	get_node("birthpanel/birthtext").set_bbcode(text)

func _on_giveaway_pressed():
	get_node("birthpanel").hide()

func _on_raise_pressed():
	get_node("birthpanel/raise/childpanel").show()
	globals.resources.gold -= 500
	get_node("birthpanel/raise/childpanel/LineEdit").set_text(baby.name)
	if globals.rules.children != true:
		get_node("birthpanel/raise/childpanel/child").hide()
	else:
		get_node("birthpanel/raise/childpanel/child").show()

func babyage(age):
	baby.name = get_node("birthpanel/raise/childpanel/LineEdit").get_text()
	if get_node("birthpanel/raise/childpanel/surnamecheckbox").is_pressed() == true:
		baby.surname = globals.player.surname
	if age == 'child':
		baby.age = 'child'
		var sizes = ['flat','small']
		if baby.sex != 'male':
			baby.titssize = sizes[rand_range(0,sizes.size())]
			baby.asssize = sizes[rand_range(0,sizes.size())]
		baby.away.duration = variables.growuptimechild
	elif age == 'teen':
		baby.age = 'teen'
		var sizes = ['flat','small','average','big']
		if baby.sex != 'male':
			baby.titssize = sizes[rand_range(0,sizes.size())]
			baby.asssize = sizes[rand_range(0,sizes.size())]
		baby.away.duration = variables.growuptimeteen
	elif age == 'adult':
		baby.age = 'adult'
		var sizes = ['flat','small','average','big','huge']
		if baby.sex != 'male':
			baby.titssize = sizes[rand_range(0,sizes.size())]
			baby.asssize = sizes[rand_range(0,sizes.size())]
		baby.away.duration = variables.growuptimeadult
	baby.away.at = 'growing'
	baby.obed += 75
	baby.loyal += 20
	if baby.sex != 'male':
		baby.vagvirgin = true
	globals.slaves = baby
	globals.state.relativesdata[baby.id].name = baby.name_long()
	globals.state.relativesdata[baby.id].state = 'normal'
	
	globals.state.babylist.erase(baby)
	baby = null
	get_node("birthpanel").hide()
	get_node("birthpanel/raise/childpanel").hide()





func _on_helpglossary_pressed():
	get_node("tutorialnode").callalise()

#### selfinsepct


func _on_selfbutton_pressed():
	hide_everything()
	get_node("MainScreen/mansion/selfinspect").show()
	get_node("MainScreen/mansion/selfinspect/selflookspanel").hide()
	var text = '[center]Personal Achievements[/center]\n'
	var text2 = ''
	var person = globals.player
	$MainScreen/slave_tab.person = globals.player
	var dict = {
	0: "You do not belong in an Order.",
	1: "Neophyte",
	2: "Apprentice",
	3: "Journeyman",
	4: "Adept",
	5: "Master",
	6: "Grand Archmage"}
	text += 'Combat Abilities: '
	for i in person.ability:
		var ability = globals.abilities.abilitydict[i]
		if ability.learnable == true:
			text2 += ability.name + ', '
	if text2 == '':
		text += 'none. \n'
	else:
		text2 = text2.substr(0, text2.length() -2)+ '. '
	text += text2 + '\nReputation: '
	for i in globals.state.reputation:
		text += i.capitalize() + " - "+ reputationword(globals.state.reputation[i]) + ", "
	text += "\nYour mage order rank: " + dict[int(globals.state.rank)]
	if globals.state.spec != "" && globals.state.spec != null:
		text += "\n\nYour speciality: [color=yellow]" + globals.state.spec + "[/color]\nBonuses: " + globals.playerspecs[globals.state.spec]
	
	get_node("MainScreen/mansion/selfinspect/mainstatlabel").set_bbcode(text)
	updatestats(person)
	if globals.state.mansionupgrades.mansionparlor >= 1:
		$MainScreen/mansion/selfinspect/selftattoo.set_disabled(false)
		$MainScreen/mansion/selfinspect/selfpierce.set_disabled(false)
		$MainScreen/mansion/selfinspect/selftattoo.set_tooltip("")
		$MainScreen/mansion/selfinspect/selfpierce.set_tooltip("")
	else:
		$MainScreen/mansion/selfinspect/selftattoo.set_disabled(true)
		$MainScreen/mansion/selfinspect/selfpierce.set_disabled(true)
		$MainScreen/mansion/selfinspect/selftattoo.set_tooltip("Unlock Beauty Parlor to access Tattoo options. ")
		$MainScreen/mansion/selfinspect/selfpierce.set_tooltip("Unlock Beauty Parlor to access Piercing options. ")
	$MainScreen/mansion/selfinspect/Contraception.pressed = person.effects.has("contraceptive")

func _on_defaultMasterNoun_text_entered(text):
	get_node("MainScreen/mansion/selfinspect/defaultMasterNoun").release_focus()

func _on_defaultMasterNoun_text_changed(text):
	if text == '':
		globals.state.defaultmasternoun = 'Master'
	else:
		globals.state.defaultmasternoun = text

func contraceptiontoggle():
	if $MainScreen/mansion/selfinspect/Contraception.pressed:
		globals.player.add_effect(globals.effectdict.contraceptive)
	else:
		globals.player.add_effect(globals.effectdict.contraceptive, true)

func stattooltip(value):
	var text = globals.statsdescript[value]
	globals.showtooltip(text)

func statup(stat):
	globals.player.stats[globals.basestatdict[stat]] += 1
	globals.player.skillpoints -= 1
	globals.player[stat] += 0
	updatestats(globals.player)

onready var sstr = get_node("MainScreen/mansion/selfinspect/statspanel/sstr")
onready var sagi = get_node("MainScreen/mansion/selfinspect/statspanel/sagi")
onready var smaf = get_node("MainScreen/mansion/selfinspect/statspanel/smaf")
onready var send = get_node("MainScreen/mansion/selfinspect/statspanel/send")

func updatestats(person):
	var text = ''
	for i in ['sstr','sagi','smaf','send']:
		text = str(person[i])
		get(i).get_node('cur').set_text(text)
		if i in ['sstr','sagi','smaf','send']:
			if person.stats[globals.maxstatdict[i].replace("_max",'_mod')] >= 1:
				get(i).get_node('cur').set('custom_colors/font_color', Color(0,1,0))
			elif person.stats[globals.maxstatdict[i].replace("_max",'_mod')] < 0:
				get(i).get_node('cur').set('custom_colors/font_color', Color(1,0.29,0.29))
			else:
				get(i).get_node('cur').set('custom_colors/font_color', Color(1,1,1))
		get(i).get_node('max').set_text(str(min(person.stats[globals.maxstatdict[i]], person.originvalue[person.origins])))
	text = person.name_long() + '\n[color=aqua][url=race]' +person.dictionary('$race[/url][/color]').capitalize() +  '\nLevel : '+str(person.level)
	get_node("MainScreen/mansion/selfinspect/statspanel/info").set_bbcode(person.dictionary(text))
	get_node("MainScreen/mansion/selfinspect/statspanel/attribute").set_text("Free Attribute Points : "+str(person.skillpoints))
	
	for i in ['send','smaf','sstr','sagi']:
		if person.skillpoints >= 1 && (globals.slaves.find(person) >= 0||globals.player == person) && person.stats[globals.maxstatdict[i].replace('_max','_base')] < person.stats[globals.maxstatdict[i]]:
			get_node("MainScreen/mansion/selfinspect/statspanel/" + i +'/Button').visible = true
		else:
			get_node("MainScreen/mansion/selfinspect/statspanel/" + i+'/Button').visible = false
	get_node("MainScreen/mansion/selfinspect/statspanel/hp").set_value((person.stats.health_cur/float(person.stats.health_max))*100)
	get_node("MainScreen/mansion/selfinspect/statspanel/en").set_value((person.stats.energy_cur/float(person.stats.energy_max))*100)
	get_node("MainScreen/mansion/selfinspect/statspanel/xp").set_value(person.xp)
	text = "Health: " + str(person.stats.health_cur) + "/" + str(person.stats.health_max) + "\nEnergy: " + str(person.stats.energy_cur) + "/" + str(person.stats.energy_max) + "\nExperience: " + str(person.xp)
	get_node("MainScreen/mansion/selfinspect/statspanel/hptooltip").set_tooltip(text)
	if person.imageportait != null && globals.loadimage(person.imageportait):
		$MainScreen/mansion/selfinspect/statspanel/TextureRect/portrait.set_texture(globals.loadimage(person.imageportait))
	else:
		person.imageportait = null
		$MainScreen/mansion/selfinspect/statspanel/TextureRect/portrait.set_texture(null)

var gradeimages = {
'slave' : load("res://files/buttons/mainscreen/40.png"),
poor = load("res://files/buttons/mainscreen/41.png"),
commoner = load("res://files/buttons/mainscreen/42.png"),
rich = load("res://files/buttons/mainscreen/43.png"),
noble = load("res://files/buttons/mainscreen/44.png"),
}




func _on_selfinspectclose_pressed():
	get_node("MainScreen/mansion/selfinspect").hide()
	_on_mansion_pressed()


func reputationword(value):
	var text = ""
	if value >= 30:
		text = "[color=green]Great[/color]"
	elif value >= 10:
		text = "[color=green]Positive[/color]"
	elif value <= -10:
		text = "[color=#ff4949]Bad[/color]"
	elif value <= -30:
		text = "[color=#ff4949]Terrible[/color]"
	else:
		text = "Neutral"
	return text


func _on_selfinspectlooks_pressed():
	get_node("MainScreen/mansion/selfinspect/selflookspanel/selfdescript").set_bbcode(globals.player.description())
	get_node("MainScreen/mansion/selfinspect/selflookspanel").show()

func _on_selfskillclose_pressed():
	get_node("MainScreen/mansion/selfinspect/selflookspanel").hide()

func _on_selfabilityupgrade_pressed():
	get_node("MainScreen/mansion/selfinspect/selfabilitypanel/abilitydescript").set_bbcode('')
	get_node("MainScreen/mansion/selfinspect/selfabilitypanel").show()
	get_node("MainScreen/mansion/selfinspect/selfabilitypanel/abilitypurchase").set_disabled(true)
	for i in get_node("MainScreen/mansion/selfinspect/selfabilitypanel/ScrollContainer/VBoxContainer").get_children():
		if i != get_node("MainScreen/mansion/selfinspect/selfabilitypanel/ScrollContainer/VBoxContainer/Button"):
			i.hide()
			i.queue_free()
	for i in globals.abilities.abilitydict.values():
		if i.learnable == true && globals.player.ability.find(i.code) < 0 && (i.has('requiredspell') == false || globals.spelldict[i.requiredspell].learned == true):
			var newbutton = get_node("MainScreen/mansion/selfinspect/selfabilitypanel/ScrollContainer/VBoxContainer/Button").duplicate()
			get_node("MainScreen/mansion/selfinspect/selfabilitypanel/ScrollContainer/VBoxContainer").add_child(newbutton)
			newbutton.show()
			newbutton.set_text(i.name)
			newbutton.connect("pressed",self,'selfabilityselect',[i])


func selfabilityselect(ability):
	var text = ''
	var person = globals.player
	var dict = {'sstr': 'Strength', 'sagi' : 'Agility', 'smaf': 'Magic', 'level': 'Level'}
	var confirmbutton = get_node("MainScreen/mansion/selfinspect/selfabilitypanel/abilitypurchase")
	
	for i in get_node("MainScreen/mansion/selfinspect/selfabilitypanel/ScrollContainer/VBoxContainer").get_children():
		if i.get_text() != ability.name:
			i.set_pressed(false)
	
	confirmbutton.set_disabled(false)
	
	text = '[center]'+ ability.name + '[/center]\n' + ability.description + '\nCooldown:' + str(ability.cooldown) + '\nLearn requirements: '
	
	var array = []
	for i in ability.reqs:
		array.append(i)
	array.sort_custom(self, 'levelfirst')
	
	for i in array:
		var temp = i
		var ref = person
		if i.find('.') >= 0:
			temp = i.split('.')
			for ii in temp:
				ref = ref[ii]
		else:
			ref = person[i]
		if ref < ability.reqs[i]:
			confirmbutton.set_disabled(true)
			text += '[color=#ff4949]'+dict[i] + ': ' + str(ability.reqs[i]) + '[/color], '
		else:
			text += '[color=green]'+dict[i] + ': ' + str(ability.reqs[i]) + '[/color], '
	text = text.substr(0, text.length() - 2) + '.'
	
	confirmbutton.set_meta('abil', ability)
	
	
	
	
	get_node("MainScreen/mansion/selfinspect/selfabilitypanel/abilitydescript").set_bbcode(text)





func _on_abilitypurchase_pressed():
	var abil = get_node("MainScreen/mansion/selfinspect/selfabilitypanel/abilitypurchase").get_meta('abil')
	globals.player.ability.append(abil.code)
	if globals.spelldict.has(abil.code):
		globals.spelldict[abil.code].learned = true
	popup('You have learned ' + abil.name+'. ')
	_on_selfabilityupgrade_pressed()
	_on_selfbutton_pressed()


func _on_selfportait_pressed():
	imageselect("portrait",globals.player)


func _on_abilityclose_pressed():
	get_node("MainScreen/mansion/selfinspect/selfabilitypanel").hide()




var potionselected

func potbuttonpressed(potion):
	potionselected = potion
	var description = get_node("MainScreen/mansion/selfinspect/selectpotionpanel/potionusedescription")
	var potlist = get_node("MainScreen/mansion/selfinspect/selectpotionpanel/ScrollContainer/selectpotionlist")
	for i in get_tree().get_nodes_in_group('usables'):
		if i.get_text() != potion.name && i.is_pressed() == true:
			i.set_pressed(false)
	description.set_bbcode(potion.description + '\n\nIn possession: ' + str(potion.amount))


func _on_potioncancelbutton_pressed():
	get_node("MainScreen/mansion/selfinspect/selectpotionpanel").hide()
	potionselected = ''

func _on_potionusebutton_pressed():
	var person = globals.player
	var itemnode = globals.items
	itemnode.person = person
	if potionselected.code != 'minoruspot' && potionselected.code != 'majoruspot' && potionselected.code != 'hairdye':
		if potionselected.code in ['aphrodisiac', 'regressionpot', 'miscariagepot','amnesiapot','stimulantpot','deterrentpot']:
			popup(person.dictionary(itemnode.call(potionselected.effect)))
			return
		popup(person.dictionary(itemnode.call(potionselected.effect)))
		_on_selfbutton_pressed()
		person.toxicity += potionselected.toxicity
		potionselected.amount -= 1
	else:
		itemnode.call(potionselected.effect)
	get_node("MainScreen/mansion/selfinspect/selectpotionpanel").hide()

var counter = 0
var slavearray = []

func _on_selfrelatives_pressed():
	get_node("MainScreen/mansion/selfinspect/relativespanel").popup()
	var text = ''
	var person = globals.player
	var relativesdata = globals.state.relativesdata
	var entry = relativesdata[person.id]
	var entry2
	counter = 0
	slavearray.clear()
	text += '[center]Parents[/center]\n'
	for i in ['father','mother']:
		if int(entry[i]) <= 0:
			text += i.capitalize() + ": Unknown\n"
		else:
			if relativesdata.has(entry[i]):
				entry2 = relativesdata[entry[i]]
				text += i.capitalize() + ": " + getentrytext(entry2) + "\n"
			else:
				text += i.capitalize() + ": Unknown\n"
	
	if entry.siblings.size() > 0:
		text += '\n[center]Siblings[/center]\n'
		for i in entry.siblings:
			entry2 = relativesdata[i]
			if entry2.state == 'fetus':
				continue
			if entry2.sex == 'male':
				text += "Brother: " 
			else:
				text += "Sister: "
			text += getentrytext(entry2) + "\n"
	
	if entry.children.size() > 0:
		text += '\n[center]Children[/center]\n'
		for i in entry.children:
			entry2 = relativesdata[i]
			if entry2.state == 'fetus':
				continue
			if entry2.sex == 'male':
				text += "Son: " 
			else:
				text += "Daughter: "
			text += getentrytext(entry2) + "\n"
	$MainScreen/mansion/selfinspect/relativespanel/relativestext.set_meta("slaves", slavearray)
	$MainScreen/mansion/selfinspect/relativespanel/relativestext.bbcode_text = text


func getentrytext(entry):
	var text = ''
	if globals.state.findslave(entry.id) != null:
		text += '[url=person' + str(counter) + '][color=yellow]' + entry.name + '[/color][/url]'
		slavearray.append(globals.state.findslave(entry.id))
		counter += 1
	else:
		text += entry.name
	if entry.state == 'dead':
		text += " - Deceased"
	elif entry.state == 'left':
		text += " - Status Unknown"
	text += ", " + entry.race
	return text

func relativeshover(meta):
	var tempslave = slavearray[int(meta.replace('person',''))]
	globals.slavetooltip(tempslave)

func relativesselected(meta):
	var tempslave = slavearray[int(meta.replace('person',''))]
	globals.slavetooltiphide()
	$MainScreen/mansion/selfinspect/relativespanel.visible = false
	globals.openslave(tempslave)
	if tempslave != globals.player:
		globals.main.get_node('MainScreen/slave_tab')._on_relativesbutton_pressed()
	else:
		globals.main._on_selfrelatives_pressed()


func _on_relativesclose_pressed():
	get_node("MainScreen/mansion/selfinspect/relativespanel").hide()





func showracedescript(person):
	var text = globals.dictionary.getRaceDescription(person.race.replace("Beastkin","Halfkin"))
	dialogue(true, self, text)

func showracedescriptsimple(race):
	var text = globals.dictionary.getRaceDescription(race)
	dialogue(true, self, text)

func _on_orderbutton_pressed():
	for i in get_tree().get_nodes_in_group("sortbutton"):
		if get_node("charlistcontrol/orderbutton").is_pressed() == true:
			i.show()
		else:
			i.hide()

####### PORTALS
func _on_portals_pressed():
	if globals.state.calculateweight().overload == true:
		infotext("Your backpack is too heavy to leave", 'red')
		return
	_on_mansion_pressed()
	#if OS.get_name() != 'HTML5':
	yield(self, 'animfinished')
	var list = get_node("MainScreen/mansion/portalspanel/ScrollContainer/VBoxContainer")
	var button = get_node("MainScreen/mansion/portalspanel/ScrollContainer/VBoxContainer/portalbutton")
	get_node("MainScreen/mansion/portalspanel").popup()
	nameportallocation = null
	$MainScreen/mansion/portalspanel/imagelocation.texture = null
	$MainScreen/mansion/portalspanel/imagelocation/RichTextLabel.bbcode_text = 'Select a desired location to travel'
	$MainScreen/mansion/portalspanel/imagelocation/namelocation.text = ''
	$MainScreen/mansion/portalspanel/traveltoportal.disabled = true
	for i in list.get_children():
		if i != button:
			i.hide()
			i.queue_free()
	for i in globals.state.portals.values():
		var newbutton = button.duplicate()
		list.add_child(newbutton)
		if i.code != globals.state.location:
			newbutton.show()
		if i.enabled == true:
			newbutton.disabled = false
			newbutton.set_text(globals.portalnames[i.code])
			newbutton.connect('pressed', self, 'portalbuttonpressed', [newbutton, i])
		else:
			newbutton.set_text('???')
			newbutton.disabled = true
	if globals.state.marklocation != null:
		var newbutton = button.duplicate()
		newbutton.show()
		list.add_child(newbutton)
		newbutton.text = exploration.areas.database[globals.state.marklocation].name
		newbutton.connect('pressed', self, 'portalbuttonpressed', [newbutton, exploration.areas.database[globals.state.marklocation]])


func portalbuttonpressed(newbutton, portal):
	var text
	nameportallocation = portal.code
	$MainScreen/mansion/portalspanel/traveltoportal.disabled = false
	for i in $MainScreen/mansion/portalspanel/ScrollContainer/VBoxContainer.get_children():
		i.pressed = (i== newbutton)
		if i.pressed == true:
			var bg 
			if globals.backgrounds.has(nameportallocation):
				bg = globals.backgrounds[nameportallocation]
			else:
				bg = globals.backgrounds[globals.areas.database[nameportallocation].background]
			get_node("MainScreen/mansion/portalspanel/imagelocation").set_texture(bg)
			get_node("MainScreen/mansion/portalspanel/imagelocation/namelocation").text = newbutton.text+" Portal"
			if newbutton.text == 'Umbra':
				get_node("MainScreen/mansion/portalspanel/imagelocation/RichTextLabel").text = "Portal leads to the "+newbutton.text+" Undergrounds"
			elif globals.backgrounds.has(nameportallocation):
				get_node("MainScreen/mansion/portalspanel/imagelocation/RichTextLabel").text = "Portal leads to the " +newbutton.text + '.'
			else:
				get_node("MainScreen/mansion/portalspanel/imagelocation/RichTextLabel").text = "Portal leads to the city of "+newbutton.text

func _on_traveltoportal_pressed():
	if nameportallocation != null:
		sound("teleport")
		get_node("MainScreen/mansion/portalspanel").hide()
		exploration.lastzone = null
		get_node("explorationnode").call('zoneenter', nameportallocation)
		yield(self, 'animfinished')
		get_node("outside").gooutside()
func _on_portalsclose_pressed():
	get_node("MainScreen/mansion/portalspanel").hide()

########FARM
func _on_farmreturn_pressed():
	get_node("MainScreen/mansion/farmpanel").hide()

func _on_farm_pressed(inputslave = null):
	_on_mansion_pressed()
	yield(self, 'animfinished')
	var manager = inputslave
	var text = ''
	var residentlimit = variables.resident_farm_limit[globals.state.mansionupgrades.farmcapacity]
	for i in globals.slaves:
		if i.work == 'farmmanager':
			manager = i
	if manager != null:
		manager.work = 'farmmanager'
		text = manager.dictionary('Your farm manager is ' + manager.name_long() + '.')
	else:
		text = "[color=yellow]You have no assigned manager. Without manager you won't be able to recieve farm income. [/color]"
	if globals.state.mansionupgrades.farmhatchery > 0:
		text = text + '\n\nYou have ' + str(globals.state.snails) + ' snails.'
		if globals.state.snails == 0:
			text += "\nSearch the woods north of Shaliq."
	var counter = 0
	var list = get_node("MainScreen/mansion/farmpanel/ScrollContainer/VBoxContainer")
	var button = get_node("MainScreen/mansion/farmpanel/ScrollContainer/VBoxContainer/farmbutton")
	for i in list.get_children():
		if i != button && i != get_node("MainScreen/mansion/farmpanel/ScrollContainer/VBoxContainer/farmadd"):
			i.hide()
			i.queue_free()
	for i in globals.slaves:
		if i.sleep == 'farm':
			counter += 1
			var newbutton = button.duplicate()
			newbutton.set_text(i.name_long())
			newbutton.show()
			list.add_child(newbutton)
			newbutton.connect("pressed",self,'farminspect',[i])
	if counter >= residentlimit:
		get_node("MainScreen/mansion/farmpanel/ScrollContainer/VBoxContainer/farmadd").set_disabled(true)
	else:
		get_node("MainScreen/mansion/farmpanel/ScrollContainer/VBoxContainer/farmadd").set_disabled(false)
	if globals.state.mansionupgrades.farmtreatment == 1:
		text += "\n\n[color=green]Your farm won't break down its residents. [/color]"
	else:
		text += "\n\n[color=yellow]Your farm will cause heavy stress to its residents. [/color]"
	text = text + '\n\nYou have ' + str(counter)+ '/' + str(residentlimit) + ' people present in farm. '
	get_node("MainScreen/mansion/farmpanel").show()
	get_node("MainScreen/mansion/farmpanel/farminfo").set_bbcode(text)
	if globals.state.tutorial.farm == false:
		get_node("tutorialnode").farm()

func farminspect(person):
	get_node("MainScreen/mansion/farmpanel/slavefarminsepct").show()
	if person.work == 'cow':
		get_node("MainScreen/mansion/farmpanel/slavefarminsepct/slaveassigntext").set_bbcode(person.dictionary("You walk to the pen with $name. The " +person.race+ " $child is tightly kept here being milked out of $his mind all day long. $His eyes are devoid of sentience barely reacting at your approach."))
	elif person.work == 'hen':
		get_node("MainScreen/mansion/farmpanel/slavefarminsepct/slaveassigntext").set_bbcode(person.dictionary("You walk to the pen with $name. The " +person.race+ " $child is tightly kept here as a hatchery for giant snail, with a sturdy leather harness covering $his body. $His eyes are devoid of sentience barely reacting at your approach. Crouching down next to $him, you can see the swollen curve of $his stomach, stuffed full of the creature's eggs. As you lay a hand on it, you can feel some movement inside - seems like something hatched quite recently and is making its way to be 'born' from $name's well-used hole."))
	selectedfarmslave = person
	get_node("MainScreen/mansion/farmpanel/slavefarminsepct/releasefromfarm").set_meta('slave', person)
	get_node("MainScreen/mansion/farmpanel/slavefarminsepct/sellproduction").set_pressed(person.farmoutcome)


var selectedfarmslave

func _on_addcow_pressed():
	var person = selectedfarmslave
	person.sleep = 'farm'
	person.work = 'cow'
	popup(person.dictionary("You put $name into specially designed pen and hook milking cups onto $his nipples, leaving $him shortly after in the custody of farm."))
	_on_closeslavefarm_pressed()
	_on_farm_pressed()
	rebuild_slave_list()


func _on_addhen_pressed():
	var person = selectedfarmslave
	person.sleep = 'farm'
	person.work = 'hen'
	popup(person.dictionary("You put $name into specially designed pen and fixate $his body, exposing $his orificies to be fully accessible to giant snail, leaving $him shortly after in the custody of farm."))
	_on_closeslavefarm_pressed()
	_on_farm_pressed()
	rebuild_slave_list()


func _on_closeslavefarm_pressed():
	get_node("MainScreen/mansion/farmpanel/slavetofarm").hide()


func _on_farmadd_pressed():
	get_node("MainScreen/mansion/farmpanel/slavetofarm").show()
	selectslavelist(false, 'farmassignpanel')

func farmassignpanel(person):
	selectedfarmslave = person
	if person.lactation == true:
		get_node("MainScreen/mansion/farmpanel/slavetofarm/addcow").set_disabled(false)
		get_node("MainScreen/mansion/farmpanel/slavetofarm/addcow").set_tooltip('')
	else:
		get_node("MainScreen/mansion/farmpanel/slavetofarm/addcow").set_tooltip(person.dictionary('$name is not lactating.'))
		get_node("MainScreen/mansion/farmpanel/slavetofarm/addcow").set_disabled(true)
	var counter = 0
	for i in globals.slaves:
		if i.work == 'hen':
			counter += 1
	if globals.state.mansionupgrades.farmhatchery == 0:
		get_node("MainScreen/mansion/farmpanel/slavetofarm/addhen").set_disabled(true)
		get_node("MainScreen/mansion/farmpanel/slavetofarm/addhen").set_tooltip("You have to unlock Hatchery first.")
	else:
		if counter >= globals.state.snails:
			get_node("MainScreen/mansion/farmpanel/slavetofarm/addhen").set_disabled(true)
			get_node("MainScreen/mansion/farmpanel/slavetofarm/addhen").set_tooltip("You don't have any free snails.")
		else:
			get_node("MainScreen/mansion/farmpanel/slavetofarm/addhen").set_disabled(false)
			get_node("MainScreen/mansion/farmpanel/slavetofarm/addhen").set_tooltip("")
	get_node("MainScreen/mansion/farmpanel/slavetofarm/slaveassigntext").set_bbcode("Selected servant - " + person.name_long()+ '. \nLactation: ' +globals.fastif(person.lactation == true, '[color=green]present[/color]', '[color=#ff4949]not present[/color]')+ '. \nTits size : '+person.titssize)

func _on_releasefromfarm_pressed():
	var person = get_node("MainScreen/mansion/farmpanel/slavefarminsepct/releasefromfarm").get_meta('slave')
	person.work = 'rest'
	person.sleep = 'communal'
	get_node("MainScreen/mansion/farmpanel/slavefarminsepct").hide()
	_on_farm_pressed()
	rebuild_slave_list()

func _on_closeslaveinspect_pressed():
	get_node("MainScreen/mansion/farmpanel/slavefarminsepct").hide()

func _on_sellproduction_pressed():
	selectedfarmslave.farmoutcome = get_node("MainScreen/mansion/farmpanel/slavefarminsepct/sellproduction").is_pressed()

func _on_over_pressed():
	mainmenu()




func _on_endlog_pressed():
	get_node("FinishDayPanel").show()


var nodetocall
var functiontocall


func selectslavelist(prisoners = false, calledfunction = 'popup', targetnode = self, reqs = 'true', player = false, onlyparty = false):
	var array = []
	nodetocall = targetnode
	functiontocall = calledfunction
	for i in $chooseslavepanel/ScrollContainer/chooseslavelist.get_children():
		if i.name != 'Button':
			i.hide()
			i.free()
	if player == true:
		array.append(globals.player)
	for person in globals.slaves:
		globals.currentslave = person
		if person.away.duration != 0:
			continue
		if onlyparty == true && !globals.state.playergroup.has(person.id):
			continue
		if globals.evaluate(reqs) == false:
			continue
		if prisoners == false && person.sleep == 'jail' :
			continue
		array.append(person)
	for person in array:
		var button = $chooseslavepanel/ScrollContainer/chooseslavelist/Button.duplicate()
		button.show()
		button.get_node('Label').text = person.name_long()
		button.connect('mouse_entered', globals, "slavetooltip", [person])
		button.connect('mouse_exited', globals, "slavetooltiphide")
		#button.get_node("slaveinfo").set_bbcode(person.name_long()+', '+person.race+ ', occupation - ' + person.work + ", grade - " + person.origins.capitalize())
		button.connect("pressed", self, "slaveselected", [button])
		button.connect("pressed", self, 'hideslaveselection')
		button.set_meta("slave", person)
		button.get_node("portrait").set_texture(globals.loadimage(person.imageportait))
		$chooseslavepanel/ScrollContainer/chooseslavelist/.add_child(button)
	if array.size() == 0:
		$chooseslavepanel/Label.text = "No characters fit the condition"
	else:
		$chooseslavepanel/Label.text = "Select Character"
	get_node("chooseslavepanel").show()

func slaveselected(button):
	var person = button.get_meta('slave')
	nodetocall.call(functiontocall, person)
	get_node("chooseslavepanel").hide()

func hideslaveselection():
	$chooseslavepanel.hide()
	globals.slavetooltiphide()


func _on_choseslavecancel_pressed():
	$chooseslavepanel.hide()






func _on_startcombat_pressed():
	get_node("outside").gooutside()
	globals.state.backpack.stackables.rope = 3
	get_node("explorationnode").zoneenter(startcombatzone)
	#get_node("combat").start_battle()

func checkplayergroup():
	var removed = []
	var checked = false
	for i in range(0, globals.state.playergroup.size()):
		checked = false
		for ii in globals.slaves:
			if str(ii.id) == str(globals.state.playergroup[i]) && ii.away.duration <= 0 && ii.away.at != 'hidden':
				checked = true
		if checked == false:
			removed.append(i)
	removed.invert()
	for i in removed:
		globals.state.playergroup.remove(i)







func _on_cleanbutton_pressed():
	animationfade()
	yield(self, 'animfinished')
	globals.state.condition = 100
	globals.resources.gold -= min(ceil(globals.resources.day/7.0)*10,100)
	_on_mansionsettings_pressed()
	_on_mansion_pressed()




func _on_defeateddescript_meta_clicked( meta ):
	var person = get_node("explorationnode/winningpanel/defeateddescript").get_meta('slave')
	showracedescript(person)





func _on_selloutclose_pressed():
	get_node("sellout").hide()


func _on_sellouttext_meta_clicked( meta ):
	OS.shell_open('https://www.patreon.com/maverik')




func _on_popupclosebutton_pressed():
	get_node("popupmessage").hide()


func infotext(newtext, color = null):
	if ( (newtext.findn("food") >= 0 || newtext.findn("gold") >= 0) && enddayprocess == true) || newtext == '' || $date.visible || (get_node("combat").visible && !get_node("combat/win").visible): 
		return
	if get_node("infotext").get_children().size() >= 15:
		get_node("infotext").get_child(get_node("infotext").get_children().size() - 14).queue_free()
	var text = newtext
	var label = get_node("infotext/Label").duplicate()
	label.set_text(text)
	label.modulate = Color(1,1,1,1)
	if color == 'red':
		label.set('custom_colors/font_color', Color(1,0.29,0.29))
	elif color == 'green':
		label.set('custom_colors/font_color', Color(0,1,0))
	elif color == 'yellow':
		label.set('custom_colors/font_color', Color(1,1,0))
	var timer = Timer.new()
	timer.set_wait_time(4)
	timer.start()
	timer.connect("timeout", self, 'infotextfade', [label])
	timer.set_name("timer")
	label.add_child(timer)
	$infotext.rect_size = $infotext.rect_min_size
	get_node("infotext").add_child(label)
	label.show()

func infotextfade(label):
	label.add_to_group('messages')
	label.get_node('timer').stop()



func _on_infotextpanel_mouse_enter():
	for i in get_node("infotext").get_children():
		if i != get_node("infotext/Label"):
			i.modulate.a = 1
			if i.is_in_group("messages"):
				i.remove_from_group("messages")


func setname(person):
	var text = person.dictionary("Choose new name for $name")
	get_node("entertext").show()
	get_node("entertext").set_meta("action", "rename")
	get_node("entertext").set_meta("slave", person)
	get_node("entertext/dialoguetext").set_bbcode(text)
	$entertext/confirmentertext.disabled = false

func seteyecolor(person):
	var assist
	for i in globals.slaves:
		if i.work == 'labassist':
			assist = i
			break
	var priceModifier = 1 / (1+assist.wit/200.0)
	var timeCost = 0
	if person == globals.player:
		priceModifier *= 2
	else:
		timeCost = max(round(2/(1+assist.smaf/8.0)),1)
	if person.race == 'Demon':
		priceModifier *= 0.7
	var manaCost = round(40 * priceModifier)
	var goldCost = round(100 * priceModifier)
	var text = person.dictionary("Choose new eye color for $name. \n[color=yellow]Requires ") + str(manaCost) + " Mana, "
	text += str(goldCost) + " Gold, 1 Nature Essence and " + str(timeCost) + " days.[/color]"
	$entertext.show()
	$entertext.set_meta('action', 'eyecolor')
	$entertext.set_meta("slave", person)
	$entertext.set_meta("manaCost", manaCost)
	$entertext.set_meta("goldCost", goldCost)
	$entertext.set_meta("timeCost", timeCost)
	$entertext/LineEdit.text = person.eyecolor
	$entertext/dialoguetext.bbcode_text = text
	if globals.resources.mana < manaCost || globals.resources.gold < goldCost || globals.itemdict.natureessenceing.amount < 1:
		$entertext/confirmentertext.disabled = true
	else:
		$entertext/confirmentertext.disabled = false

func _on_confirmentertext_pressed():
	var text = get_node("entertext/LineEdit").get_text()
	if text == "":
		return
	var person
	var meta = get_node("entertext").get_meta("action")
	if meta == 'rename':
		person = get_node("entertext").get_meta("slave")
		person.name = text
		rebuild_slave_list()
	elif meta == 'eyecolor':
		person = get_node("entertext").get_meta("slave")
		var manaCost = get_node("entertext").get_meta("manaCost")
		var goldCost = get_node("entertext").get_meta("goldCost")
		var timeCost = get_node("entertext").get_meta("timeCost")
		person.eyecolor = text
		if person != globals.player:
			person.away.duration = timeCost
			person.away.at = 'lab'
		globals.resources.gold -= goldCost
		globals.resources.mana -= manaCost
		globals.itemdict.natureessenceing.amount -= 1
		rebuild_slave_list()
		$MainScreen/mansion/labpanel._on_labstart_pressed()
	get_node("entertext").hide()


func _on_cancelentertext_pressed():
	$entertext.hide()

func _on_infotextpanel_mouse_exit():
	for i in get_node("infotext").get_children():
		if i != get_node("infotext/Label"):
			i.modulate.a = 1
			i.add_to_group("messages")

func _on_slavelist_pressed():
	get_node("slavelist").visible = !get_node("slavelist").visible
	slavelist()


func slavelist():
	for i in get_node("slavelist/ScrollContainer/VBoxContainer").get_children():
		if i != get_node("slavelist/ScrollContainer/VBoxContainer/line"):
			i.hide()
			i.queue_free()
	for person in globals.slaves:
		if person.away.duration == 0 && !person.sleep in ['farm']:
			var newline = get_node("slavelist/ScrollContainer/VBoxContainer/line").duplicate()
			newline.show()
			get_node("slavelist/ScrollContainer/VBoxContainer").add_child(newline)
			newline.get_node("line/name/choseslave").connect("pressed",self,'openslave',[person])
			newline.get_node("line/name/Label").set_text(person.name_short())
			newline.get_node("line/grade/Label").set_text(person.origins.capitalize())
			if person.spec != null:
				newline.get_node("line/spec/Label").set_text(person.spec.capitalize())
			else:
				newline.get_node("line/spec/Label").set_text("None")
			newline.get_node("line/phys/Label").set_text("S:" + str(person.sstr) + " A:" + str(person.sagi) + " M:" + str(person.smaf) + " E:"+str(person.send))
			newline.get_node("line/mentals/Label").set_text("R:" + str(person.cour) + " O:" + str(person.conf) + " W:" + str(person.wit) + " H:" + str(person.charm) )
			newline.get_node("line/mentals").set_custom_minimum_size(newline.get_node("line/mentals/Label").get_minimum_size() + Vector2(10,0))
			newline.get_node("line/race/Label").set_text(person.race_short())
			newline.get_node("line/race/Label").set_tooltip(person.race)
			newline.get_node("job").set_text(get_node("MainScreen/slave_tab").jobdict[person.work].name)
			newline.get_node("job").connect("pressed",self,'selectjob',[person])
			if person.sleep == 'jail':
				newline.get_node("job").set_disabled(true)
			newline.get_node("sleep").set_text(globals.sleepdict[person.sleep].name)
			newline.get_node("sleep").set_meta("slave", person)
			newline.get_node("sleep").connect("pressed", self, 'sleeppressed', [newline.get_node("sleep")])
			newline.get_node("sleep").connect("item_selected",self, 'sleepselect', [newline.get_node("sleep")])


func sleeppressed(button):
	var person = button.get_meta('slave')
	var beds = globals.count_sleepers()
	button.clear()
	button.add_item(globals.sleepdict['communal'].name)
	if person.sleep == 'communal':
		button.set_item_disabled(button.get_item_count()-1, true)
		button.select(button.get_item_count()-1)
	button.add_item(globals.sleepdict['jail'].name)
	if beds.jail >= globals.state.mansionupgrades.jailcapacity:
		button.set_item_disabled(button.get_item_count()-1, true)
	if person.sleep == 'jail':
		button.set_item_disabled(button.get_item_count()-1, true)
		button.select(button.get_item_count()-1)
	button.add_item(globals.sleepdict['personal'].name)
	if beds.personal >= globals.state.mansionupgrades.mansionpersonal:
		button.set_item_disabled(button.get_item_count()-1, true)
	if person.sleep == 'personal':
		button.set_item_disabled(button.get_item_count()-1, true)
		button.select(button.get_item_count()-1)
	button.add_item(globals.sleepdict['your'].name)
	if beds.your_bed >= globals.state.mansionupgrades.mansionbed || (person.loyal + person.obed < 130 || person.tags.find('nosex') >= 0):
		button.set_item_disabled(button.get_item_count()-1, true)
	if person.sleep == 'your':
		button.set_item_disabled(button.get_item_count()-1, true)
		button.select(button.get_item_count()-1)

var sleepdict = {0 : 'communal', 1 : 'jail', 2 : 'personal', 3 : 'your'}

func sleepselect(item, button):
	var person = button.get_meta('slave')
	person.sleep = sleepdict[item]
	if person.sleep == 'jail':
		person.work = 'rest'
	rebuild_slave_list()
	slavelist()



func selectjob(person):
	globals.currentslave = person
	joblist()

func openslave(person):
	currentslave = globals.slaves.find(person)
	if get_node("MainScreen/slave_tab").visible:
		get_node("MainScreen/slave_tab").hide()
	get_node("MainScreen/slave_tab").slavetabopen()
	get_node("slavelist").hide()

func joblist():
	get_node("joblist").joblist()

func _on_listclose_pressed():
	get_node("slavelist").hide()




var itemselected
var categoryselected
var inventorymode = 'mainscreen'


func _on_inventory_pressed(mode = 'mainscreen'):
	get_node("inventory").open("mansion")
#
#func itemhovered(button):
#	var item = button.get_meta("item")
#	var pos
#	get_node("inventory/Panel/tooltip/Label").set_text(item.name)
#	get_node("inventory/Panel/tooltip").show()
#	pos = button.get_global_pos()
#	pos.y -= 40
#	pos.x -= 62
#	
#	get_node("inventory/Panel/tooltip").set_global_pos(pos)
#
#func itemunhovered(button):
#	get_node("inventory/Panel/tooltip").hide()



func _on_wiki_pressed():
	OS.shell_open('http://strive4power.wikia.com/wiki/Strive4power_Wiki')





func _on_personal_pressed():
	_on_selfbutton_pressed()



func alisegreet():
	get_node("tutorialnode").show()
	get_node("tutorialnode").alisegreet()


func _on_ugrades_pressed():
	get_node("MainScreen/mansion/upgradespanel").show()

func _on_upgradesclose_pressed():
	get_node("MainScreen/mansion/upgradespanel").hide()

func imageselect(mode = 'portrait', person = globals.currentslave):
	if OS.get_name() != 'HTML5':
		get_node("imageselect").person = person
		get_node("imageselect").mode = mode
		get_node("imageselect").chooseimage()
	else:
		popup("Sorry, this option can't be utilized in HTML5 Version. ")

#Sex & interactions


func _on_sexbutton_pressed():
	sexslaves.clear()
	sexassist.clear()
	sexselect()
	if globals.state.tutorial.interactions == false:
		get_node("tutorialnode").interactions()

var sexarray = ['meet','sex']
var sexmode = 'meet'

func sexselect():
	var newbutton
	get_node("sexselect").show()
	get_node("sexselect/selectbutton").set_text('Mode: ' + sexmode.capitalize())
	for i in sexanimals:
		sexanimals[i] = 0
	$sexselect/managerypanel.visible = sexmode != 'meet' && globals.state.mansionupgrades.mansionkennels > 0
	for i in get_node("sexselect/ScrollContainer1/VBoxContainer").get_children() + get_node("sexselect/ScrollContainer/VBoxContainer").get_children():
		if i.get_name() != 'Button':
			i.hide()
			i.queue_free()
	for i in globals.slaves:
		if sexmode == 'meet':
			if i.away.duration != 0 || i.sleep == 'farm':
				continue
			newbutton = get_node("sexselect/ScrollContainer/VBoxContainer/Button").duplicate()
			get_node("sexselect/ScrollContainer/VBoxContainer").add_child(newbutton)
			newbutton.set_text(i.dictionary('$name'))
			newbutton.show()
			if sexslaves.find(i) >= 0:
				newbutton.set_pressed(true)
			elif sexslaves.size() >= 1:
				newbutton.disabled = true
			newbutton.connect("pressed",self,'selectsexslave',[newbutton, i])
			if i.lastinteractionday == globals.resources.day:
				newbutton.set_disabled(true)
				newbutton.set_tooltip(i.dictionary('You have already interacted with $name today.'))
		elif sexmode == 'sex':
			if i.away.duration != 0 || i.sleep in ['farm']:
				continue
			newbutton = get_node("sexselect/ScrollContainer/VBoxContainer/Button").duplicate()
			get_node("sexselect/ScrollContainer/VBoxContainer").add_child(newbutton)
			newbutton.set_text(i.dictionary('$name'))
			newbutton.show()
			if sexslaves.find(i) >= 0:
				newbutton.set_pressed(true)
			newbutton.connect("pressed",self,'selectsexslave',[newbutton, i])
			if i.consent == false:
				newbutton.set('custom_colors/font_color', Color(1,0.2,0.2))
				newbutton.hint_tooltip = i.dictionary('$name gave you no consent. ')
			if i.lastinteractionday == globals.resources.day:
				newbutton.set_disabled(true)
				newbutton.set_tooltip(i.dictionary('You have already interacted with $name today.'))
#		elif sexmode == 'abuse':
#			if i.away.duration != 0 || i.sleep in ['farm']:
#				continue
#			newbutton = get_node("sexselect/ScrollContainer/VBoxContainer/Button").duplicate()
#			get_node("sexselect/ScrollContainer/VBoxContainer").add_child(newbutton)
#			newbutton.set_text(i.dictionary('$name'))
#			newbutton.show()
#			if sexslaves.find(i) >= 0:
#				newbutton.set_pressed(true)
#			elif sexslaves.size() > 0:
#				newbutton.set_disabled(true)
#			newbutton.connect("pressed",self,'selectsexslave',[newbutton, i])
#			if i.consent == false || sexslaves.find(i) >= 0:
#				continue
#			newbutton = get_node("sexselect/ScrollContainer/VBoxContainer/Button").duplicate()
#			get_node("sexselect/ScrollContainer1/VBoxContainer").add_child(newbutton)
#			newbutton.set_text(i.dictionary('$name'))
#			newbutton.show()
#			if sexassist.find(i) >= 0:
#				newbutton.set_pressed(true)
#			elif sexassist.size() > 0:
#				newbutton.set_disabled(true)
#			newbutton.connect("pressed",self,'selectassist',[newbutton, i])
#			if i.lastinteractionday == globals.resources.day:
#				newbutton.set_disabled(true)
#				newbutton.set_tooltip(i.dictionary('You have already interacted with $name today.'))
	updatedescription()

func animalforsex(node):
	var name = node.name
	match name:
		'dogplus':
			if sexanimals.dog < 3:
				sexanimals.dog += 1
		'dogminus':
			if sexanimals.dog > 0:
				sexanimals.dog -= 1
		'horseplus':
			if sexanimals.horse < 3:
				sexanimals.horse += 1
		'horseminus':
			if sexanimals.horse > 0:
				sexanimals.horse -= 1
	
	updatedescription()

func _on_selectbutton_pressed():
	sexmode = sexarray[sexarray.find(sexmode)+1] if sexarray.size() > sexarray.find(sexmode)+1 else sexarray[0]
	_on_sexbutton_pressed()

var sexslaves = []
var sexassist = []

func selectsexslave(button, person):
	if button.is_pressed():
		sexslaves.append(person)
		if sexassist.find(person) >= 0:
			sexassist.erase(person)
	else:
		sexslaves.erase(person)
	sexselect()

func selectassist(button, person):
	if button.is_pressed():
		sexassist.append(person)
	else:
		sexassist.erase(person)
	sexselect()

func updatedescription():
	var text = ''
	
	if sexmode == 'meet':
		text += "[center][color=yellow]Interact[/color][/center]\nBuild relationship or train your servant:\n"
		for i in sexslaves:
			text += i.dictionary('[color=aqua]$name[/color]') + ". "
	elif sexmode == 'sex':
		if sexslaves.size() <= 1:
			text += "[center][color=yellow]Consensual Sex[/color][/center]"
		elif sexslaves.size() in [2,3]:
			text += "[center][color=yellow]Group sex[/color][/center]"
		else:
			text += "[center][color=yellow]Orgy[/color][/center]"
			text += "\n[color=aqua]Aphrodite's Brew[/color] is required to initialize an orgy. "
		text += "\nConsent is required from participants. \nCurrent participants: "
		for i in sexslaves:
			text += i.dictionary('[color=aqua]$name[/color]') + ", "
		text = text.substr(0, text.length() - 2) + '.'
		for i in sexanimals:
			if sexanimals[i] != 0:
				text += "\n" + i.capitalize() + '(s): ' + str(sexanimals[i])
		text += '\nClick Start to initiate.'
	elif sexmode == 'abuse':
		text += "[center][color=yellow]Rape[/color][/center]"
		text += "\nRequires a target and an optional assistant. Can be initiated with prisoners. \nCurrent target: "
		for i in sexslaves:
			text += i.dictionary('[color=aqua]$name[/color]') + ". "
		text += "\nCurrent assistant: "
		for i in sexassist:
			text += i.dictionary('[color=aqua]$name[/color]') + ". "
		for i in sexanimals:
			if sexanimals[i] != 0:
				text += "\n" + i.capitalize() + '(s): ' + str(sexanimals[i])
		text += '\nClick Start to initiate.'
		get_node("sexselect/startbutton").set_disabled(sexslaves.size() == 1 && sexassist.size() <= 1)
	text += "\n\nNon-sex Interactions left for today: " + str(globals.state.nonsexactions)
	text += "\nSex Interactions left for today: " + str(globals.state.sexactions)
	
	var enablebutton = true
	
	if sexslaves.size() >= 4 && sexmode == 'sex' && globals.itemdict.aphroditebrew.amount < 1:
		enablebutton = false
	elif sexslaves.size() == 0:
		enablebutton = false
	if (sexmode == 'meet' && globals.state.nonsexactions < 1) || (sexmode != 'meet' && globals.state.sexactions < 1):
		enablebutton = false 
	
	$sexselect/startbutton.disabled = !enablebutton
	get_node("sexselect/sextext").set_bbcode(text)


func _on_startbutton_pressed():
	if sexmode == 'meet':
		globals.state.nonsexactions -= 1
	else:
		globals.state.sexactions -= 1
	if globals.state.sidequests.emily == 16:
		var emily = false
		var tisha = false
		for i in sexslaves + sexassist:
			if i.unique == 'Emily':
				emily = true
			elif i.unique == 'Tisha':
				tisha = true
		if emily && tisha:
			globals.state.sidequests.emily = 17
			$sexselect.visible = false
			globals.events.emilytishasex()
			return
	var mode = 'normal'
	if sexslaves.size() >= 4 && sexmode == 'sex':
		globals.itemdict.aphroditebrew.amount -= 1
	animationfade()
	yield(self, 'animfinished')
	get_node("Navigation").hide()
	get_node('MainScreen').hide()
	get_node("charlistcontrol").hide()
	get_node("sexselect").hide()
	if sexmode == 'meet':
		$ResourcePanel.hide()
		$date.initiate(sexslaves[0])
		return
	elif sexmode == 'abuse':
		mode = 'abuse'
		get_node("interactions").startsequence([globals.player] + sexassist, mode, sexslaves, sexanimals)
	else:
		get_node("interactions").startsequence([globals.player] + sexslaves + sexassist, mode, [], sexanimals)
	get_node("interactions").show()

func _on_cancelbutton_pressed():
	get_node("sexselect").hide()




func _on_mansionsettings_pressed():
	get_node("mansionsettings").show()
	var text = ''
	text += "Cleaning can be done by either assigning your persons to the cleaning task or by hiring one time help from city. \n\nCost: "
	text += '[color=yellow]' + str(min(ceil(globals.resources.day/5.0)*10,100)) + '[/color]'
	if globals.resources.gold >= min(ceil(globals.resources.day/5.0)*10,100) && globals.state.condition < 80:
		get_node("mansionsettings/Panel/cleanbutton").set_disabled(false)
	elif globals.state.condition >= 80:
		text += '\n\nYour mansion requires no cleaning.'
		get_node("mansionsettings/Panel/cleanbutton").set_disabled(true)
	else:
		text += "\n\nYou don't have enough gold."
		get_node("mansionsettings/Panel/cleanbutton").set_disabled(true)
	get_node("mansionsettings/Panel/cleaningtext").set_bbcode(text)
	var dict = {'none':0,'kind':1,'strict':2}
	get_node("mansionsettings/Panel/headgirlbehavior").select(dict[globals.state.headgirlbehavior])
	_on_headgirlbehavior_item_selected(dict[globals.state.headgirlbehavior])



func _on_headgirlbehavior_item_selected( ID ):
	var text = ''
	if ID == 0:
		globals.state.headgirlbehavior = 'none'
		text += "Headgirl will not interfere with others' business. "
	if ID == 1:
		globals.state.headgirlbehavior = 'kind'
		text += 'The Headgirl will focus on a kind approach and reduce the stress of others, trying to endrose acceptance of their master. '
	if ID == 2:
		globals.state.headgirlbehavior = 'strict'
		text += "Headgirl will focus on putting other servants in line at the cost of their stress. "
	var headgirl = null
	for i in globals.slaves:
		if i.work == 'headgirl':
			headgirl = i
	if headgirl == null:
		text += "\nCurrently you have no headgirl assigned. "
	else:
		text += headgirl.dictionary("\n$name is your current headgirl. ")
	get_node("mansionsettings/Panel/headgirldescript").set_bbcode(text)
	get_node("mansionsettings/Panel/foodbuy").set_value(globals.state.foodbuy)
	get_node("mansionsettings/Panel/supplykeep").set_value(globals.state.supplykeep)
	get_node("mansionsettings/Panel/supplykeep/supplybuy").set_pressed(globals.state.supplybuy)

func _on_foodbuy_value_changed( value ):
	globals.state.foodbuy = get_node("mansionsettings/Panel/foodbuy").get_value()

func _on_supplykeep_value_changed( value ):
	globals.state.supplykeep = get_node("mansionsettings/Panel/supplykeep").get_value()


func _on_supplybuy_pressed():
	globals.state.supplybuy = get_node("mansionsettings/Panel/supplykeep/supplybuy").is_pressed()

func _on_close_pressed():
	get_node("mansionsettings").hide()

func _on_hideui_pressed():
	$outside.visible = !$outside.visible
	$ResourcePanel.visible = !$ResourcePanel.visible

func _on_selfpierce_pressed():
	$MainScreen/slave_tab.person = globals.player
	$MainScreen/slave_tab._on_piercing_pressed()

func _on_selftattoo_pressed():
	$MainScreen/slave_tab.person = globals.player
	$MainScreen/slave_tab._on_tattoo_pressed()


#Tweens

func tweenanimate(node, name):
	var pos = node.rect_position
	var tweennode
	if node.has_node('tween') == false:
		tweennode = tween.duplicate()
		tweennode.repeat = false
		tweennode.name = 'tween'
		node.add_child(tweennode)
	else:
		tweennode = node.get_node("tween")
	
	
	

func repeattweenanimate(node, name):
	var pos = node.rect_position
	var tweennode
	if node.has_node('reptween') == false:
		tweennode = tween.duplicate()
		tweennode.remove_all()
		tweennode.repeat = true
		tweennode.name = 'reptween'
		node.add_child(tweennode)
	else:
		tweennode = node.get_node("reptween")
	if name == 'stop':
		tweennode.seek(0)
		tweennode.set_active(false)
	elif name == 'fairy':
		if tweennode.get_runtime() == 0:
			var change = 30
			tweennode.interpolate_property(node, "rect_position", pos, Vector2(pos.x, pos.y-change), 2.5, Tween.TRANS_SINE, Tween.EASE_OUT)
			tweennode.interpolate_property(node, "rect_position", Vector2(pos.x, pos.y-change), pos, 2.5, Tween.TRANS_SINE, Tween.EASE_OUT, 2.5)
		tweennode.start()

func nodeunfade(node, duration = 0.4, delay = 0):
	tween.interpolate_property(node, 'modulate', Color(1,1,1,0), Color(1,1,1,1), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	tween.start()

func nodefade(node, duration = 0.4, delay = 0):
	tween.interpolate_property(node, 'modulate', Color(1,1,1,1), Color(1,1,1,0), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	tween.start()

var traitaction = '' 

func traitpanelshow(person, effect):
	$traitselect.show()# = true
	traitaction = effect
	var text = ''
	var array = []
	var timeCost = 0
	var manaCost = 0
	var goldCost = 0
	for i in $traitselect/Container/VBoxContainer.get_children():
		if i.name != 'Button':
			i.hide()
			i.queue_free()
	if effect == 'clearmental':
		text += person.dictionary("Select mental trait to remove from $name.")
	elif effect == 'clearphys':
		var assist
		for i in globals.slaves:
			if i.work == 'labassist':
				assist = i
				break
		var priceModifier = 1 / (1+assist.wit/200.0)
		if person == globals.player:
			priceModifier *= 2
		else:
			timeCost = max(round(3/(1+assist.smaf/8.0)),1)
		if person.race == 'Demon':
			priceModifier *= 0.7
		manaCost = round(50 * priceModifier)
		goldCost = round(100 * priceModifier)
		text += person.dictionary("Select physical trait to remove from $name. Requires 1 [color=yellow]Clarity Potion[/color], ") + str(manaCost) + " mana, " + str(goldCost) +" gold, and " + str(timeCost) + " days."
	for i in person.traits:
		var trait = globals.origins.trait(i)
		if effect == 'clearmental':
			if trait.tags.has('mental'):
				array.append(trait)
		elif effect == 'clearphys':
			if globals.itemdict.claritypot.amount < 1 || globals.resources.gold < goldCost || globals.resources.mana < manaCost || trait.tags.has('physical') == false:
				continue
			else:
				array.append(trait)
	for i in array:
		var newnode = $traitselect/Container/VBoxContainer/Button.duplicate()
		$traitselect/Container/VBoxContainer.add_child(newnode)
		newnode.show()
		newnode.text = i.name
		newnode.connect("mouse_entered", globals, 'showtooltip', [person.dictionary(i.description)])
		newnode.connect("mouse_exited", globals, 'hidetooltip')
		newnode.connect("pressed", self, 'traitselect', [person, i, manaCost, goldCost, timeCost])
	$traitselect/RichTextLabel.bbcode_text = text

func traitselect(person, i, manaCost, goldCost, timeCost):
	person.trait_remove(i.name)
	$traitselect.hide()
	globals.hidetooltip()
	if traitaction == 'clearmental':
		globals.state.removeStackableItem('claritypot', 1, $inventory.state)
		$inventory.updateitems()
	elif traitaction == 'clearphys':
		globals.itemdict.claritypot.amount -= 1
		if person != globals.player:
			person.away.duration = timeCost
			person.away.at = 'lab'
		globals.resources.gold -= goldCost
		globals.resources.mana -= manaCost
		rebuild_slave_list()
		$MainScreen/mansion/labpanel._on_labstart_pressed()



func _on_traitselectclose_pressed():
	$traitselect.hide()


func _on_selfgear_pressed():
	globals.main._on_inventory_pressed()
	globals.main.get_node('inventory').selectcategory(globals.main.get_node('inventory/everything'))
	globals.main.get_node('inventory/gear').pressed = true
	globals.main.get_node('inventory').selectcategory(globals.main.get_node('inventory/gear'))
	globals.main.get_node('inventory').selectbuttonslave(globals.player)
