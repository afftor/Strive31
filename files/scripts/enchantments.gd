extends Node

var enchantmentdict = {
enchdmg = {name = "+&v Damage", id = 'weapondamage', effect = "damage", mineffect = 2, maxeffect = 3, itemtypes = ['weapon'], type = 'incombat'},
enchspeed = {name = "+&v Speed", id = 'weaponspeed', effect = "speed", mineffect = 3, maxeffect = 5, itemtypes = ['weapon'], type = 'incombat'},
encharmor = {name = "+&v Armor", id = 'armorbonus', effect = "armor", mineffect = 2, maxeffect = 4, itemtypes = ['armor'], type = 'incombat'},
enchstr = {name = "+&v Strength", id = 'armorstr', effect = "stren", mineffect = 1, maxeffect = 1, itemtypes = ['armor','accessory'], type = 'onequip'},
enchagi = {name = "+&v Agility", id = 'armoragi', effect = "agi", mineffect = 1, maxeffect = 1, itemtypes = ['armor','accessory'], type = 'onequip'},
enchend = {name = "+&v Endurance", id = 'armorend', effect = "end", mineffect = 1, maxeffect = 1, itemtypes = ['armor','accessory'], type = 'onequip'},
enchmaf = {name = "+&v Magic affinity", id = 'armormaf', effect = "maf", mineffect = 1, maxeffect = 1, itemtypes = ['armor','accessory'], type = 'onequip'},
enchhealth = {name = "+&v Health", id = 'armorhealth', effect = "health", mineffect = 15, maxeffect = 25, itemtypes = ['armor'], type = 'onequip'},
enchenergy = {name = "+&v Energy", id = 'armorenergy', effect = "energy", mineffect = 10, maxeffect = 20, itemtypes = ['armor'], type = 'onequip'},
enchcour = {name = "+&v Courage", id = 'costumecour', effect = "cour", mineffect = 10, maxeffect = 20, itemtypes = ['costume'], type = 'onequip'},
enchconf = {name = "+&v Confidence", id = 'costumeconf', effect = "conf", mineffect = 10, maxeffect = 20, itemtypes = ['costume'], type = 'onequip'},
enchwit = {name = "+&v Wit", id = 'costumewit', effect = "wit", mineffect = 10, maxeffect = 20, itemtypes = ['costume'], type = 'onequip'},
enchcharm = {name = "+&v Charm", id = 'costumecharm', effect = "charm", mineffect = 10, maxeffect = 20, itemtypes = ['costume'], type = 'onequip'},
enchbeauty = {name = "+&v Beauty", id = 'costumebeauty', effect = "beauty", mineffect = 5, maxeffect = 15, itemtypes = ['costume'], type = 'onequip'},
enchfear = {name = "+&v Fear per day", id = 'costumefear', effect = "fear", mineffect = 5, maxeffect = 8, itemtypes = ['costume'], type = 'onendday'},
enchfearaccess = {name = "+&v Fear per day", id = 'accessfear', effect = "fear", mineffect = 3, maxeffect = 6, itemtypes = ['accessory'], type = 'onendday'},
enchstress = {name = "-&v Stress per day", id = 'costumestress', effect = "stress", mineffect = 5, maxeffect = 8, itemtypes = ['costume'], type = 'onendday'},
enchobedmod = {name = "+&100v% Obedience", id = 'costumeobed', effect = "obedmod", mineffect = 0.15, maxeffect = 0.30, itemtypes = ['costume'], type = 'onequip'},
enchaccobedmod = {name = "+&100v% Obedience", id = 'accessobed', effect = "obedmod", mineffect = 0.05, maxeffect = 0.15, itemtypes = ['accessory'], type = 'onequip'},

}


#warning-ignore:unused_argument
func addrandomenchant(item, number = 1):
	var encharray = []
	var existingenchants = []
	var existingenchantsids = []
	if item.enchant != '': return
	for i in item.effects:
		existingenchants.append(i.effect)
		if i.has("id"):
			existingenchantsids.append(i.id)
	for i in enchantmentdict:
		if enchantmentdict[i].itemtypes.has(item.type) && !existingenchantsids.has(enchantmentdict[i].id):
			encharray.append(i)
	while number > 0 && encharray.size() > 0:
		number -= 1
		item.enchant = 'basic'
		var encharrayid = encharray[randi()%encharray.size()]
		var tempenchant = enchantmentdict[encharrayid]
		var enchant = {type = tempenchant.type, effect = tempenchant.effect, effectvalue = 0, descript = ""}
		encharray.erase(encharrayid)
		if tempenchant.has("mineffect") and tempenchant.has("maxeffect"):
			if tempenchant.maxeffect < 1:
				enchant.effectvalue = round(rand_range(tempenchant.mineffect, tempenchant.maxeffect)*100)/100
			else:
				enchant.effectvalue = round(rand_range(tempenchant.mineffect, tempenchant.maxeffect))
		elif tempenchant.has('effectvalue'):
			enchant.effectvalue = tempenchant.effectvalue
		enchant.descript = "[color=green]" + tempenchant.name.replace('&100v', str(enchant.effectvalue*100)).replace("&v", str(enchant.effectvalue)) + "[/color]"
		
		item.effects += [enchant]

#warning-ignore:unused_argument
func addenchant(item):
	pass