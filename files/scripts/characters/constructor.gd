extends Node

var person

func getrandomsex(person):
	if globals.rules.male_chance > 0 && rand_range(0, 100) < globals.rules.male_chance:
		person.sex = 'male'
	elif rand_range(0, 100) < globals.rules.futa_chance && globals.rules.futa == true:
		person.sex = 'futanari'
	else:
		person.sex = 'female'

func getage(age):
	var temp
	var agearray = ['teen']
	if globals.rules.children == true:
		agearray.append('child')
	if globals.rules.noadults == false:
		agearray.append('adult')
	if age == 'random' || agearray.find(age) < 0:
		age = globals.randomfromarray(agearray)
	if (age == 'child' && globals.rules.children == false) || (age == 'adult' && globals.rules.noadults == true):
		age = globals.randomfromarray(agearray)
	return age


func newslave(race, age, sex, origins = 'slave'):
	var temp
	var temp2
	var person = globals.person.new()
	if race == 'randomcommon':
		race = globals.getracebygroup("starting")
	elif race == 'randomany':
		race = globals.randomfromarray(globals.allracesarray)
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
	person.masternoun = ''
	if randf() < variables.specializationchance/100.0:
		globals.currentslave = person
		var possible = []
		for i in globals.specarray:
			if globals.evaluate(globals.jobs.specs[i].reqs.replacen("person.consent == true","true").replacen("person.loyal >= 50","true")) == true:
				possible.append(i)
		if possible.size() > 0:
			person.spec = possible[randi()%possible.size()]
			if person.spec == 'bodyguard':
				person.add_effect(globals.effectdict.bodyguardeffect)
	if person.age == 'child' && randf() < 0.1:
		person.vagvirgin = false
	elif person.age == 'teen' && randf() < 0.3:
		person.vagvirgin = false
	elif person.age == 'adult' && randf() < 0.65:
		person.vagvirgin = false
	person.health = 1000
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
			person[i] = globals.randomfromarray(races[personrace][i])
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
		person.charm -= rand_range(5,15)
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
		person.charm += rand_range(5,25)
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
		var temp = globals.randomfromarray(array)
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

var portraits_by_race = {}

func _fill_portraits_by_race():
	for full_race in globals.allracesarray:
		for raceWord in full_race.split(" "):
			portraits_by_race[raceWord] = []

	var extensions = globals.imageExtensions
	for path in globals.dir_contents(globals.setfolders.portraits):
		if !path.get_extension() in extensions:
			continue
		for raceWord in portraits_by_race:
			if path.findn(raceWord) >= 0:
				portraits_by_race[raceWord].append(path)

func randomportrait(person):
	if portraits_by_race.empty():
		_fill_portraits_by_race()

	var count = 0
	var raceWords = person.race.split(" ")
	for raceWord in raceWords:
		count += portraits_by_race[raceWord].size()
	if count == 0:
		return
	count = randi() % count
	
	for raceWord in raceWords:
		var newCount = count - portraits_by_race[raceWord].size()
		if newCount < 0:
			var path = portraits_by_race[raceWord][count]
			person.imageportait = path
			path = path.replace(globals.setfolders.portraits, globals.setfolders.fullbody)
			if globals.canloadimage(path):
				person.imagefull = path
			return
		else:
			count = newCount
