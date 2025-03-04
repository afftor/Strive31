
extends Node

#func _init():
	#globals.effectdict = effectlist


var effectlist = {
	captured = {code = 'captured', obed_max = -50, duration = 5},
	stimulated = {code = 'stimulated',lust_mod = 50,duration = 1},
	beautypot = {code = 'beautypot', beautytemp = 20, duration = 8},
	numbed = {code = 'numbed',lust_mod = -50,duration = 1},
	entranced =  {code = 'entranced', duration = 1},
	sedated = {code = 'sedated',duration = 1},
	drunk = {code = 'drunk', duration = 1},
	augmentfur = {code = 'augmentfur', armor_cur = 2, armor_base = 2},
	augmentscales = {code = 'augmentscales', armor_cur = 2, armor_base = 2},
	augmentstr = {code = 'augmentstr', str_max = 2},
	augmentagi = {code = 'augmentagi', agi_max = 2},
	unnatural = {code = 'unnatural'},
	bodyguardeffect = {code = 'bodyguardeffect', armor_cur = 4, armor_base = 4, health_bonus = 40},
	bandaged = {code = 'bandaged', duration = 1},
	contraceptive = {code = 'contraceptive', duration = 2},
	#tattoo effects
	nature1 = {code = 'nature1', beautytemp = 5},
	nature2 = {code = 'nature2', beautytemp = 10},
	nature3 = {code = 'nature3', beautytemp = 15},
	degrading1 = {code = 'degrading1', ondayend = 'degrading1'},
	degrading2 = {code = 'degrading2', ondayend = 'degrading2'},
	degrading3 = {code = 'degrading3', ondayend = 'degrading3'},
	degrading4 = {code = 'degrading4', ondayend = 'degrading4'},
	animalistic1 = {code = 'animalistic1', ondayend = 'animalistic1'},
	animalistic2 = {code = 'animalistic2', ondayend = 'animalistic2'},
	animalistic3 = {code = 'animalistic3', ondayend = 'animalistic3'},
	tribal1 = {code = 'tribal1'},
	tribal2 = {code = 'tribal2'},
	tribal3 = {code = 'tribal3'},
	magic1 = {code = 'magic1'},
	magic2 = {code = 'magic2', maf_mod = 1},
	magic3 = {code = 'magic3', maf_mod = 1},
	magic4 = {code = 'magic4', maf_mod = 1},
	magic5 = {code = 'magic5', maf_mod = 2},
}

func degrading1(person):
	person.lust += 5
	person.obed += 5

func degrading2(person):
	person.lust += 10
	person.obed += 10

func degrading3(person):
	person.lust += 15
	person.obed += 15

func degrading4(person):
	person.lust += 20
	person.obed += 20

func animalistic1(person):
	person.energy += 8

func animalistic2(person):
	person.energy += 16

func animalistic3(person):
	person.energy += 25
