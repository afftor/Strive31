
extends Node


static func getRaceFunction(name):
	var text
	var temp
	temp = name
	if temp.find('Beastkin ') >= 0 || temp.find('Halfkin') >= 0 || temp.find(' ') >= 0:
		temp = temp.replace('Beastkin ', '')
		temp = temp.replace('Halfkin ', '')
		temp = temp.replace(' ', '')
	text = globals.races.call('Race'+temp)
	return text


static func newslave(race, age, sex, origins = 'slave'):
#warning-ignore:unused_variable
	var temp
	var temp2
	var person = globals.person.new()
	if race == 'randomcommon':
		race = globals.starting_pc_races[rand_range(0,globals.starting_pc_races.size())]
	elif race == 'randomany':
		race = globals.allracesarray[rand_range(0,globals.allracesarray.size())]
	if age == 'random':
		temp2 = ['child','teen','adult']
		age = temp2[rand_range(0,3)]
	if age == 'child' && globals.rules.children == false:
		temp2 = ['teen','adult']
		age = temp2[rand_range(0,2)]
	elif age == 'adult' && globals.rules.noadults == true:
		temp2 = ['child','teen']
		age = temp2[rand_range(0,2)]
	person.race = race
	person.age = age
	if globals.rules.children == false:
		person.mindage = 'adult'
	else:
		person.mindage = age
	person.sex = sex
	if person.sex == 'random': person.sex = globals.assets.getrandomsex()
	globals.assets.getRandomName(person)
	person.stats = {
		str_cur = 0,
		str_max = 0,
		str_mod = 0,
		str_base = 0,
		agi_cur = 0, 
		agi_max = 0,
		agi_mod = 0,
		agi_base = 0,
		maf_cur = 0,
		maf_max = 0,
		maf_mod = 0,
		maf_base = 0,
		end_base = 0,
		end_cur = 0,
		end_mod = 0,
		end_max = 0,
		cour_cur = 0,
		cour_max = 100,
		cour_base = rand_range(35,65),
		conf_cur = 0,
		conf_max = 100,
		conf_base = rand_range(35,65),
		wit_cur = 0,
		wit_max = 100,
		wit_base = rand_range(35,65),
		charm_cur = 0,
		charm_max = 100,
		charm_base = rand_range(35,65),
		obed_cur = 0,
		obed_max = 100,
		obed_min = 0,
		obed_mod = 0,
		stress_cur = 0,
		stress_max = 150,
		stress_min = 0,
		stress_mod = 0,
		dom_cur = rand_range(40,60),
		dom_max = 100,
		dom_min = 0,
		tox_cur = 0,
		tox_max = 100,
		tox_min = 0,
		lust_cur = 0,
		lust_max = 100,
		lust_min = 0,
		lust_mod = 0,
		health_cur = 0,
		health_max = 35,
		health_base = 35,
		health_bonus = 1,
		energy_cur = 75,
		energy_max = 100,
		energy_mod = 0,
		armor_cur = 0,
		armor_max = 0,
		armor_base = 0,
		loyal_cur = 0,
		loyal_mod = 0,
		loyal_max = 100,
		loyal_min = 0,
	}
	person.id = OS.get_unix_time() + OS.get_ticks_msec() + round(rand_range(0,100))
	person.hairlength = globals.assets.getHairLengthBase(person)
	person.nickname = ''
	person.fetch(getRaceFunction(race))
	person.relatives = {father = -1, mother = -1, siblings = [], children =[]}
	person.brand = 'none'
	getPregnancy(person)
	person.work = 'rest'
	person.ability = ['attack','protect']
	person.abilityactive = ['attack','protect']
	person.level = 1
	person.xp = 0
	person.skillpoints = 2
	person.sleep = 'communal'
	person.hairstyle = globals.assets.getRandomHairStyle(person)
	person.sexuals.actions.kiss = 0
	person.sexuals.actions.massage = 0
	globals.assets.getSexFeatures(person)
	if person.race.find('Halfkin') >= 0 || (person.race.find('Beastkin') >= 0 && globals.rules['furry'] == false):
		person.race = person.race.replace('Beastkin', 'Halfkin')
		person.bodyshape = 'humanoid'
		person.skincov = 'none'
		person.arms = 'normal'
		person.legs = 'normal'
		if rand_range(0,1) > 0.4:
			person.eyeshape = 'normal'
	person.origins = ''
	get_caste(person, origins)
	getsexactions(person)
	person.health = 100
	person.memory = person.origins
	person.masternoun = globals.state.defaultmasternoun
	if rand_range(0,100) < 5:
		var spec = globals.specarray[rand_range(0,globals.specarray.size())]
		globals.currentslave = person
		if globals.evaluate(globals.jobs.specs[spec].reqs) == true:
			person.spec = spec
	return person

static func getsexactions(person):
	var category
	for i in person.sexuals.unlocks:
		category = globals.sexscenes.categories[i]
		for ii in category.actions:
			person.sexuals.actions[ii] = 0


static func get_caste(person, caste):
	var array = []
	var spin = 0
	person.origins = caste
	if caste == 'slave':
		person.cour -= rand_range(10,30)
		person.conf -= rand_range(10,30)
		person.wit -= rand_range(10,30)
		person.charm -= rand_range(10,30)
		person.beautybase = rand_range(5,40)
		person.stats.obed_mod = 25
		if rand_range(0,10) >= 9:
			person.level += 1
	elif caste == 'poor':
		person.cour -= rand_range(5,15)
		person.conf -= rand_range(5,15)
		person.wit -= rand_range(5,15)
		person.charm += rand_range(-5,15)
		person.beautybase = rand_range(10,50)
		if rand_range(0,10) >= 8:
			person.level += round(rand_range(0,2))
	elif caste == 'commoner':
		person.cour += rand_range(-5,15)
		person.conf += rand_range(-5,15)
		person.wit += rand_range(-5,15)
		person.charm += rand_range(-5,20)
		person.beautybase = rand_range(25,65)
		if rand_range(0,10) >= 7:
			person.level += round(rand_range(0,2))
	elif caste == 'rich':
		person.cour += rand_range(5,20)
		person.conf += rand_range(5,25)
		person.wit += rand_range(5,20)
		person.charm += rand_range(-5,15)
		person.beautybase = rand_range(35,75)
		person.stats.obed_mod = -20
		if rand_range(0,10) >= 5:
			person.level += round(rand_range(0,3))
	elif caste == 'noble':
		person.cour += rand_range(10,30)
		person.conf += rand_range(10,30)
		person.wit += rand_range(10,30)
		person.charm += rand_range(10,30)
		person.beautybase = rand_range(45,95)
		person.stats.obed_mod = -40
		if rand_range(0,10) >= 4:
			person.level += round(rand_range(0,3))
	
	person.skillpoints += (person.level-1)*3
	spin = person.skillpoints
	array = ['sstr','sagi','smaf','send']
	while spin > 0:
		var temp = array[rand_range(0, array.size())]
		if rand_range(0,100) < 50 && person[temp] < person.stats[globals.maxstatdict[temp]]:
			person[temp] += 1
			person.skillpoints -= 1
		spin -= 1
	
	person.add_trait(globals.origins.traits('any'))
	if person.traits.has("Fickle") == true:
		person.sexuals.unlocks.append("swing")


static func getPregnancy(person):
	person.preg.duration = 0
	person.preg.baby = ''
	if person.sex == 'male':
		person.preg.has_womb = false
		person.preg.fertility = 0
	else:
		person.preg.has_womb = true
		if person.age == 'child': 
			person.preg.fertility = 10
		else:
			person.preg.fertility = 20