extends Node

#warning-ignore:unused_class_variable
var person

func getrandomsex(person):
	if globals.rules.male_chance > 0 && rand_range(0, 100) < globals.rules.male_chance:
		person.sex = 'male'
	elif rand_range(0, 100) < globals.rules.futa_chance && globals.rules.futa == true:
		person.sex = 'futanari'
	else:
		person.sex = 'female'

func getage(age):
#warning-ignore:unused_variable
	var temp
	var agearray = ['teen']
	if globals.rules.children == true:
		agearray.append('child')
	if globals.rules.noadults == false:
		agearray.append('adult')
	if age == 'random' || agearray.find(age) < 0:
		age = agearray[rand_range(0,agearray.size())]
	if (age == 'child' && globals.rules.children == false) || (age == 'adult' && globals.rules.noadults == true):
		age = agearray[rand_range(0,agearray.size())]
	return age


func newslave(race, age, sex, origins = 'slave'):
#warning-ignore:unused_variable
	var temp
#warning-ignore:unused_variable
	var temp2
	var person = globals.person.new()
	if race == 'randomcommon':
		race = globals.getracebygroup("starting")
	elif race == 'randomany':
		race = globals.allracesarray[rand_range(0,globals.allracesarray.size())]
	person.race = race
	person.age = getage(age)
	person.mindage = person.age
	person.sex = sex
	if person.sex == 'random': getrandomsex(person)
	for i in ['cour_base','conf_base','wit_base','charm_base']:
		person.stats[i] = rand_range(35,65)
	person.id = str(globals.state.slavecounter)
	globals.state.slavecounter += 1
	changerace(person, 'Human')
	changerace(person)
	person.work = 'rest'
	person.sleep = 'communal'
	person.sexuals.actions.kiss = 0
	person.sexuals.actions.massage = 0
	globals.assets.getsexfeatures(person)
	if person.race.find('Halfkin') >= 0 || (person.race.find('Beastkin') >= 0 && globals.rules.furry == false):
		person.race = person.race.replace('Beastkin', 'Halfkin')
		person.bodyshape = 'humanoid'
		person.skincov = 'none'
		person.arms = 'normal'
		person.legs = 'normal'
		if rand_range(0,1) > 0.4:
			person.eyeshape = 'normal'
	if globals.rules.randomcustomportraits == true:
		randomportrait(person)
	get_caste(person, origins)
	for i in person.sexuals.unlocks:
		var category = globals.sexscenes.categories[i]
		for ii in category.actions:
			person.sexuals.actions[ii] = 0
	person.memory = person.origins
	person.masternoun = globals.state.defaultmasternoun
	if randf() < 0.05:
		var spec = globals.specarray[rand_range(0,globals.specarray.size())]
		globals.currentslave = person
		if globals.evaluate(globals.jobs.specs[spec].reqs) == true:
			person.spec = spec
	if person.age == 'child' && randf() < 0.1:
		person.vagvirgin = false
	elif person.age == 'teen' && randf() < 0.3:
		person.vagvirgin = false
	elif person.age == 'adult' && randf() < 0.65:
		person.vagvirgin = false
	person.health = 100
	return person

func changerace(person, race = null):
	var races = globals.races
	var personrace
	if race == null:
		personrace = person.race.replace('Halfkin','Beastkin')
	else:
		personrace = race
	for i in races[personrace]:
		if i in ['description', 'details']:
			continue
		if typeof(races[personrace][i]) == TYPE_ARRAY:
			person[i] = races[personrace][i][rand_range(0,races[personrace][i].size())]
		elif typeof(races[personrace][i]) == TYPE_DICTIONARY:
			if person.get(i) == null:
				continue
			for k in (races[personrace][i]):
				person[i][k] = races[personrace][i][k]
		else:
			if person.get(i) != null:
				person[i] = races[personrace][i]
	

func get_caste(person, caste):
	var array = []
	var spin = 0
	person.origins = caste
	if caste == 'slave':
		person.cour -= rand_range(10,30)
		person.conf -= rand_range(10,30)
		person.wit -= rand_range(10,30)
		person.charm -= rand_range(10,30)
		person.beautybase = rand_range(5,40)
		person.stats.obed_mod += 0.25
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
		person.stats.obed_mod -= 0.2
		if rand_range(0,10) >= 5:
			person.level += round(rand_range(0,3))
	elif caste == 'noble':
		person.cour += rand_range(10,30)
		person.conf += rand_range(10,30)
		person.wit += rand_range(10,30)
		person.charm += rand_range(10,30)
		person.beautybase = rand_range(45,95)
		person.stats.obed_mod -= 0.4
		if rand_range(0,10) >= 4:
			person.level += round(rand_range(0,3))
	
	person.skillpoints += (person.level-1)*variables.skillpointsperlevel
	spin = person.skillpoints
	array = ['sstr','sagi','smaf','send']
	while spin > 0:
		var temp = array[rand_range(0, array.size())]
		if rand_range(0,100) < 50 && person.stats[globals.basestatdict[temp]] < person.stats[globals.maxstatdict[temp]]:
			person.stats[globals.basestatdict[temp]] += 1
			person.skillpoints -= 1
		spin -= 1
	
	
	if randf() >= 0.8:
		spin = 2
	else:
		spin = 1
	while spin > 0:
		person.add_trait(globals.origins.traits('any').name)
		spin -= 1
	if person.traits.find("Fickle") >= 0:
		person.sexuals.unlocks.append("swing")

func tohalfkin(person):
	person.legs = 'normal'
	person.arms = 'normal'
	person.skincov = 'none'
	person.bodyshape = 'humanoid'

func randomportrait(person):
	var array = []
	var racenames = person.race.split(" ")
	for i in globals.dir_contents(globals.setfolders.portraits):
		for k in racenames:
			if i.findn(k) >= 0:
				array.append(i)
				continue
	if array.size() > 0:
		person.imageportait = array[randi()%array.size()]
	
