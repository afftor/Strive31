
extends Node

var person
var main
var caster

func spellsynchronize():
	for i in globals.state.spelllist:
		if i.learned == true:
			globals.spelldict[i].learned = true
			print('spellsynchroned')

var spelllist = {
#	mindread = { Spell entry
#		code = 'mindread', # spell entry reference
#		name = 'Mind Reading', # Displayed name
#		description = 'Enhances your mind to be more cunning towards others. Allows to get accurate information about other characters. ', #description
#		effect = 'mindreadeffect', #effect called on activation
#		manacost = 3, #mana cost
#		req = 0, #requirements (mansion alchemy upgrade)
#		price = 100, #gold cost to learn
#		personal = true, #can be used on another slave
#		combat = true, #has a corresponding combat ability
#		learned = false, #when learned, will be saved and loaded
#		type = 'control', #category
#		flavor = "Bonus description",
#	},
	mindread = {
		code = 'mindread',
		name = 'Mind Reading',
		description = 'Enhances your mind to be more cunning towards others. Allows to get accurate information about other characters. ',
		effect = 'mindreadeffect',
		manacost = 3,
		req = 0,
		price = 100,
		personal = true,
		combat = true,
		learned = false,
		type = 'control',
		flavor = "Reading other person's thoughts hardly worth the effort: way too often they are just chaotic streams changing one after another. Nevertheless, you can grasp some understanding how others think by devoting your time to them. ",
	},
	sedation = {
		code = 'sedation',
		name = 'Sedation',
		description = "Eases target's stress and fear.",
		effect = 'sedationeffect',
		manacost = 10,
		req = 0,
		price = 200,
		personal = true,
		combat = true,
		learned = false,
		type = 'control',
		flavor = "Ability to calm down another person is invaluable in many situations. ",
	},
	heal = {
		code = 'heal',
		name = 'Heal',
		description = 'Heals physical wounds. ',
		effect = 'healeffect',
		manacost = 10,
		req = 0,
		price = 200,
		personal = true,
		combat = true,
		learned = false,
		type = 'defensive',
		flavor = "Regeneration is a part of every living being.",
	},
	dream = {
		code = 'dream',
		name = 'Dream',
		description = 'Puts target into deep, restful sleep. ',
		effect = 'dreameffect',
		manacost = 20,
		req = 0,
		price = 350,
		personal = true,
		combat = false,
		learned = false,
		type = 'control',
	},
	entrancement = {
		code = 'entrancement',
		name = 'Entrancement',
		description = 'Makes target more susceptible to suggestions and easier to acquire various kinks.',
		effect = 'entrancementeffect',
		manacost = 15,
		req = 10,
		price = 400,
		personal = true,
		combat = false,
		learned = false,
		type = 'control',
	},
	fear = {
		code = 'fear',
		name = 'Fear',
		description = 'Invokes subconscious feel of terror onto the target. Can be effective punishment. ',
		effect = 'feareffect',
		manacost = 10,
		req = 0,
		price = 250,
		personal = true,
		combat = false,
		learned = false,
		type = 'control',
	},
	domination = {
		code = 'domination',
		name = 'Domination',
		description = 'Attempts to overwhelm  the target′s mind and instill unwavering obedience. May cause irreversible mental trauma. ',
		effect = 'dominationeffect',
		manacost = 40,
		req = 10,
		price = 500,
		personal = true,
		combat = false,
		learned = false,
		type = 'control',
	},
	mutate = {
		code = 'mutate',
		name = 'Mutation',
		description = 'Enforces mutation onto target. Results may vary drastically. ',
		effect = 'mutateeffect',
		manacost = 15,
		req = 2,
		price = 400,
		personal = true,
		combat = false,
		learned = false,
		type = 'utility',
	},
	barrier = {
		code = 'barrier',
		name = 'Barrier',
		description = "Creates a magical barrier around target, raising its armor. ",
		effect = '',
		manacost = 12,
		req = 1,
		price = 200,
		personal = false,
		combat = true,
		learned = false,
		type = 'defensive',
	},
	shackle = {
		code = 'shackle',
		name = 'Shackle',
		description = "Ties single target to ground making escape impossible. ",
		effect = '',
		manacost = 10,
		req = 1,
		price = 200,
		personal = false,
		combat = true,
		learned = false,
		type = 'utility',
	},
	acidspit = {
		code = 'acidspit',
		name = 'Acid Spit',
		description = "Turns your saliva into highly potent corrosive substance for a short time. \nDeals spell damage to single target enemy and reduces its armor. ",
		effect = '',
		manacost = 6,
		req = 2,
		price = 400,
		personal = false,
		combat = true,
		learned = false,
		type = 'offensive',
	},
	mindblast = {
		code = 'mindblast',
		name = 'Mind Blast',
		description = "Simple mind attack which can be utilized in combat. While not terribly effective on its own, can eventually break the enemy. \nDeals spell damage to single target enemy. ",
		effect = '',
		manacost = 5,
		req = 1,
		price = 100,
		personal = false,
		combat = true,
		learned = false,
		type = 'offensive',
	},
	invigorate = {
		code = 'invigorate',
		name = 'Invigorate',
		description = "Restores caster's and target's energy by using mana and target body's potential. Builds up target's stress. Can be used in wild. ",
		effect = 'invigorateeffect',
		manacost = 5,
		req = 2,
		price = 300,
		personal = true,
		combat = false,
		learned = false,
		type = 'utility',
	},
	summontentacle = {
		code = 'summontentacle',
		name = 'Summon Tentacle',
		description = 'Summons naughty tentacles from the otherworld for a short time. Can make up for a very effective punishment.',
		effect = 'tentacleeffect',
		manacost = 35,
		req = 10,
		price = 650,
		personal = true,
		combat = false,
		learned = false,
		type = 'utility',
	},
	guidance = {
		code = 'guidance',
		name = 'Guidance',
		description = "An utility spell which helps to find shortest and safest paths among the wilds. \nEffect grows with Magic Affinity. \n[color=yellow]Effect reduced in enclosed spaces[/color] ",
		effect = 'guidanceeffect',
		manacost = 8,
		req = 2,
		price = 250,
		personal = false,
		combat = false,
		learned = false,
		type = 'utility',
	},
	mark = {
		code = 'mark',
		name = 'Mark',
		description = "An utility spell, leaving a permanent mark on the location, allowing to return to it from portal room later on. Only 1 mark at the time is allowed. ",
		effect = 'markeffect',
		manacost = 10,
		req = 2,
		price = 500,
		personal = false,
		combat = false,
		learned = false,
		type = 'utility',
	},
}

func spellcost(spell):
	var cost = spell.manacost
	if globals.state.spec == 'Mage':
		cost = cost/2
	return cost

func mindreadeffect():
	var spell = globals.spelldict.mindread
	var text = ''
	globals.resources.mana -= spellcost(spell)
	text = "You peer into $name's soul. $He is of " + person.origins + " origins. \nObedience: " + str(round(person.obed)) + ", Fear: " + str(person.fear) + ', Stress: '+ str(round(person.stress)) + ', Loyalty: ' + str(round(person.loyal)) + ', Lust: '+ str(round(person.lust)) + ', Courage: ' + str(round(person.cour)) + ', Confidence: ' + str(round(person.conf)) + ', Wit: '+ str(round(person.wit)) + ', Charm: ' + str(round(person.charm)) + ", Toxicity: " + str(floor(person.toxicity)) + ", Lewdness: " + str(floor(person.lewdness)) + ", Role Preference: " + str(floor(person.asser))
	text += "\nStrength: " + str(person.sstr) + ", Agility: " + str(person.sagi) + ", Magic Affinity: " + str(person.smaf) + ", Endurance: " + str(person.send)
	text += "\nBase Beauty: " + str(person.beautybase) + ', Temporal Beauty: ' + str(person.beautytemp)
	if person.effects.has('captured') == true:
		text = text + "\n$name doesn't accept $his new life in your domain. (Rebelling: " + str(person.effects.captured.duration) + ")"
	if person.traits.size() >= 0:
		text += '\n$name has corresponding traits:'
		for i in person.traits:
			text += ' ' + i
		text += '.'
	if person.preg.duration > 0:
		text += "\nPregnancy: " + str(person.preg.duration)
	if person.lastsexday != 0:
		text += "\n$name had sex last time " + str(globals.resources.day - person.lastsexday) + " day(s) ago"
	text = person.dictionary(text)
	return text

func sedationeffect():
	var text = ''
	var spell = globals.spelldict.sedation
	globals.resources.mana -= spellcost(spell)
	if person.effects.has('sedated'):
		text = "You cast Sedation spell on $name, but it appears $he is already under its effect. "
		return person.dictionary(text)
	person.add_effect(globals.effectdict.sedated)
	person.stress -= rand_range(20,30) + globals.player.smaf*6
	person.fear -= rand_range(5,15)
	main.rebuild_slave_list()
	text = 'You cast Sedation spell on the $name and $he relaxes a bit.'
	return person.dictionary(text)

func healeffect():
	var text = ''
	var spell = globals.spelldict.heal
	globals.resources.mana -= spellcost(spell)
	if person.health < person.stats.health_max:
		person.health += rand_range(20,30) + globals.player.smaf*7
		if globals.player != person:
			text = "After you finish casting the spell, $name's wounds close up. "
			if person.loyal < 20:
				person.loyal += rand_range(2,4)
				person.obed += rand_range(10,15)
				text += '$He looks somewhat surprised at your kind treatment and grows bit closer to you. '
		else:
			text = "After you finish casting the healing spell, your wounds close up. "
	else:
		text = "It seems like $name was not injured in first place. "
	text = person.dictionary(text)
	return text

func dreameffect():
	var text = ''
	var spell = globals.spelldict.dream
	globals.resources.mana -= spellcost(spell)
	person.away.duration = 1
	person.away.at = 'rest'
	person.energy = person.stats.energy_max
	person.stress -= rand_range(25,35) + caster.smaf*5
	text = 'You cast sleep on $name, putting $him into deep rest until the next day. '
	main._on_mansion_pressed()
	return person.dictionary(text)


func invigorateeffect():
	var text = ''
	var spell = globals.spelldict.invigorate
	globals.resources.mana -= spellcost(spell)
	person.energy += person.stats.energy_max/2
	person.stress += max(rand_range(25,35)-globals.player.smaf*4, 10)
	globals.player.energy += 50
	text = person.dictionary("You cast Invigorate on $name. Your and $his energy is partly restored. $His stress has increased. ")
	return text

func entrancementeffect():
	var text = ''
	var spell = globals.spelldict.entrancement
	var exists = false
	globals.resources.mana -= spellcost(spell)
	if person.effects.has('entranced') == false:
		text = "Light gradually fades from $name's eyes, and $his gaze becomes downcast. $He seems ready to accept whatever you tell $him. "
		person.add_effect(globals.effectdict.entranced)
	else:
		text = "It seems like $name is already entranced. "
	return person.dictionary(text)

func feareffect():
	var text = "You grab hold of $name's shoulders and hold $his gaze. At first, $he’s calm, but the longer you stare into $his eyes, the more $he trembles in fear. Soon, panic takes over $his stare. "
	var spell = globals.spelldict.fear
	globals.resources.mana -= spellcost(spell)
	person.fear += 20+caster.smaf*10
	person.stress += max(5, 20-caster.smaf*3)
	if person.effects.has('captured') == true:
		text += "\n[color=green]$name becomes less rebellious towards you.[/color]"
		person.effects.captured.duration -= 1+globals.player.smaf
	text = (person.dictionary(text))
	return text

func dominationeffect():
	var text = ''
	var spell = globals.spelldict.domination
	globals.resources.mana -= spellcost(spell)
	if rand_range(0,100) < 20 && globals.player.smaf < 5:
		text = "Your spell badly damages $name's mind as $he twitches and yells under its effect."
		person.cour -= rand_range(1,25)
		person.conf -= rand_range(1,25)
		person.wit -= rand_range(1,25)
		person.charm -= rand_range(1,25)
	else:
		if person.wit + person.conf > rand_range(100,175):
			text = '$name managed to resist influence of your spell. $His disposition towards you worsened. '
			person.loyal += -rand_range(15,25)
			person.obed += -rand_range(25,50)
		else:
			text = 'Your spell greatly affected $name and $he became way more submissive towards you.  '
			person.loyal += rand_range(25,50)
			person.obed += 100
			if person.effects.has('captured') == true:
				text += "\n[color=green]$name becomes less rebellious towards you.[/color]"
				person.effects.captured.duration -= 3+(1*globals.player.smaf)
	text = (person.dictionary(text))
	return text

func guidanceeffect():
	var spell = globals.spelldict.guidance
	globals.resources.mana -= spellcost(spell)
	var text = 'You cast guidance and move forward through the area avoiding any unnecessary encounters. '
	
	if main.exploration.currentzone.tags.has("enclosed"):
		main.exploration.progress += round((2 + globals.player.smaf*1.5)/2)
	else:
		main.exploration.progress += round(2 + globals.player.smaf*1.5)
	main.exploration.zoneenter(main.exploration.currentzone.code)
	return text

func markeffect():
	var spell = globals.spelldict.mark
	globals.resources.mana -= spellcost(spell)
	var text = 'You cast the Mark on hidden spot to return here later. '
	globals.state.marklocation = main.exploration.currentzone.code
	
	return text

func tentacleeffect():
	var spell = globals.spelldict.summontentacle
	var text = "As you finish chanting the spell, a stream of tentacles emerge from small breach in air. "
	if person.unique == 'Zoe':
		text += "\n\n[color=yellow]—No... Please NO![/color]\n\n"
	
	text += "They quickly seize $name by the limbs and free $him from the clothes. You observe how $name is being toyed and raped by tentacles. After a couple of orgasms the tentacles disappear from reality and you make sure that $name learned this lesson well before leaving."
	person.obed += 75
	person.fear += 90
	person.lust -= rand_range(20,30)
	if person.vagvirgin == true:
		person.vagvirgin = false
	if !person.traits.has("Deviant"):
		person.loyal -= 20
		person.stress += rand_range(30,50)
	if person.unique == 'Zoe':
		person.loyal = 0
		text += "\n\n[color=yellow]—How could you...?[/color]"
	
	return person.dictionary(text)

func sortspells(first, second):
	if first.name >= second.name:
		return false
	else:
		return true

func randNewFromArray(array, old):
	array = array.duplicate()
	array.erase(old)
	return globals.randomfromarray(array)

func randNewPartFromArray(targetPerson, part, array):
	array = array.duplicate()
	array.erase(targetPerson[part])
	targetPerson[part] = globals.randomfromarray(array)

func mutateeffect():
	globals.resources.mana -= spellcost(spelllist.mutate)
	var text = mutate(2)
	globals.main.rebuild_slave_list()
	return text

var dictChangeParts = {
	15 : ['height', globals.heightarray, "height"],
	16 : ['titssize', globals.sizearray, "chest size"],
	17 : ['asssize', globals.sizearray, "butt size"],
	18 : ['skin', globals.allskincolors, "skin color"],
	19 : ['eyecolor', globals.alleyecolors, "eye color"],
	20 : ['eyeshape', ['normal','slit'], "pupil shape"],
	21 : ['haircolor', globals.allhaircolors, "hair color"],
	22 : ['ears', globals.allears, "ear shape"],
}
func mutate(power=2):
	var text = "Raw magic in $name's body causes $him to uncontrollably mutate. \n\n"
	var temp
	while power >= 1:
		var didChange = true
		match randi() % 23:
			0:
				if person.add_trait(globals.origins.traits('any').name):
					text += "$name has received a new trait. "
				else:
					didChange = false
			1:
				if person.penis == 'none':
					person.penis = 'small'
					if (globals.rules.futa && randi() % 3 != 0) || person.vagina == 'none':
						text += "$name has grown a dick. "
					else:
						person.vagina = 'none'
						person.preg.has_womb = false
						text += "$name's vagina has transformed into a dick. "
				elif person.vagina == 'none':
					person.vagina = 'normal'
					person.preg.has_womb = true
					if (globals.rules.futa && randi() % 3 != 0) || person.penis == 'none':
						text += "$name has grown a vagina. "
					else:
						person.penis = 'none'
						text += "$name's dick has transformed into a vagina. "
				elif randi() % 2 == 0:
					person.vagina = 'none'
					person.preg.has_womb = false
					text += "$name's vagina has shrunk to nothing. "
				else:
					person.penis = 'none'
					text += "$name's dick has shrunk to nothing. "
			2:
				if person.penis == 'none':
					didChange = false
				elif randi() % 2 == 0:
					text += "$name's dick size has changed. "
					randNewPartFromArray(person, 'penis', globals.genitaliaarray)
				else:
					text += "$name's dick shape has changed. "
					randNewPartFromArray(person, 'penistype', globals.penistypearray)		
			3:
				if !globals.rules.futaballs && person.sex != 'male':
					if person.balls != 'none':
						person.balls = 'none'
						text += "$name's scrotum has shrunk to nothing. "
					else:
						didChange = false
				elif person.balls == 'none':
					person.balls = 'small'
					text += "$name has grown a scrotum. "
				else:
					randNewPartFromArray(person, 'balls', globals.genitaliaarray + ['none'])
					if person.balls == 'none':
						text += "$name's scrotum has shrunk to nothing. "
					else:
						text += "$name's scrotum size has changed. "
			4:
				text += "$name's skin coverage has changed. "
				if globals.rules.furry:
					randNewPartFromArray(person, 'skincov', globals.skincovarray)
					randNewPartFromArray(person, 'furcolor', globals.allfurcolors)
				else:
					temp = globals.skincovarray
					temp.erase('full_body_fur')
					randNewPartFromArray(person, 'skincov', temp)
			5:
				if globals.hairlengtharray.find(person.hairlength) < globals.hairlengtharray.size() - 1:
					person.hairlength = globals.hairlengtharray[globals.hairlengtharray.find(person.hairlength) + 1]
					text += "$name's hair has grown. "
				else:
					didChange = false 
			6:
				text += "$name's general appeal has drastically changed. "
				temp = person.beautybase
				while abs(temp - person.beautybase) < 15:
					temp = round(rand_range(10, 90))
				person.beautybase = temp
			7:
				if person.lactation == false:
					text += "$name's breasts started secreting milk. "
					person.lactation = true
				else:
					text += "$name's breasts stopped secreting milk. "
					person.lactation = false
			8:
				temp = randNewFromArray(range(6), int(person.titsextra))
				text += "Additional %s have %s on $name's torso. " % ["tits" if person.titsextradeveloped else "nipples", "sprouted" if (temp > person.titsextra) else "shrunk to nothing"]
				person.titsextra = temp
			9:
				if person.preg.has_womb && person.preg.duration == 0 && !person.effects.has("contraceptive"):
					text += "It seems some new life has began in $name. "
					person.preg.fertility = 100
					globals.impregnation(person)
				else:
					didChange = false
			10:
				text += "$name's cognitive abilities have worsened. "
				person.wit -= rand_range(10,25)
			11:
				text += "$name's lust has greatly increased. "
				person.lust += rand_range(40,80)
			12:
				temp = randNewFromArray(globals.allhorns + ['none'], person.horns)
				if person.horns == 'none':
					text += "$name has grown a pair of horns. "
				elif temp == 'none':
					text += "$name's horns have shrunk to nothing. "
				else:
					text += "$name's horns have changed in shape. " 
				person.horns = temp
			13:
				temp = randNewFromArray(globals.alltails + ['none'], person.tail)
				if person.tail == 'none':
					text += "$name has grown a tail. "
				elif temp == 'none':
					text += "$name's tail has shrunk to nothing. "
				else:
					text += "$name's tail has changed in shape. " 
				person.tail = temp
			14:
				temp = randNewFromArray(globals.allwings + ['none'], person.wings)
				if person.wings == 'none':
					text += "$name has grown a pair of wings. "
				elif temp == 'none':
					text += "$name's wings have shrunk to nothing. " 
				else:
					text += "$name's wings have changed in shape. " 
				person.wings = temp
			var val:
				var ref = dictChangeParts.get(val)
				if ref == null:
					didChange = false
				else:
					randNewPartFromArray(person, ref[0], ref[1])
					text += "$name's %s has changed. " % ref[2]
		if didChange:
			person.stress += rand_range(5,15)
			power -= 1
	person.checksex()
	person.toxicity -= rand_range(20,30)
	text = person.dictionary(text)
	return text

