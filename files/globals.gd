
extends Node

var effectdict = {}
var guildslaves = {wimborn = [], gorn = [], frostford = [], umbra = []}
var gameversion = '0.5.23c'
var state = progress.new()
var developmode = false
var gameloaded = false

var mainscreen = 'mainmenu'

var filedir = 'res://files'
var backupdir = 'res://backfup'

var resources = resource.new()
var person = load("res://files/scripts/person/person.gd")
var questtext = load("res://files/scripts/questtext.gd").new()
var slavegen = load("res://files/scripts/slavegen.gd").new()
var assets = load("res://files/scripts/assets.gd").new()
var constructor = load("res://files/scripts/characters/constructor.gd").new()
var origins = load("res://files/scripts/origins.gd").new()
var description = load("res://files/scripts/characters/description.gd").new()
var dictionary = load("res://files/scripts/dictionary.gd").new()
var sexscenes = load("res://files/scripts/sexscenes.gd").new()
var glossary = load("res://files/scripts/glossary.gd").new()
var repeatables = load("res://files/scripts/repeatable_quests.gd").new()
var abilities = load("res://files/scripts/abilities.gd").new()
var effects = load("res://files/scripts/effects.gd").new()
var events = load("res://files/scripts/events.gd").new()
var items = load("res://files/scripts/items.gd").new()
var spells = load("res://files/scripts/spells.gd").new()
var spelldict = spells.spelllist
var itemdict = items.itemlist
var racefile = load("res://files/scripts/characters/races.gd").new()
var races = racefile.races
var names = racefile.names
var dailyevents = load("res://files/scripts/dailyevents.gd").new()
var jobs = load("res://files/scripts/jobs&specs.gd").new()
var mansionupgrades = load("res://files/scripts/mansionupgrades.gd").new()
var gallery = load("res://files/scripts/gallery.gd").new()
var slavedialogues = load("res://files/scripts/slavedialogues.gd").new()
var characters = gallery
var patronlist = load("res://files/scripts/patronlists.gd").new()
var areas = load('res://files/scripts/explorationregions.gd').new()
var combatdata = load("res://files/scripts/combatdata.gd").new()

#QMod - Variables
var mainQuestTexts = events.mainquestTexts
var sideQuestTexts = events.sidequestTexts
var places = {
	anywhere = {region = 'any', area = 'any', location = 'any'},
	nowhere = {region = 'none', area = 'none', location = 'none'},
	wimborn = {region = 'wimborn', area = 'any', location = 'any'},
	gorn = {region = 'gorn', area = 'any', location = 'any'},
	frostford = {region = 'frostford', area = 'any', location = 'any'}
}
var main

var slaves = [] setget slaves_set
var allracesarray = []
var specarray = ['geisha','ranger','executor','bodyguard','assassin','housekeeper','trapper','nympho','merchant','tamer']
var player = person.new()
var partner

var spritedict = gallery.sprites
var musicdict = {
combat1 = load("res://files/music/battle1.ogg"),
combat2 = load("res://files/music/battle2.ogg"),
combat3 = load("res://files/music/battle3.ogg"),
mansion1 = load("res://files/music/mansion1.ogg"),
mansion2 = load("res://files/music/mansion2.ogg"),
mansion3 = load("res://files/music/mansion3.ogg"),
mansion4 = load("res://files/music/mansion4.ogg"),
wimborn = load("res://files/music/wimborn.ogg"),
gorn = load("res://files/music/gorn.ogg"),
frostford = load("res://files/music/frostford.ogg"),
explore = load("res://files/music/exploration.ogg"),
maintheme = load("res://files/music/opening.ogg"),
ending = load("res://files/music/ending.ogg"),
dungeon = load("res://files/music/dungeon.ogg"),
intimate = load("res://files/music/intimate.ogg"),
}
var sounddict = {
door = load("res://files/sounds/door.wav"),
stab = load("res://files/sounds/stab.wav"),
win = load("res://files/sounds/win.wav"),
teleport = load("res://files/sounds/teleport.wav"),
fall = load("res://files/sounds/fall.wav"),
page = load("res://files/sounds/page.wav"),
attack = load("res://files/sounds/normalattack.wav"),
}
var backgrounds = gallery.backgrounds
var scenes = gallery.scenes
var mansionupgradesdict = mansionupgrades.dict
var gradeimages = {
"slave" : load("res://files/buttons/mainscreen/40.png"),
poor = load("res://files/buttons/mainscreen/41.png"),
commoner = load("res://files/buttons/mainscreen/42.png"),
rich = load("res://files/buttons/mainscreen/43.png"),
noble = load("res://files/buttons/mainscreen/44.png"),
}
var specimages = {
Null = null,
geisha = load("res://files/buttons/mainscreen/33.png"),
ranger = load("res://files/buttons/mainscreen/37.png"),
executor = load("res://files/buttons/mainscreen/39.png"),
bodyguard = load("res://files/buttons/mainscreen/31.png"),
assassin = load("res://files/buttons/mainscreen/30.png"),
housekeeper = load("res://files/buttons/mainscreen/34.png"),
trapper = load("res://files/buttons/mainscreen/38.png"),
nympho = load("res://files/buttons/mainscreen/36.png"),
merchant = load("res://files/buttons/mainscreen/35.png"),
tamer = load("res://files/buttons/mainscreen/32.png"),
}

var sexicon = {
female = load("res://files/buttons/sexicons/female.png"),
male = load("res://files/buttons/sexicons/male.png"),
futanari = load("res://files/buttons/sexicons/futa.png"),
}

#var combatencounterdata = explorationscrips.enemygroup

var noimage = load("res://files/buttons/noimagesmall.png")

var punishcategories = ['spanking','whipping','nippleclap','clitclap','nosehook','mashshow','facesit','afacesit','grovel']

var playerspecs = {
Slaver = "+100% gold from selling captured slaves\n+33% gold reward from slave delivery tasks",
Hunter = "+100% gold drop from random encounters\n+20% gear drop chance\nBonus to preventing ambushes",
Alchemist = "Start with an alchemy room\nDouble potion production\nSelling potions earn 100% more gold",
Mage = "-50% mana cost of spells\nCombat spell deal 20% more damage",
}

func _init():
	if OS.get_executable_path() == 'C:\\Users\\1\\Desktop\\godot\\Godot_v3.0.4-stable_win64.exe':
		developmode = true
	randomize()
	loadsettings()
	effectdict = effects.effectlist 
#	var tempvars = load("res://mods/variables.gd").duplicate()
#	var tempnode = Node.new()
#	tempnode.set_script(tempvars)
#	for i in variables.list:
#		if tempnode.get(i) != null:
#			variables[i] = tempnode[i]
#	tempnode.queue_free()
	
	for i in races:
		allracesarray.append(i)
		if i.find("Beastkin") >= 0:
			allracesarray.append(i.replace("Beastkin", "Halfkin"))
	
#	if variables.oldemily == true:
#		for i in ["emilyhappy", "emilynormal","emily2normal","emily2happy","emily2worried","emilynakedhappy","emilynakedneutral"]:
#			spritedict[i] = spritedict['old'+ i]
#		characters.characters.Emily.imageportait = "res://files/images/emily/oldemilyportrait.png"


func savevars():
	var file = File.new()
	var text = 'extends Node\n'
	for i in variables.list:
		text += 'var ' + i + " = " + str(variables[i]) + "\n" 
	file.open("res://mods/variables.gd", File.WRITE)
	file.store_line(text)
	file.close()

func loadsettings():
	var settings = File.new()
	var dir = Directory.new()
	for i in setfolders.values():
		if dir.dir_exists(i) == false:
			dir.make_dir(i)
		
	if settings.file_exists("user://settings.ini") == false:
		settings.open("user://settings.ini", File.WRITE)
		settings.store_line(var2str(rules))
		settings.close()
	settings.open("user://settings.ini", File.READ)
	var temp = str2var(settings.get_as_text())
	for i in rules:
		if temp.has(i):
			rules[i] = temp[i]
	settings.close()
	var data = {chars = charactergallery, folders = setfolders}
	
	if settings.file_exists("user://progressdata") == false:
		overwritesettings()
	
	settings.open_encrypted_with_pass("user://progressdata", File.READ, 'tehpass')
	var storedsettings = settings.get_var()
	temp = storedsettings.chars
	
	for character in charactergallery:
		if temp.has(character):
			for part in charactergallery[character]:
				if part in ['unlocked', 'nakedunlocked'] && temp[character].has(part):
					charactergallery[character][part] = temp[character][part]
				elif part == 'scenes':
					for scene in range(temp[character][part].size()):
						charactergallery[character][part][scene].unlocked = temp[character][part][scene].unlocked
	if storedsettings.has('folders') == false:
		overwritesettings()
		settings.open_encrypted_with_pass("user://progressdata", File.READ, 'tehpass')
		storedsettings = settings.get_var()
	temp = storedsettings.folders
	for i in temp:
		if !temp[i].ends_with('/'):
			temp[i] += '/'
		setfolders[i] = temp[i]
	modfolder = setfolders.mods
	if storedsettings.has('savelist') == false:
		overwritesettings()
		settings.open_encrypted_with_pass("user://progressdata", File.READ, 'tehpass')
		storedsettings = settings.get_var()
	temp = storedsettings.savelist
	for i in temp:
		savelist[i] = temp[i]
	settings.close()

var charactergallery = gallery.charactergallery setget savechars
var setfolders = {portraits = 'user://portraits/', fullbody = 'user://bodies/', mods = 'user://mods/'} setget savefolders
var savelist = {}
var modfolder = setfolders.mods


func savechars(value):
	gallery.charactergallery = value

func savefolders(value):
	overwritesettings()

func overwritesettings():
	var settings = File.new()
	settings.open("user://settings.ini", File.WRITE)
	settings.store_line(var2str(rules))
	settings.close()
	settings.open_encrypted_with_pass("user://progressdata", File.WRITE, 'tehpass')
	var data = {chars = charactergallery, folders = setfolders, savelist = savelist}
	settings.store_var(data)
	settings.close()

func clearstate():
	state = progress.new()
	slaves.clear()
	events = load("res://files/scripts/events.gd").new()
	items = load("res://files/scripts/items.gd").new()
	itemdict = items.itemlist
	spells = load("res://files/scripts/spells.gd").new()
	spelldict = spells.spelllist
	resources.reset()

func newslave(race, age, sex, origins = 'slave'):
	return constructor.newslave(race, age, sex, origins)

func slaves_set(person):
	person.originstrue = person.origins
	person.health = max(person.health, 5)
	if person.ability.has('protect') == false:
		person.ability.append("protect")
		person.abilityactive.append("protect")
	slaves.append(person)
	if get_tree().get_current_scene().find_node('CharList'):
		get_tree().get_current_scene().rebuild_slave_list()
	if get_tree().get_current_scene().find_node('ResourcePanel'):
		get_tree().get_current_scene().find_node('population').set_text(str(slavecount())) 
	if globals.get_tree().get_current_scene().has_node("infotext"):
		globals.get_tree().get_current_scene().infotext("New Character acquired: " + person.name_long(),'green')

func loadimage(path):
	#var file = File.new()
	if typeof(path) == TYPE_OBJECT:
		return path
	if path == null:
		return
	if path.find('res:') >= 0:
		return load(path)
	var image = Image.new()
	if File.new().file_exists(path):
		image.load(path)
	var temptexture = ImageTexture.new()
	temptexture.create_from_image(image)
	return temptexture

func slavecount():
	var number = 0
	for i in slaves:
		if i.away.at != 'hidden':
			number += 1
	return number



var rules = {
futa = true,
futaballs = false,
furry = true,
furrynipples = true,
male_chance = 15,
futa_chance = 10,
children = false,
noadults = false,
slaverguildallraces = false,
fontsize = 14,
musicvol = 24,
soundvol = 24,
receiving = true,
fullscreen = false,
oldresize = true,
fadinganimation = true,
permadeath = false,
autoattack = true,
enddayalise = 1,
spritesindialogues = true,
instantcombatanimation = false,
randomcustomportraits = true,
thumbnails = false,
}

var scenedict = {
	#Mansion = 'res://files/Mansion.scn',
	Mansion = 'res://files/Mansion.tscn',
}

var CurrentScene

func ChangeScene(name):
	var loadscreen = load("res://files/LoadScreen.tscn").instance()
	get_tree().get_root().add_child(loadscreen)
	loadscreen.goto_scene(scenedict[name])


class resource:
	var day = 1 setget day_set
	var gold = 0 setget gold_set
	var mana = 0 setget mana_set
	var energy = 0 setget energy_set
	var food = 0 setget food_set
	var upgradepoints = 0 setget upgradepoints_set
	var panel
	var array = ['day','gold','mana','energy','food']
	
	var foodcaparray = [500, 750, 1000, 1500, 2000, 3000]
	
	func update():
		for i in array:
			#self[i] += 0
			set(i, get(i))
	
	func reset():
		day = 1
		gold = 0
		mana = 0
		energy = 0
		food = 0
	
	func gold_set(value):
		value = round(value)
		var color
		var difference = gold - value
		var text = ""
		gold = value
		if gold < 0:
			gold = 0
		if panel != null:
			panel.get_node('gold').set_text(str(gold))
		
		
		if difference != 0:
			if difference < 0:
				text = "Obtained " + str(abs(difference)) +  " gold"
				color = 'green'
			else:
				color = 'red'
				text = "Lost " + str(abs(difference)) +  " gold"
		
		if globals.get_tree().get_current_scene().has_node("infotext"):
			globals.get_tree().get_current_scene().infotext(text,color)
	
	func day_set(value):
		day = value
		if day < 0:
			day = 0
		if panel != null:
			panel.get_node('day').set_text(str(day))
	
	func food_set(value):
		value = round(value)
		var color
		var difference = round(food - value)
		var text = ""
		food = clamp(value, 0, foodcaparray[globals.state.mansionupgrades.foodcapacity])
		if panel != null:
			panel.get_node('food').set_text(str(food))
		if difference != 0:
			if difference < 0:
				text = "Obtained " + str(abs(difference)) +  " food"
				color = 'green'
			else:
				text = "Lost " + str(abs(difference)) +  " food"
				color = 'red'
		if globals.get_tree().get_current_scene().has_node("infotext"):
			globals.get_tree().get_current_scene().infotext(text,color)
	
	func mana_set(value):
		value = round(value)
		#var color
		var difference = mana - value
		var text = ""
		mana = value
		if mana < 0:
			mana = 0
		
		if panel != null:
			panel.get_node('mana').set_text(str(mana))
		
		if difference != 0:
			if difference < 0:
				text = "Obtained " + str(abs(difference)) +  " mana"
			else:
				text = "Used " + str(abs(difference)) +  " mana"
		
		if globals.get_tree().get_current_scene().has_node("infotext"):
			globals.get_tree().get_current_scene().infotext(text)
		
		
	
	func upgradepoints_set(value):
		var difference = upgradepoints - value
		var bonus = 0
		var gifted = false
		if difference < 0:
			for i in globals.slaves:
				if i.traits.has("Gifted"):
					gifted = true
		if gifted:
			bonus = ceil(abs(difference) * 0.2)
		var text = ""
		upgradepoints = value + bonus
		
		
		if difference < 0:
			text = "Obtained " + str(abs(difference)+bonus) +  " Mansion Upgrade Points"
		
		
		if globals.get_tree().get_current_scene().has_node("infotext"):
			globals.get_tree().get_current_scene().infotext(text,'green')
	
	func energy_set(value):
		if panel != null:
			panel.get_node("energy").set_text(str(round(globals.player.energy)))

var portalnames = {wimborn = 'Wimborn', gorn = 'Gorn', frostford = 'Frostford', umbra = 'Umbra',amberguard = 'Amberguard', dragonnests = 'Dragon Nests'}

class progress:
	var tutorialcomplete = false
	var supporter = false
	var location = 'wimborn'
	var nopoplimit = false
	var condition = 85 setget cond_set
	var conditionmod = 1.3
	var spec = ''
	var farm = 0 
	var apiary = 0
	var branding = 0
	var slaveguildvisited = 0
	var umbrafirstvisit = true
	var itemlist = {}
	var spelllist = {}
	var mainquest = 0
	var mainquestcomplete = false
	var rank = 0
	var password = ''
	var sidequests = {startslave = 0, emily = 0, brothel = 0, cali = 0, caliparentsdead = false, chloe = 0, ayda = 0, ivran = '', yris = 0, zoe = 0, ayneris = 0, sebastianumbra = 0, maple = 0} setget quest_set
	var repeatables = {wimbornslaveguild = [], frostfordslaveguild = [], gornslaveguild = []}
	var babylist = []
	var companion = -1
	var headgirlbehavior = 'none'
	var portals = {wimborn = {'enabled' : false, 'code' : 'wimborn'}, gorn = {'enabled':false, 'code' : 'gorn'}, frostford = {'enabled':false, 'code' : 'frostford'}, amberguard = {'enabled':false, 'code':'amberguard'}, umbra = {'enabled':false, 'code':'umbra'}}
	var sebastianorder = {race = 'none', taken = false, duration = 0}
	var sebastianslave
	var sandbox = false
	var snails = 0
	var groupsex = true
	var playergroup = []
	var timedevents = {}
	var customcursor = "res://files/buttons/kursor1.png"
	var upcomingevents = []
	var reputation = {wimborn = 0, frostford = 0, gorn = 0, amberguard = 0} setget reputation_set
	var dailyeventcountdown = 0
	var dailyeventprevious = 0
	var currentversion = 5000
	var unstackables = {}
	var supplykeep = 10
	var foodbuy = 200
	var supplybuy = false
	var tutorial = {basics = false, person = false, alchemy = false, jail = false, lab = false, farm = false, outside = false, combat = false, interactions = false}
	var itemcounter = 0
	var slavecounter = 0
	var alisecloth = 'normal'
	var decisions = []
	var lorefound = []
	var relativesdata = {}
	var descriptsettings = {full = true, basic = true, appearance = true, genitals = true, piercing = true, tattoo = true, mods = true}
	var mansionupgrades = {
	farmcapacity = 0,
	farmhatchery = 0,
	farmtreatment = 0,
	foodcapacity = 0,
	foodpreservation = 0,
	jailcapacity = 1,
	jailtreatment = 0,
	jailincenses = 0,
	mansioncommunal = 4,
	mansionpersonal = 1,
	mansionbed = 0,
	mansionluxury = 0,
	mansionalchemy = 0,
	mansionlibrary = 0,
	mansionlab = 0,
	mansionkennels = 0,
	mansionnursery = 0,
	mansionparlor = 0,
	}
	var plotsceneseen = []
	var capturedgroup = []
	var ghostrep = {wimborn = 0, frostford = 0, gorn = 0, amberguard = 0}
	var backpack = {stackables = {}, unstackables = []} setget backpack_set
	var restday = 0
	var defaultmasternoun = "Master"
	var sexactions = 1
	var nonsexactions = 1
	var actionblacklist = []
	var marklocation 
	
	func quest_set(value):
		sidequests = value
		if globals.mainscreen != 'mainmenu':
			globals.main.infotext('Side Quest Advanced',"yellow")
	
	func calculateweight():
		var _slave
		var tempitem
		var currentweight = 0
		var maxweight = variables.basecarryweight + max(globals.player.sstr*variables.carryweightperstrplayer, 0)
		var array = [globals.player]
		for i in globals.state.playergroup:
			_slave = globals.state.findslave(i)
			array.append(_slave)
			maxweight += max(_slave.sstr*variables.slavecarryweightperstr,0) + variables.baseslavecarryweight
		for i in globals.state.backpack.stackables:
			if globals.itemdict[i].has('weight'):
				currentweight += globals.itemdict[i].weight * globals.state.backpack.stackables[i]
		
		for i in globals.state.unstackables.values():
			if i.has('weight') && str(i.owner) == 'backpack':
				currentweight += i.weight
		for i in array:
			for k in i.gear.values():
				if k != null && globals.state.unstackables[k].code == 'acctravelbag': maxweight += 20
		var dict = {currentweight = currentweight, maxweight = maxweight, overload = maxweight < currentweight}
		return dict
	
	func reputation_set(value):
		var text = ''
		var color
		for i in value:
			if ghostrep[i] != value[i]:
				value[i] = min(max(value[i], -50),50)
				if ghostrep[i] > value[i]:
					text += "Reputation with " + i.capitalize() + " has worsened!"
					color = 'red'
				else:
					text += "Reputation with " + i.capitalize() + " has increased!"
					color = 'green'
				ghostrep[i] = value[i]
		if globals.get_tree().get_current_scene().has_node("infotext"):
			globals.get_tree().get_current_scene().infotext(text,color)

	
	func cond_set(value):
		condition += value*conditionmod
		if condition > 100:
			condition = 100
		elif condition < 0:
			condition = 0
	
	func findbaby(id):
		var rval
		for i in babylist:
			if str(i.id) == str(id):
				rval = i
		return rval
	
	func findslave(id):
		var rval
		if str(globals.player.id) == str(id):
			return globals.player
		for i in range(0, globals.slaves.size()):
			if str(globals.slaves[i].id) == str(id):
				rval = globals.slaves[i]
		return rval
	
	func backpack_set(value):
		backpack = value
		checkbackpack()
	
	func checkbackpack():
		for i in backpack.stackables.duplicate():
			if backpack.stackables[i] <= 0:
				backpack.stackables.erase(i)

	func getCountStackableItem(item, search = 'any'):
		var count = 0
		if (search in ['any','backpack']):
			if backpack.stackables.has(item):
				count += backpack.stackables[item]
		if (search in ['any','inventory']):		
			if globals.itemdict.has(item):
				count += globals.itemdict[item].amount
		return count

	func removeStackableItem(item, count = 1, search = 'any'):
		if count > 0 && (search in ['any','backpack']):
			if backpack.stackables.has(item):
				if backpack.stackables[item] > count:
					backpack.stackables[item] -= count
					return 0
				else:
					count -= max(backpack.stackables[item], 0)
					backpack.stackables.erase(item)
		if count > 0 && (search in ['any','inventory']):	
			if globals.itemdict.has(item):
				if globals.itemdict[item].amount >= count:
					globals.itemdict[item].amount -= count
					return 0
				else:
					count -= max(globals.itemdict[item].amount, 0)
					globals.itemdict[item].amount = 0
		return count

	

func addrelations(person, person2, value):
	if person == player || person2 == player || person == person2:
		return
	if person.relations.has(person2.id) == false:
		person.relations[person2.id] = 0
	if person2.relations.has(person.id) == false:
		person2.relations[person.id] = 0
	if person.relations[person2.id] > 500 && value > 0 && checkifrelatives(person, person2):
		value = value/1.5
	elif person.relations[person2.id] < -500 && value < 0 && checkifrelatives(person,person2):
		value = value/1.5
	person.relations[person2.id] += value
	person.relations[person2.id] = clamp(person.relations[person2.id], -1000, 1000)
	person2.relations[person.id] = person.relations[person2.id]
	if person.relations[person2.id] < -200 && value < 0:
		person.stress += rand_range(4,8)
		person2.stress += rand_range(4,8)

static func count_sleepers():
	var your_bed = 0
	var personal_room = 0
	var jail = 0
	var farm = 0
	var communal = 0
	var rval = {}
	for i in globals.slaves:
		if i.away.at != 'hidden':
			if i.sleep == 'personal':
				personal_room += 1
			elif i.sleep == 'your':
				your_bed += 1
			elif i.sleep == 'jail':
				jail += 1
			elif i.sleep == 'farm':
				farm += 1
			elif i.sleep == 'communal':
				communal += 1
	rval.personal = personal_room
	rval.your_bed = your_bed
	rval.jail = jail
	rval.farm = farm
	rval.communal = communal
	return rval

func impregnation(mother, father = null, anyfather = false):
	var realfather
	if father == null:
		var gender
		realfather = -1
		if globals.rules.futa == true:
			gender = ['male','futanari']
		else:
			gender = ['male']
		if anyfather == false:
			father = globals.newslave('randomcommon', 'random', gender[rand_range(0,gender.size())])
		else:
			father = globals.newslave('randomany', 'random', gender[rand_range(0,gender.size())])
	else:
		if father.penis == 'none':
			return
#		realfather = father.id
	if mother.preg.has_womb == false || mother.preg.duration > 0 || mother == father || mother.effects.has("contraceptive") || father.effects.has('contraceptive'):
		return
	var rand = rand_range(0,100)
	if globals.developmode == true:
		rand = 0
	if mother.preg.fertility < rand:
		if mother.traits.has("Infertile") || father.traits.has("Infertile"):
			mother.preg.fertility += rand_range(2,5)
		else:
			mother.preg.fertility += rand_range(5,10)
		return
	var age = ''
	var babyrace = mother.race
	if globals.rules.children == true:
		age = 'child'
	else: 
		age = 'teen'
	if (mother.race.find('Beastkin') >= 0 && father.race.find('Beastkin') < 0)|| (father.race.find('Beastkin') >= 0 && mother.race.find('Beastkin') < 0):
		if father.race.find('Beastkin') >= 0 && mother.race in ['Human','Elf','Dark Elf','Drow','Demon','Seraph']:
			babyrace = father.race.replace('Beastkin', 'Halfkin')
		else:
			babyrace = mother.race.replace('Beastkin', 'Halfkin')
		
	var baby = globals.newslave(babyrace, age, 'random', mother.origins)
	baby.state = 'fetus'
	baby.surname = mother.surname
	var array = ['skin','tail','ears','wings','horns','arms','legs','bodyshape','haircolor','eyecolor','eyeshape','eyesclera']
	for i in array:
		if rand_range(0,10) > 5:
			baby[i] = father[i]
		else:
			baby[i] = mother[i]
	if baby.race.find('Halfkin')>=0 && mother.race.find('Beastkin') >= 0 && father.race.find('Beastkin') < 0:
		baby.bodyshape = 'humanoid'
	if father.beautybase > mother.beautybase:
		baby.beautybase = father.beautybase + rand_range(-2,5)
	else:
		baby.beautybase = mother.beautybase + rand_range(-2,5)
	baby.cleartraits()
	
	var traitpool = father.traits + mother.traits
	for i in traitpool:
		if rand_range(0,100) <= variables.traitinheritchance:
			baby.add_trait(i)
	
	if rand_range(0,100) <= variables.babynewtraitchance:
		baby.add_trait(globals.origins.traits('any').name)
	
	connectrelatives(mother, baby, 'mother')
	if realfather != -1:
		connectrelatives(father, baby, 'father')
	mother.preg.baby = baby.id
	mother.preg.duration = 1
	
	mother.metrics.preg += 1
	globals.state.babylist.append(baby)

var baby


func connectrelatives(person1, person2, way):
	if person1 == null || person2 == null:
		return
	if globals.state.relativesdata.has(person1.id) == false:
		createrelativesdata(person1)
	if globals.state.relativesdata.has(person2.id) == false:
		createrelativesdata(person2)
	if way in ['mother','father']:
		var entry = globals.state.relativesdata[person1.id]
		entry.children.append(person2.id)
		for i in entry.children:
			if i != person2.id:
				var entry2 = globals.state.relativesdata[i]
				connectrelatives(person2, entry2, 'sibling')
		entry = globals.state.relativesdata[person2.id]
		entry[way] = person1.id
		if typeof(person1) != TYPE_DICTIONARY && typeof(person2) != TYPE_DICTIONARY:
			addrelations(person1, person2, 200)
	elif way == 'sibling':
		var entry = globals.state.relativesdata[person1.id]
		var entry2 = globals.state.relativesdata[person2.id]
		if entry.siblings.has(entry2.id) == false: entry.siblings.append(entry2.id)
		if entry2.siblings.has(entry.id) == false: entry2.siblings.append(entry.id)
		for i in entry.siblings + entry2.siblings:
			if !globals.state.relativesdata[i].siblings.has(entry.id) && i != entry.id:
				globals.state.relativesdata[i].siblings.append(entry.id)
			if !globals.state.relativesdata[i].siblings.has(entry2.id) && i != entry2.id:
				globals.state.relativesdata[i].siblings.append(entry2.id)
			if !entry.siblings.has(i) && i != entry.id:
				entry.siblings.append(i)
			if !entry2.siblings.has(i) && i != entry2.id:
				entry2.siblings.append(i)
		
		if typeof(person1) != TYPE_DICTIONARY && typeof(person2) != TYPE_DICTIONARY:
			addrelations(person1, person2, 0)


func createrelativesdata(person):
	var newdata = {name = person.name_long(), state = person.state, id = person.id, race = person.race, sex = person.sex, mother = -1, father = -1, siblings = [], halfsiblings = [], children = []}
	globals.state.relativesdata[person.id] = newdata

func clearrelativesdata(id):
	var entry
	if globals.state.relativesdata.has(id):
		entry = globals.state.relativesdata[id]
		
		for i in ['mother','father']:
			if globals.state.relativesdata.has(entry[i]):
				var entry2 = globals.state.relativesdata[entry[i]]
				entry2.children.erase(id)
		for i in entry.siblings:
			if globals.state.relativesdata.has(i):
				var entry2 = globals.state.relativesdata[i]
				entry2.siblings.erase(id)
		
	
	globals.state.relativesdata.erase(id)

func checkifrelatives(person, person2):
	var result = false
	var data1 
	var data2
	if globals.state.relativesdata.has(person.id):
		data1 = globals.state.relativesdata[person.id]
	else:
		createrelativesdata(person)
		data1 = globals.state.relativesdata[person.id]
	if globals.state.relativesdata.has(person2.id):
		data2 = globals.state.relativesdata[person2.id]
	else:
		createrelativesdata(person2)
		data2 = globals.state.relativesdata[person2.id]
	for i in ['mother','father']:
		if str(data1[i]) == str(data2.id) || str(data2[i]) == str(data1.id):
			result = true
	for i in [data1, data2]:
		if i.siblings.has(data1.id) || i.siblings.has(data2.id):
			result = true
	
	
	return result

func getrelativename(person, person2):
	var result = null
	var data1 
	var data2
	if globals.state.relativesdata.has(person.id):
		data1 = globals.state.relativesdata[person.id]
	else:
		createrelativesdata(person)
		data1 = globals.state.relativesdata[person.id]
	if globals.state.relativesdata.has(person2.id):
		data2 = globals.state.relativesdata[person2.id]
	else:
		createrelativesdata(person2)
		data2 = globals.state.relativesdata[person2.id]
	
	#print(data1, data2)
	for i in ['mother','father']:
		if str(data1[i]) == str(data2.id):
			result = '$parent'
		elif str(data2[i]) == str(data1.id):
			result = '$son'
	for i in [data1, data2]:
		if i.siblings.has(data1.id) || i.siblings.has(data2.id):
			result = '$sibling'
	if result != null:
		result = person2.dictionary(result)
	return result

func showtooltip(text):
	var screen = get_viewport().get_visible_rect()
	var tooltip = main.get_node("tooltip")
	main.get_node("tooltip/RichTextLabel").set_bbcode(text)
	var pos = main.get_global_mouse_position()
	pos = Vector2(pos.x+20, pos.y+20)
	tooltip.set_position(pos)
	tooltip.visible = true
	yield(get_tree(), "idle_frame")
	tooltip.get_node("RichTextLabel").rect_size.y = main.get_node("tooltip/RichTextLabel").get_v_scroll().get_max()
	tooltip.rect_size.y = main.get_node("tooltip/RichTextLabel").rect_size.y + 30
	if tooltip.get_rect().end.x >= screen.size.x:
		tooltip.rect_global_position.x -= tooltip.get_rect().end.x - screen.size.x
	if tooltip.get_rect().end.y >= screen.size.y:
		tooltip.rect_global_position.y -= tooltip.get_rect().end.y - screen.size.y

func hidetooltip():
	main.get_node("tooltip").visible = false
	slavetooltiphide()
	itemtooltiphide()

func slavetooltip(person):
	var text = ''
	var node = main.get_node('slavetooltip')
	if node == null:
		return
	node.visible = true
	text += "Level: " + str(person.level)
	text += "\n[color=yellow]" + person.race.capitalize() + "[/color]\n" 
	description.person = person
	text += description.getbeauty(true).capitalize() + '\n' + person.age.capitalize()
	node.get_node("portrait").texture = loadimage(person.imageportait)
	node.get_node("portrait").visible = !node.get_node('portrait').texture == null
	node.get_node("name").text = person.name_long()
	if globals.player == person:
		node.get_node("name").set('custom_colors/font_color', Color(1,1,0))
		node.get_node("name").text = "Master " + node.get_node("name").text
	else:
		node.get_node("name").set('custom_colors/font_color', Color(1,1,1))
	if person != globals.player:
		node.get_node("spec").set_texture(specimages[str(person.spec)])
	node.get_node("grade").set_texture(gradeimages[person.origins])
	node.get_node("spec").visible = !globals.player == person
	node.get_node("grade").visible = !globals.player == person
	node.get_node("text").bbcode_text = text
	node.get_node("sex").texture = globals.sexicon[person.sex]
	
	text = 'Traits: '
	if person.traits.size() > 0:
		text += "[color=aqua]"
		for i in person.traits:
			text += i + ', '
		text = text.substr(0, text.length() - 2) + '.[/color]'
	else:
		text += "None"
	
	node.get_node('traittext').bbcode_text = text
	
	var screen = get_viewport().get_visible_rect()
	var pos = main.get_global_mouse_position()
	pos = Vector2(pos.x+20, pos.y+20)
	node.set_position(pos)
	if node.get_rect().end.x >= screen.size.x:
		node.rect_global_position.x -= node.get_rect().end.x - screen.size.x
	if node.get_rect().end.y >= screen.size.y:
		node.rect_global_position.y -= node.get_rect().end.y - screen.size.y

func slavetooltiphide(empty = null):
	if get_tree().get_current_scene().has_node('slavetooltip'):
		get_tree().get_current_scene().get_node('slavetooltip').visible = false

func openslave(person):
	if person == globals.player:
		main._on_selfbutton_pressed()
	elif globals.slaves.has(person) && person.away.duration == 0:
		main.openslavetab(person)

func itemtooltip(item):
	var text = itemdescription(item, true)
	var node = main.get_node('itemtooltip')
	if node == null:
		return
	node.visible = true
	node.get_node("image").texture = loadimage(item.icon)
	node.get_node('text').bbcode_text = text
	
	var screen = get_viewport().get_visible_rect()
	var pos = main.get_global_mouse_position()
	pos = Vector2(pos.x+20, pos.y+20)
	node.set_position(pos)
	if node.get_rect().end.x >= screen.size.x:
		node.rect_global_position.x -= node.get_rect().end.x - screen.size.x
	if node.get_rect().end.y >= screen.size.y:
		node.rect_global_position.y -= node.get_rect().end.y - screen.size.y
	

func itemtooltiphide(empty = null):
	if get_tree().get_current_scene().has_node('itemtooltip'):
		get_tree().get_current_scene().get_node('itemtooltip').visible = false

func gradetooltip(person):
	var text = ''
	for i in globals.originsarray:
		if i == person.origins:
			text += '[color=green] ' + i.capitalize() + '[/color]'
		else:
			text += i.capitalize()
		if i != 'noble':
			text += ' - '
	text += '\n\n' + globals.dictionary.getOriginDescription(person)
	globals.showtooltip(text)

static func merge(target, patch):
	for key in patch:
		if target.has(key):
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				merge(tv, patch[key])
			elif typeof(tv) == TYPE_INT || typeof(tv) == TYPE_REAL:
				target[key] = target[key] + patch[key]
			else:
				target[key] = patch[key]
		else:
			target[key] = patch[key]

static func merge_overwrite(target, patch):
	for key in patch:
		if target.has(key):
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				merge(tv, patch[key])
			else:
				target[key] = patch[key]
		else:
			target[key] = patch[key]

static func mergeclass(target, patch):
	for key in patch:
		target[key] = patch[key]

static func mergearrays(target, patch):
	var count = 0
	for key in patch:
		target[count] = patch[count]
		count += 1

static func fastif(formula, result1, result2):
	if formula == true:
		return result1
	else:
		return result2

static func find_trait(array, trait):
	var result = false
	for i in array:
		if i.name == trait:
			result = true
	return result

func getcodefromarray(array, code):
	var rval = false
	for i in array:
		if i.code == code:
			rval = i
	return rval

static func decapitalize(text):
	text = text.to_lower()
	text = text.replace(' ', '_')
	return text

static func sortbyname(first, second):
	if first.name < second.name:
		return true
	else:
		return false

static func sortbycost(first, second):
	if first.cost < second.cost:
		return true
	elif first.cost == second.cost:
		if first.name < second.name:
			return true
		else:
			return false
	else:
		return false

static func sortbynumber(first, second):
	if first.number < second.number:
		return true
	else:
		return false


var hairlengtharray = ['ear','neck','shoulder','waist','hips']
var sizearray = ['masculine','flat','small','average','big','huge']
var heightarray = ['petite','short','average','tall','towering']
var agesarray = ['child','teen','adult']
var genitaliaarray = ['small','average','big']
var originsarray = ['slave','poor','commoner','rich','noble']
var longtails = ['cat','fox','wolf','demon','dragon','scruffy','snake tail','racoon']
var skincovarray = ['none','scales','feathers','full_body_fur', 'plants']
var penistypearray = ['human','canine','feline','equine']
var alltails = ['cat','fox','wolf','bunny','bird','demon','dragon','scruffy','snake tail','racoon']
var allwings = ['feathered_black', 'feathered_white', 'feathered_brown', 'leather_black','leather_red','insect']
var allears = ['human','feathery','pointy','short_furry','long_pointy_furry','fins','long_round_furry', 'long_droopy_furry']
var statsdict = {sstr = 'Strength', sagi = 'Agility', smaf = "Magic Affinity", send = "Endurance", cour = 'Courage', conf = 'Confidence', wit = 'Wit', charm = 'Charm'}
var maxstatdict = {sstr = 'str_max', sagi = 'agi_max', smaf = 'maf_max', send = 'end_max', cour = 'cour_max', conf = 'conf_max', wit = 'wit_max', charm = 'charm_max'}
var basestatdict = {sstr = 'str_base', sagi = 'agi_base', smaf = 'maf_base', send = 'end_base', cour = 'cour_base', conf = 'conf_base', wit = 'wit_base', charm = 'charm_base'}
var statsdescript = dictionary.statdescription
var sleepdict = {communal = {name = 'Communal Room'}, jail = {name = "Jail"}, personal = {name = 'Personal Room'}, your = {name = "Your bed"}}


func itemdescription(item, short = false):
	var text = ''
	var name = ''
	name = item.name
	if short == false:
		text += item.description + '\n\n'
	elif !item.has('owner'):
		text += item.description
	if item.has('owner'):
		#text += '\n\n'
		if item.enchant == 'basic':
			name = '[color=green]' + name + '[/color]'
		elif item.enchant == 'unique':
			name = '[color=#cc8400]' + name + '[/color]'
		for i in item.effects:
			text += i.descript + "\n"
	if item.type == 'gear':
		text += '\n\n'
		for i in item.effect:
			text += i.descript + "\n"
	if item.has('weight'):
		text += "\n[color=yellow]Weight: " + str(item.weight) + "[/color]"
	return '[center]' + name + '[/center]\n' + text

#saveload system
func save():
	state.spelllist.clear()
	state.itemlist.clear()
	var dict = {}
	for i in spelldict:
		if spelldict[i].learned == true:
			state.spelllist[i] = true
	for i in itemdict:
		if itemdict[i].amount > 0:
			state.itemlist[i] = {}
			state.itemlist[i].amount = itemdict[i].amount
	dict.resources = inst2dict(resources)
	dict.state = inst2dict(state)
	dict.state.currentversion = gameversion
	dict.guildslaves = {}
	for g in guildslaves:
		dict.guildslaves[g] = []
		for i in guildslaves[g]:
			dict.guildslaves[g].append(inst2dict(i))
	dict.slaves = []
	dict.babylist = []
	if globals.state.sebastianorder.taken == true:
		dict.sebastianslave = inst2dict(state.sebastianslave)
	for i in slaves:
		dict.slaves.append(inst2dict(i))
	for i in state.babylist:
		dict.babylist.append(inst2dict(i))
	dict.player = inst2dict(player) 
	return dict

func save_game(var savename):
	var savegame = File.new()
	var dir = Directory.new()
	if dir.dir_exists("user://saves") == false:
		dir.make_dir("user://saves")
	savegame.open(savename, File.WRITE)
	var nodedata = save()
	savelistentry(savename)
	overwritesettings()
	savegame.store_line(to_json(nodedata))
	savegame.close()
	get_tree().get_current_scene().infotext("Game Saved.",'green')

func savelistentry(savename):
	var date = OS.get_datetime()
	for i in date:
		if int(date[i]) < 10:
			date[i] = '0' + str(date[i])
		else:
			date[i] = str(date[i])
	var entry = {name = "Master " + player.name + "\nDay: " + str(resources.day) + '\nGold: [color=yellow] ' + str(resources.gold) + '[/color]\nSlaves: ' + str(slavecount()), path = savename, date = date.hour + ":" + date.minute + " " + date.day + '.' + date.month + '.' + date.year, portrait = player.imageportait}
	savelist[savename] = entry

func load_game(text):
	var savegame = File.new()
	var newslave
	if !savegame.file_exists(text):
		return #Error!  We don't have a save to load
	clearstate()
	var currentline = {} 
	savegame.open(text, File.READ)
	currentline = parse_json(savegame.get_as_text())
	ChangeScene("Mansion")
	#get_tree().change_scene("res://files/Mansion.scn")
	for i in currentline.values():
		if i.has("@path") && i['@path'] in ["res://globals.gdc",'res://globals.gdc']:
			i['@path'] = "res://globals.gd"
		if i.has("@path"):
			i['@path'] = i['@path'].replace('.gdc','.gd')
	if currentline.player["@path"] != 'res://files/scripts/person/person.gd':
		currentline.player['@path'] = 'res://files/scripts/person/person.gd'
		currentline.player["@subpath"] = ''
		for i in currentline.values():
			if typeof(i) == TYPE_DICTIONARY:
				if i.has('stats'):
					i['@path'] = 'res://files/scripts/person/person.gd'
					i['@subpath'] = ''
			elif typeof(i) == TYPE_ARRAY:
				for k in i:
					k['@path'] = 'res://files/scripts/person/person.gd'
					k['@subpath'] = ''
	if currentline.resources['@subpath'] == '':
		currentline.resources['@subpath'] = "resource"
#		currentline.player['@subpath'] = 'person'
		currentline.state['@subpath'] = 'progress'
	if currentline.resources['@path'] == "res://globals.gd":
		currentline.resources['@path'] = "res://files/globals.gd"
#		currentline.player['@path'] = 'res://files/globals.gd'
		currentline.state['@path'] = 'res://files/globals.gd'
		for i in currentline.values():
			if typeof(i) == TYPE_DICTIONARY:
				if i['@path'].find("res://globals.gd") >= 0:
					i['@path'] = i['@path'].replace("res://globals.gd", "res://files/globals.gd")
			
			if i.has('stats') && i.stats.has("str_cur"):
				i.stats.str_base = i.stats.str_cur
				i.stats.agi_base = i.stats.agi_cur
				i.stats.maf_base = i.stats.maf_cur
				i.stats.end_base = i.stats.end_cur
			elif typeof(i) == TYPE_ARRAY:
				for k in i:
					if k['@path'].find("res://globals.gd") >= 0:
						k['@path'] = k['@path'].replace("res://globals.gd", "res://files/globals.gd")
					if k.has('stats') && k.stats.has("str_cur"):
						k.stats.str_base = k.stats.str_cur
						k.stats.agi_base = k.stats.agi_cur
						k.stats.maf_base = k.stats.maf_cur
						k.stats.end_base = k.stats.end_cur
					if k.has('stats') && k.stats.obed_mod <= 0:
						k.stats.obed_mod = 1
	if currentline.has('sebastianslave'):
		currentline.sebastianslave['@subpath'] = 'person'
	resources = dict2inst(currentline.resources)
	player = dict2inst(currentline.player)
	state = dict2inst(currentline.state)
	guildslaves = {wimborn = [], gorn = [], frostford = [], umbra = []}
	if currentline.has('guildslaves'):
		for g in currentline.guildslaves:
			for i in currentline.guildslaves[g]:
				guildslaves[g].append(dict2inst(i))
	var statetemp = progress.new()
	for i in statetemp.reputation:
		if state.ghostrep.has(i) == false:
			state.ghostrep[i] = statetemp.reputation[i]
		if state.reputation.has(i) == false:
			state.reputation[i] = statetemp.reputation[i]
	for i in state.itemlist:
		if itemdict.has(i):
			itemdict[i].amount = state.itemlist[i].amount
	for i in statetemp.sidequests:
		if state.sidequests.has(i) == false:
			state.sidequests[i] = statetemp.sidequests[i]
	for i in statetemp.tutorial:
		if state.tutorial.has(i) == false:
			state.tutorial[i] = statetemp.tutorial[i]
	state.itemlist = {}
	for i in state.spelllist:
		spelldict[i].learned = true
	state.spelllist = {}
	if globals.state.sebastianorder.taken == true:
		state.sebastianslave = person.new()
		state.sebastianslave = dict2inst(currentline.sebastianslave)
	state.babylist.clear()
	for i in currentline.slaves:
		newslave = person.new()
		if i['@path'].find('.gdc') >= 0:
			i['@path'] = i['@path'].replace('.gdc', '.gd')
#		if i['@subpath'] == '':
#			i['@subpath'] = 'person'
		newslave = dict2inst(i)
		if i.has('face'):
			newslave.beautybase = round(i.face.beauty)
		slaves.append(newslave)
	for i in currentline.babylist:
		newslave = person.new()
		if i['@path'].find('.gdc'):
			i['@path'] = i['@path'].replace('.gdc', '.gd')
		if i['@subpath'] == '':
			i['@subpath'] = 'person'
		newslave = dict2inst(i)
		if i.has('face'):
			newslave.beautybase = round(i.face.beauty)
		state.babylist.append(newslave)
	savegame.close()
	if state.customcursor == null:
		Input.set_custom_mouse_cursor(null)
	else:
		state.customcursor = "res://files/buttons/kursor1.png"
	
	
	gameloaded = true
	if str(state.currentversion) != str(gameversion):
		print("Using old save, attempting repair")
		repairsave()
	

func repairsave():
	state.currentversion = gameversion
	for person in [player] + slaves + state.babylist:
		person.id = str(person.id)
		if person.sexexp.has('partners') == false:
			person.sexexp = {partners = {}, watchers = {}, actions = {}, seenactions = {}, orgasms = {}, orgasmpartners = {}}
	for i in globals.state.unstackables.values():
		if i.enchant == null:
			i.enchant = ''
	globals.state.playergroup.clear()

var showalisegreet = false

func dir_contents(target = "user://saves"):
	var dir = Directory.new()
	var array = []
	if dir.open(target) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				array.append(target + "/" + file_name)
			elif !file_name in ['.','..', null] && dir.current_is_dir():
				array += dir_contents(target + "/" + file_name)
			file_name = dir.get_next()
		return array
	else:
		print("An error occurred when trying to access the path.")

var currentslave
var currentsexslave

func evaluate(input): #used to read strings as conditions when needed
	var script = GDScript.new()
	script.set_source_code("var person\nfunc eval():\n\treturn " + input)
	script.reload()
	var obj = Reference.new()
	obj.set_script(script)
	obj.person = currentslave
	return obj.eval()

func weightedrandom(array): #array must be made out of dictionaries with {value = name, weight = number} Number is relative to other elements which may appear
	var total = 0
	var counter = 0
	for i in array:
		if typeof(i) == TYPE_DICTIONARY:
			total += i.weight
		else:
			total += i[1]
	var random = rand_range(0,total)
	for i in array:
		if typeof(i) == TYPE_DICTIONARY:
			if counter + i.weight >= random:
				return i.value
			counter += i.weight
		else:
			if counter + i[1] >= random:
				return i[0]
			counter += i[1]

func randomfromarray(array):
	return array[rand_range(0,array.size())]

func buildportrait(node, person):
	var array = ['race','hairlength','ears'] #add more pieces of layers in order they should be added
	var imagedict = { #should have all pieces you added to the array with paths
	race = {human = load('humanheadimage.png'), elf = load('elfheadimage.png')},
	hairlength = {long = load('longhairimage.png'), short = load('shorthairimage.png')},
	ears = {normal = load('normalears.png'), pointy = load('pointyearsimg.png')},
	} 
	for i in array:
		var newlayer = node.duplicate()
		node.add_child(newlayer)
		newlayer.set_texture(imagedict[i][person[i]])

func getracedata(person):
	var race = person.race
	return races[race.replace('Halfkin', 'Beastkin')]

func getracebygroup(group):
	var array = []
	for i in races:
		if group == 'bandits' && races[i].banditrace == true:
			array.append(i)
		elif group == 'starting' && races[i].startingrace == true:
			array.append(i)
		elif group == 'wimborn' && races[i].wimbornrace == true:
			array.append(i)
		elif group == 'gorn' && races[i].gornrace == true:
			array.append(i)
		elif group == 'frostford' && races[i].frostfordrace == true:
			array.append(i)
	addnonfurrycounterpart(array)
	if rules.furry == false:
		removefurries(array)
	return array[randi()%array.size()]


func addnonfurrycounterpart(array):
	for i in array:
		if i.find('Beastkin') >= 0:
			array.append(i.replace('Beastkin', 'Halfkin'))

func removefurries(array):
	for i in array:
		if i.find('Beastkin') >= 0:
			array.erase(i)


func checkfurryrace(text):
	if text in ['Cat','Wolf','Fox','Bunny','Tanuki']:
		if rules.furry == true:
			if rand_range(0,1) >= 0.5:
				text = 'Halfkin ' + text
			else:
				text = 'Beastkin ' + text
		else:
			text = 'Halfkin ' + text
	return text
