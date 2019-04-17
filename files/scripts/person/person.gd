var name = ''
var surname = ''
var nickname = ''

var unique = null
var id = 0
var race = ''
var age = ''

var mindage = ''
var sex = ''
var spec = null

var imageportait = null

var imagefull = null
var haircolor = ''

var hairlength = ''

var hairstyle = ''
var eyecolor = ''

var skin = ''

var height = ''

var titssize = ''

var asssize = ''

var eyeshape = 'normal'

var eyesclera = 'normal'

var arms = 'normal'

var legs = 'normal'

var bodyshape = 'humanoid'

var skincov = 'none'

var furcolor = 'none'

var ears = 'human'

var tail = 'none'

var wings = 'none'

var horns = 'none'

var beauty = 0 setget ,beauty_get
var beautybase = 0 setget beautybase_set
var beautytemp = 0 


var asser = 0

var pubichair = 'clean'

var fear = 0 setget fear_set,fear_get
var fear_mod = 1

var lewdness = 0 setget lewdness_set

var lactation = false

var titsextra = 0

var titsextradeveloped = false

var consent = false
var vagina = 'normal'
var vagvirgin = true

var mouthvirgin = true

var assvirgin = true

var penisvirgin = true
var penis = 'none'

var balls = 'none'

var penistype = 'human'

var penisextra = 0

var sensvagina = 0

var sensmouth = 0

var senspenis = 0

var sensanal = 0

var knowntechniques = []



var state = 'normal'
var preg = {fertility = 0, has_womb = true, duration = 0, baby = null}
var rules = {'silence':false, 'pet':false, 'contraception':false, 'aphrodisiac':false, 'masturbation':false, 'nudity':false, 'betterfood':false, 'personalbath':false,'cosmetics':false,'pocketmoney':false}
var traits = []

var gear = {costume = null, underwear = null, armor = null, weapon = null, accessory = null}

var genes = {}
var effects = {}

var brand = 'none'

var work = 'rest'
var sleep = ''

var farmoutcome = false


var ability = ['attack']

var abilityactive = ['attack']

var customdesc = ''

var piercing = {earlobes = null, eyebrow = null, nose = null, lips = null, tongue = null, navel = null, nipples = null, clit = null, labia = null, penis = null}

var tattoo = {chest = 'none', face = 'none', ass = 'none', arms = 'none', legs = 'none', waist = 'none'}
var level = 1
var xp = 0 setget xp_set, xp_get
var realxp = 0
var skillpoints = 2
var levelupreqs = {} setget levelupreqs_set
var away = {duration = 0, at = ''}

var cattle = {is_cattle = false, work = '', used_for = 'food'}
var mods = {}

var tattooshow = {chest = true, face = true, ass = true, arms = true, legs = true, waist = true}

var tags = []
var origins = 'slave'

var originstrue = ''

var memory = ''

var attention = 0

var sexuals = {actions = {}, unlocked = false, affection = 0, kinks = {}, unlocks = [], lastaction = ''}

var kinks = []

var forcedsex = false

var sexexp = {partners = {}, watchers = {}, actions = {}, seenactions = {}, orgasms = {}, orgasmpartners = {}}

var sensation = {}

var metrics = {ownership = 0, jail = 0, mods = 0, brothel = 0, sex = 0, partners = [], randompartners = 0, item = 0, spell = 0, orgy = 0, threesome = 0, win = 0, capture = 0, goldearn = 0, foodearn = 0, manaearn = 0, birth = 0, preg = 0, vag = 0, anal = 0, oral = 0, roughsex = 0, roughsexlike = 0, orgasm = 0}
var fromguild = false
var masternoun = 'Master'

var lastinteractionday = 0

var lastsexday = 0
var learningpoints = 0 setget learningpoints_set
var luxury = 0


var relations = {}

var stats = {
	str_max = 0,
	str_mod = 0,
	str_base = 0,
	agi_max = 0, 
	agi_mod = 0,
	agi_base = 0,
	maf_max = 0,
	maf_mod = 0,
	maf_base = 0,
	end_base = 0,
	end_mod = 0,
	end_max = 0,
	cour_max = 100,
	cour_base = 0,
	conf_max = 100,
	conf_base = 0,
	wit_max = 100,
	wit_base = 0,
	charm_max = 100,
	charm_base = 0,
	obed_cur = 0.0,
	obed_max = 100,
	obed_min = 0,
	obed_mod = 1,
	stress_cur = 0.0,
	stress_max = 120,
	stress_min = 0,
	stress_mod = 1,
	tox_cur = 0.0,
	tox_max = 100,
	tox_min = 0,
	tox_mod = 1,
	lust_cur = 0,
	lust_max = 100,
	lust_min = 0,
	lust_mod = 0,
	health_cur = 0,
	health_max = 100,
	health_base = 0,
	health_bonus = 0,
	energy_cur = 75,
	energy_max = 100,
	energy_mod = 0,
	armor_cur = 0,
	armor_max = 0,
	armor_base = 0,
	loyal_cur = 0.0,
	loyal_mod = 1,
	loyal_max = 100,
	loyal_min = 0,
}
var health setget health_set,health_get

var obed setget obed_set,obed_get
var stress setget stress_set,stress_get
var loyal setget loyal_set,loyal_get
var cour setget cour_set,cour_get
var conf setget conf_set,conf_get
var wit setget wit_set,wit_get
var charm setget charm_set,charm_get

var lust setget lust_set,lust_get
var toxicity setget tox_set,tox_get

var energy setget energy_set,energy_get

var sstr setget str_set,str_get
var sagi setget agi_set,agi_get

var smaf setget maf_set,maf_get

var send setget end_set,end_get

func fear_raw(value):
	fear += value


func get_traits():
	var array = []
	for i in traits:
		array.append(globals.origins.trait(i))
	return array

#warning-ignore:unused_argument
func add_trait(trait, remove = false):
	trait = globals.origins.trait(trait)
	var conflictexists = false
	var text = ""
	var traitexists = false
	for i in get_traits():
		if i.name == trait.name:
			traitexists = true
		for ii in i.conflict:
			if trait.name == ii:
				conflictexists = true
	if traitexists || conflictexists:
		return
	else:
		traits.append(trait.name)
		if globals.get_tree().get_current_scene().has_node("infotext") && globals.slaves.find(self) >= 0 && away.at != 'hidden':
			text += self.dictionary("$name acquired new trait: " + trait.name)
			globals.get_tree().get_current_scene().infotext(text,'yellow')
		if trait['effect'].empty() != true:
			add_effect(trait['effect'])

func trait_remove(trait):
	var text = ''
	trait = globals.origins.trait(trait)
	if traits.find(trait.name) < 0:
		return
	traits.erase(trait.name)
	if trait['effect'].empty() != true:
		add_effect(trait['effect'], true)
	text += self.dictionary("$name lost trait: " + trait.name)
	if globals.get_tree().get_current_scene().has_node("infotext") && globals.slaves.find(self) >= 0 && away.at != 'hidden':
		globals.get_tree().get_current_scene().infotext(text,'yellow')

func levelupreqs_set(value):
	levelupreqs = value

func lewdness_set(value):
	lewdness = clamp(round(value), 0, 120)

func fear_set(value):
	var difference = value - fear
	if difference > 0:
		difference = difference - difference*self.cour/200
	
	fear += round(difference*fear_mod)
	fear = clamp(fear, 0, 100+self.wit/2)

func fear_get():
	return fear

func levelup():
	levelupreqs.clear()
	level += 1
	skillpoints += variables.skillpointsperlevel
	realxp = 0
	self.loyal += rand_range(5,10)
	if self != globals.player:
		globals.get_tree().get_current_scene().infotext(dictionary("$name has advanced to Level " + str(level)),'green')
	else:
		globals.get_tree().get_current_scene().infotext(dictionary("You have advanced to Level " + str(level)),'green')

func xp_set(value):
	var difference = value - realxp
	realxp += max(difference/max(level,1),1)
	realxp = round(clamp(realxp, 0, 100))
	if realxp >= 100 && self == globals.player:
		levelup()


func xp_get():
	return realxp

func getessence():
	var essence
	if race in ['Demon', 'Arachna', 'Lamia']:
		essence = 'taintedessenceing'
	elif race in ['Fairy', 'Drow', 'Dragonkin']:
		essence = 'magicessenceing'
	elif race == 'Dryad':
		essence = 'natureessenceing'
	elif race in ['Harpy', 'Centaur'] || race.find('Beastkin') >= 0 || race.find('Halfkin') >= 0:
		essence = 'bestialessenceing'
	elif race in ['Slime','Nereid', "Scylla"]:
		essence = 'fluidsubstanceing'
	return essence


func cleartraits():
	spec = null
	while !traits.empty():
		trait_remove(traits.back())
	for i in ['str_base','agi_base', 'maf_base', 'end_base']:
		stats[i] = 0
	skillpoints = 2
	level = 1
	xp = 0

func add_effect(effect, remove = false):
	effect = effect.duplicate()
	if effects.has(effect.code):
		if remove == true:
			effects.erase(effect.code)
			for i in effect:
				if stats.has(i):
					stats[i] = stats[i] + -effect[i]
				elif self.get(i) != null:
					#self[i] -= effect[i]
					set(i, get(i) - effect[i])
	elif remove != true:
		effects[effect.code] = effect
		for i in effect:
			if stats.has(i):
				stats[i] = stats[i] + effect[i]
			elif self.get(i) != null:
				#self[i] += effect[i]
				set(i, get(i) + effect[i])


func beauty_get():
	return beautybase + beautytemp


func health_set(value):
	stats.health_max = max(10, ((variables.basehealth + (stats.end_base+stats.end_mod)*variables.healthperend) + floor(level/2)*5) + stats.health_bonus)
	stats.health_cur = clamp(floor(value), 0, stats.health_max) 
	if stats.health_cur <= 0:
		death()

func obed_set(value):
	var difference = stats.obed_cur - value
	var string = ""
#warning-ignore:unused_variable
	var color
#warning-ignore:unused_variable
	var text = ""
	stats.obed_mod = clamp(stats.obed_mod, 0.2, 2)
	if difference > 0:
		difference = abs(difference)
		if abs(difference) < 20:
			string = "(-)"
		elif abs(difference) < 40:
			string = "(--)"
		else:
			string = "(---)"
		stats.obed_cur -= difference
		text = self.dictionary("$name's obedience has decreased " + string)
		color = 'red'
	else:
		difference = abs(difference)
		if abs(difference) < 20:
			string = "(+)"
		elif abs(difference) < 40:
			string = "(++)"
		else:
			string = "(+++)"
		text = self.dictionary("$name's obedience has grown " + string)
		color = 'green'
		stats.obed_cur += difference*stats.obed_mod
	
	stats.obed_cur = clamp(stats.obed_cur, stats.obed_min, stats.obed_max)
	if stats.obed_cur < 50 && spec == 'executor':
		stats.obed_cur = 50

func loyal_set(value):
	var difference = stats.loyal_cur - value
	var string = ""
#warning-ignore:unused_variable
	var color
#warning-ignore:unused_variable
	var text = ""
	if difference > 0:
		difference = abs(difference)
		if abs(difference) < 5:
			string = "(-)"
		elif abs(difference) < 10:
			string = "(--)"
		else:
			string = "(---)"
		stats.loyal_cur -= difference
		text = self.dictionary("$name's loyalty decreased " + string)
		color = 'red'
	elif difference < 0:
		difference = abs(difference)
		if abs(difference) < 5:
			string = "(+)"
		elif abs(difference) < 10:
			string = "(++)"
		else:
			string = "(+++)"
		text = self.dictionary("$name's loyalty grown " + string)
		color = 'green'
		stats.loyal_cur += difference*stats.loyal_mod
	
	
	stats.loyal_cur = max(min(stats.loyal_cur, stats.loyal_max),stats.loyal_min)
#		if globals.get_tree().get_current_scene().has_node("infotext") && globals.slaves.find(self) >= 0 && away.at != 'hidden':
#			globals.get_tree().get_current_scene().infotext(text,color)

func stress_set(value):
	
	var difference = value - stats.stress_cur 
	difference = difference*stats.stress_mod
	var endvalue = stats.stress_cur + difference
	var text = ""
	var color
	if stats.stress_cur < 99 && endvalue >= 99:
		text += "$name is about to suffer from mental breakdown... "
		color = 'red'
	if stats.stress_cur < 66 && endvalue >= 66:
		text += "$name has become considerably stressed. "
		color = 'red'
	elif (stats.stress_cur < 33 || stats.stress_cur >= 66) && (endvalue >= 33 && endvalue < 66):
		text += "$name has become mildly stressed. "
		color = 'yellow'
	elif stats.stress_cur >= 33 && endvalue < 33:
		text += "$name is no longer stressed. "
		color = 'green'
	
	stats.stress_cur = clamp(endvalue, stats.stress_min, stats.stress_max)
	if text != '' && globals.get_tree().get_current_scene().has_node("infotext") && globals.slaves.has(self) && away.at != 'hidden':
		globals.get_tree().get_current_scene().infotext(self.dictionary(text),color)
	if self == globals.player:
		stats.stress_cur = 0

func mentalbreakdown():
	self.cour -= rand_range(5,self.cour/4)
	self.conf -= rand_range(5,self.conf/4)
	self.wit -= rand_range(5,self.wit/4)
	self.charm -= rand_range(5,self.charm/4)
	if self.effects.has('captured'):
		self.add_effect(globals.effectdict.captured, true)
	if sleep != 'farm':
		self.health -= rand_range(0, stats.health_max/5)
	self.stress -= 30

func learningpoints_set(value):
	
	var difference = learningpoints - value
	var string = ""
	var text = ""
	var color
	if difference < 0:
		difference = abs(difference)
		string = difference
		text = self.dictionary("$name has acquired " + str(string) + " learning points. " )
		color = 'green'
	
	if globals.get_tree().get_current_scene().has_node("infotext") && globals.slaves.find(self) >= 0 && away.at != 'hidden':
		globals.get_tree().get_current_scene().infotext(text,color)
	learningpoints = value

func tox_set(value):
	var difference = value - stats.tox_cur
	stats.tox_cur = clamp(stats.tox_cur + difference*stats.tox_mod, stats.tox_min, stats.tox_max)

func energy_set(value):
	value = round(value)
	var difference = value - stats.energy_cur
	stats.energy_cur = clamp(stats.energy_cur + difference*(1 + stats.energy_mod/100), 0, stats.energy_max)
	if self == globals.player:
		globals.resources.energy = 0

var originvalue = {'slave' : 55, 'poor' : 65, 'commoner' : 75, 'rich' : 85, 'atypical' : 85, 'noble' : 100}

func cour_set(value):
	stats.cour_base = clamp(value, 0, min(stats.cour_max, originvalue[origins]))

func conf_set(value):
	stats.conf_base = clamp(value, 0, min(stats.conf_max, originvalue[origins]))

func wit_set(value):
	stats.wit_base = clamp(value, 0, min(stats.wit_max, originvalue[origins]))

func charm_set(value):
	stats.charm_base = clamp(value, 0, min(stats.charm_max, originvalue[origins]))

func lust_set(value):
	var difference = value - stats.lust_cur
	if difference > 0:
		stats.lust_cur = clamp(stats.lust_cur + difference*(1 + stats.lust_mod/100),stats.lust_min,stats.lust_max)
	else:
		stats.lust_cur = clamp(stats.lust_cur + difference,stats.lust_min,stats.lust_max)

#warning-ignore:unused_argument
func str_set(value):
	stats.str_base = min(stats.str_base, stats.str_max)

#warning-ignore:unused_argument
func agi_set(value):
	stats.agi_base = min(stats.agi_base, stats.agi_max)

#warning-ignore:unused_argument
func maf_set(value):
	stats.maf_base = min(stats.maf_base, stats.maf_max)

func end_set(value):
	var plushealth = false
	if stats.end_base < value:
		plushealth = true
	stats.end_base = min(stats.end_base, stats.end_max)
	if plushealth:
		self.health += variables.healthperend
	else:
		self.health = self.health



func beautybase_set(value):
	value = round(value)
	beautybase = min(max(value,0),100)

func loyal_get():
	return stats.loyal_cur

func health_get():
	return stats.health_cur

func obed_get():
	return stats.obed_cur

func stress_get():
	return stats.stress_cur

func cour_get():
	return floor(stats.cour_base)

func conf_get():
	return floor(stats.conf_base)

func wit_get():
	return floor(stats.wit_base)

func charm_get():
	return floor(stats.charm_base)

func lust_get():
	return stats.lust_cur


func tox_get():
	return stats.tox_cur

func energy_get():
	return stats.energy_cur

func str_get():
	return stats.str_base + stats.str_mod

func agi_get():
	return stats.agi_base + stats.agi_mod

func maf_get():
	return stats.maf_base + stats.maf_mod

func end_get():
	return stats.end_base + stats.end_mod

func awareness(hunt = false):
	var number = 0
	number = self.sagi*3 + self.wit/10
	if mods.has('augmenthearing'):
		number += 3
	if race.find('Wolf') >= 0:
		number += 4
	if globals.state.spec == 'Hunter' && hunt == false:
		number += 10
	if effects.has("tribal1"):
		number += 3
	elif effects.has('tribal2'):
		number += 6
	elif effects.has('tribal3'):
		number += 9
	return number


func health_icon():
	var health
	if float(stats.health_cur)/stats.health_max > 0.75: 
		health = load("res://files/buttons/icons/health/2.png")
	elif float(stats.health_cur)/stats.health_max > 0.4:
		health = load("res://files/buttons/icons/health/1.png")
	else:
		health = load("res://files/buttons/icons/health/3.png")
	return health

func obed_icon():
	var obed
	if float(stats.obed_cur)/stats.obed_max > 0.75: 
		obed = load("res://files/buttons/icons/obedience/2.png")
	elif float(stats.obed_cur)/stats.obed_max > 0.4:
		obed = load("res://files/buttons/icons/obedience/1.png")
	else:
		obed = load("res://files/buttons/icons/obedience/3.png")
	return obed

func stress_icon():
	var icon
	if stats.stress_cur >= 66: 
		icon = load("res://files/buttons/icons/stress/3.png")
	elif stats.stress_cur >= 33:
		icon = load("res://files/buttons/icons/stress/1.png")
	else:
		icon = load("res://files/buttons/icons/stress/2.png")
	return icon


func name_long():
	var text = ''
	if nickname == '':
		text = name
	else:
		text = '"' + nickname + '" ' + name
	if surname != "":
		text += " " + surname
	
	return text

func name_short():
	if nickname == '':
		return name
	else:
		return nickname

func race_short():
	if race.find("Beastkin") >= 0:
		return race.replace("Beastkin ", 'B.')
	elif race.find("Halfkin") >= 0:
		return race.replace("Halfkin ", "H.")
	else:
		return race

func dictionary(text):
	var string = text
	string = string.replace('$name', name_short())
	string = string.replace('$surname', surname)
	string = string.replace('$penis', globals.fastif(penis == 'none', 'strapon', '$his cock'))
	string = string.replace('$child', globals.fastif(sex == 'male', 'boy', 'girl'))
	string = string.replace('$sex', sex)
	string = string.replace('$He', globals.fastif(sex == 'male', 'He', 'She'))
	string = string.replace('$he', globals.fastif(sex == 'male', 'he', 'she'))
	string = string.replace('$His', globals.fastif(sex == 'male', 'His', 'Her'))
	string = string.replace('$his', globals.fastif(sex == 'male', 'his', 'her'))
	string = string.replace('$him', globals.fastif(sex == 'male', 'him', 'her'))
	string = string.replace('$son', globals.fastif(sex == 'male', 'son', 'daughter'))
	string = string.replace('$sibling', globals.fastif(sex == 'male', 'brother', 'sister'))
	string = string.replace('$parent', globals.fastif(sex == 'male', 'father', 'mother'))
	string = string.replace('$sir', globals.fastif(sex == 'male', 'Sir', "Ma'am"))
	string = string.replace('$race', globals.decapitalize(race).replace('_', ' '))
	string = string.replace('$playername', globals.player.name_short())
	string = string.replace('$master', masternoun)
	string = string.replace('[haircolor]', haircolor)
	string = string.replace('[eyecolor]', eyecolor)
	return string

func dictionaryplayer(text):
	var string = text
	string = string.replace('[Playername]', globals.player.name_short())
	string = string.replace('$name', name_short())
	string = string.replace('$penis', globals.fastif(penis == 'none', 'strapon', '$his cock'))
	string = string.replace('$child', globals.fastif(sex == 'male', 'boy', 'girl'))
	string = string.replace('$sex', sex)
	string = string.replace('$He', 'You')
	string = string.replace('$he', 'you')
	string = string.replace('$His', 'Your')
	string = string.replace('$his', 'your')
	string = string.replace('$him', 'your')
	string = string.replace('$child', globals.fastif(sex == 'male', 'son', 'daughter'))
	string = string.replace('$sibling', globals.fastif(sex == 'male', 'brother', 'sister'))
	string = string.replace('$sir', globals.fastif(sex == 'male', 'Sir', "Ma'am"))
	string = string.replace('$master', globals.fastif(sex == 'male', 'Master', "Mistress"))
	string = string.replace('[haircolor]', haircolor)
	string = string.replace('[eyecolor]', eyecolor)
	string = string.replace('$race', globals.decapitalize(race).replace('_', ' '))
	return string

func dictionaryplayerplus(text):
	var string = text
	string = string.replace(' has', ' have')
	string = string.replace(' Has', ' have')
	string = string.replace('You is', 'You are')
	string = string.replace("You's", "You're")
	string = string.replace('appears', 'appear')
	return string

func description():
	return globals.description.getslavedescription(self)

func descriptionsmall():
	return globals.description.getslavedescription(self, 'compact')

func status():
	return globals.description.getstatus(self)

func countluxury():
	var templuxury = luxury
	var goldspent = 0
	var foodspent = 0
	var nosupply = false
	var value = 0
	if sleep == 'personal':
		templuxury += 10+(5*globals.state.mansionupgrades.mansionluxury)
	elif sleep == 'your':
		templuxury += 5+(5*globals.state.mansionupgrades.mansionluxury)
	if rules.betterfood == true && globals.resources.food >= 5:
		globals.resources.food -= 5
		foodspent += 5
		templuxury += 5
	if rules.personalbath == true:
		if spec != 'housekeeper':
			value = 2
		else:
			value = 1
		if globals.itemdict.supply.amount >= value:
			templuxury += 5
			globals.itemdict.supply.amount -= value
		else:
			#nosupply == true
			nosupply = true
	if rules.pocketmoney == true:
		if spec != 'housekeeper':
			value = 10
		else:
			value = 5
		if globals.resources.gold >= value:
			templuxury += 10
			goldspent += value
			globals.resources.gold -= value
	if rules.cosmetics == true:
		if globals.itemdict.supply.amount > 1:
			templuxury += 5
			globals.itemdict.supply.amount -= 1
		else:
			nosupply = true
	
	var luxurydict = {luxury = templuxury, goldspent = goldspent, foodspent = foodspent, nosupply = nosupply}
	return luxurydict

func calculateluxury():
	var luxury = variables.luxuryreqs[origins]
	if traits.has("Ascetic"):
		luxury = luxury/2
	elif traits.has("Spoiled"):
		luxury *= 2
	return luxury



func calculateprice():
	var price = 0
	var bonus = 1
	price = beautybase*variables.priceperbasebeauty + beautytemp*variables.priceperbonusbeauty
	price += (level-1)*variables.priceperlevel
	price = price*globals.races[race.replace('Halfkin', 'Beastkin')].pricemod
	if vagvirgin == true:
		bonus += variables.pricebonusvirgin
	if sex == 'futanari':
		bonus += variables.pricebonusfuta
	for i in get_traits():
		if i.tags.has('detrimental'):
			bonus += variables.pricebonusbadtrait

	if self.toxicity >= 60:
		bonus -= variables.pricebonustoxicity
	
	if variables.gradepricemod.has(origins):
		bonus += variables.gradepricemod[origins]
	if variables.agepricemods.has(age):
		bonus += variables.agepricemods[age]
	
	
	if traits.has('Uncivilized'):
		bonus -= variables.priceuncivilized
	
	
	price = price*bonus
	
	if price < 0:
		price = variables.priceminimum
	return round(price)

func buyprice():
	return calculateprice()

func sellprice(alternative = false):
	var price = calculateprice()*0.6
	
	if effects.has('captured') == true && alternative == false:
		price = price/2
	var influential = false
	for i in globals.slaves:
		if i.traits.has("Influential"):
			influential = true
	if influential:
		price *= 1.2
	price = max(round(price), variables.priceminimumsell)
	if globals.state.spec == 'Slaver' && fromguild == false:
		price *= 2
	return price

func death():
	if globals.slaves.has(self):
		globals.main.infotext(self.dictionary("$name has deceased. "),'red')
		globals.items.unequipall(self)
		globals.slaves.erase(self)
		if globals.state.relativesdata.has(id):
			globals.state.relativesdata[id].state = 'dead'
	elif globals.state.babylist.has(self):
		globals.state.babylist.erase(self)
		globals.clearrelativesdata(self.id)
	globals.state.playergroup.erase(self.id)

func removefrommansion():
	globals.slaves.erase(self)
	globals.main.infotext(self.dictionary("$name $surname is no longer in your possession. "),'red')
	globals.items.unequipall(self)
	if globals.state.relativesdata.has(id):
		globals.state.relativesdata[id].state = 'left'

func abortion():
	if preg.duration > 0:
		preg.duration = 0
		var baby = globals.state.findbaby(preg.baby)
		preg.baby = null
		baby.death()

func checksex():
	var male = false
	var female = false
	
	if penis != 'none':
		male = true
	if vagina != 'none':
		female = true
	
	if male && female:
		sex = 'futanari'
	elif male:
		sex = 'male'
	else:
		sex = 'female'

func fetch(dict):
	for key in dict:
		var tv = dict[key]
		if typeof(tv) == TYPE_DICTIONARY:
			globals.merge(get(key), dict[key])
		elif typeof(tv) == TYPE_INT:
			set(key, get(key) + dict[key])
		else:
			set(key, dict[key])