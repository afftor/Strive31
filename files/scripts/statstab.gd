extends Node


var person
var player
var tab = ''

func _on_stats_visibility_changed():
	if get_parent().visible == false:
		return
	if get_parent().get_name() == 'prisoner_tab':
		tab = 'prison'
	else:
		tab = 'normal'
#warning-ignore:unused_variable
	var text
	player = globals.player
	person = globals.slaves[get_tree().get_current_scene().currentslave]


func _on_trainingcancel_pressed():
	get_node("trainingpanel").visible = false

func _on_training_pressed():
	get_node("trainingpanel").visible = true
	#_on_skillname_item_selected(get_node("trainingpanel/skillname").get_selected())


func alphabeticalsortbycode(first, second):
	if first.code > second.code:
		return false
	else:
		return true


func _on_trainingabils_pressed():
	get_node("trainingabilspanel").popup()
	get_parent().upgradecostupdate()
	for i in get_node("trainingabilspanel/ScrollContainer/VBoxContainer").get_children():
		if i != get_node("trainingabilspanel/ScrollContainer/VBoxContainer/Button"):
			i.visible = true
			i.free()
	
	for i in ['cour','conf','wit','charm']:
		get_node("trainingabilspanel/" +i ).text = globals.statsdict[i] + ": " + str(person[i]) + "/" + str(min(person.stats[globals.maxstatdict[i]], person.originvalue[person.origins]))
		get_node("trainingabilspanel/"+i+"/Button").disabled = !(person.stats[i+'_base'] < min(person.stats[globals.maxstatdict[i]], person.originvalue[person.origins]) && person.learningpoints >= variables.learnpointsperstat)
		get_node("trainingabilspanel/"+i+"/Button2").disabled = !(person.stats[i+'_base']+5 <= min(person.stats[globals.maxstatdict[i]], person.originvalue[person.origins]) && person.learningpoints >= variables.learnpointsperstat*5)
		
	
	$trainingabilspanel/learningpoints.text = "Free Learn Points: " + str(person.learningpoints)
	get_node("trainingabilspanel/abilitytext").set_bbcode('')
	$trainingabilspanel/abilityicon.texture = null
	var array = []
	for i in globals.abilities.abilitydict.values():
		if i.attributes.find('onlyself') < 0:
			array.append(i)
	array.sort_custom(self, 'alphabeticalsortbycode')
	
	for i in array:
		if i.learnable == true:
			var newbutton = get_node("trainingabilspanel/ScrollContainer/VBoxContainer/Button").duplicate()
			get_node("trainingabilspanel/ScrollContainer/VBoxContainer").add_child(newbutton)
			newbutton.visible = true
			newbutton.connect("pressed", self, "chooseability", [i])
			newbutton.text = i.name
			if person.ability.has(i.code):
				newbutton.disabled = true
				newbutton.hint_tooltip = person.dictionary("$name already learned this ability")


func chooseability(ability):
	var text = ''
	var confirmbutton = get_node("trainingabilspanel/abilityconfirm")
	var dict = {'sstr': 'Strength', 'sagi' : 'Agility', 'smaf': 'Magic', 'level': 'Level'}
	for i in get_node("trainingabilspanel/ScrollContainer/VBoxContainer").get_children():
		if i.get_text() != ability.name:
			i.set_pressed(false)
	
	confirmbutton.set_disabled(false)
	
	text = '[center]'+ ability.name + '[/center]\n' + ability.description + '\nCooldown:' + str(ability.cooldown) + '\nLearn requirements: ' 
	if ability.has('iconnorm'):
		$trainingabilspanel/abilityicon.texture = ability.iconnorm
	else:
		$trainingabilspanel/abilityicon.texture = null
	var array = []
	for i in ability.reqs:
		array.append(i)
	array.sort_custom(self, 'levelfirst')
	
	for i in array:
		var temp = i
		var ref = person
		if i.find('.') >= 0:
			temp = i.split('.')
			for ii in temp:
				ref = ref[ii]
		else:
			ref = person[i]
		if ref < ability.reqs[i]:
			confirmbutton.set_disabled(true)
			text += '[color=#ff4949]'+dict[i] + ': ' + str(ability.reqs[i]) + '[/color], '
		else:
			text += '[color=green]'+dict[i] + ': ' + str(ability.reqs[i]) + '[/color], '
	text = text.substr(0, text.length() - 2) + '.'
	
	if ability.has("learncost"):
		text += "\nRequred skillpoints: [color=aqua]" + str(ability.learncost) + "[/color]"
	
	confirmbutton.set_meta('abil', ability)
	
	
	
	if person.ability.find(ability.code) >= 0:
		confirmbutton.set_disabled(true)
		text += person.dictionary('\n[color=green]$name already knows this ability. [/color]')
	elif globals.resources.gold < ability.price:
		text += '\n\n[color=#ff4949]Price to learn: ' + str(ability.price) + ' gold.[/color]' 
		confirmbutton.set_disabled(true)
	else:
		text += '\n\n[color=green]Price to learn: ' + str(ability.price) + ' gold.[/color]' 
	
	
	if ability.has('requiredspell') == true:
		if globals.spelldict[ability.requiredspell].learned == false:
			confirmbutton.set_disabled(true)
			text += person.dictionary('\n[color=#ff4949]You must purchase this spell before you will be able to teach it others. [/color]')
	get_node("trainingabilspanel/abilitytext").set_bbcode(text)

#warning-ignore:unused_argument
func levelfirst(first, second):
	if first == 'level':
		return true
	else:
		return false


func _on_abilcancel_pressed():
	get_node("trainingabilspanel").visible = false
	get_parent().slavetabopen()


func _on_abilityconfirm_pressed():
	var abil = get_node("trainingabilspanel/abilityconfirm").get_meta('abil')
	if abil == null:
		return
	elif person.ability.find(abil.code) >= 0:
		return
	elif abil.has('learncost') && person.learningpoints < abil.learncost:
		globals.main.infotext(person.dictionary("$name does not have enough learning points."),"red")
		return
	if abil.has("learncost"):
		person.learningpoints -= abil.learncost
	person.ability.append(abil.code)
	person.abilityactive.append(abil.code)
	globals.resources.gold -= abil.price
	get_tree().get_current_scene().popup(person.dictionary('$name has learned '+ abil.name))
	_on_trainingabils_pressed()
	get_parent().slavetabopen()
	get_node("trainingabilspanel").update()


func _on_spcancel_pressed():
	get_node("trainingskillpointspanel").visible = false


func _on_trainskillpoints_pressed():
	get_node("trainingskillpointspanel").visible = true
	get_node("trainingskillpointspanel/spspin").set_value(0)








func _on_castspell_pressed():
	person = globals.currentslave
	get_node("selectspellpanel").visible = true
	get_node("selectspellpanel/spellusedescription").set_bbcode('')
	var spelllist = get_node("selectspellpanel/ScrollContainer/selectspelllist")
	var button = get_node("selectspellpanel/ScrollContainer/selectspelllist/spellbutton")
	for i in spelllist.get_children():
		if i != button:
			i.visible = false
			i.queue_free()
	for i in globals.spelldict.values():
		if i.learned == true && i.personal == true:
			var newspellbutton = button.duplicate()
			newspellbutton.set_text(i.name)
			newspellbutton.visible = true
			newspellbutton.connect('pressed', self, 'spellbuttonpressed', [i])
			spelllist.add_child(newspellbutton)
	if spelllist.get_children().size() <= 1:
		get_node("selectspellpanel/spellusebutton").set_disabled(true)
		get_node("selectspellpanel/spellusedescription").set_bbcode('You have no fitting spells. ')
	else:
		get_node("selectspellpanel/spellusebutton").set_disabled(false)

var spellselected

func spellbuttonpressed(spell):
	get_node("selectspellpanel").popup()
	spellselected = spell
	var description = get_node("selectspellpanel/spellusedescription")
#warning-ignore:unused_variable
	var spelllist = get_node("selectspellpanel/ScrollContainer/selectspelllist")
	for i in get_tree().get_nodes_in_group('spells'):
		if i.get_text() != spell.name && i.is_pressed() == true:
			i.set_pressed(false)
	description.set_bbcode(spell.description + '\nMana cost - ' + str(globals.spells.spellcost(spell)))
	if globals.spells.spellcost(spell) > globals.resources.mana:
		get_node("selectspellpanel/spellusebutton").set_disabled(true)
	else:
		get_node("selectspellpanel/spellusebutton").set_disabled(false)


func _on_spellcancelbutton_pressed():
	get_node("selectspellpanel").visible = false
	spellselected = ''

func _on_spellusebutton_pressed():
	person.metrics.spell += 1
	var spellnode = globals.spells
	spellnode.person = person
	spellnode.caster = globals.player
	var text = spellnode.call(spellselected.effect)
	person.attention = 0
	get_node("selectspellpanel").visible = false
	globals.main.popup(text)
	if spellselected.code != 'dream':
		get_parent().slavetabopen()
	get_tree().get_current_scene().rebuild_slave_list()



var nakedspritesdict = globals.gallery.nakedsprites

func _on_talk_pressed(mode = 'talk'):
	var state = true
	var sprite = []
	var buttons = []
	var text = ''
	if person.unique == 'Cali' && globals.state.sidequests.cali in [12,13,22]:
		globals.events.calitalk0()
		return
	elif person.unique == 'Ayda' && globals.state.sidequests.ayda in [9,12,15]:
		globals.events.aydapersonaltalk()
		return
	if nakedspritesdict.has(person.unique):
		if person.obed >= 50 || person.stress < 10:
			sprite = [[nakedspritesdict[person.unique].clothcons, 'pos1', 'opac']]
		else:
			sprite = [[nakedspritesdict[person.unique].clothrape, 'pos1', 'opac']]
	elif person.imagefull != null:
		sprite = [[person.imagefull,'pos1','opac']]
	if mode == 'talk':
		if person.sleep == 'jail':
			text = "You enter jail cell with $name handcuffed in it. "
		else:
			text = "You summon $name to your appartments. "
		if person.rules.silence:
			text = "After giving $him a permission to talk, you begin a conversation. "
		
		text += '\n\n'
		
		if person.traits.has("Mute"):
			text += "Despite your best attempts, you can't get more out of $name, than uncomfortable look. "
		else:
			if person.obed < 50:
				text = text + "— I don't wanna talk with you after all you've done!\n"
			elif person.traits.has('Sex-crazed') == true:
				text = text + "— I don't care about my life, or anything, can we just fuck here, Master?"
			else:
				if person.loyal < 25:
					text = text + '— Yes, I will obey your orders, $master. \n'
					if person.brand != 'none':
						text = text + "It's not like I have much of an option anyway. \n$name gives you a trapped look. "
				elif person.loyal < 60:
					text = text + "—It wasn't easy at first, but I think warmly of you, $master. \n"
					if person.brand != 'none':
						text = text + "Even though I'm just your little slave now. \n"
				else:
					text = text + "— I'll try my best for you, $master. Despite what others might think, you are invaluable to me!\n"
				if person.stress > 50:
					text = text + "— It has been tough for me recently... Could you consider giving me a small break, please?\n"
				if person.lust >= 60 && person.consent == true && person.sexuals.actions.has('pussy'):
					text = text + "— I actually would love to fuck right now. \n"
				elif person.lust >= 60 && person.consent == true:
					text = text + "— Uhm... would you like to give me some private attention? — $name gives you a deep lusting look. \n"
		if person.xp >= 100 && person.levelupreqs.has('code') == false:
			buttons.append({text = person.dictionary("Investigate $name's potential"), function = 'levelreqs'})
		elif person.levelupreqs.has('code'):
			text += "\n\n[color=yellow]Your investigation shown, that " + person.dictionary(person.levelupreqs.speech) + '[/color]'
			if person.levelupreqs.activate == 'fromtalk':
				buttons.append({text = person.levelupreqs.button, function = 'levelup', args = person.levelupreqs.effect})
		if person.unique == 'Zoe' && globals.state.sidequests.zoe == 5:
			if globals.itemdict.teleportseal.amount >= 10 && globals.itemdict.taintedessenceing.amount >= 5 && globals.itemdict.magicessenceing.amount >= 5:
				buttons.append({text = "Give Zoe requested items", function = 'zoequest'})
			else:
				buttons.append({text = "Give Zoe requested items", function = 'zoequest', disabled = true, tooltip = "You don't have everything requested."})
		
		
#		if person.sleep != 'jail':
#			buttons.append({text = person.dictionary("Praise $name"), function = '_on_talk_pressed', args = 'praise'})
#		buttons.append({text = person.dictionary("Punish $name"), function = '_on_talk_pressed', args = 'punish'})
#		if person.sleep != 'jail' && person.consent == false:
#			buttons.append({text = person.dictionary("Propose intimate relationship (25 energy)"), function = 'unlocksex'})
#			if globals.player.energy < 25: buttons[buttons.size()-1].disabled = true
		buttons.append({text = person.dictionary("Order to call you ..."), function = 'callorder'})
		buttons.append({text = person.dictionary("Release $name"), function = 'release'})
	elif mode == 'praise':
		if person.obed >= 85 && person.praise == 0:
			text = "$name obediently waits for your reaction looking beneath $himself. "
		elif person.praise > 0:
			text = "$name seems to be still in high spirits probably keeping in mind your recent approval. "
		elif person.obed < 85:
			text = "$name appears to be not very disciplined as $his eyes wander around the room. "
		buttons.append({text = "Praise (10 energy)", function = 'action', args = 'praise'})
		if globals.player.energy < 10: buttons[buttons.size()-1].disabled = true
		buttons.append({text = "Make a Gift (15 energy, 15 gold)", function = 'action', args = 'gift'})
		if globals.player.energy < 15 || globals.resources.gold < 15: buttons[buttons.size()-1].disabled = true
	elif mode in ['punish', 'sexpunish']:
		if person.punish.expect == true:
			text = "$name gives you a fearsome look indicating strong recent memories of your authority. "
		elif person.obed <= 65:
			text = "$name appears to be not very disciplined as $he shows slight irritation having to submit to you. "
		else:
			text = "$name shows mild awareness to your authority. "
		if mode == 'punish':
			buttons.append({text = "Berate (10 energy)", function = 'action', args = 'berate'})
			if globals.player.energy < 10: buttons[buttons.size()-1].disabled = true
			buttons.append({text = "Beat (15 energy)", function = 'action', args = 'beat'})
			if globals.player.energy < 15: buttons[buttons.size()-1].disabled = true
			buttons.append({text = "Sexual Punishments (20 energy)", function = "_on_talk_pressed", args = 'sexpunish'})
			if globals.player.energy < 20: buttons[buttons.size()-1].disabled = true
		elif mode == 'sexpunish':
			text += "\n\nYou can take $name to the punishment room for more oscure actions. These are not specifically harmful, but sufficiently painful and stimulating to provide a lesson. \nIf 'Public' is checked, other servants will also be watching and it will severe the punishment."
			buttons.append({text = "Tickling", function = 'action', args = 'tickling'})
			buttons.append({text = "Spanking", function = 'action', args = 'spanking'})
			buttons.append({text = "Whipping", function = 'action', args = 'whipping'})
			buttons.append({text = "Wooden Horse", function = 'action', args = 'woodenhorse'})
			buttons.append({text = "Hot Wax", function = 'action', args = 'hotwax'})
	if mode in ['praise', 'punish']:
		buttons.append({text = "Return", function = '_on_talk_pressed'})
	elif mode == 'sexpunish':
		buttons.append({text = "Return", function = '_on_talk_pressed', args = 'punish'})
	get_tree().get_current_scene().dialogue(state, self, person.dictionary(text), buttons, sprite)
	get_tree().get_current_scene().rebuild_slave_list()
	get_parent().slavetabopen()

func callorder():
	get_node("callorder").popup()
	get_node("callorder/Label").set_text(person.dictionary("How $name should call you?"))
	get_node("callorder/LineEdit").set_text(person.masternoun)

func zoequest():
	globals.itemdict.teleportseal.amount -= 10
	globals.itemdict.taintedessenceing.amount -= 5
	globals.itemdict.magicessenceing.amount -= 5
	globals.events.zoepassitems()

func _on_callconfirm_pressed():
	get_node("callorder").visible = false
	var text = "You have ordered $name to call $master from this moment. "
	if person.traits.has('Mute'): text += "However $he only returned you a guilty look. "
	person.masternoun = get_node("callorder/LineEdit").get_text()
	get_tree().get_current_scene().close_dialogue()
	get_tree().get_current_scene().popup(person.dictionary(text))

func unlocksex():
	var text = ''
	var difficulty = 0
	var state = false
	var buttons = []
	var sprite = []
	globals.player.energy -= 25
	text += "You make a proposal to $name saying how you would like to move your relationship on a new level. \n\n"
	if person.obed < 40:
		text += "$name gives you an indignant look and laughs your suggestion off. [color=yellow]$His lack of respect of you will have to be corrected first[/color]  "
	else:
		difficulty = person.loyal/3 + person.lust/10
		if person.sex == globals.player.sex:
			difficulty -= 10
		if str(person.relatives.father) == '0' || str(person.relatives.mother) == '0':
			difficulty -= 10
		for i in person.traits:
			if i == 'Prude':
				difficulty -= 5
		if difficulty <= 30:
			text += "[color=yellow]— Sorry, $master, but I don't think I'm ready for this. [/color]\n\nIt seems something holds $name back and $he does not like you enough. "
		else:
			if person.conf >= 40:
				text += "[color=yellow]— Sure, I'd love to get to know you more... intimately, $master![/color]"
			else:
				text += "[color=yellow]— Uhm... I don't mind... I mean if you wish so, $master. [/color]"
			text+= "\n\n[color=green]Unlocked sexual actions with $name.[/color]"
			if person.levelupreqs.has('code') && person.levelupreqs.code == 'relationship':
				text += "\n\n[color=green]As you got closer with $name, you felt like $he unlocked new potential. [/color]"
				person.levelup()
			person.consent = true
	if nakedspritesdict.has(person.unique):
		if person.consent:
			sprite = [[nakedspritesdict[person.unique].clothcons, 'pos1']]
		else:
			sprite = [[nakedspritesdict[person.unique].clothrape, 'pos1']]
	elif person.imagefull != null:
		sprite = [[person.imagefull,'pos1','opac']]
	buttons.append({text = person.dictionary("Continue"), function = '_on_talk_pressed'})
	get_tree().get_current_scene().dialogue(state, self, person.dictionary(text), buttons, sprite)





func levelreqs():
	globals.jobs.getrequest(person)
	_on_talk_pressed()
	get_parent().slavetabopen()

func levelup(command):
	globals.jobs.call(command, person)
	globals.get_tree().get_current_scene().close_dialogue()
	get_parent().slavetabopen()


func action(actionname):
	var text = ''
	var buttons = []
	var sprite = []
	if actionname in ['berate', 'praise']: globals.player.energy -= 10
	elif actionname in ['beat','gift']: globals.player.energy -= 15
	elif actionname in ['whipping','tickling','spanking','woodenhorse','hotwax']: globals.player.energy -= 20
	if actionname == 'berate':
		text = "You scold $name for their lousy behavior and make few remarks on possible future punishments if $he doesn't improve it. "
		if person.obed < 85 && person.punish.expect == false:
			if person.effects.has('captured') == true:
				person.effects.captured.duration -= 1
			person.obed += 30 - person.conf/5
			text = text + "\n$He seems to be taking your repremand seriously."
			person.punish.expect = true
			if person.race == 'Human':
				person.punish.strength = 10 - person.cour/25
			else:
				person.punish.strength = 5 - person.cour/25
			person.stress += rand_range(5,10)
		elif person.obed >= 85:
			text = text + '\n$He unhappy to your repremand, as $he does not believe $he has offended you rightly.'
			person.stress += 15
		else:
			text = text + "\n$He does not seems to be very afraid of your threats, as you haven't followed through on them previously."
			person.obed += max(20 - person.conf/5,0)
			person.punish.expect = true
			if person.race == 'Human':
				person.punish.strength = 10 - person.cour/25
			else:
				person.punish.strength = 5 - person.cour/25
			person.stress += rand_range(5,10)
			if person.effects.has('captured') == true:
				person.effects.captured.duration += 1
	elif actionname == 'beat':
		text = "You give $name a painful, but relatively harmless beating, providing $him a valueable lesson in subordination. "
		person.stress += rand_range(15,25)
		person.health -= rand_range(5,10)
		if person.health <= 0:
			text += "\n\n[color=#ff4949]Due to $his already poor health that was simply too much for $name and $he falls into a coma. You are unable to resuscitate $him despite trying for a while, and eventually can't help but to accept $his death.[/color] "
			globals.slaves.erase(person)
			if globals.slaves.size() > 1:
				text += "\n[color=#ff4949]Your other servants are shocked by this incident. [/color]"
				for i in globals.slaves:
					i.obed += rand_range(10, 50)
					i.stress += rand_range(25, 50)
			get_tree().get_current_scene().popup(person.dictionary(text))
			get_tree().get_current_scene().rebuild_slave_list()
			get_tree().get_current_scene().close_dialogue()
			get_tree().get_current_scene()._on_mansion_pressed()
			return
		if person.obed < 75||person.traits.has('Masochist') == true:
			if person.effects.has('captured') == true:
				person.effects.captured.duration -= 1
				text = text + "\nBy the end $he glares at you with sorrow and hatred, showing leftovers of a yet untamed spirit."
			else:
				text = text + "\nBy the end $he is begging for mercy and takes your lesson to heart."
				person.obed += rand_range(30,60)
			if person.punish.expect == true:
				person.obed += rand_range(20,40)
				if person.race == 'Human':
					person.punish.strength += 10 - person.cour/25
				else:
					person.punish.strength += 5 - person.cour/25
			else:
				person.conf += -rand_range(2,5)
				person.cour += -rand_range(2,5)
		else:
			text = text + "\n$He obediently takes $his punishment and begs for your pardon, but $name doesn't feel like $he trully deserves such a treatment."
			person.obed += rand_range(20,30)
			person.conf += -rand_range(3,6)
			person.cour += -rand_range(3,6)
			person.stress += rand_range(5,15)
			person.loyal -= rand_range(4,8)
	elif actionname == 'tickling':
		text = "After bringing $name to the torture room, you tie $him securely to the special chair and work your way over $his body with the feathers and brushes, until $his laughter turn into cries for mercy. You give $him small break then start over. Before long, $his overstimulated feet, armpits and genitals are aching so much that $he nearly loses coherence... "
	elif actionname == 'spanking':
		text = "After bringing $name to the torture room, you tie $him securely to the table, baring $his defenseless bare butt for open access. Then you begin spanking $him, slowly at first. With each hit $his bottom gets redder and soon $his cries are filled with whimpers and tears. Despite $his appeals you don't stop until $he is nearly hoarse, making sure your lesson made its point. "
	elif actionname == 'whipping':
		text = "After bringing $name to the torture room, you place $him in standing position, naked before you. Then you take out a whip and start the lashings. At first $he stays silent but soon $he bursts out in tears and painful cries as you rain further lashes across $his body - making them string, especially when you focus on $his delicate parts. Despite $his appeals you don't stop until $he nearly hoarse, making sure your lesson made its point. "
	elif actionname == 'hotwax':
		text = "After bringing $name to the torture room, you tie $him securely to the bed, spread eagled and naked. Then you light a few candles and proceed to slowly drip hot wax over $his body. $He tries to break free and avoid the painful sensations, but it is to no avail. Irritating $his nipples and genitals seems to produce the best results. After some time you finally stop, making sure the lesson had an impact. "
	elif actionname == 'woodenhorse':
		text = "After bringing $name to the torture room, you tie $him securely to the wooden horse with $his legs spread wide. Adding some extra weights to hand from $his feet, you increase the pull against the uncomfortable seat and proceed to watch $his suffering. In no time $he starts begging for mercy, but you already made your decision and are not about to stop now. After some time you finally untie $him, making sure the lesson had an impact. "
	elif actionname == 'praise':
		text = "You give $name short speech praising $his recent behavior and achievments. "
		if person.obed >= 85 && person.praise == 0:
			person.conf += rand_range(2,6)
			person.loyal += rand_range(3,8)
			person.sexuals.affection += round(rand_range(1,2))
			if person.race == 'Human':
				person.praise = 4
			else:
				person.praise = 2
			person.stress += -rand_range(5,10)
			text = text + "$He looks happy with your adoration and obediently bows to you. "
		elif person.obed >= 85:
			text = text + "$He takes your words calmly without much of enthusiasm. You probably overpraised $him lately. "
			person.praise += 1
		else:
			text = text + "$He takes your praise arrogantly, gaining joy from it. "
			if person.race == 'Human':
				person.praise = 2
			else:
				person.praise = 1
			person.cour += rand_range(2,5)
			person.loyal += -rand_range(1,2)
			person.obed += -rand_range(15,25)
	elif actionname == 'gift':
		globals.resources.gold -= 15
		text = "You present $name with small gift of adoration. "
		if person.obed >= 85 && person.praise == 0:
			person.conf += rand_range(2,5)
			person.sexuals.affection += round(rand_range(2,4))
			if person.race == 'Human':
				person.praise = 8
			else:
				person.praise = 4
			person.loyal += rand_range(5,12)
			person.stress += -rand_range(10,20)
			text = text + "$He looks greatly pleased with it and thanks you properly. "
		elif person.obed >= 85:
			text = text + "$He takes it with reasonable respect, but it seems you may have overpraised $him lately. "
			person.praise += 1
			person.loyal += rand_range(2,5)
			person.stress += -rand_range(5,10)
		elif person.obed < 85 && person.praise == 0:
			text = text + "$He takes your gift with cautious expression but thanks you afterwards. $He does not feel like $he quite deserved it but slightly softens up to you. "
			if person.race == 'Human':
				person.praise = 4
			else:
				person.praise = 2
			person.obed += rand_range(20,40)
		else:
			text = text + "$He takes your gift without much of consideration. It seems your recent actions barely give $him any reason to appreciate your attention. "
			person.praise += 1
			person.obed += -rand_range(10,20)
			person.loyal += -rand_range(4,8)
	if actionname in ['tickling','spanking','whipping','hotwax','woodenhorse']:
		if person.lust > 70 || (person.lust > 30 && (person.traits.has('Masochist') == true||person.asser <= 20)):
			text = text + "\nDuring the procedure $name twitches and climaxes, unable to hold back $his excitement."
			person.lust = -rand_range(8,15)
			if rand_range(1,10) > 7 || person.effects.has('entranced') == true:
				person.add_trait('Masochist')
		if person.traits.has('Masochist'):
			person.sexuals.affection += round(rand_range(1,3))
		person.stress += rand_range(15,25)
		person.lust = rand_range(2,10)
		if person.obed < 75||person.traits.has('Masochist') == true:
			text = text + "\nBy the end $he begs for mercy and clearly takes your lesson to heart."
			person.obed += rand_range(15,30)
			if person.punish.expect == true:
				person.obed += rand_range(30,60)
				if person.race == 'Human':
					person.punish.strength += 10 - person.cour/25
				else:
					person.punish.strength += 5 - person.cour/25
			else:
				person.conf += -rand_range(1,4)
				person.cour += -rand_range(1,4)
		else:
			text = text + "\n$He obediently takes $his punishment and begs for your pardon, but it seems like $he doesn't feel $he trully deserved it."
			person.obed += rand_range(15,25)
			person.conf += -rand_range(1,4)
			person.cour += -rand_range(1,4)
			person.stress += rand_range(10,20)
			person.loyal -= rand_range(5,10)
	
	
	if get_parent().get_node("stats/customization/rules/publiccheckbox").is_pressed() == true && globals.slaves.size() > 1 && !actionname in ['date','gift','praise','sex']:
		text = text + "Other servants watch your actions closely."
		for i in globals.slaves:
			if i.traits.has('Loner') == false && i.away.duration < 1:
				i.obed += max(rand_range(5,15)-i.conf/10,0)
			if actionname in ['tickling','spanking','whiping','hotwax','woodenhorse']:
				i.lust = rand_range(5,10)
	
	person.attention = 0
	if nakedspritesdict.has(person.unique):
		if actionname in ['praise','gift']:
			sprite = [[nakedspritesdict[person.unique].clothcons, 'pos1']]
		else:
			sprite = [[nakedspritesdict[person.unique].clothrape, 'pos1']]
	get_tree().get_current_scene().dialogue(true, self, person.dictionary(text), buttons, sprite)
	get_tree().get_current_scene().rebuild_slave_list()
	get_parent().slavetabopen()


func release():
	get_tree().get_current_scene().yesnopopup(person.dictionary("[color=#ff4949]Let $name leave? You can't cancel this action.[/color]"),'getridof')



