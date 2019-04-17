
extends Control

onready var mansion = get_parent()

var progress = 0.0
var enemygroup = {}
var defeated = {units = {}}
var inencounter = false
var currentzone
var lastzone
#warning-ignore:unused_class_variable
var awareness = 0
var ambush = false
var scout
var launchonwin = null
var combatdata = globals.combatdata
var deeperregion = false
var capturedtojail = 0
var enemyloot = {stackables = {}, unstackables = []}
var enemygear = {}
var areas = globals.areas

var scriptedareas = {
	aydashop = load("res://files/scripts/areascripts/aydashop.gd").new(),
	
}

var enemygrouppools = combatdata.enemygrouppools
var capturespool = combatdata.capturespool
var enemypool = combatdata.enemypool


var zones = areas.database

var buttoncontainer
var button
var newbutton
var main
var outside
#warning-ignore:unused_class_variable
var minimap

func mansionreturn():
	main._on_mansion_pressed()

func event(eventname):
	globals.events.call(eventname)

func zoneenter(zone):
	var text = ''
	var endofarea = false
	if lastzone == null:
		lastzone = zones[zone].code
	else:
		lastzone = currentzone.code
	zone = self.zones[zone]
	outside.location = zone.code
	if zone.combat == false:
		progress = 0
	if progress == 0:
		main.background_set(zone.background, true)
		yield(main, "animfinished")
	enemyinfoclear()
	if globals.state.playergroup.size() > 0:
		for i in globals.state.playergroup:
			var scouttemp = globals.state.findslave(i)
			var scoutawareness = 0
			if scouttemp == null:
				globals.state.playergroup.erase(i)
			else:
				if scouttemp.awareness() > scoutawareness:
					scout = scouttemp
					scoutawareness = scout.awareness()
	else:
		scout = globals.player
	main.checkplayergroup()
	outside.playergrouppanel()
	text = zone.name
	if deeperregion:
		text = "+" + text + "+"
	outside.get_node('locationname').set_text(text)
	main.nodeunfade(outside.get_node("locationname"), 0.5)
	text = ''
	var progressvalue = (progress/max(zone.length,1))*100
	var progressbar = globals.get_tree().get_current_scene().get_node("outside/exploreprogress")
	if progress != 0:
		get_parent().tween.interpolate_property(progressbar, "value", progressbar.value, progressvalue, 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	else:
		progressbar.set_value(progressvalue)
	currentzone = zone
	outside.currentzone = zone
	outside.clearbuttons()
	showmap(currentzone)
	text += zone.description
	if globals.state.marklocation == zone.code:
		text += "\n\n[color=aqua]You have a mark in this area[/color]"
	if zone.code in ['wimborn','gorn','amberguard','frostford']:
		text += "\n\n[color=yellow]You can use public teleport to return to mansion from this location.[/color]"
	mansion.maintext = text
	if zone.combat == false:
		call(zone.locationscript)
		return
	else:
		main.music_set(zone.music)
#		if zone.code in ['mountaincave','undercitytunnels','undercityruins','undercityhall','redcave','darkness','culthideout','cavelake']:
#			main.music_set('dungeon')
#		else:
#			main.music_set('explore')
	var array = []
	if zone.combat == true && progress >= zone.length:
		for i in zone.exits:
			var temp = self.zones[i]
			if globals.evaluate(temp.reqs) == true:
				array.append({name = 'Move to ' + temp.name, function = 'zoneenter', args = temp.code})
		if globals.state.backpack.stackables.has('supply') && globals.state.backpack.stackables.supply >= 3 && globals.state.playergroup.size()*5+5 <= globals.resources.food:
			array.append({name = "Rest and eat", function = 'rest', tooltip = 'Requires 3 units of supplies (in total) and 5 food per party member'})
		else:
			array.append({name = "Rest and eat", function = 'rest', disabled = true, tooltip = 'Requires 3 units of supplies (in total) and 5 food per party member'})
		if globals.state.restday == globals.resources.day:
			array[array.size()-1].disabled = true
			array[array.size()-1].tooltip = 'Can only be done once per day'
		progress = 0
		endofarea = true
		if deeperregion == false:
			array.insert(0,{name = 'Move deeper into the region', function = 'deepzone', args = currentzone.code})
			array.insert(0,{name = 'Explore this area again', function = 'zoneenter', args = currentzone.code})
		else:
			array.insert(0,{name = 'Return to the central region', function = 'zoneenter', args = currentzone.code})
			array.insert(0,{name = 'Stay in the deeper region', function = 'deepzone', args = currentzone.code})
		deeperregion = false
		outside.buildbuttons(array, self)
	else:
		inencounter = false
		array.append({name = "Proceed through area", function = 'enemyencounter'})
		if globals.developmode == true:
			array.append({name = "Skip", function = 'areaskip'})
	
	if globals.state.sidequests.cali == 19 && zone.code == 'forest':
		array.append({name = "Look for bandits' camp", function = 'event',args = 'calibanditcamp'})
	elif (globals.state.sidequests.cali == 23 || globals.state.sidequests.cali == 24) && zone.code == 'wimbornoutskirts':
		array.append({name = "Visit slaver's camp", function = 'event',args = 'calislavercamp'})
	elif (globals.state.sidequests.cali == 25) && zone.code == 'wimbornoutskirts':
		array.append({name = "Find the Bandit",function = 'event',args = 'calistraybandit'})
	elif (globals.state.sidequests.cali == 26) && zone.code == 'grove':
		array.append({name = "Find Cali's village",function = 'event',args = 'calireturnhome'})
	elif zone.code == 'dragonnests' && endofarea && globals.state.decisions.has('dragonkilled') == false:
		array.append({name = "Approach Cave Entrance", function = 'event',args = 'dragonbossenc'})
	elif zone.code == 'culthideout' && endofarea && globals.state.decisions.has('cultbosskilled') == false:
		array.append({name = "Approach Central Hall", function = 'event',args = 'cultbossenc'})
	elif zone.code == 'darkness' && endofarea && globals.state.decisions.has('darknessbosskilled') == false:
		array.append({name = "Approach Bright Passage", function = 'event',args = 'finalbossenc'})
	if globals.state.mainquest == 13 && zone.code == 'gornoutskirts':
		array.append({name = "Search for Ivran's location",function = 'event',args = 'gornivran'})
	if zone.code == 'undercitytunnels' && progress >= 6 && globals.state.lorefound.find('amberguardlog1') < 0:
		globals.state.lorefound.append('amberguardlog1')
		mansion.maintext = mansion.maintext + "[color=yellow]\n\nYou've found some old writings in the ruins. Does not look like what you came for, but you can read them later.[/color]"
	if zone.code == 'undercityruins' && progress >= 5 && globals.state.lorefound.find('amberguardlog2') < 0:
		globals.state.lorefound.append('amberguardlog2')
		mansion.maintext = mansion.maintext + "[color=yellow]\n\nYou've found some old writings in the ruins. Does not look like what you came for, but you can read them later.[/color]"
	if zone.code == 'frostfordoutskirts' && globals.state.mainquest in [27,30,32] && progress >= 5:
		array.append({name = "Explore hunting grounds to South-East", function = 'event', args = 'frostforddryad'})
	if zone.code == 'frostfordoutskirts' && globals.state.sidequests.zoe == 1 && progress >= 3:
		globals.state.sidequests.zoe = 2
		main.dialogue(true, self, globals.questtext.MainQuestFrostfordBeforeForestZoe, [], [['zoehappy','pos1','opac']])
	if zone.code == 'mountaincave' && globals.state.mainquest == 39:
		array.append({name = "Search for Ayda's location",function = 'event',args = 'mountainelfcamp'})
	if zone.code == 'mountains' && globals.state.mainquest == 40 && globals.state.decisions.has("goodroute"):
		event('garthorencounter')
	if zone.code == 'gornoutskirts' && globals.state.mainquest == 40 && globals.state.decisions.has("badroute"):
		event('davidencounter')
	if zone.code == 'cavelake' && !globals.state.decisions.has("cultbosskilled") && endofarea:
		event('cavelakedoor')
	if progress == 0 && lastzone != zone.code && globals.evaluate(zones[lastzone].reqs) == true && lastzone != 'umbra':
		array.append({name = "Return to " + zones[lastzone].name, function = "zoneenter", args = lastzone})
	if zone.code == 'dragonnests' && progress == 0:
		array.append({name = "Return to Mansion",function = 'mansion'})
	outside.buildbuttons(array, self)

func showmap(currentzone):
	var map = currentzone.code
	main.minimap.mapshowup(map)

func teleportmansion():
	globals.resources.gold -= 25
	globals.main.sound("teleport")
	mansionreturn()

func deepzone(currentzonecode):
	deeperregion = true
	zoneenter(currentzonecode)


func rest():
	globals.state.backpack.stackables.supply -= 3
	globals.player.health += globals.player.stats.health_max/4
	globals.player.energy += globals.player.stats.energy_max
	globals.resources.food -= 5
	for i in globals.state.playergroup:
		var person = globals.state.findslave(i)
		person.health += person.stats.health_max/4
		person.energy += person.stats.energy_max
		person.stress -= person.stress/1.5
		globals.resources.food -= 5
	outside.playergrouppanel()
	progress = currentzone.length
	globals.state.restday = globals.resources.day
	zoneenter(currentzone.code)
	get_parent().popup("You set up a small camp and take a rest with your party. ")

func frostfordclearing():
	event('frostforddryad')



func areaskip():
	progress = currentzone.length
	zoneenter(currentzone.code)

func calculateawareness():
	
	var scouttemp
	var scoutawareness = -1
	if globals.state.playergroup.size() > 0:
		for i in globals.state.playergroup:
			if globals.state.findslave(i) == null:
				globals.state.playergroup.erase(i)
				continue
			scouttemp = globals.state.findslave(i)
			if scouttemp.awareness() > scoutawareness:
				scout = scouttemp
				scoutawareness = scout.awareness()
	else:
		scout = globals.player
		scoutawareness = scout.awareness()
	return scoutawareness

func enemyencounter():
	var enc
	var encmoveto
	var scoutawareness = -1
	var patrol = 'none'
	var text = ''
#warning-ignore:unused_variable
	var enemyawareness
	enemygear.clear()
	enemygroup.clear()
	inencounter = true
	outside.clearbuttons()
	scoutawareness = calculateawareness()
	if currentzone.encounters.size() > 0:
		for i in currentzone.encounters:
			enc = i[0]
			var condition = i[1]
			var chance = i[2]
			if globals.evaluate(condition) == true && rand_range(0,100) < chance:
				encmoveto = enc
				break
	if encmoveto != null:
		call(enc)
		return
	else:
		for i in currentzone.tags:
			if i in ['wimborn','frostford','gorn','amberguard'] && globals.state.reputation[i] <= -10 && max(10, min(abs(globals.state.reputation[i])/1.2,30)) - scoutawareness/2 > rand_range(0,100):
				if globals.state.reputation[i] <= -25 && rand_range(0,10) > 3:
					buildenemies(i+'guardsmany')
					patrol = 'patrolbig'
					break
				elif globals.state.reputation[i] <= -10:
					buildenemies(i+'guards')
					patrol = 'patrolsmall'
					break
		if enemygroup.empty() == true:
			buildenemies()
#		for i in enemygroup.units:
#			if i.capture == true:
#				buildslave(i)
		if enemygroup.captured != null:
			var group = enemygroup.captured
			enemygroup.captured = []
			for i in group:
				enemygroup.captured.append(buildslave(capturespool[i]))
	enemyawareness = enemygroup.awareness
	if deeperregion == true:
		enemyawareness *= 1.25
	if patrol != 'none':
		text = encounterdictionary(enemygroup.description) + "Your bad reputation around here will certainly lead to a difficult fight..."
		encounterbuttons(patrol)
	elif scoutawareness < enemygroup.awareness:
		ambush = true
		text = encounterdictionary(enemygroup.descriptionambush)
		if enemygroup.special == null:
			encounterbuttons()
		else:
			call(enemygroup.specialambush)
			return
	else:
		ambush = false
		text = encounterdictionary(enemygroup.description)
		if enemygroup.special == null:
			encounterbuttons()
		else:
			call(enemygroup.special)
			return
	mansion.maintext = text
	enemyinfo()

func buildslave(i):
	var race = ''
	var sex = ''
	var age = ''
	var origins = ''
#warning-ignore:unused_variable
	var rand = 0
	if currentzone != null && currentzone.has('races') == false:
		currentzone.races = [['Human', 1]]
	if i.capturerace.find('area') >= 0:
		race = globals.weightedrandom(currentzone.races)
	elif i.capturerace.find('any') >= 0:
		race = globals.allracesarray[rand_range(0,globals.allracesarray.size())]
	elif i.capturerace.find('bandits') >= 0:
		if randf() <= variables.banditishumanchance/100:
			race = 'Human'
		else:
			
			race = globals.getracebygroup('bandits') #globals.banditraces[rand_range(0,globals.banditraces.size())]
	else:
		race = globals.weightedrandom(i.capturerace)
	race = globals.checkfurryrace(race)
	
	
	
	if i.capturesex.find('any') >= 0:
		sex = 'random'
	else:
		sex = globals.weightedrandom(i.capturesex)
	age = globals.weightedrandom(i.captureagepool)
	origins = globals.weightedrandom(i.captureoriginspool)
	if deeperregion == true && globals.originsarray.find(origins) < 4 && randf() > 0.3:
		origins = globals.originsarray[globals.originsarray.find(origins)+1]
	var slavetemp = globals.newslave(race, age, sex, origins)
	enemylevelup(slavetemp, currentzone.levelrange)
	
	slavetemp.health = slavetemp.stats.health_max
	i.capture = slavetemp
	
	if i.has('gear'):
		var gear = {}
		for k in ['armor','weapon','costume','underwear','accessory']:
			if k == 'armor' && globals.player.level < 2:
				continue
			if !combatdata.enemyequips[i.gear].has(k):
				continue
			gear[k] = globals.weightedrandom(combatdata.enemyequips[i.gear][k])
			if gear[k] == 'nothing':
				continue
			var enchant = false
			var item
			if gear[k].find("+") >= 0:
				enchant = true
				gear[k] = gear[k].replace("+","")
			item = globals.items.createunstackable(gear[k])
			if enchant:
				globals.items.enchantrand(item)
			enemygear[item.id] = item
			globals.items.equipitem(item.id, slavetemp, true)
		slavetemp.health = slavetemp.stats.health_max
	return slavetemp

func enemyinfo():
	var text = ''
	if enemygroup.units.size() <= 3:
		text = "Number: " + str(enemygroup.units.size())
	else:
		text += "Estimate number: " + str(max(round(enemygroup.units.size() + rand_range(-2,2)),1))
	if enemygroup.units[0].capture != null:
		text += "\nEstimated level: " + str(enemygroup.units[0].capture.level)
	else:
		text += "\nEstimated level: " + str(max(1,enemygroup.units[0].level + round(rand_range(-1,1))))
	text += '\nGroup: ' + enemygroup.units[0].faction
	if enemygroup.captured != null && enemygroup.captured.size() >= 1:
		text += "\n\nHave other persons involved. "
	outside.get_node("textpanelexplore/enemyportrait").set_texture(enemygroup.units[0].icon)
	outside.get_node("textpanelexplore/enemyinfo").set_bbcode(text)

func enemyinfoclear():
	outside.get_node("textpanelexplore/enemyportrait").set_texture(null)
	outside.get_node("textpanelexplore/enemyinfo").set_bbcode('')

func enemylevelup(person, levelarray):
	var level = levelarray[randi()%levelarray.size()]
	var statdict = ['sstr','sagi','smaf','send']
	person.skillpoints = 0
	person.level = level
	var skillpoints = 2+(level-1)*variables.skillpointsperlevel
	while skillpoints > 0 && statdict.size() > 0:
		if randf() <= 0.2:
			person.skillpoints += 1
			skillpoints -= 1
			continue
		var tempstat = statdict[randi()%statdict.size()]
		if person.stats[globals.maxstatdict[tempstat].replace('_max',"_base")] >= person.stats[globals.maxstatdict[tempstat]]:
			statdict.erase(tempstat)
			continue
		person.stats[globals.maxstatdict[tempstat].replace('_max',"_base")] += 1
		skillpoints -= 1
	person.health = person.stats.health_max

func buildenemies(enemyname = null):
	if enemyname == null:
		enemygroup = enemygrouppools[globals.weightedrandom(currentzone.enemies)].duplicate()
	else:
		enemygroup = enemygrouppools[enemyname].duplicate()
	var tempunits = enemygroup.units.duplicate()
	var unitcounter = {}
	enemygroup.units = []
	var addnumbers
	for i in tempunits:
		addnumbers = false
		var count = round(rand_range(i[1], i[2]))
		if deeperregion:
			count = round(count * rand_range(1.2,1.6))
		if count >= 2:
			addnumbers = true
		while count >= 1:
			var newunit = enemypool[i[0]].duplicate()
			if unitcounter.has(newunit.name) == false:
				unitcounter[newunit.name] = 1
			else:
				unitcounter[newunit.name] += 1
			if addnumbers:
				newunit.name = newunit.name + " " + str(unitcounter[newunit.name])
			enemygroup.units.append(newunit)
			count -= 1
	for i in enemygroup.units:
		if i.capture == true:
			buildslave(i)


func encounterbuttons(state = null):
	var array = []
	if state == null:
		if ambush == false:
			array.append({name = "Attack",function = "enemyfight"})
			array.append({name = "Leave", function = "enemyleave"})
		else:
			array.append({name = "Fight",function = "enemyfight"})
	elif state in ['patrolsmall', 'patrolbig']:
		array.append({name = "Fight",function = "enemyfight"})
		var dict = {}
		if state == 'patrolsmall':
			dict = {name = "Bribe with 100 gold", args = 100, function = 'patrolbribe'}
			if globals.resources.gold < 100 :
				dict.disabled = true
		elif state == 'patrolbig':
			dict = {name = "Bribe with 300 gold", args = 300, function = 'patrolbribe'}
			if globals.resources.gold < 300 :
				dict.disabled = true
		array.append(dict)
	outside.buildbuttons(array, self)

func patrolbribe(sum):
	var array = []
	globals.resources.gold -= sum
	array.append({name = "Leave", function = "enemyleave"})
	mansion.maintext = "You bribe Patrol's leader and hastily escape from the scene. "
	outside.buildbuttons(array, self)


##############


var treasuremisc = [['magicessenceing',7],['taintedessenceing',7],['natureessenceing',7],['bestialessenceing',7],['fluidsubstanceing',7],['gem',1],['claritypot',0.5],['regressionpot',1],['youthingpot',2],['maturingpot',2]]

var chestloot = {
	easy = ['armorleather','armorchain','weapondagger','weaponsword','clothsundress','clothmaid','clothbutler'],
	medium = ['armorchain','weaponsword','clothsundress','clothmaid','clothbutler', 'armorelvenchain','armorrobe', 'weaponhammer','weaponclaymore','clothkimono','clothpet','clothmiko','clothbedlah','accgoldring','accslavecollar','acchandcuffs','acctravelbag'],
	hard = ['armorplate','accamuletemerald','accamuletruby'],
}



var chest = {strength = 0, agility = 0, treasure = {}, trap = ''}
#warning-ignore:unused_class_variable
var selectedpartymember = null
var chestaction = ''

func getchestlevel():
	var level = rand_range(currentzone.levelrange[0], currentzone.levelrange[1])
	if level < 5:
		level = 'easy'
		chest.strength = round(rand_range(1,3))
		chest.agility = round(rand_range(1,3))
	elif level < 10:
		level = 'medium'
		chest.strength = round(rand_range(3,5))
		chest.agility = round(rand_range(3,5))
	else:
		level = 'hard'
		chest.strength = round(rand_range(5,8))
		chest.agility = round(rand_range(5,8))
	return level

func treasurechest():
	var level = getchestlevel()
	treasurechestgenerate(level)
	var text = "You found a hidden [color=yellow]chest[/color]. However, it seems to be locked and is too heavy to carry with you. "
	treasurechestoptions(text)
	text = "Chest\nDifficulty level: [color=aqua]" + level.capitalize() + '[/color]\n\nStrength : ' + str(chest.strength) + '\nComplexity: ' + str(chest.agility)
	outside.get_node("textpanelexplore/enemyportrait").set_texture(load("res://files/buttons/chest.png"))
	outside.get_node("textpanelexplore/enemyinfo").set_bbcode(text)


func chestselectslave(action):
	chestaction = action
	var reqs = ''
	var text = ''
	if chestaction == 'chestlockpick':
		reqs = 'person.energy >= 5'
		text = 'Lock difficulty: ' + str(chest.agility)
	else:
		reqs = 'person.energy >= 20'
		text = 'Lock strength: ' + str(chest.strength)
	outside.chosepartymember(true, [self,chestaction], reqs, text)#func chosepartymember(includeplayer = true, targetfunc = [null,null], reqs = 'true'):


func treasurechestoptions(text = ''):
	var array = []
	mansion.maintext = text
	array.append({name = 'Use a lockpick (5 energy)', function = 'chestselectslave', args = 'chestlockpick'})
	if !globals.state.backpack.stackables.has("lockpick"):
		array.back().disabled = true
	array.append({name = 'Crack it open (20 energy)', function = 'chestselectslave', args = 'chestbash'})
	array.append({name = "Leave", function = 'enemyleave'})
	outside.buildbuttons(array, self)



func treasurechestgenerate(level = 'easy'):
	var gear = {number = 0, enchantchance = 0 }
	var misc = 0
#warning-ignore:unused_variable
	var text
	var miscnumber = 1
	if level == 'easy':
		gear.number = round(rand_range(1,2))
		gear.enchantchance = 45
		misc = round(rand_range(0,1))
		miscnumber = [1,2]
	elif level == 'medium':
		gear.number = round(rand_range(1,4))
		gear.enchantchance = 55
		misc = round(rand_range(0,2))
		miscnumber = [1,3]
	elif level == 'hard':
		gear.number = round(rand_range(2,4))
		gear.enchantchance = 65
		misc = round(rand_range(1,3))
		miscnumber = [1,4]
	var gearpool = chestloot[level]
	if level == 'hard':
		gearpool = chestloot.medium+chestloot.hard
	winscreenclear()
	generaterandomloot(gearpool, gear, misc, miscnumber)

func chestlockpick(person):
	var unlock = false
	var text = ''
	person.energy -= 5
	globals.state.backpack.stackables.lockpick -= 1
	if person.sagi >= chest.agility:
		unlock = true
		text = "$name skillfully picks the lock on the chest."
	else:
		if 60 - (chest.agility - person.sagi) * 10 >= rand_range(0,100):
			text = "With some luck, $name manages to pick the lock on the chest. "
			unlock = true
		else:
			text = "$name fails to pick the lock and breaks the lockpick. "
			unlock = false
	
	text = person.dictionary(text)
	if unlock == false:
		treasurechestoptions(text)
	else:
		showlootscreen(text)

func chestbash(person):
	var unlock = false
	var text = ''
	person.energy -= 20
	if person.sstr >= chest.strength:
		unlock = true
		text = "$name easily smashes the chest's lock mechanism."
	else:
		if 60 - (chest.agility - person.sagi) * 10 >= rand_range(0,100):
			text = "With some luck, $name manages to crack the chest open. "
			unlock = true
		else:
			text = "[color=yellow]$name seems to be too weak to break the chest open. [/color]"
			unlock = false
	
	text = person.dictionary(text)
	if unlock == false:
		treasurechestoptions(text)
	else:
		showlootscreen(text)





###################

func blockedsection():
	var array = []
	
	mansion.maintext = "You found a hidden [color=yellow]section[/color] covered in thick roots. "
	if globals.state.backpack.stackables.has("torch"):
		array.append({name = "Use a torch", function = 'blockedsectionopen'})
	else:
		array.append({name = "Use a torch", function = 'blockedsectionopen', tooltip = 'You have no torches with you',disabled = true})
	
	array.append({name = "Leave", function = 'enemyleave'})
	outside.buildbuttons(array, self)

func blockedsectionopen():
	var gear = {number = round(randf()*3), enchantchance = 75 }
	var misc = rand_range(1,4)
	var text
	var miscnumber = [1,3]
	var loottable = chestloot.medium
	globals.state.backpack.stackables.torch -= 1
	text = "After roots burn down you discover a hidden stash."
	if gear.number == 0:
		gear.number = 1
	winscreenclear()
	generaterandomloot(loottable, gear, misc, miscnumber)
	showlootscreen(text)

#warning-ignore:unused_argument
func generateloot(loot = [], text = ''):
	var winpanel = get_node("winningpanel")
	var tempitem
	var enchant
	for i in winpanel.get_node("ScrollContainer/VBoxContainer").get_children():
		if i != winpanel.get_node("ScrollContainer/VBoxContainer/Button"):
			i.visible = false
			i.free()
	enchant = false
	var item = loot[0]
	if item.findn('+') >= 0:
		enchant = true
		item = item.replace("+","")
	if globals.itemdict[item].type == 'gear':
		var counter = loot[1]
		while counter > 0:
			tempitem = globals.items.createunstackable(item)
			if enchant:
				globals.items.enchantrand(tempitem)
			enemyloot.unstackables.append(tempitem)
			counter -= 1
	else:
		enemyloot.stackables[loot[0]] = loot[1]
	
	showlootscreen()

#warning-ignore:unused_argument
func generaterandomloot(loottable = [], gear = {number = 0, enchantchance = 0}, misc = 0, miscnumber = [0,0]):
	var tempitem
	while gear.number > 0:
		gear.number -= 1
		tempitem = globals.items.createunstackable(loottable[randi()%loottable.size()])
		if randf() <= float(gear.enchantchance)/100:
			globals.items.enchantrand(tempitem)
		enemyloot.unstackables.append(tempitem)
	while misc > 0:
		misc -= 1
		tempitem = globals.weightedrandom(treasuremisc)
		if enemyloot.stackables.has(tempitem):
			enemyloot.stackables[tempitem] += round(rand_range(miscnumber[0], miscnumber[1]))
		else:
			enemyloot.stackables[tempitem] = round(rand_range(miscnumber[0], miscnumber[1]))
	
	#showlootscreen()

func showlootscreen(text = ''):
	var winpanel = get_node("winningpanel")
	for i in winpanel.get_node("ScrollContainer/VBoxContainer").get_children():
		if i.name != "Button":
			i.visible = false
			i.free()
	winpanel.visible = true
	winpanel.get_node("wintext").set_bbcode(text)
	builditemlists()





func banditcamp():
	globals.get_tree().get_current_scene().get_node('outside').clearbuttons()
	newbutton = button.duplicate()
	buttoncontainer.add_child(newbutton)
	newbutton.set_text('Attack them')
	newbutton.visible = true
	newbutton.connect("pressed",self,'enemyfight')
	newbutton = button.duplicate()
	buttoncontainer.add_child(newbutton)
	newbutton.set_text('Ignore them')
	newbutton.visible = true
	newbutton.connect("pressed",self,'enemyleave')

func slaversenc(stage = 0):
#warning-ignore:unused_variable
	var state = false
	var buttons = []
#warning-ignore:unused_variable
	var image
#warning-ignore:unused_variable
	var sprites = []
	if stage == 0:
		if enemygroup.units.size() < 4:
			mansion.maintext = "You spot a small group of slavers escorting a captured person. "
		else:
			mansion.maintext = "You come across a considerable group of slavers escorting a few capturees. "
		buttons.append({name = 'Attack Slavers', function = 'slaversenc', args = 1})
		buttons.append({name = 'Greet Slavers',function = 'slaversenc',args = 2})
		buttons.append({name = 'Leave',function = 'enemyleave'})
	elif stage == 1:
		enemyfight()
		return
	elif stage == 2:
		mansion.maintext = "You greet the group of slavers and they offer you to check their freshly acquired merchandise. "
		buttons.append({name = 'Fight Slavers', function = 'slaversenc', args = 1})
		buttons.append({name = 'Check Victims',function = 'slaversenc',args = 4})
		buttons.append({name = 'Leave',function = 'enemyleave'})
	elif stage == 3:
		progress += 1
		zoneenter(currentzone.code)
	elif stage == 4:
		globals.main.get_node("outside").closefunction = ['slaversenc',2]
		globals.main.get_node("outside").slavearray = enemygroup.captured
		globals.main.get_node("outside").guildlocation = 'outside'
		globals.main.get_node("outside").slaveguildslaves()
	outside.buildbuttons(buttons,self)
	#globals.main.dialogue(state, self, text, buttons, sprites)
	
#func slaverwin():
#	var state = false
#	var text = ''
#	var buttons = []
#	var sprites = []
#	text = textnode.SlaverWin1
#	globals.main.dialogue(state, self, text, buttons, sprites)
	
func merchantencounter(stage = 0):
	var state = false
	var text = ''
	var buttons = []
#warning-ignore:unused_variable
	var image
	var sprites = []
	if stage == 0:
		text = ""
		buttons.append({text = 'Trade',function = 'merchantencounter',args = 1})
		buttons.append({text = 'Ignore',function = 'merchantencounter',args = 2})
	elif stage == 1:
		globals.main.get_node("outside").shopinitiate('outdoor')
		globals.main.get_node("outside").shopbuy()
		globals.main.close_dialogue()
		return
	elif stage == 2:
		globals.main.close_dialogue()
		return
	globals.main.dialogue(state, self, text, buttons, sprites)
#-----------------------------------------------------------------------


func slaversgreet():
	globals.get_tree().get_current_scene().get_node('outside').clearbuttons()
	globals.get_tree().get_current_scene().get_node('outside').maintext = globals.player.dictionary("You reveal yourself to the slavers' group and wonder if they'd be willing to part with their merchandise saving them hassle of transportation.\n\n- You, $sir, know how to bargain. We'll agree to part with our treasure here for ")+str(max(round(enemygroup.captured.buyprice()*0.7),40))+" gold.\n\nYou still might try to take their hostage by force, but given they know about your presence, you are at considerable disadvantage. "
	newbutton = button.duplicate()
	buttoncontainer.add_child(newbutton)
	newbutton.set_text('Inspect')
	newbutton.visible = true
	newbutton.connect("pressed",self,'inspectenemy')
	newbutton = button.duplicate()
	buttoncontainer.add_child(newbutton)
	newbutton.set_text('Agree on the deal')
	newbutton.visible = true
	newbutton.connect("pressed",self,'slaverbuy')
	if globals.resources.gold < max(round(enemygroup.captured.buyprice()*0.7),40):
		newbutton.set_disabled(true)
		newbutton.set_tooltip("You don't have enough gold.")
	if globals.spelldict.mindread.learned == true:
		newbutton = button.duplicate()
		buttoncontainer.add_child(newbutton)
		newbutton.set_text('Cast Mindread to check personality')
		newbutton.visible = true
		newbutton.connect("pressed",self,'mindreadcapturee', ['slavers'])
		if globals.spelldict.mindread.manacost > globals.resources.mana:
			newbutton.set_disabled(true)
	newbutton = button.duplicate()
	buttoncontainer.add_child(newbutton)
	newbutton.set_text('Fight')
	newbutton.visible = true
	newbutton.connect("pressed",self,'enemyfight')
	newbutton = button.duplicate()
	buttoncontainer.add_child(newbutton)
	newbutton.set_text('Refuse and leave')
	newbutton.visible = true
	newbutton.connect("pressed",self,'enemyleave')

func snailevent():
	var array = []
	mansion.maintext = "You come across a humongous snail making its way through the trees. It makes you remember hearing how you could use it for farming additional income but you will likely need to sacrifice some food to tame it first. "
	if globals.resources.food >= 200:
		array.append({name = 'Feed Snail (200 food)', function = 'snailget'})
	else:
		array.append({name = 'Feed Snail (200 food)', function = 'snailget', disabled = true, tooltip = "not enough food"})
	array.append({name = "Ignore it", function = "zoneenter", args = 'grove'})
	outside.buildbuttons(array,self)

func snailget():
	globals.resources.food -= 200
	globals.state.snails += 1
	main.popup("You've brought a giant snail back with you and left it at your farm. ")
	main._on_mansion_pressed()

func slaverbuy():
	globals.resources.gold -= max(round(enemygroup.captured.buyprice()*0.7),30)
	#enemycapture()
	globals.get_tree().get_current_scene().popup("You purchase slavers' captive and return to the mansion. " )

func inspectenemy():
	globals.get_tree().get_current_scene().popup(enemygroup.captured.descriptionsmall())

func mindreadcapturee(state = 'encounter'):
	globals.spells.person = enemygroup.captured
	globals.main.popup(globals.spells.mindreadeffect())
	if state == 'win':
		enemydefeated()
	elif state == 'slavers':
		slaversgreet()
	else:
		encounterbuttons()


func enemyleave():
	progress += 1.0
	var text = ''
	globals.player.energy -= max(5-floor((globals.player.sagi+globals.player.send)/2),1)
	for i in globals.state.playergroup:
		var person = globals.state.findslave(i)
		person.energy -= max(5-floor((person.sagi+person.send)/2),1)
	zoneenter(currentzone.code)
	if text != '':
		mansion.maintext = mansion.maintext +'\n[color=yellow]'+text+'[/color]'

func enemyfight(soundkeep = false):
	mansion.maintext = ''
	outside.clearbuttons()
	main.get_node("combat").currentenemies = enemygroup.units
	main.get_node('combat').area = currentzone
	main.get_node('combat').enemygear = enemygear
	main.get_node("combat").start_battle(soundkeep)


func winscreenclear():
	var winpanel = get_node("winningpanel")
	defeated = {units = [], names = [], select = [], faction = []}
	enemyloot = {stackables = {}, unstackables = []}
	for i in winpanel.get_node("ScrollContainer/VBoxContainer").get_children():
		if i != winpanel.get_node("ScrollContainer/VBoxContainer/Button"):
			i.visible = false
			i.free()
	winpanel.get_node("ScrollContainer").visible = false
	winpanel.get_node("Panel").visible = false
	main.checkplayergroup()

func enemydefeated():
	if launchonwin != null:
		globals.events.call(launchonwin)
		launchonwin = null
		return
	var text = 'You have defeated the enemy group!\n'
	var ranger = false
	for i in globals.state.playergroup:
		if globals.state.findslave(i).spec == 'ranger':
			ranger = true
	winscreenclear()
	enemyinfoclear()
	capturedtojail = 0
	#Fight rewards
	var winpanel = get_node("winningpanel")
	var goldearned = 0
	var expearned = 0
	var questitem = false
	for unit in enemygroup.units:
		if unit.state == 'escaped':
			expearned += unit.rewardexp*0.66
			continue
		if unit.capture != null:
			defeated.units.append(unit.capture)
			defeated.names.append(unit.name)
			defeated.select.append(0)
			defeated.faction.append(unit.faction)
			for i in unit.capture.gear.values():
				if i != null:
					globals.items.unequipitemraw(enemygear[i],unit.capture)
					if randf() * 100 <= variables.geardropchance:
						enemyloot.unstackables.append(enemygear[i])
		
		if int(globals.state.sidequests.ayda) == 14 && currentzone.code == 'gornoutskirts' && questitem == false && globals.itemdict.aydajewel.amount == 0:
			unit.rewardpool.aydajewel = 5
			questitem = true #questitem == true
		for i in unit.rewardpool:
			var chance = unit.rewardpool[i]
			var bonus = 1
			if ranger == true:
				bonus += 0.4
			if deeperregion:
				bonus += 0.25
			if globals.state.spec == "Hunter":
				bonus += 0.2
			chance = chance*bonus
			if rand_range(0,100) <= chance:
				if i == 'gold':
					var gold = round(rand_range(unit.rewardgold[0], unit.rewardgold[1]))
					if globals.state.spec == 'Hunter':
						gold *= 2
					goldearned += gold
				else:
					if globals.itemdict.has(i):
						var item = globals.itemdict[i]
						if item.type != 'gear':
							if enemyloot.stackables.has(item.code):
								enemyloot.stackables[item.code] += 1
							else:
								enemyloot.stackables[item.code] = 1
						else:
							var tempitem = globals.items.createunstackable(item.code)
							enemyloot.unstackables.append(tempitem)
		expearned += unit.rewardexp
	if deeperregion:
		expearned *= 1.2
	expearned = round(expearned)
	globals.resources.gold += goldearned
	text += '\nYou have received a total sum of [color=yellow]' + str(round(goldearned)) +'[/color] pieces of gold and [color=aqua]' + str(expearned) + '[/color] experience points. \n'
	globals.player.xp += round(expearned/(globals.state.playergroup.size()+1))
	for i in globals.state.playergroup:
		var person = globals.state.findslave(i)
		person.xp += round(expearned/(globals.state.playergroup.size()+1))
		if person.levelupreqs.has('code') && person.levelupreqs.code == 'wincombat':
			person.levelup()
			text += person.dictionary("[color=green]Your decisive win inspired $name, and made $him unlock new potential. \n")
		if person.health > person.stats.health_max/1.3:
			person.cour += rand_range(1,3)
	
	
	if defeated.units.size() > 0:
		text += 'Your group gathers defeated opponents in one place for you to decide what to do about them. \n'
	if enemygroup.captured != null:
		text += 'You are also free to decide what you wish to do with bystanders, who were in possession of your opponents. \n'
		for i in enemygroup.captured:
			defeated.units.append(i)
			defeated.names.append('Captured')
			defeated.select.append(0)
			defeated.faction.append('stranger')
	
	winpanel.get_node("ScrollContainer").visible = true
	winpanel.get_node("Panel").visible = true
	
	winpanel.visible = true
	winpanel.get_node("wintext").set_bbcode(text)
	for i in range(0, defeated.units.size()):
		defeated.units[i].stress += rand_range(20, 50)
		defeated.units[i].obed += rand_range(10, 20)
		defeated.units[i].health -= rand_range(40,70)
		if defeated.names[i] == 'Captured':
			defeated.units[i].obed += rand_range(10,20)
			defeated.units[i].loyal += rand_range(5,15)
	buildcapturelist()
	builditemlists()
	
	if globals.state.sidequests.cali == 18 && defeated.names.find('Bandit 1') >= 0 && currentzone.code == 'forest':
		main.popup("One of the defeated bandits in exchange for their life reveals the location of their camp you've been searching for. ")
		globals.state.sidequests.cali = 19

func buildcapturelist():
	var winpanel = get_node("winningpanel")
	var text = "Defeated and Captured | Free ropes left: "
	text += str(globals.state.backpack.stackables.rope) if globals.state.backpack.stackables.has('rope') else '0'
	winpanel.get_node("Panel/Label").set_text(text)
	for i in get_node("winningpanel/ScrollContainer/VBoxContainer").get_children():
		if i.get_name() != 'Button':
			i.visible = false
			i.queue_free()
	for i in range(0, defeated.units.size()):
		var newbutton = winpanel.get_node("ScrollContainer/VBoxContainer/Button").duplicate()
		winpanel.get_node("ScrollContainer/VBoxContainer").add_child(newbutton)
		newbutton.visible = true
		newbutton.get_node("capture").connect("pressed",self,'captureslave', [defeated.units[i]])
		if !globals.state.backpack.stackables.has('rope') || globals.state.backpack.stackables.rope < 1:
			newbutton.get_node('capture').set_disabled(true)
		newbutton.get_node("Label").set_text(defeated.names[i] + ' ' + defeated.units[i].sex+ ' ' + defeated.units[i].race)
		newbutton.connect("pressed", self, 'defeatedselected', [defeated.units[i]])
		newbutton.connect("mouse_entered", globals, 'slavetooltip', [defeated.units[i]])
		newbutton.connect("mouse_exited", globals, 'slavetooltiphide')
		newbutton.get_node("choice").set_meta('person', defeated.units[i])
		newbutton.get_node("mindread").connect("pressed",self,'mindreadslave', [defeated.units[i]])
		if globals.resources.mana < globals.spelldict.mindread.manacost && globals.spelldict.mindread.learned:
			newbutton.get_node('mindread').set_disabled(true)
		newbutton.get_node("choice").add_to_group('winoption')
		newbutton.get_node("choice").connect("item_selected",self, 'defeatedchoice', [defeated.units[i], newbutton.get_node("choice")])

func mindreadslave(person):
	globals.spells.person = person
	globals.main.popup(globals.spells.mindreadeffect())
	buildcapturelist()

func captureslave(person):
	var location
	if variables.consumerope != 0:
		globals.state.backpack.stackables.rope -= variables.consumerope
	for i in person.gear:
		i = null
	if globals.races[person.race.replace("Halfkin", "Beastkin")].uncivilized == true:
		person.add_trait('Uncivilized')
	captureeffect(person)
	if defeated.names[defeated.units.find(person)] == 'Captured':
		if currentzone.tags.find("wimborn") >= 0:
			location = 'wimborn'
		elif currentzone.tags.find("frostford") >= 0:
			location = 'frostford'
		elif currentzone.tags.find("gorn") >= 0:
			location = 'gorn'
		elif currentzone.tags.find("amberguard") >= 0:
			location = 'amberguard'
		if location != null:
			globals.state.reputation[location] -= 1
	defeated.names.remove(defeated.units.find(person))
	defeated.units.erase(person)
	get_tree().get_current_scene().infotext("New captive added to your group",'green')
	buildcapturelist()
	builditemlists()

func captureeffect(person):
	
	var effect = globals.effectdict.captured
	var dict = {'slave':0.7, 'poor':1,'commoner':1.2,"rich": 2, "noble": 4}
	person.fear += rand_range(30, 25+person.cour/4)
	effect.duration = round((4 + (person.conf+person.cour)/20) * dict[person.origins])
	person.add_effect(effect)
	globals.state.capturedgroup.append(person)

func builditemlists():
	var newbutton
	var tempitem
	for i in get_node("winningpanel/lootpanel/backpack/VBoxContainer").get_children()+get_node("winningpanel/lootpanel/enemyloot/VBoxContainer").get_children():
		if i.get_name() != "Button":
			i.visible = false
			i.queue_free()
	for i in enemyloot.stackables:
		tempitem = globals.itemdict[i]
		newbutton = get_node("winningpanel/lootpanel/enemyloot/VBoxContainer/Button").duplicate()
		get_node("winningpanel/lootpanel/enemyloot/VBoxContainer").add_child(newbutton)
		newbutton.visible = true
		newbutton.get_node("amount").set_text(str(enemyloot.stackables[i]))
		if tempitem.icon != null:
			newbutton.get_node("image").set_texture(tempitem.icon)
		newbutton.connect("pressed",self,'moveitemtobackpack',[newbutton])
		newbutton.set_meta("item", tempitem)
		newbutton.connect("mouse_entered", self, 'itemtooltip', [tempitem])
		newbutton.connect("mouse_exited", self, 'itemtooltiphide')
	for i in enemyloot.unstackables:
		newbutton = get_node("winningpanel/lootpanel/enemyloot/VBoxContainer/Button").duplicate()
		get_node("winningpanel/lootpanel/enemyloot/VBoxContainer").add_child(newbutton)
		newbutton.visible = true
		if i.icon != null:
			newbutton.get_node("image").set_texture(load(i.icon))
		if i.enchant != '':
			newbutton.get_node("enchant").visible = true
		newbutton.connect("pressed",self,'moveitemtobackpack',[newbutton])
		newbutton.set_meta("item", i)
		newbutton.get_node("amount").visible = false
		newbutton.connect("mouse_entered", self, 'itemtooltip', [i])
		newbutton.connect("mouse_exited", self, 'itemtooltiphide')
	
	
	for i in globals.state.backpack.stackables:
		tempitem = globals.itemdict[i]
		newbutton = get_node("winningpanel/lootpanel/backpack/VBoxContainer/Button").duplicate()
		get_node("winningpanel/lootpanel/backpack/VBoxContainer").add_child(newbutton)
		newbutton.visible = true
		newbutton.get_node("amount").set_text(str(globals.state.backpack.stackables[i]))
		if tempitem.icon != null:
			newbutton.get_node("image").set_texture(tempitem.icon)
		newbutton.connect("pressed",self,'moveitemtoenemy',[newbutton])
		newbutton.set_meta("item", tempitem)
		newbutton.connect("mouse_entered", self, 'itemtooltip', [tempitem])
		newbutton.connect("mouse_exited", self, 'itemtooltiphide')
	for i in globals.state.unstackables.values():
		if str(i.owner) != 'backpack':
			continue
		newbutton = get_node("winningpanel/lootpanel/backpack/VBoxContainer/Button").duplicate()
		get_node("winningpanel/lootpanel/backpack/VBoxContainer").add_child(newbutton)
		newbutton.visible = true
		newbutton.get_node("amount").visible = false
		if i.icon != null:
			newbutton.get_node("image").set_texture(load(i.icon))
		newbutton.connect("pressed",self,'moveitemtoenemy',[newbutton])
		if i.enchant != '':
			newbutton.get_node("enchant").visible = true
		newbutton.set_meta("item", i)
		newbutton.connect("mouse_entered", self, 'itemtooltip', [i])
		newbutton.connect("mouse_exited", self, 'itemtooltiphide')
	$winningpanel/lootpanel/backpack/VBoxContainer.move_child($winningpanel/lootpanel/backpack/VBoxContainer/Button, $winningpanel/lootpanel/backpack/VBoxContainer.get_children().size())
	$winningpanel/lootpanel/enemyloot/VBoxContainer.move_child($winningpanel/lootpanel/enemyloot/VBoxContainer/Button, $winningpanel/lootpanel/enemyloot/VBoxContainer.get_children().size())
	calculateweight()

func calculateweight():
#warning-ignore:unused_variable
	var person
#warning-ignore:unused_variable
	var tempitem
	var weight = globals.state.calculateweight()
	
	get_node("winningpanel/lootpanel/weightmeter/Label").set_text("Weight: " + str(weight.currentweight) + '/' + str(weight.maxweight))
	get_node("winningpanel/lootpanel/weightmeter/").set_value((weight.currentweight*10/max(weight.maxweight,1)*10))
	if weight.currentweight > weight.maxweight:
		get_node("winningpanel/confirmwinning").set_tooltip("Reduce carry weight before proceeding")
		get_node("winningpanel/confirmwinning").set_disabled(true)
	else:
		get_node("winningpanel/confirmwinning").set_tooltip("")
		get_node("winningpanel/confirmwinning").set_disabled(false)

func moveitemtobackpack(button):
	var item = button.get_meta('item')
	if item.type == 'quest':
		globals.items.call(item.effect, item)
		enemyloot.stackables[item.code] -= 1
		if enemyloot.stackables[item.code] <= 0:
			enemyloot.stackables.erase(item.code)
	elif item.has('owner') == false:
		enemyloot.stackables[item.code] -= 1
		if enemyloot.stackables[item.code] <= 0:
			enemyloot.stackables.erase(item.code)
		if globals.state.backpack.stackables.has(item.code):
			globals.state.backpack.stackables[item.code] += 1
		else:
			globals.state.backpack.stackables[item.code] = 1
	else:
		globals.state.unstackables[item.id] = item
		item.owner = 'backpack'
		enemyloot.unstackables.erase(item)
	itemtooltiphide()
	builditemlists()


func _on_takeallbutton_pressed():
	for i in enemyloot.stackables:
		if globals.state.backpack.stackables.has(i):
			globals.state.backpack.stackables[i] += enemyloot.stackables[i]
		else:
			globals.state.backpack.stackables[i] = enemyloot.stackables[i]
		enemyloot.stackables.erase(i)
	for i in enemyloot.unstackables:
		globals.state.unstackables[i.id] = i
		i.owner = 'backpack'
		enemyloot.unstackables.erase(i)
	
	builditemlists()

func moveitemtoenemy(button):
	var item = button.get_meta('item')
	if item.has('owner') == false:
		if enemyloot.stackables.has(item.code):
			enemyloot.stackables[item.code] += 1
		else:
			enemyloot.stackables[item.code] = 1
		globals.state.backpack.stackables[item.code] -= 1
	else:
		enemyloot.unstackables.append(item)
		globals.state.unstackables.erase(item.id)
	itemtooltiphide()
	builditemlists()

func itemtooltip(item):
	globals.itemtooltip(item)

func itemtooltiphide():
	globals.hidetooltip()


func defeatedselected(person):
	get_tree().get_current_scene().popup(person.descriptionsmall())


#warning-ignore:unused_argument
func defeatedchoice(ID, person, node):
	defeated.select[defeated.units.find(person)] = ID






var secondarywin = false

func _on_confirmwinning_pressed(): #0 leave, 1 capture, 2 rape, 3 kill
	var text = ''
#warning-ignore:unused_variable
	var selling = false
#warning-ignore:unused_variable
	var sellyourself = false
	var orgy = false
	var orgyarray = []
	var location
	var reward = false
	var killed = false
	if currentzone.tags.find("wimborn") >= 0:
		location = 'wimborn'
	elif currentzone.tags.find("frostford") >= 0:
		location = 'frostford'
	elif currentzone.tags.find("gorn") >= 0:
		location = 'gorn'
	elif currentzone.tags.find("amberguard") >= 0:
		location = 'amberguard'
	else:
		location = 'wimborn'
	for i in range(0, defeated.units.size()):
		if defeated.faction[i] == 'stranger' && defeated.names[i] != "Captured":
			globals.state.reputation[location] -= 1
		if defeated.select[i] == 0:
			if defeated.names[i] != 'Captured':
				text += defeated.units[i].dictionary("You have left $race $child alone.\n")
			else:
				text += defeated.units[i].dictionary("You have released $race $child and set $him free.\n")
				globals.state.reputation[location] += rand_range(1,2)
				if randf() < 0.25 + globals.state.reputation[location]/20 && reward == false:
					reward = true
					rewardslave = defeated.units[i]
					rewardslavename = defeated.names[i]
		elif defeated.select[i] == 1:
			if !defeated.faction[i] in ['bandit','monster']:
				globals.state.reputation[location] -= rand_range(0,1)
			orgy = true
			orgyarray.append(defeated.units[i])
		elif defeated.select[i] == 2:
			killed = true
			if !defeated.faction[i] in ['monster','bandit']:
				globals.state.reputation[location] -= 3
			elif defeated.faction[i] == 'bandit':
				globals.state.reputation[location] -= 1
			if defeated.faction[i] == 'elf':
				globals.state.reputation.amberguard -= 3
			text += defeated.names[i] + " has been killed. \n"
	if killed == true:
		text += "[color=yellow]Your execution strikes fear into your group and captives. [/color]"
		for i in globals.state.capturedgroup:
			if i.fear < 80:
				i.fear += rand_range(20,35)
		#for i in captured
	get_node("winningpanel").visible = false
	if secondarywin:
		secondarywin = false
	else:
		enemyleave()
	get_node("winningpanel/defeateddescript").set_bbcode('')
	outside.playergrouppanel()
	if orgy == true:
		var totalmanagain = 0
		if orgyarray.size() >= 2: ### See if there's more than 1 enemy to rape
			text += "After freeing those left from their clothes, you joyfully start to savour their bodies one after another. "
		else:
			text += "You undress your prisoner and without further hesitation mercilessly rape " + orgyarray[0].dictionary("$race $child") + ". \n"
		for i in globals.state.playergroup:
			var person = globals.state.findslave(i)
			if killed == true && person.fear < 50 && person.loyal < 40:
				person.fear += rand_range(20,30)
			if person.consent == false:
				if person.loyal < 30:
					text+= person.dictionary('\n$name watches your actions with disgust, eventually averting $his eyes. ')
					person.obed += -rand_range(15,25)
				else:
					text += person.dictionary('\n$name watches your deeds with interest, occasionally rustling around $his waist. ')
					person.lust = 20
			elif person.consent == true:
				if person.lust >= 50 && person.lewdness >= 40:
					person.asser += rand_range(6,12)
					person.lastsexday = globals.resources.day
					person.lust -= rand_range(5,15)
					text += person.dictionary('\n$name, overwhelmed by the situation, joins you and pleasures $himself with one of the captives. ')
				else:
					text += person.dictionary("\n$name does not appear to be very interested in the ongoing action and just waits patiently.")
		for i in orgyarray:
			var temp = rand_range(3,5)
			globals.resources.mana += temp
			totalmanagain += temp
		text += "You've earned [color=aqua]" + str(round(totalmanagain)) + "[/color] mana. "
	if reward == true:
		capturereward()
	if text != '':
		main.popup(text)

var rewardslave
var rewardslavename

func capturereward():
	var text = ""
	var buttons = [['Take no reward','capturedecide',1],['Ask for material reward','capturedecide',2],['Ask for sex','capturedecide',3],['Ask to join you','capturedecide',4]]
	text = "As you are about to move on, " + rewardslavename + " person, that you have rescued, appeals to you. $His name is $name and $he's very thankful for your help. $race $child wishes to repay you somehow.  "
	
	
	main.dialogue(false,self,rewardslave.dictionary(text),buttons)

func capturedecide(stage): #1 - no reward, 2 - material, 3 - sex, 4 - join
	var text = ""
	var location
	if currentzone.tags.find("wimborn") >= 0:
		location = 'wimborn'
	elif currentzone.tags.find("frostford") >= 0:
		location = 'frostford'
	elif currentzone.tags.find("gorn") >= 0:
		location = 'gorn'
	elif currentzone.tags.find("amberguard") >= 0:
		location = 'amberguard'
	else:
		location = 'wimborn'
	
	if stage == 1:
		text = rewardslave.dictionary("$race ").capitalize() + "$child is surprised by your generosity, and after thanking you again, leaves. "
		globals.state.reputation[location] += 1
	elif stage == 2:
		if randf() >= 0.25:
			text = "After getting through $his belongings, $name passes you some valueables and gold. "
			var goldreward = round(rand_range(3,6)*10)
			if globals.state.spec == 'Hunter':
				goldreward *= 2
			globals.resources.gold += goldreward
		else:
			text = "After getting through $his belongings, $name passes you a piece of gear. "
			var gear = {number = 1, enchantchance = 75 }
			var loottable = chestloot[getchestlevel()]
			winscreenclear()
			generaterandomloot(loottable, gear)
			secondarywin = true
			showlootscreen()
	elif stage == 3:
		if rand_range(0,100) >= 35 + globals.state.reputation[location]/2:
			text = "$name hastily refuses and retreats excusing $himself. "
		else:
			text = "After a brief pause, $name gives you an accepting nod. After you seclude to nearby bushes, $he rewards you with a passionate session. "
			globals.resources.mana += 5
	elif stage == 4:
		if rand_range(0,100) >= 20 + globals.state.reputation[location]/4:
			text = "$name excuses $himself, but can't accept your proposal and quickly leaves. "
		else:
			rewardslave.obed = 85
			rewardslave.stress = 10
			globals.slaves = rewardslave
			text = "$name observes you for some time, measuring your words, but to your surprise, $he complies either out of symphathy, or out of desperate life $he had to carry. "
	main.dialogue(true,self,rewardslave.dictionary(text))
	

func _on_sellconfirm_pressed():
	#_on_confirmwinning_pressed(true)
	_on_confirmwinning_pressed()
	get_node("winningpanel/sellpanel").visible = false




func wimborn():
	main.get_node('outside').wimborn()
	
	if globals.state.location != 'wimborn':
		if globals.resources.gold >= 25 :
			outside.addbutton({name = 'Teleport to Mansion - 25 gold', function = 'teleportmansion', textcolor = 'green', tooltip = '25 gold'}, self)
		else:
			outside.addbutton({name = 'Teleport to Mansion - 25 gold', function = 'teleportmansion', textcolor = 'green', tooltip = '25 gold', disabled = true}, self)

func gorn():
	outside.location = 'gorn'
	main.music_set('gorn')
	var array = []
	array.append({name = "Visit local Slaver Guild", function = 'gornslaveguild'})
	array.append({name = "Visit local bar", function = 'gornbar'})
	if globals.state.mainquest in [12,13,14,15,37]:
		array.append({name = "Visit Palace", function = 'gornpalace'})
	if ((globals.state.sidequests.ivran in ['tobetaken','tobealtered','potionreceived'] || globals.state.mainquest >= 16) && !globals.state.decisions.has("mainquestslavers")) || globals.state.sandbox == true:
		array.append({name = "Visit Alchemist", function = 'gornayda'})
	array.append({name = "Gorn's Market (shop)", function = 'gornmarket'})
	array.append({name = "Outskirts", function = 'zoneenter', args = 'gornoutskirts'})
	if globals.state.location == 'gorn':
		array.append({name = "Return to Mansion",function = 'mansion'})
	else:
		if globals.resources.gold >= 25 :
			array.append({name = 'Teleport to Mansion - 25 gold', function = 'teleportmansion', textcolor = 'green', tooltip = '25 gold'})
		else:
			array.append({name = 'Teleport to Mansion - 25 gold', function = 'teleportmansion', textcolor = 'green', tooltip = '25 gold', disabled = true})
	outside.buildbuttons(array,self)
	

func mansion():
	get_parent().mansion()

func gornbar():
	var array = []
	var text = globals.questtext.GornBar
	main.animationfade()
	yield(main, 'animfinished')
	
	if globals.state.sidequests.yris == 0:
		text += "As you move towards the bar your presence is noticed by a girl of beastkin origins. Drawing your attention she gives you an  undoubtedly interested look. "
		array.append({name = "Approach the girl", function = "gornyris"})
	elif globals.state.sidequests.yris < 6:
		array.append({name = "Approach Yris", function = 'gornyris'})
	array.append({name = "Leave",function = 'zoneenter', args = 'gorn'})
	mansion.maintext = text
	outside.buildbuttons(array,self)

func gornyris():
	var state = false
	var text
	var buttons = []
	var sprite = [['yrisnormal', 'pos1', 'opac']]
	if globals.player.penis == 'none':
		main.popup("This encounter requires your character to possess a penis. ")
		return
	if globals.state.sidequests.yris == 0:
		text = globals.questtext.GornYrisMeet
		globals.charactergallery.yris.unlocked = true
		if globals.resources.gold >= 200:
			buttons.append({text = "Accept (200 Gold)", function = "gornyrisaccept", args = 1})
		else:
			buttons.append({text = "Accept (200 Gold)", function = "gornyrisaccept", args = 1, disabled = true})
		globals.state.sidequests.yris = 1
	elif globals.state.sidequests.yris == 1:
		text = globals.questtext.GornYrisRepeatMeet
		if globals.resources.gold >= 200:
			buttons.append({text = "Accept (200 Gold)", function = "gornyrisaccept", args = 1})
		else:
			buttons.append({text = "Accept (200 Gold)", function = "gornyrisaccept", args = 1, disabled = true})
	elif globals.state.sidequests.yris == 2:
		text = globals.questtext.GornYrisRepeatMeet
		if globals.resources.gold >= 200:
			buttons.append({text = "Accept (200 Gold)", function = "gornyrisaccept", args = 2})
			if globals.itemdict.deterrentpot.amount >= 1:
				buttons.append({text = "Accept and use Deterrent potion (200 Gold)", function = "gornyrisaccept", args = 3})
		else:
			buttons.append({text = "Accept (200 Gold)", function = "gornyrisaccept", args = 2, disabled = true})
	elif globals.state.sidequests.yris == 3:
		text = globals.questtext.GornYrisOffer2
		globals.state.sidequests.yris += 1
	elif globals.state.sidequests.yris in [4,5]:
		text = globals.questtext.GornYrisOffer2Repeat
		if globals.resources.gold < 1000 || globals.itemdict.deterrentpot.amount < 1 || globals.state.sidequests.yris < 5:
			text += "\n\n[color=yellow]You decide, that you should prepare before putting your money on the table.[/color] "
			if globals.state.sidequests.yris < 5:
				text += "\n\nPerhaps, somebody skilled in alchemy might shine some light upon your previous finding. "
			buttons.append({text = "Accept (1000 Gold)", function = "gornyrisaccept", args = 4, disabled = true})
		else:
			buttons.append({text = "Accept (1000 Gold)", function = "gornyrisaccept", args = 4})
	buttons.append({text = "Refuse", function = "gornyrisaccept", args = 0})
	gornbar()
	main.dialogue(state, self, text, buttons, sprite)

#warning-ignore:unused_argument
func gornyrisleave(args):
	zoneenter('gorn')
	main.close_dialogue()

func gornyrisaccept(stage):
	var text = ''
	var state = false
	var buttons = []
	var sprite = []
	var image
	if stage == 0:
		sprite = [['yrisnormal', 'pos1']]
		text = globals.questtext.GornYrisRefuse
		buttons.append({text = "Continue", function = 'gornyrisleave', args = null})
	elif stage == 1:
		sprite = [['yrisnormalnaked', 'pos1']]
		image = 'yrisbj'
		globals.charactergallery.yris.scenes[0].unlocked = true
		globals.charactergallery.yris.nakedunlocked = true
		text = globals.questtext.GornYrisAccept1
		globals.resources.gold -= 200
		globals.resources.mana += 15
		globals.state.sidequests.yris = 2
		buttons.append({text = "Close", function = 'closescene'})
		state = true
	elif stage == 2:
		sprite = [['yrisnormalnaked', 'pos1']]
		text = globals.questtext.GornYrisAcceptRepeat
		image = 'yrisbj'
		state = true
		buttons.append({text = "Close", function = 'closescene'})
		globals.resources.gold -= 200
		globals.resources.mana += 15
	elif stage == 3:
		sprite = [['yrisnormalnaked', 'pos1']]
		text = globals.questtext.GornYrisAccept2
		image = 'yrissex'
		buttons.append({text = "Close", function = 'closescene'})
		globals.charactergallery.yris.scenes[1].unlocked = true
		globals.state.sidequests.yris += 1
		globals.itemdict.deterrentpot.amount -= 1
		state = true
		globals.resources.mana += 25
	elif stage == 4:
		sprite = [['yrisshocknaked', 'pos1']]
		globals.charactergallery.yris.scenes[2].unlocked = true
		image = 'yrissex'
		globals.itemdict.deterrentpot.amount -= 1
		text = globals.questtext.GornYrisAccept3
		buttons.append({text = "Reveal everything", function = 'gornyrisaccept', args = 5})
		buttons.append({text = "Demand the gold", function = 'gornyrisaccept', args = 6})
	elif stage == 5:
		sprite = [['yrisnormalnaked', 'pos1']]
		text = globals.questtext.GornYrisReveal
		buttons.append({text = "Offer Yris to work for you", function = 'gornyrisaccept', args = 8})
		buttons.append({text = "Demand the gold", function = 'gornyrisaccept', args = 7})
	elif stage == 6:
		sprite = [['yrisaltnaked', 'pos1']]
		text = globals.questtext.GornYrisTakeGold
		globals.state.sidequests.yris = 100
		globals.resources.gold += 1000
		text += "\n\nIn the end you get the gold you asked for, but never seen Yris again. "
		state = true
	elif stage == 7:
		sprite = [['yrisaltnaked', 'pos1']]
		text = globals.questtext.GornYrisTakeGold2
		globals.state.sidequests.yris = 100
		text += "\n\nIn the end you get the gold you asked for, but never seen Yris again. "
		globals.resources.gold += 1000
		state = true
	elif stage == 8:
		state = true
		sprite = [['yrisnormalnaked', 'pos1']]
		text = globals.questtext.GornYrisHire
		globals.state.sidequests.yris += 1
		var person = globals.characters.create("Yris")
		globals.slaves = person
	gornbar()
	if image != null:
		main.close_dialogue()
		main.scene(self, image, text, buttons)
	else:
		main.closescene()
		main.dialogue(state, self, text, buttons, sprite)

func closescene():
	main.closescene()

func amberguard():
	var array = []
	outside.location = 'amberguard'
	main.music_set('frostford')
#	if globals.state.portals.amberguard.enabled == false:
#		globals.state.portals.amberguard.enabled = true
#		mansion.maintext = mansion.maintext + "\n\n[color=yellow]You have unlocked new portal![/color]"
	if globals.state.mainquest == 17:
		globals.state.mainquest = 18
	elif globals.state.mainquest == 19:
		array.append({name = "Search for clues", function = "amberguardsearch"})
	elif globals.state.mainquest == 20:
		array.append({name = 'Find stranger', function = 'amberguardsearch', args = 2})
	array.append({name = "Local Market (shop)", function = 'amberguardmarket'})
	array.append({name = "Return to Elven Grove", function = 'zoneenter', args = 'elvenforest'})
	array.append({name = "Move to the Amber Road", function = 'zoneenter', args = 'amberguardforest'})
	if globals.state.sidequests.ayneris == 6:
		for i in globals.state.playergroup:
			if globals.state.findslave(i).unique == 'Ayneris':
				event("aynerisrapieramberguard")
	outside.buildbuttons(array,self)
	if globals.state.location != 'amberguard':
		if globals.resources.gold >= 25 :
			outside.addbutton({name = 'Teleport to Mansion - 25 gold', function = 'teleportmansion', textcolor = 'green', tooltip = '25 gold'}, self)
		else:
			outside.addbutton({name = 'Teleport to Mansion - 25 gold', function = 'teleportmansion', textcolor = 'green', tooltip = '25 gold', disabled = true}, self)

func amberguardsearch(stage = 1):
	var text
	var buttons = []
	globals.state.mainquest = 20
	if stage == 1:
		text = globals.questtext.MainQuestAmberguardSearch
	elif stage == 2:
		text = globals.questtext.MainQuestAmberguardReturn
	if globals.resources.gold >= 1000:
		buttons.append({text = 'Pay 1000 gold',function = 'amberguardpurchase',args = 1})
	else:
		buttons.append({text = 'Pay 1000 gold',function = 'amberguardpurchase',args = 1, disabled = true})
	buttons.append({text = 'Leave',  function = 'amberguardpurchase', args = 2})
	main.dialogue(false,self,text,buttons)
	amberguard()

func amberguardpurchase(stage):
	var text
	if stage == 1:
		globals.state.mainquest = 21
		globals.resources.gold -= 1000
		text = globals.questtext.MainQuestAmberguardPay
	elif stage == 2:
		text = "You return to the main street."
	amberguard()
	main.dialogue(true, self, text, null)

func witchhut():
	var array = []
	if globals.state.mainquest == 21:
		globals.state.mainquest = 22
		mansion.maintext = globals.questtext.MainQuestAmberguardWitch
		array.append({name = "Go inside", function = 'shuriyavisit', args = 1})
	else:
		array.append({name = "Go inside", function = 'shuriyavisit', args = 2})
	array.append({name = "Return to Amber Road", function = 'zoneenter', args = 'amberguardforest'})
	outside.buildbuttons(array,self)

func shuriyavisit(stage):
	var text
	var buttons = []
	var state = true
	if stage == 1:
		text = globals.questtext.AmberguardShuriyaVisit
	elif stage == 2:
		text = "Shuriya greets you with frown on her face. \n\n[color=yellow]— Oh, it's you again? What do you need?[/color]"
	elif stage == 3:
		text = globals.questtext.MainQuestAmberguardTunnelsAsk
	elif stage == 4:
		text = globals.questtext.MainQuestAmberguardTunnelEnterAsk
		globals.state.mainquest = 23
	buttons.append({text = 'Ask about the tunnels', function = 'shuriyavisit', args = 3})
	if globals.state.mainquest == 22:
		buttons.append({text = 'Ask about entrance', function = 'shuriyavisit', args = 4})
	if globals.state.mainquest == 23:
		buttons.append({text = 'Deliver slaves', function = 'shuriyaslaves', args = true})
	zoneenter(currentzone.code)
	main.dialogue(state, self, text, buttons)

var slave1 = null
var slave2 = null

func shuriyaslaves(first = true):
	var state = true
	var text = '[color=yellow]— Well, who do you have?[/color]'
	var buttons = []
	var cancontinue = false
	if first == true:
		slave1 = null
		slave2 = null
	else:
		if slave1 != null && slave2 != null:
			cancontinue = true
	
	if slave1 != null:
		text += slave1.dictionary("\n$name will be given away as an Elf.")
	if slave2 != null:
		text += slave2.dictionary("\n$name will be given away as a Drow.")
	
	if cancontinue == true:
		buttons.append({text = "Confirm", function = 'shuriyaslavesgive', args = null})
	else:
		if slave1 == null:
			buttons.append({text = 'Select an Elf', function = 'shuriyaslaveselect', args = 1})
		if slave2 == null:
			buttons.append({text = 'Select a Drow', function = 'shuriyaslaveselect', args = 2})
	main.dialogue(state, self, text, buttons)

func shuriyaslaveselect(stage):
	if stage == 1:
		main.selectslavelist(true, 'shuriyaelfselect', self, 'person.race == "Elf"')
	else:
		main.selectslavelist(true, 'shuriyadrowselect', self, 'person.race == "Drow"')

#warning-ignore:unused_argument
func shuriyaslavesgive(none):
	globals.state.mainquest = 24
	globals.slaves.erase(slave1)
	globals.slaves.erase(slave2)
	var text = globals.questtext.MainQuestAmberguardSlaveDeliver
	main.popup(text)
	main.close_dialogue()

func shuriyaelfselect(person):
	slave1 = person
	shuriyaslaves(false)

func shuriyadrowselect(person):
	slave2 = person
	shuriyaslaves(false)


func undercityentrance():
	var array = []
	if globals.state.mainquest == 18:
		globals.state.mainquest = 19
	if globals.state.mainquest >= 24:
		array.append({name = 'Go through hidden passage', function = 'zoneenter', args = 'undercitytunnels'})
	array.append({name = "Return to Amber Road", function = 'zoneenter', args = 'amberguardforest'})
	outside.buildbuttons(array,self)

func undercityhall():
	var array = []
	if globals.state.mainquest == 24:
		array.append({name = "Search for documents", function = 'undercityboss'})
	else:
		array.append({name = "Search for valuables", function = 'undercityboss'})
	outside.buildbuttons(array,self)

func undercityboss():
	main.get_node("combat").nocaptures = true
	if globals.state.mainquest == 24:
		buildenemies("bossgolem")
		launchonwin = 'undercitybosswin'
		enemyfight()
	else:
		buildenemies("bosswyvern")
		launchonwin = 'undercitybosswin'
		enemyfight()

func undercitylibrary():
	globals.main.maintext = globals.questtext.undercitybookenc
	var array = []
	array.append({name = "Fight", function = 'undercitylibraryfight'})
	outside.buildbuttons(array,self)

func undercitylibraryfight():
	buildenemies("bookmutants")
	globals.main.get_node("combat").nocaptures = true
	launchonwin = 'undercitylibrarywin'
	enemyfight()

func undercitylibrarywin():
	generateloot(['zoebook', 1], globals.questtext.undercitybookafterabttle)
	showlootscreen()
	zoneenter("undercityruins")

func gornmarket():
	main.animationfade()
	yield(main, 'animfinished')
	outside.shopinitiate('gornmarket')

func amberguardmarket():
	
	main.animationfade()
	yield(main, 'animfinished')
	if globals.state.sidequests.ayneris == 4:
		globals.events.aynerismarket()
		return
	outside.shopinitiate('amberguardmarket')

func gornpalace():
	main.animationfade()
	yield(main, 'animfinished')
	globals.events.gornpalace()
	zoneenter('gorn')

func gornayda():
	main.animationfade()
	yield(main, 'animfinished')
	scriptedareas.aydashop.gornayda()

func frostford():
	outside.location = 'frostford'
	main.music_set('frostford')
	var array = []
	if globals.state.mainquest in [28, 29, 30, 31, 33, 34, 35]:
		array.append({name = "Visit City Hall", function = "frostfordcityhall"})
	if globals.state.reputation.frostford >= 20 && globals.state.mainquest == 30 && globals.state.sidequests.zoe == 0:
		var text = globals.questtext.MainQuestFrostfordCityhallZoe
		var buttons = []
		var sprite = [['zoeneutral','pos1','opac']]
		buttons.append({text = 'Accept', function = "frostfordzoe", args = 1})
		buttons.append({text = 'Refuse', function = "frostfordzoe", args = 2})
		main.dialogue(false, self, text, buttons, sprite)
	if globals.state.sandbox == true && globals.state.reputation.frostford >= 20 && globals.state.sidequests.zoe < 3:
		array.append({name = "Invite Zoe to your mansion", function = 'frostfordzoe', args = 3})
	array.append({name = "Visit local Slaver Guild", function = 'frostfordslaveguild'})
	array.append({name = "Frostford's Market (shop)", function = 'frostfordmarket'})
	array.append({name = "Outskirts", function = 'zoneenter', args = 'frostfordoutskirts'})
	if globals.state.location == 'frostford':
		array.append({name = "Return to Mansion",function = 'mansion'})
	else:
		if globals.resources.gold >= 25 :
			array.append({name = 'Teleport to Mansion - 25 gold', function = 'teleportmansion', textcolor = 'green', tooltip = '25 gold'})
		else:
			array.append({name = 'Teleport to Mansion - 25 gold', function = 'teleportmansion', textcolor = 'green', tooltip = '25 gold', disabled = true})
	outside.buildbuttons(array,self)
	

func frostfordzoe(stage):
	var text
	var buttons = []
	var sprite = [['zoehappy','pos1']]
	if stage == 1:
		text = globals.questtext.MainQuestFrostfordCityhallZoeAccept
		globals.state.sidequests.zoe = 1
	elif stage == 2:
		text = globals.questtext.MainQuestFrostfordCityhallZoeRefuse
		globals.state.sidequests.zoe = 100
	elif stage == 3:
		text = globals.questtext.MainQuestFrostfordZoeJoin
		sprite = [['zoehappy','pos1']]
		var person = globals.characters.create("Zoe")
		globals.state.sidequests.zoe = 3
		globals.slaves = person
		frostford()
	
	main.dialogue(true, self, text, buttons, sprite)

func frostfordcityhall():
	main.animationfade()
	yield(main, 'animfinished')
	globals.events.frostfordcityhall()

func frostfordmarket():
	main.animationfade()
	yield(main, 'animfinished')
	outside.shopinitiate('frostfordmarket')

func gornslaveguild():
	main.animationfade()
	yield(main, 'animfinished')
	outside.slaveguild('gorn')

func frostfordslaveguild():
	outside.slaveguild('frostford')


func shaliq():
	main.animationfade()
	yield(main, 'animfinished')
	var array = []
	if globals.state.sidequests.cali == 17:
		globals.events.calivillage()
	elif globals.state.sidequests.cali in [20,21]:
		globals.events.calivillage2()
	array.append({name = "Visit Local Trader", function = 'shaliqshop'})
	if globals.state.sidequests.chloe >= 1:
		array.append({name = "Visit Chloe's house", function = "chloehouse"})
	array.append({name = "Leave to the Forest", function = 'zoneenter', args = 'forest'})
	array.append({name = "Leave to the Eerie Grove", function = 'zoneenter', args = 'grove'})
	if globals.state.sidequests.chloe == 15:
		globals.state.sidequests.chloe = 16
		mansion.maintext = "You lead Chloe back to her house and give her some time to rest and clean herself."
		
	outside.buildbuttons(array,self)

func shaliqshop():
	outside.shopinitiate('shaliqshop')

func umbra():
	if globals.state.umbrafirstvisit == true:
		globals.state.umbrafirstvisit = false
		mansion.maintext = mansion.maintext + "\n\n" + globals.questtext.UmbraFirstVisit
	var array = []
	if globals.state.mainquest >= 38 && globals.state.portals.has('dragonnests') == false:
		globals.events.umbraportalenc()
	outside.location = 'umbra'
	array.append({name = "Black Market (shop)", function = 'umbrashop'})
	array.append({name = "Buy Slaves", function = 'umbrabuyslaves'})
	array.append({name = "Sell Servants", function = 'umbrasellslaves'})
	array.append({name = "Return to Mansion", function = 'mansionreturn'})
	outside.buildbuttons(array,self)

func umbrashop():
	outside.shopinitiate('blackmarket')

func umbrabuyslaves():
	outside.mindread = false
	outside.slavearray = globals.guildslaves.umbra
	outside.slaveguildslaves()

func umbrasellslaves():
	outside.sellslavelist('umbra')
	outside.sellslavelocation = 'umbra'

func chloeforest():
	globals.events.chloeforest()

func aynerisencounter():
	globals.events.aynerisforest()

func merchantrandomencounter():
	globals.events.merchantencounter()


func chloehouse():
	if globals.state.sidequests.chloe in [2,3]:
		globals.events.chloevillage(1)
	elif globals.state.sidequests.chloe in [4,5,6]:
		globals.events.chloevillage(4)
	elif globals.state.sidequests.chloe in [7,8,9]:
		globals.events.chloevillage(5)
	elif globals.state.sidequests.chloe == 10:
		globals.events.chloevillage(8)

func chloegrove():
	globals.events.chloegrove()

func encounterdictionary(text):
	var string = text
	var temp
	temp = str(enemygroup.units.size())
	if temp == '1':
		temp = 'sole'
	string = string.replace('$unitnumber', temp)
	if enemygroup.captured != null:
		temp = str(enemygroup.captured.size())
		if temp == '1':
			temp = 'sole'
		string = string.replace('$capturednumber', temp)
		string = string.replace('$capturedrace', enemygroup.captured[0].race)
		if enemygroup.captured[0].sex == 'male':
			temp = 'guy'
		else:
			temp = 'girl'
		string = string.replace('$capturedsex', temp)
		string = string.replace('$capturedchild', enemygroup.captured[0].dictionary('$child'))
	if enemygroup.units[0].capture != null:
		string = enemygroup.units[0].capture.dictionary(string)
	string = string.replace('$scoutname', scout.dictionary('$name'))
	return string

func unloadgroup():
	for i in globals.state.capturedgroup:
		globals.slaves = i
		if globals.count_sleepers().jail < globals.state.mansionupgrades.jailcapacity:
			i.sleep = 'jail'
			get_parent().infotext(i.dictionary("$name has been moved to jail"),'green')
		else:
			get_parent().infotext(i.dictionary("With no free cells in jail $name has been assigned to the communal room"),'yellow')
	for i in globals.state.backpack.stackables:
		var item = globals.itemdict[i]
		if item.type in ['ingredient']:
			item.amount += globals.state.backpack.stackables[i]
			globals.state.backpack.stackables.erase(i)

