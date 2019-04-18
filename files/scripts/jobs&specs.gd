
extends Node

var jobdict = {
rest = {
code = 'rest',
name = "Rest",
type = 'basic',
description = "$name will rest for today",
workline = "$name will be taking a rest for today.",
reqs = 'true',
unlockreqs = 'true',
maxnumber = 0,
order = 1,
location = 'mansion',
tags = ['mansion'],
},forage = {
code = 'forage',
name = 'Forage',
type = 'basic',
description = "$name will be looking around for edible berries and fungi.\n\n[color=yellow]Efficiency grows with Wit. Penalty affected by Courage. Strength and Endurance affect carrying weight. [/color]",
workline = '$name will be foraging in the nearby woods.',
reqs = 'true',
unlockreqs = 'true',
maxnumber = 0,
order = 2,
location = 'wild',
tags = ['wild','physical'],
},hunt = {
code = 'hunt',
name = "Hunt",
type = 'basic',
description = '$name will try hunting wild animals.\n\n[color=yellow]Efficiency grows Agility and Endurance. Penalty affected by Courage. Strength and Endurance affect carrying weight. [/color]',
workline = '$name will be hunting in the nearby woods.',
reqs = 'true',
unlockreqs = 'true',
maxnumber = 0,
order = 3,
location = 'wild',
tags = ['wild','physical'],
},library = {
code = 'library',
name = "Library",
type = 'basic',
description = '$name will manage the library and study.\n\n[color=yellow]Provides Experience and Learning Points based on Wit and Library level.\nExperience efficiency decreases with level.[/color]',
workline = "$name will be studying in the library.",
reqs = 'true',
unlockreqs = 'true',
maxnumber = 0,
order = 6,
location = 'mansion',
tags = ['mansion'],
},cooking = {
code = 'cooking',
name = "Cooking",
type = 'basic',
description = '$name will cook for the other residents and buy food from the market when it runs short.\n\n[color=yellow]Requires grade of [color=aqua]Poor[/color] or higher. \n\nEfficiency grows with Agility and Wit. [/color]',
workline = "$name will be cooking for residents.",
reqs = 'globals.originsarray.find(globals.currentslave.origins) >= 1',
unlockreqs = 'true',
maxnumber = 1,
order = 5,
location = 'mansion',
tags = ['mansion','physical'],
},maid = {
code = 'maid',
name = "Cleaning",
type = 'basic',
description = '$name will dedicate $his time to tidying your mansion. \n\n[color=yellow]Efficiency grows with Agility and Endurance.[/color]',
workline = "$name will spend $his day dedicated to cleaning your mansion.",
reqs = 'true',
unlockreqs = 'true',
maxnumber = 0,
order = 4,
location = 'mansion',
tags = ['mansion','physical'],
},nurse = {
code = 'nurse',
name = "Nurse",
type = 'basic',
description = '$name will help residents maintain and recover their health.\n\n[color=yellow]Efficiency grows with Wit and Magic Affinity.[/color]',
workline = "$name will be watching over residents' health.",
reqs = 'true',
unlockreqs = 'true',
maxnumber = 1,
order = 7,
location = 'mansion',
tags = ['mansion'],
},whorewimborn = {
code = 'whorewimborn',
name = "W - Prostitution",
type = 'sexual',
description = "$name will be assigned to the town's brothel as a common whore.\n\n[color=yellow]Efficiency grows with Charm, Endurance, Beauty and basic sexual actions. \n\nRequires unlocked sex actions for sufficient performance.[/color]",
workline = "$name will whore $himself at the brothel.",
reqs = "true",
unlockreqs = 'globals.state.sidequests.brothel >= 2',
maxnumber = 0,
order = 10,
location = 'wimborn',
tags = ['sex', 'wimborn', 'social'],
},
escortwimborn = {
code = 'escortwimborn',
name = "W - Escort",
type = 'sexual',
description = "$name will be assigned to the town's brothel as a high class whore for rich men. \n\n[color=yellow]Requires grade of a [color=aqua]Commoner[/color] or higher. \n\nEfficiency grows with Charm, Confidence, Beauty and your reputation. [/color]",
workline = "$name will be earning money as an escort for rich people.",
reqs = "globals.originsarray.find(globals.currentslave.origins) >= 2",
unlockreqs = 'globals.state.sidequests.brothel >= 2',
maxnumber = 0,
order = 11,
location = 'wimborn',
tags = ['sex', 'wimborn', 'social'],
},fucktoywimborn = {
code = 'fucktoywimborn',
name = "W - Exotic Whore",
type = 'sexual',
description = "$name will be used by the most deviant men in the brothel. \n\n[color=yellow]Efficiency grows with Courage, Endurance, Beauty, and advanced sex actions. \n\nRequires unlocked advanced sex actions for sufficient performance. [/color]",
workline = "$name will be earning money by offering $his body for all sorts of deviant plays.",
reqs = "true",
unlockreqs = 'globals.state.sidequests.brothel >= 2',
maxnumber = 0,
order = 12,
location = 'wimborn',
tags = ['sex', 'wimborn', 'social'],
},fucktoy = {
code = 'fucktoy',
name = "U - Fucktoy",
type = 'sexual',
description = "$name will be subjugated and abused by all sorts of criminals in Umbra without $his consent. \n\n[color=yellow]Builds obedience in exchange for mental degeneration. Income is based on your negative reputation. [/color]",
workline = "$name will be subjugated and abused by all sorts of criminals in Umbra without $his consent. ",
reqs = "true",
unlockreqs = 'globals.state.portals.umbra.enabled == true',
maxnumber = 0,
order = 12,
location = 'umbra',
tags = ['sex', 'umbra'],
},storewimborn = {
code = 'storewimborn',
name = "W - Market",
type = 'social',
description = "$name will attempt to sell excessive supplies or will try to make some profit by speculating with cheap products. \n\n[color=yellow]Efficiency grows with Charm, Wit and Grade. [/color]",
workline = "$name will be working at the town's market.",
reqs = 'true',
unlockreqs = 'true',
maxnumber = 0,
order = 8,
location = 'wimborn',
tags = ['wimborn','vocal', 'social','physical'],
},assistwimborn = {
code = 'assistwimborn',
name = "W - Mage Order Assistant",
type = 'social',
description = "$name will work as a staff member on various guild assignments. \n\n[color=yellow]Requires grade of [color=aqua]Commoner[/color] or higher. \n\nEfficiency grows with Magic Affinity, Wits and your reputation.[/color]",
workline = "$name will be working for the Mage's Order.",
reqs = "globals.originsarray.find(globals.currentslave.origins) >= 2 && globals.currentslave.traits.has('Mute') == false ",
unlockreqs = 'globals.state.rank >= 2',
maxnumber = 0,
order = 10,
location = 'wimborn',
tags = ['wimborn','social','physical'],
},artistwimborn = {
code = 'artistwimborn',
name = "W - Public Entertainer",
type = 'social',
description = "$name will earn money by doing dances, shows and other stage performances. \n\n[color=yellow]Requires grade of [color=aqua]Commoner[/color] or higher. \n\nEfficiency grows with Charm, Courage, Agility and beauty.[/color]",
workline = "$name will be working as a public entertainer.",
reqs = "globals.originsarray.find(globals.currentslave.origins) >= 2 && globals.currentslave.traits.has('Mute') == false",
unlockreqs = 'true',
maxnumber = 0,
order = 9,
location = 'wimborn',
tags = ['wimborn','vocal','social'],
},lumberer = {
code = 'lumberer',
name = "F - Lumberer",
type = 'social',
description = "$name will be cutting down trees near Frostford for a woodcutting company. [color=yellow]\n\nEfficiency grows with Strength and Endurance.[/color]",
workline = "$name will be cutting down trees near Frostford.",
reqs = "true",
unlockreqs = 'true',
maxnumber = 0,
order = 9,
location = 'frostford',
tags = ['frostford','physical'],
},ffprostitution = {
code = 'ffprostitution',
name = "F - Prostitution",
type = 'sexual',
description = "$name will be serving lone customers with $his body at Frostford. \n\n[color=yellow]\n\nEfficiency grows with Charm and beauty.[/color]",
workline = "$name will be serving lone customers with $his body in the streets of Frostford.",
reqs = "globals.currentslave.tags.find('nosex') < 0",
unlockreqs = 'true',
maxnumber = 0,
order = 9,
location = 'frostford',
tags = ['sex','frostford','social'],
},guardian = {
code = 'guardian',
name = "G - Guardian",
type = 'social',
description = "$name will be patrolling streets with Gorn's city guard. \n\n[color=yellow]Requires grade of [color=aqua]Poor[/color] or higher. \n\nEfficiency grows with Strength, Courage.[/color]",
workline = "$name will be patrolling streets with Gorn's city guard.",
reqs = "globals.originsarray.find(globals.currentslave.origins) >= 1 && globals.currentslave.traits.has('Mute') == false",
unlockreqs = 'true',
maxnumber = 0,
order = 9,
location = 'gorn',
tags = ['gorn','social'],
},research = {
code = 'research',
name = "U - Research Subject",
type = 'social',
description = "$name will be used in harsh experiments in Umbra. \n\n[color=yellow]\n\nWill earn a lot of money, but quickly deteriorate physical and mental health.[/color] \n[color=#ff4949]Can have negative consequences and even sometimes kill the servant. [/color]",
workline = "$name will be used in harsh experiments in Umbra.",
reqs = "true",
unlockreqs = 'globals.state.portals.umbra.enabled == true',
maxnumber = 0,
order = 9,
location = 'umbra',
tags = ['umbra'],
},slavecatcher = {
code = 'slavecatcher',
name = "G - Slave Catcher",
type = 'social',
description = "$name will be joining slaver parties and help catching and transporting slaves. \n\n[color=yellow]Requires grade of [color=aqua]Poor[/color] or higher.[/color] \n\nEfficiency grows with Agility, Strength and Courage.[/color]",
workline = "$name will be joining slaver parties and help catching and transporting slaves around Gorn.",
reqs = "globals.originsarray.find(globals.currentslave.origins) >= 1",
unlockreqs = 'true',
maxnumber = 0,
order = 9,
location = 'gorn',
tags = ['gorn','social','physical'],
},headgirl = {
code = 'headgirl',
name = "Headgirl",
type = 'social',
description = "$name will watch over other servants, improving their behavior. \n\n[color=yellow]Requires grade of [color=aqua]Rich[/color] or higher. [/color]",
workline = "$name will be directing and managing other residents.",
reqs = "globals.originsarray.find(globals.currentslave.origins) >= 3 && globals.currentslave.traits.has('Mute') == false ",
unlockreqs = 'globals.slaves.size() >= 8',
maxnumber = 1,
order = 12,
location = 'mansion',
tags = ['mansion','management'],
},jailer = {
code = 'jailer',
name = "Jailer",
type = 'social',
description = "$name will be feeding and watching over your prisoners.\n\n[color=yellow]Requires grade of [color=aqua]Poor[/color] or higher. [/color]",
workline = "$name will be managing prisoners.",
reqs = 'globals.originsarray.find(globals.currentslave.origins) >= 1',
unlockreqs = 'true',
maxnumber = 1,
order = 12,
location = 'mansion',
tags = ['mansion','management'],
},farmmanager = {
code = 'farmmanager',
name = "Farm Manager",
type = 'basic',
description = "$name will be managing your farm and slaves assigned to it. \n\n[color=yellow]Requires grade of [color=aqua]Commoner[/color] or higher. [/color]",
workline = "$name will be looking over your farm and collect its income.",
reqs = 'globals.originsarray.find(globals.currentslave.origins) >= 2',
unlockreqs = 'globals.state.farm >= 3',
maxnumber = 1,
order = 13,
location = 'mansion',
tags = ['mansion','management'],
},labassist = {
code = 'labassist',
name = "Laboratory Assistant",
type = 'basic',
description = "$name will be helping out and managing your laboratory operations.\n\n[color=yellow]Requires grade of [color=aqua]Commoner[/color] or higher. [/color]",
workline = "$name will be assisting you in the laboratory.",
reqs = 'globals.originsarray.find(globals.currentslave.origins) >= 2',
unlockreqs = 'globals.state.mansionupgrades.mansionlab >= 1',
maxnumber = 1,
order = 14,
location = 'mansion',
tags = ['mansion'],
},

}

var specs = {
geisha = {
name = "Geisha",
code = 'geisha',
descript = "A Geisha is an adept of love. They are trained to please both men and women, not only with sex but also in companionship. They are genuinely pleasant to have around as they try their best to feel what a potential partner might want. ",
descriptbonus = "+25% gold and half stress from escort and prostitution, no penalties for same-sex, opposite dominance or perverted actions",
descriptreqs = "Charm 75+, Beauty 60+, grade Commoner or above, unlocked sex.",
reqs = "person.charm >= 75 && person.beautybase >= 60 && !person.origins in ['slave','poor'] && person.consent == true"
},
ranger = {
name = "Ranger",
code = 'ranger',
descript = "Rangers are quick and resourceful individuals who are at home in any natural environment.. Not only do they have an eye for better opportunities, but also can spot richer preys. ",
descriptbonus = "+40% drop rate from combat encounters, forage and hunt efficiency + 25%, scouting bonus",
descriptreqs = "Wit 75+, Endurance 3+.",
reqs = "person.wit >= 75 && person.send >= 3"
},
executor = {
name = "Executor",
code = 'executor',
descript = "Executors are trained to work with people in a most efficient way. Their commands are always straight and on-point and their attitude is met with respect. ",
descriptbonus = "At least 100 confidence for Management-related tasks. Obedience can't drop below 50.",
descriptreqs = "Conf 75+, Wit 50+, grade Rich or above",
reqs = "person.conf >= 75 && person.wit >= 50 && person.origins in ['rich', 'noble']"
},
bodyguard = {
name = "Bodyguard",
code = 'bodyguard',
descript = "A Bodyguard is trained to put their Master’s life before their own. Not only are they capable of taking down threats on their own, but are also substantially more effective at protecting others. ",
descriptbonus = "+ 4 Armor, +40 Maximum Health, 'Protect' action doubles the amount of reduced damage.",
descriptreqs = "Courage 60+, agility 3+, strength 4+, loyalty 50+",
reqs = "person.cour >= 60 && person.sagi >= 3 && person.sstr >= 4 && person.loyal >= 50"
},
assassin = {
name = "Assassin",
code = 'assassin',
descript = "Assassins are trained to act swiftly and decisively, when required. They prefer efficiency over show and offence to defence.  ",
descriptbonus = "Speed +5, Damage +5",
descriptreqs = "Agility 5+, Wit 65+",
reqs = "person.wit >= 65 && person.sagi >= 5"
},
housekeeper = {
name = "Housekeeper",
code = 'housekeeper',
descript = "Housekeepers are experts at supplying and taking care of the living quarters. ",
descriptbonus = "Will clean the house on stationary jobs (half effect of normal cleaning). Personal daily expenses are cut in half.",
descriptreqs = "None",
reqs = "true"
},
trapper = {
name = "Trapper",
code = 'trapper',
descript = "Trappers are generally common professionals you can find in any slavers party. They are also reasonably well trained in hunting. ",
descriptbonus = "Bonus hunting +20%, 50% chance to automatically capture escaping person, bonus capture rate. ",
descriptreqs = "Wit 50+, Grade: Commoner and above ",
reqs = "person.wit >= 50 && !person.origins in ['slave','poor']"
},
nympho = {
name = "Nympho",
code = 'nympho',
descript = "Nymphos devote their life entirely to the lewdness. They are ready for anything and everything and want more. It's common practice to make such slaves into tools and toys for their owners. ",
descriptbonus = "+1 mana from sex actions, +25% to fucktoy, half stress from other sexual jobs, no penalties from any sex activities.",
descriptreqs = "Grade: Commoner and below, Unlocked sex, Charm and Courage 50+ ",
reqs = "person.origins in ['slave','poor','commoner'] && person.consent == true && person.cour >= 50 && person.charm >= 50"
},
merchant = {
name = "Merchant",
code = 'merchant',
descript = "People with a talent for bargains, not only profitable to keep around, but also good at connecting with others. ",
descriptbonus = "Bonus to market job, 25% bonus to non-gear item selling while in party (does not stack).",
descriptreqs = "Wit and Charm 50+ ",
reqs = "person.wit >= 50 && person.charm >= 50"
},
tamer = {
name = "Tamer",
code = 'tamer',
descript = "Tamers are trained to work with wild animals and savagely behaving individuals. By utilizing many simple lessons they will eventually bring their true potential out of those. ",
descriptbonus = "Uncivilized races become more obedient and can lose that trait while a Tamer is resting, managing or working on the same occupation. ",
descriptreqs = "Confidence and charm 50+, Grade: Commoner and above, not Uncivilized",
reqs = "person.conf >= 50 && person.charm >= 50 && person.origins in ['commoner','rich','noble'] && !person.traits.has('Uncivilized')"
},
}

var leveluprequests = {
weakitem = {reqs = 'true', speech = "you will need a [color=aqua]$item[/color] to unlock $his potential. ", descript = '$name needs a [color=aqua]$item[/color] to advance $his level.  ', execfunc = 'weakitem'},
multitem = {reqs = 'true', speech = "you will need a [color=aqua]$item[/color] to unlock $his potential. ", descript = '$name needs a [color=aqua]$item[/color] to advance $his level.  ', execfunc = 'multitem'},
gearitem = {reqs = 'true', speech = "you will need a [color=aqua]$item[/color] to unlock $his potential. ", descript = '$name needs a [color=aqua]$item[/color] to advance $his level.  ', execfunc = 'gearitem'},
ingreditem = {reqs = 'true', speech = "you will need a [color=aqua]$item[/color] to unlock $his potential. ", descript = '$name needs [color=aqua]$item[/color] to advance $his level. ', execfunc = 'ingreditem'},
vacation = {reqs = 'true', speech = "you should provide $name with [color=aqua]3 free days[/color] to furtherly unlock $his potential.", descript = '$name needs a [color=aqua]vacation[/color] to advance $his level. ', execfunc = 'vacationshort'},
relationship = {reqs = "person.consent == false && person.tags.find('nosex') < 0", speech = "you should unlock [color=aqua]intimacy[/color] with $name to unlock $his potential.", descript = "$name needs to have [color=aqua]intimacy unlocked[/color] to advance $his level. ", execfunc = 'startrelationship'},
wincombat = {reqs = 'true', speech = "you should let $name to [color=aqua]win in a fight[/color] to unlock $his potential.", descript = "$name needs to [color=aqua]win in a fight[/color] to advance $his level. ", execfunc = 'wincombat'},
improvegrade = {reqs = 'globals.originsarray.find(person.origins) <= 3', speech = "you should raise $name's [color=aqua]grade[/color] to unlock $his potential.", descript = "$name needs to [color=aqua]raise $his grade[/color] to advance $his level. ", execfunc = 'raisegrade'},
specialization = {reqs = 'person.spec == null && person.level >= 4', speech = "you should let $name's [color=aqua]learn a specialization[/color] to unlock $his potential.", descript = "$name needs to [color=aqua]learn a specialization[/color] to advance $his level. ", execfunc = 'getspec'},
}

var requestsbylevel = {
easy = ['weakitem', 'ingreditem', 'vacation', 'relationship', 'wincombat', 'improvegrade'],
medium = ['multitem','specialization','gearitem','improvegrade'],
}


var weakitemslist = ['aphrodisiac','hairdye', 'hairgrowthpot', 'stimulantpot', 'deterrentpot', 'beautypot']
var gearitemslist = ['clothsundress','clothmaid','clothkimono','clothmiko','clothbutler','underwearlacy','underwearboxers','armorleather','armorchain','weapondagger','weaponsword','accslavecollar','acchandcuffs']
var ingredlist = ['bestialessenceing', 'natureessenceing','taintedessenceing','magicessenceing','fluidsubstanceing']

func vacation(person):
	person.away.duration = int(person.levelupreqs.value)
	globals.get_tree().get_current_scene()._on_mansion_pressed()
	globals.get_tree().get_current_scene().popup(person.dictionary("You've sent $name on vacation, boosting $his mood with this sudden reward. "))
	person.levelup()

func itemlevelup(person):
	if globals.state.getCountStackableItem(person.levelupreqs.value) < 1:
		globals.get_tree().get_current_scene().popup(person.dictionary("Sadly, you have no available " + globals.itemdict[person.levelupreqs.value].name + " in possession. "))
	else:
		globals.state.removeStackableItem(person.levelupreqs.value)
		globals.get_tree().get_current_scene().popup(person.dictionary("You gift $name " + globals.itemdict[person.levelupreqs.value].name + ". After returning a surprised look, $he whole-heartedly shows $his gratitude"))
		person.levelup()

func gearlevelup(person):
	var item = person.levelupreqs.value
	var founditem = false
	for i in globals.state.unstackables.values():
		if i.code == item && i.owner == null:
			globals.state.unstackables.erase(i.id)
			founditem = true
			break
	if founditem == true:
		globals.get_tree().get_current_scene().popup(person.dictionary("You gift $name " + globals.itemdict[person.levelupreqs.value].name + ". After returning a surprised look, $he whole-heartedly shows $his gratitude"))
		person.levelup()
	else:
		globals.get_tree().get_current_scene().popup("Sadly, there's no unused [color=aqua]" + globals.itemdict[person.levelupreqs.value].name + "[/color] in your possessions. ")

func vacationshort(person):
	var text = person.dictionary(leveluprequests.vacation.speech)
	person.levelupreqs = {code = 'vacation', value = '3', speech = leveluprequests.vacation.speech, descript = person.dictionary(leveluprequests.vacation.descript), button = person.dictionary('Send $name on vacation'), effect = 'vacation', activate = 'fromtalk'}
	return text

func weakitem(person):
	var item = globals.itemdict[weakitemslist[rand_range(0,weakitemslist.size())]]
	var text = person.dictionary(leveluprequests.weakitem.speech)
	text = text.replace('$item', item.name)
	var descript = person.dictionary(leveluprequests.weakitem.descript).replace('$item', item.name)
	person.levelupreqs = {code = 'weakitem', value = item.code, speech = text, descript = descript , button = person.dictionary('Provide $name with $item').replace('$item', item.name), effect = 'itemlevelup', activate = 'fromtalk'}
	return text

func multitem(person):
	var array = []
	var count = 2
	var item
	var itemnumber
	var itemtext = ''
	var array2 = []
	for i in ingredlist:
		if !(i in ['fluidsubstanceing','taintedessenceing'] && globals.state.mainquest < 17):
			array.append(i)
	while count < array.size():
		array.remove(rand_range(0,array.size()))
	for i in array:
		item = globals.itemdict[i]
		itemnumber = round(rand_range(1,3))
		itemtext += item.name + ': ' + str(itemnumber) + ", "
		array2.append({item.code : itemnumber})
		
	
	var text = person.dictionary(leveluprequests.multitem.speech)
	text = text.replace('$item', itemtext)
	var descript = person.dictionary(leveluprequests.multitem.descript).replace('$item', itemtext)
	person.levelupreqs = {code = 'multitem', value = array2, speech = text, descript = descript , button = person.dictionary('Provide $name with necessary items'), effect = 'multitemlevelup', activate = 'fromtalk'}
	return text

func multitemlevelup(person):
	var hasitems = true
	for i in person.levelupreqs.value:
		for k in i:
			if globals.state.getCountStackableItem(k) < i[k]:
				hasitems = false
	if hasitems == false:
		globals.get_tree().get_current_scene().popup("Sadly, you don't have all required items in your possessions. ")
	else:
		for i in person.levelupreqs.value:
			for k in i:
				globals.state.removeStackableItem(k,i[k])
		globals.get_tree().get_current_scene().popup(person.dictionary("You gift $name an assortment of items. After returning a surprised look, $he whole-heartedly shows $his gratitude"))
		person.levelup()

func gearitem(person):
	var item = globals.itemdict[gearitemslist[rand_range(0,gearitemslist.size())]]
	var text = person.dictionary(leveluprequests.gearitem.speech)
	text = text.replace('$item', item.name)
	var descript = person.dictionary(leveluprequests.gearitem.descript).replace('$item', item.name)
	person.levelupreqs = {code = 'gearitem', value = item.code, speech = text, descript = descript , button = person.dictionary('Provide $name with $item').replace('$item', item.name), effect = 'gearlevelup', activate = 'fromtalk'}
	return text

func getspec(person):
	var text = person.dictionary(leveluprequests.specialization.speech)
	person.levelupreqs = {code = 'specialization', value = '0', speech = leveluprequests.specialization.speech, descript = person.dictionary(leveluprequests.specialization.descript), effect = 'specialization', activate = 'action'}
	return text

func ingreditem(person):
	var ingnumber = 1
	var ingrange = [1,3]
	var finalitems = {}
	var item
	var text = ''
	var temptext = ''
	var itemarray = []
	for i in ingredlist:
		if !(i in ['fluidsubstanceing','taintedessenceing'] && globals.state.mainquest < 17):
			itemarray.append(i)
	while ingnumber >= 1:
		ingnumber -= 1
		item = itemarray[rand_range(0,itemarray.size())]
		finalitems[item] = round(rand_range(ingrange[0], ingrange[1]))
	for i in finalitems:
		item = globals.itemdict[i]
		temptext += item.name + ": " + str(finalitems[i]) + ", "
	temptext = temptext.substr(0, temptext.length() -2)+ ' '
	text = person.dictionary(leveluprequests.ingreditem.speech.replace('$item', temptext)) 
	var descript = person.dictionary(leveluprequests.ingreditem.descript).replace('$item', temptext)
	person.levelupreqs = {code = 'ingreditem', value = [finalitems], speech = text, descript = descript , button = person.dictionary('Provide $name with $item').replace('$item', temptext), effect = 'multitemlevelup', activate = 'fromtalk'}
	return text

func startrelationship(person):
	var text = person.dictionary(leveluprequests.relationship.speech)
	person.levelupreqs = {code = 'relationship', value = '0', speech = leveluprequests.relationship.speech, descript = person.dictionary(leveluprequests.relationship.descript), effect = 'relationship', activate = 'action'}
	return text

func wincombat(person):
	var text = person.dictionary(leveluprequests.wincombat.speech)
	person.levelupreqs = {code = 'wincombat', value = '0', speech = leveluprequests.wincombat.speech, descript = person.dictionary(leveluprequests.wincombat.descript), effect = 'wincombat', activate = 'action'}
	return text

func raisegrade(person):
	var text = person.dictionary(leveluprequests.improvegrade.speech)
	person.levelupreqs = {code = 'improvegrade', value = '0', speech = leveluprequests.improvegrade.speech, descript = person.dictionary(leveluprequests.improvegrade.descript), effect = 'improvegrade', activate = 'action'}
	return text

func getrequest(person):
	var array = []
	if person.level in [1,2]:
		for i in requestsbylevel.easy:
			if globals.evaluate(leveluprequests[i].reqs) == true:
				array.append(leveluprequests[i])
	else:
		for i in requestsbylevel.medium:
			if globals.evaluate(leveluprequests[i].reqs) == true:
				array.append(leveluprequests[i])
	var request = array[rand_range(0, array.size())]
	var text = call(request.execfunc, person)
	return text



func rest(person):
	var text = '$name has spent most of the day relaxing.\n'
	person.health += 10
	person.stress -= 20
	return {text = text}

func forage(person):
	var text = '$name went to the forest in search of wild edibles.\n'
	var food = rand_range(15,25) - min(globals.resources.day/10,10)
	food += person.wit/4
	if person.race == 'Dryad':
		food = food*1.4
	if person.cour < 50 && rand_range(0,100) + person.cour/5 < 33:
		food = food*rand_range(0.25, 0.75)
		text += "Due to [color=yellow]lack of courage[/color], $he obtained less food than $he could. \n"
	if person.smaf * 3 + 2 >= rand_range(0,100):
		text += "$name has found nature's essence. \n"
		globals.itemdict.natureessenceing.amount += 1
	food = min(food, (person.sstr+person.send)*20+25)
	if person.spec == 'ranger':
		food *= 1.25
	food = round(food)
	text += '$He brought back [color=aqua]'+ str(food) + '[/color] units of food.\n'
	person.xp += food/5
	var dict = {text = text, food = food}
	
	return dict

func hunt(person):#agility, strength, endurance, courage
	var text = "$name went to the forest to search for wild animals.\n"
	var food = person.awareness(true)*rand_range(2,4) + max(0,person.send*rand_range(5,10))
	if person.cour < 60 && rand_range(0,100) + person.cour/4 < 45:
		food = food*rand_range(0.25, 0.50)
		text +=  "Due to [color=yellow]lack of courage[/color], $he obtained less food than $he could. \n"
	if person.race == 'Arachna':
		food = food*1.3
	if person.spec in ['ranger','trapper']:
		food *= 1.25
	food = round(min(food, (person.sstr+person.send)*30+40))
	globals.itemdict.supply.amount += round(food/12)
	person.xp += food/7
	text += "In the end $he brought [color=aqua]" + str(round(food)) + "[/color] food and [color=yellow]" + str(round(food/12)) + "[/color] supplies. \n"
	if person.smaf * 3 + 3 >= rand_range(0,100):
		text += "$name has found bestial essence. \n"
		globals.itemdict.bestialessenceing.amount += 1
	
	var dict = {text = text, food = food}
	return dict

func library(person):
	var text = "$name spends $his time studying in the library.\n"
	if person.race == 'Gnome':
		person.xp += 2 * max((15 + 5*globals.state.mansionupgrades.mansionlibrary + person.wit/12) - (person.level-1)*8,0)
		person.learningpoints += ceil(2 * (person.wit/20 + globals.state.mansionupgrades.mansionlibrary))
	else:
		person.xp += max((15 + 5*globals.state.mansionupgrades.mansionlibrary + person.wit/12) - (person.level-1)*8,0)
		person.learningpoints += ceil(person.wit/20)+globals.state.mansionupgrades.mansionlibrary
	if person.traits.has("Clever"):
		person.learningpoints += 2
	var dict = {text = text}
	return dict

func nurse(person):
	var text = "$name is taking care of residents' health.\n"
	if globals.player.health < globals.player.health_max:
		globals.player.health += person.wit/15+person.smaf*3
		person.xp += rand_range(1,3)
	for i in globals.slaves:
		if i.away.duration == 0 && i.health < i.stats.health_max:
			if globals.itemdict.supply.amount > 0:
				i.health += person.wit/25+person.smaf*3
			else:
				i.health += person.wit/35+person.smaf*3
			person.xp += rand_range(1,3)
	
	var dict = {text = text}
	return dict

func cooking(person):
	var text = ''
	var gold = 0
	var food = 0
	person.xp += globals.slaves.size()
	if globals.resources.food < 200:
		if globals.resources.gold >= globals.state.foodbuy/2:
			text = '$name went to purchase groceries and brought back new food supplies.\n'
			gold = -globals.state.foodbuy/2
			food = globals.state.foodbuy
		else:
			text = '$name complained about the lack of food and no money to supply the kitchen on $his own.\n'
	text += '$name spent $his time preparing meals for everyone.\n'
	text = person.dictionary(text)
	var dict = {text = text, gold = gold, food = food}
	return dict

func lumberer(person):
	var text = "$name spent the day in the Frostford woods, cutting and chopping trees. \n"
	var gold = max(person.sstr*rand_range(4,8) + person.send*rand_range(4,8),5)
	person.xp += gold/4
	text += "In the end $he made [color=yellow]" + str(round(gold)) + "[/color] gold\n"
	var dict = {text = text, gold = gold}
	return dict

func ffprostitution(person):
	var text = "$name spent the day in Frostford, selling $his body for sexual pleasure.\n"
	var gold = 0
	person.metrics.brothel += 1
	var jobactions = ['vaginal','anal','oral','toys']
	if person.vagvirgin == true:
		person.vagvirgin = false
		#slave.pussy.first = 'brothel'
		person.health -= 5
		person.stress += 15
		text += "$His virginity was taken by one of the customers.\n"
	person.lust -= rand_range(15,25)
	person.lastsexday = globals.resources.day
	person.loyal += rand_range(-1,-3)
	if rand_range(1,10) > 4:
		globals.impregnation(person)
	var counter = 0
	gold = rand_range(1,5) + max(5, person.charm/4 + person.send*15 + person.lewdness/2) + person.beauty/5
	if person.traits.has('Sex-crazed') == true || person.traits.has('Fickle') == true:
		person.stress += -counter*4
		gold = gold*1.2
	if person.mods.has("augmenttongue"):
		gold = gold * 1.15
	person.metrics.randompartners += round(rand_range(2,4))
	person.metrics.sex += round(rand_range(2,5))
	if person.race.find('Bunny') >= 0 || person.spec in ['geisha','nympho']:
		person.stress += 12 - min(counter*4, 10)
	else:
		person.stress += 25 - min(counter*5, 20)
	if person.spec == 'geisha':
		gold = gold*1.25
	gold = round(gold)
	person.xp += gold/5
	text += "By the end of the day $he earned [color=yellow]"+ str(gold) + "[/color] gold.\n"
	
	var dict = {text = text, gold = gold}
	return dict

func guardian(person):
	var text = "$name spent the day in Gorn, patrolling the city as part of the guard.\n"
	var gold = max(person.sstr*rand_range(5,10) + person.cour/4,5)
	person.xp += gold/6
	text += "In the end $he made [color=yellow]" + str(round(gold)) + "[/color] gold\n"
	person.loyal -= 1
	var dict = {text = text, gold = gold}
	return dict

func research(person):
	var text = "$name spent the day being used in magical experiments. \n"
	var gold = 25*(globals.originsarray.find(person.origins)+1) + 20*person.level + rand_range(0,10)
	var array = []
	var dead = false
	text += "In the end $he earned [color=yellow]" + str(round(gold)) + "[/color] gold\n"
	person.obed += rand_range(15,25)
	if rand_range(0,100) >= 40:
		person.health -= person.health/3
	if rand_range(0,100) < 30:
		array = ['conf','cour','wit','charm']
		person[array[rand_range(0,array.size())]] -= rand_range(15,25)
		text += "[color=#ff4949]$name's mental health has been damaged. [/color]"
	if rand_range(0,100) < 20 && person.send >= 1:
		person.send -= 1
		text += "[color=#ff4949]$name's physical health has been damaged. [/color]"
	if person.wit >= 65 && person.cour >= 65 && rand_range(0,100) <= 15:
		text = "[color=#ff4949]$name has managed to escape from the place of $his employment and hasn't returned to mansion. [/color]"
		dead = true
	person.stress += rand_range(10,25)
	if rand_range(35,50) > person.health && rand_range(0,100) < 15:
		person.health -= 200
		dead = true
		text = "[color=#ff4949]Due to life-threatening experiments $name has deceased.[/color]"
	var dict = {text = person.dictionary(text), gold = gold, dead = dead}
	return dict

func fucktoy(person):
	var gold = 0
	var text
	person.metrics.brothel += 1
	text = "$name was sent to Umbra to be used as a Fucktoy.\n"
	var jobactions = ['oral','anal','vaginal','fetish','fetish2','toy','group']
	if person.vagvirgin == true:
		person.vagvirgin = false
		#slave.pussy.first = 'brothel'
		person.health -= 5
		person.stress += 10
		person.loyal += rand_range(-2,-4)
		text += "$His virginity was taken by one of the customers.\n"
	if rand_range(1,10) > 2:
		globals.impregnation(person)
	var counter = 0
	person.lastsexday = globals.resources.day
	for i in globals.state.reputation:
		if globals.state.reputation[i] < 0:
			gold += abs(globals.state.reputation[i])
	gold += rand_range(5,10)
	if person.traits.has('Sex-crazed'):
		person.stress -= counter*3
	person.metrics.sex += round(rand_range(3,6))
	person.metrics.randompartners += round(rand_range(2,5))
	if person.mods.has("augmenttongue"):
		gold = gold * 1.15
	gold = round(gold)
	if person.wit >= 25:
		person.loyal -= 8
	if person.conf >= 25:
		person.stress += 15
	if person.effects.has('captured'):
		person.effects.captured.duration -= 3
	person.obed += 20
	person.asser -= rand_range(4,8)
	text += "By the end of the day $he earned [color=yellow]" + str(gold) + "[/color] gold.\n"
	var dict = {text = text, gold = gold}
	return dict


func slavecatcher(person):
	var text = "$name spent the day helping Gorn's slavers to acquire and transport slaves. \n"
	var gold = max(5, person.sstr*rand_range(5,10) + person.sagi*rand_range(5,10) + person.cour/4)
	person.xp += gold/6
	text += "In the end $he made [color=yellow]" + str(round(gold)) + "[/color] gold\n"
	person.stress += rand_range(5,15)
	person.loyal -= rand_range(1,3)
	var dict = {text = text, gold = gold}
	return dict

func storewimborn(person):
	var text = "$name worked at the local market. "
	var bonus = 1
	var supplyPrice = round(rand_range(3,4))
	if person.race.find("Tanuki")>= 0:
		bonus += 0.3
		supplyPrice += 1
	if person.traits.has('Pretty voice') == true:
		bonus += 0.2
	elif person.traits.has('Foul Mouth') == true:
		bonus -= 0.3
	if person.spec == 'merchant':
		bonus += 0.3
		supplyPrice += 1
	var gold = rand_range(1,5) + (person.charm + person.wit) / 2
	gold = round(gold * min(0.30 * (globals.originsarray.find(person.origins) + 1), 1) * bonus)

	var supplySold = min(floor(gold / supplyPrice), globals.itemdict.supply.amount - globals.state.supplykeep)
	if supplySold > 0:
		gold += supplySold * supplyPrice / 3
		globals.itemdict.supply.amount -= supplySold
		text += "$He managed to sell [color=yellow]" + str(supplySold) + "[/color] units of supplies. "
	elif globals.state.supplybuy == true && supplySold < 0:
		supplySold = min(floor(gold / 5), -supplySold)
		gold -= 5 * supplySold
		globals.itemdict.supply.amount += supplySold
		text += "With the money earned $he purchased [color=yellow]" + str(supplySold) + "[/color] supply units. "
		supplySold = -supplySold

	gold = round(gold)
	person.xp += gold / 4
	person.stress += rand_range(5,10)
	text = text + "$He earned "+str(gold)+" gold by the end of day.\n"
	var dict = {text = text, gold = gold, supplies = -supplySold}
	return dict

func assistwimborn(person):
	var text
	var gold
	text = "$name worked at the Mage's Order.\n"
	gold = rand_range(1,5) + person.smaf*15 + person.wit/4 + min(globals.state.reputation.wimborn/1.5,50)
	gold = round(max(5, gold))
	person.xp += gold/5
	person.stress += rand_range(5,10)
	text = text + "$He earned [color=yellow]"+str(gold)+"[/color] gold by the end of day.\n"
	var dict = {text = text, gold = gold}
	return dict

func artistwimborn(person):
	var text
	var gold
	text ="$name worked in town as a public entertainer.\n"
	gold = rand_range(1,5) + max(5, person.cour/7 + person.charm/4 + person.sagi*20) + person.beauty/3
	if person.race == 'Nereid':
		gold = gold*1.25
	if person.traits.has('Pretty voice') == true:
		gold = gold*1.2
	elif person.traits.has('Foul Mouth') == true:
		gold = gold*0.7
	gold = round(gold)
	person.stress += rand_range(10,15)
	person.xp += gold/7
	text += "$He earned [color=yellow]"+str(gold)+"[/color] gold by the end of day.\n"
	var dict = {text = text, gold = gold}
	return dict

func whorewimborn(person):
	var text = "$name went to work as a whore at the brothel.\n"
	var gold = 0
	person.metrics.brothel += 1
	var jobactions = ['vaginal','anal','oral','toys']
	if person.vagvirgin == true:
		person.vagvirgin = false
		#slave.pussy.first = 'brothel'
		person.health -= 5
		person.stress += 15
		text += "$His virginity was taken by one of the customers.\n"
	person.lust -= rand_range(15,25)
	person.lastsexday = globals.resources.day
	person.loyal += rand_range(-1,-3)
	if rand_range(1,10) > 4:
		globals.impregnation(person)
	var counter = 0
	gold = rand_range(1,5) + max(5, person.charm/4 + person.send*15 + person.lewdness/2) + person.beauty/5
	if person.traits.has('Sex-crazed') == true || person.traits.has('Fickle') == true:
		person.stress += -counter*4
		gold = gold*1.2
	if person.mods.has("augmenttongue"):
		gold = gold * 1.15
	if person.lewdness < 15:
		text += "\nThe owner of the brothel complained that $name does not have sufficient skill and didn't satisfy many customers. $His salary was cut by half. \n"
		gold = gold/2
		person.metrics.sex += round(rand_range(1,3))
		person.metrics.randompartners += round(rand_range(1,2))
	else:
		person.metrics.randompartners += round(rand_range(2,4))
		person.metrics.sex += round(rand_range(2,5))
	if person.race.find('Bunny') >= 0 || person.spec in ['geisha','nympho']:
		person.stress += 12 - min(counter*4, 10)
	else:
		person.stress += 25 - min(counter*5, 20)
	if person.spec == 'geisha':
		gold = gold*1.25
	gold = round(gold)
	person.xp += gold/5
	text += "By the end of the day $he earned [color=yellow]"+ str(gold) + "[/color] gold.\n"
	
	var dict = {text = text, gold = gold}
	return dict

func escortwimborn(person):
	person.metrics.brothel += 1
	var text = "$name provided escort service for rich clients of the brothel.\n"
	var gold
	if person.vagvirgin == true:
		person.vagvirgin = false
		person.health -= 5
		if person.race.find('Bunny') >= 0:
			person.stress += 7
		else:
			person.stress += 15
		person.loyal += rand_range(-1,-3)
		text += "$His virginity was taken by one of the customers.\n"
	if person.race.find('Bunny') >= 0 || person.spec in ['geisha','nympho']:
		person.stress += 10 - person.lewdness/5
	else:
		person.stress += 20 - person.lewdness/10
	person.lust -= rand_range(10,20)
	person.lastsexday = globals.resources.day
	if rand_range(1,10) > 7:
		globals.impregnation(person)
	gold = rand_range(15,35) + person.conf/3 + person.beauty/3 + max(5, person.charm/1.8 + min(globals.state.reputation.wimborn,60))
	if person.traits.has('Pretty voice') == true:
		gold = gold*1.2
	elif person.traits.has('Foul Mouth') == true:
		gold = gold*0.7
	if person.race.find('Fox') >= 0:
		gold = gold*1.2
	if person.spec == 'geisha':
		gold = gold*1.25
	if person.mods.has("augmenttongue"):
		gold = gold * 1.15
	gold = round(gold)
	person.xp += gold/6
	person.metrics.randompartners += round(rand_range(1,2))
	person.metrics.sex += round(rand_range(1,2))
	text += "By the end of the day $he earned [color=yellow]"+ str(gold) + "[/color] gold.\n"
	
	var dict = {text = text, gold = gold}
	return dict

func fucktoywimborn(person):
	var gold
	var text
	person.metrics.brothel += 1
	text = "$name went to work as an exotic whore.\n"
	var jobactions = ['oral','anal','vaginal','fetish','fetish2','toy','group']
	if person.vagvirgin == true:
		person.vagvirgin = false
		#slave.pussy.first = 'brothel'
		person.health -= 5
		person.stress += 10
		person.loyal += rand_range(-2,-4)
		text += "$His virginity was taken by one of the customers.\n"
	if rand_range(1,10) > 2:
		globals.impregnation(person)
	var counter = 0
	gold = rand_range(5,10) + person.cour/2.3 + person.send*15 + person.beauty/5 + person.lewdness/1.5
	if person.traits.has('Sex-crazed') == true || person.traits.has('Fickle'):
		person.stress += -counter*4
		gold = gold*1.2
	if person.vagina != 'none' && person.penis != 'none':
		gold = gold*1.1
	if person.mods.has("hollownipples") == true:
		gold = gold*1.2
	if person.mods.has("augmenttongue"):
		gold = gold * 1.15
	if person.lewdness < 45:
		text += "\nThe owner of the brothel complained that $name does not have sufficient skill and didn't satisfy many customers. $His salary was cut by half. \n"
		person.metrics.sex += round(rand_range(2,4))
		gold = gold/2
		person.metrics.randompartners += round(rand_range(1,4))
	else:
		
		person.metrics.sex += round(rand_range(3,6))
		person.metrics.randompartners += round(rand_range(2,5))
	
	
	if person.race.find('Bunny') >= 0 || person.spec == 'nympho':
		person.stress += 25 - min(counter*4, 20)
	else:
		person.stress += 50 - min(counter*7, 35)
	person.lust -= rand_range(20,30)
	person.lastsexday = globals.resources.day
	if person.spec == 'nympho':
		gold = gold*1.25
	gold = round(gold)
	person.xp += gold/6
	text += "By the end of the day $he earned [color=yellow]" + str(gold) + "[/color] gold.\n"
	var dict = {text = text, gold = gold}
	return dict

func maid(person):
	var text = ""
	var temp = 5.5 + (person.sagi+person.send)*6
	person.xp += temp/4
	globals.state.condition = temp
	text = "$name spent the day cleaning around the mansion. \n"
	var dict = {text = text}
	return dict

