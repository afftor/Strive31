
extends Node


func getrandomage():
	var text = []
	if globals.rules.children == true:
		text.append('child')
	
	if globals.rules.teens == true:
		text.append('teen')
	
	if globals.rules.adults == true:
		text.append('adult')
	
	return getrandomfromarray(text)


func getsexfeatures(person):
	var temp
	var dick = false
	var pussy = false
	if person.race.find("Beastkin") >= 0 && globals.rules.furrynipples == true:
		person.titsextra = 3
	if person.sex == 'male':
		person.asser = rand_range(30,90)
		dick = true
		if person.age == 'child':
			temp = ['flat']
		else:
			temp = ['flat','masculine']
		person.asssize = getrandomfromarray(temp)
		person.titssize = getrandomfromarray(temp)
	else:
		person.asser = rand_range(10,70)
		pussy = true
		if person.sex == 'futanari':
			dick = true
		if person.age == 'child':
			temp = ['flat','flat','small','small','small','average']
		elif person.age == 'teen':
			temp = ['flat','small','small','average','average','big']
		else:
			temp = ['flat','small','average','big','huge']
		person.asssize = getrandomfromarray(temp)
		person.titssize = getrandomfromarray(temp)
	if dick == true:
		if person.age in ['child','teen']:
			temp = ['small','average']
		else:
			temp = ['small','average','big']
		person.penis = getrandomfromarray(temp)
		if person.sex == 'male' || globals.rules.futaballs == true:
			person.balls = getrandomfromarray(temp)
		else:
			person.balls = 'none'
	else:
		person.penis = 'none'
		person.balls = 'none'
	if pussy == true:
		person.vagina = 'normal'
	else:
		person.vagina = 'none'
		person.preg.has_womb = false
	
	if person.penis != 'none' && person.race.find('Beastkin') >= 0:
		if person.race.find('Cat') >= 0:
			person.penistype = 'feline'
		elif person.race.find('Fox') >= 0 || person.race.find('Wolf') >= 0:
			person.penistype = 'canine'
	if person.penis != 'none' && person.race.find('Centaur') >= 0:
		person.penistype = 'equine'
	getheight(person)
	gethair(person)
	getname(person)

func getname(person):
	var text = person.race.to_lower()+person.sex.replace("futanari",'female')
	if !globals.racefile.names.has(text):
		text = 'human'+person.sex.replace("futanari",'female')
	person.name = getrandomfromarray(globals.names[text])

func getheight(person):
	if person.bodyshape == 'shortstack':
		person.height = 'tiny'
	else:
		if person.age == 'child':
			person.height = getrandomfromarray(['petite', 'short'])
		elif person.age == 'teen':
			person.height = getrandomfromarray(['petite', 'short', 'average', 'tall'])
		else:
			person.height = getrandomfromarray(['short', 'average', 'tall', 'towering'])

func gethair(person):
	if person.sex == 'male':
		person.hairlength = getrandomfromarray(['ear','ear','ear','neck','neck','shoulder'])
		person.hairstyle = getrandomfromarray(['straight', 'straight', 'straight', 'straight', 'ponytail'])
	else:
		if person.age == 'child':
			person.hairlength = getrandomfromarray(['ear','neck','shoulder'])
		elif person.age == 'teen':
			person.hairlength = getrandomfromarray(['ear','neck','shoulder','waist'])
		else:
			person.hairlength = getrandomfromarray(['ear','neck','shoulder','waist','hips'])
		
		if person.hairlength != 'short' && rand_range(0,10) < 6:
			person.hairstyle = getrandomfromarray(['ponytail', 'twintails', 'braid', 'two braids', 'bun'])
		else:
			person.hairstyle = 'straight'

func getrandomfromarray(array):
	return array[randi() % array.size()]


func getrandomeyecolor():
	return getrandomfromarray(globals.alleyecolors)

func getrandomfurcolor():
	return getrandomfromarray(globals.allfurcolors)

func getrandomhaircolor():
	return getrandomfromarray(globals.allhaircolors)


func getrandomhorns():
	return getrandomfromarray(globals.allhorns)


func getrandomskincolor():
	return getrandomfromarray(globals.allskincolors)


