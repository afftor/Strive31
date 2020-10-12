extends Node

####Resources
var textnode = load('res://files/scripts/questtext.gd').new() #Old quest system text
var EventBuilder = preload("res://files/scripts/event/event_builder.gd").new()
const EventResult = preload("res://files/scripts/event/event_result.gd")
const Quest = preload("res://files/scripts/event/quest.gd")


#Old Variables
var emilystate = 0
var outside
var ivran
var finaleperson

###Member Variables
#Event System Variables
var lastEventPlace = {region = 'none', location = 'none'}

#Quest Variables
var mainquest
var sidequests = {}

var mainquestTexts
var sidequestTexts


###Init & Ready
#func _init():
#	init_quest()
#
#func init_quest():
#	var newQuest
#
#	#Emily Quest
#	newQuest = EventBuilder.quest_maker('emily')
#	sidequests[newQuest.uid] = newQuest
#
#	#Tisha Quest
#	#newQuest = EventBuilder.quest_maker('tisha')
#	#sidequests[newQuest.uid] = newQuest
#
#
####Public Function
#func call_events(place, startType, callback = null): 
#	var placeEffects
#
#	match startType:
#		'trigger':
#			if place.hash() == lastEventPlace.hash(): #Cannot repeat or 'farm' trigger events at one place, ToFix - Perhaps make a 3-place history?
#				return placeEffects
#			else:
#				placeEffects = _call_events_trigger(place)			
#		'hook':
#			placeEffects = _call_events_hook(place, callback)
#		'schedule':
#			placeEffects = _call_events_schedule(place)
#
#	return placeEffects
#
#func _call_events_trigger(place): #Select one available triggered event per call
#	var availableEvents = _get_events(place, 'trigger')
#	var placeEffects = {text = ''} #Post-Event scene effects?
#
#	if !availableEvents.empty():
#		var diceRoll = randi() % availableEvents.size()
#		var randomEvent = availableEvents[diceRoll]		
#		_process_event('start', randomEvent)
#
#	return placeEffects
#
#func _call_events_hook(place, callback = null):
#	var availableEvents = _get_events(place, 'hook')
#	var placeEffects = {text = '', buttons = []} #Pre-Event scene effects
#
#	for ievent in availableEvents:
#		var action = ievent.get_start_action()
#		ievent.callback = callback
#		if placeEffects.text == '':
#			placeEffects.text = action.text
#		else:
#			placeEffects.text += "\n\n" + action.text
#		for ibutton in action.get_buttons():
#			placeEffects.buttons.append(ibutton)
#
#	return placeEffects
#
#func _call_events_schedule(place, callback = null):	
#	var placeEffects = {hasEvent = false, text = ''}
#
#	var scheduledEvent
#	for ievent in globals.state.upcomingevents:
#		if ievent.duration > 0:
#			ievent.duration -= 1
#		if ievent.duration <= 0:
#			scheduledEvent = ievent			
#	if scheduledEvent == null:
#		return placeEffects
#
#	var availableEvents = _get_events(place, 'schedule')
#	var activeEvent	
#	for ievent in availableEvents:
#		if ievent.name == scheduledEvent.code:
#			activeEvent = ievent
#			break
#	if activeEvent == null:		
#		return placeEffects
#
#	placeEffects.hasEvent = true
#	globals.state.upcomingevents.erase(scheduledEvent) #ToFix - probably a mistake, better handled by events._process_event after event 'finish'?	
#	_process_event('start', activeEvent)
#
#	return placeEffects
#
#
####Private Functions	
#func _get_events(place, startType = 'any'): #Returns an array of 'available' events at 'place'
#	var availableEvents = []
#
#	for ikey in sidequests:
#		var partEvents = sidequests[ikey].get_events(place)
#		for ievent in partEvents:
#			if startType == 'any' || startType == ievent.startType:
#				availableEvents.append(ievent)
#
#	return availableEvents
#
#
##Event System Loop
#func _process_event(newEventState, event, result = {}):
#	#Process result of prior EventAction
#	if !result.empty():
#		EventResult.process_result(result)					
#
#	#Update Event's state and process next action
#	_process_event_action(newEventState, event)
#
#func _process_event_action(newEventState, event):
#	var main = globals.main
#	var action = null
#	var buttons = []
#	var hasClose = false
#	var text = ''
#
#	match newEventState:
#		'reset':
#			event.state = 'start'
#			main.close_dialogue()
#			main.closescene() #ToFix - snake_case this
#			if !(event.callback == null):
#				var origin = event.callback.source
#				origin.call_deferred(event.callback.function)
#		'finish':
#			event.state = newEventState
#			main.close_dialogue()
#			main.closescene()
#			if !(event.callback == null):
#				var origin = event.callback.source
#				origin.call_deferred(event.callback.function)
#		_:
#			event.state = newEventState
#			action = event.actions[event.state]
#			match action.actionType:			
#				'dialogue':
#					main.closescene()
#					buttons = action.get_buttons()
#					text = action.text
#					if action.pov == 'player': #ToFix - Redundant as dialogue/scene default to 'player' pov.  When future povs are enabled, this will be the edit point
#						text = globals.player.dictionaryplayer(text)
#					main.dialogue(hasClose, self, text, buttons, action.sprites)
#				'scene':
#					main.close_dialogue()
#					buttons = action.get_buttons()
#					text = action.text
#					if action.pov == 'player':
#						text = globals.player.dictionaryplayer(text)
#					main.scene(self, action.image, text, buttons)
#				'decision':
#					_process_event_action_decision(event)
#				'combat':
#					_process_event_action_combat(event)
#
#func _process_event_action_decision(event):
#	#Get decisionNode
#	var action = event.actions[event.state]
#	var decisionNode = action.get_node()
#
#	#Process decisionNode
#	_process_event(decisionNode.eventState, event, decisionNode.meta.result)
#
#func _process_event_action_combat(event):
#	var action = event.actions[event.state]
#	var combatNodes = action.get_combat()
#	var combatData = combatNodes.combat
#
#	#Setup combat
#	globals.main.get_node("explorationnode").buildenemies(combatData.enemies)
#	globals.main_get_node("combat").nocaptures = true
#	globals.main.exploration.launchonwin = '_process_combat_end'
#
#	if combatData.enemy.has('hasCaptures'):
#		globals.main.get_node("combat").nocaptures = !combatData.hasCaptures
#	if combatData.has('hasRewards') && combatData.hasRewards == true:
#		globals.main.exploration.launchonwin = null
#
#	#Combat
#	globals.main.exploration.enemyfight()
#
#	#Post-Combat - Currently only 'win' condition available, 'lose' = 'gameover' ToFix?
#	var win = combatNodes.win
#	_process_event(win.eventState, event, win.result)
#
#
#func _process_combat_end():
#	pass
#







### EMILY QUESTS
#Emily Side Quest
func emily(state = 1):
	var buttons = []
	var text = ''
	var sprites = null
	var main = globals.main
	
	globals.state.sidequests.emily = state
	if state == 1:
		globals.charactergallery.emily.unlocked = true
		text = textnode.EmilyMeet
		if globals.resources.food < 10:
			buttons.append({text = 'Give her food', function = 'emily', args = 2, disabled = true, tooltip = "not enough food"})
		else:
			buttons.append(['Give her food', 'emily', 2])
		buttons.append(['Shoo her away', 'emily', 5])
		buttons.append(["Make an excuse and tell her you'll bring some later", 'emily', 0])
		sprites = [['emilynormal','pos1','opac']]
		main.dialogue(false, self, text, buttons, sprites)
	elif state == 2:
		text = textnode.EmilyFeed
		globals.resources.food -= 10
		buttons.append(['Offer to take her as a servant', 'emily', 3])
		buttons.append(["Leave her alone", 'emily', 5])
		sprites = [['emilynormal','pos1']]
		main.dialogue(false, self, text, buttons, sprites)
	elif state == 3:
		text = textnode.EmilyTake
		sprites = [['emilyhappy','pos1']]
		main.dialogue(true, self, text, buttons, sprites)
		var emily = globals.characters.create('Emily')
		globals.state.upcomingevents.append({code = 'tishaappearance',duration =7})
		globals.slaves = emily
		outside.backstreets()
	elif state == 5:
		outside.backstreets()
		main.close_dialogue()
	elif state == 0:
		outside.backstreets()
		main.close_dialogue()

func emilymansion(stage = 0):
	var text = ""
	var state = true
	var sprite
	var buttons = []
	var emily
	var image
	for i in globals.slaves:
		if i.unique == 'Emily':
			emily = i
	if emily == null:
		return
	if stage == 0:
		text = textnode.EmilyMansion
		sprite = [['emilyhappy','pos1','opac']]
		state = false
		if globals.state.getCountStackableItem('aphrodisiac') > 0:
			buttons.append({text = 'Spike her with aphrodisiac',function = 'emilymansion',args = 1})
		else:
			buttons.append({text = 'Spike her with aphrodisiac',function = 'emilymansion',args = 1, disabled = true})
		buttons.append({text = 'Assault her after bath', function = 'emilymansion', args = 2})
		buttons.append({text = "Just wait", function = "emilymansion", args = 3})
	elif stage == 1:
		image = 'emilyshower'
		globals.state.decisions.append("emilyseduced")
		globals.state.removeStackableItem('aphrodisiac')
		text = textnode.EmilyShowerSex
		globals.main.savedtrack = globals.main.get_node("music").get_meta("currentsong")
		globals.main.music_set("intimate")
		sprite = [['emilynakedhappy','pos1']]
		emily.consent = true
		emily.tags.erase('nosex')
		emily.vagvirgin = false
		emily.metrics.orgasm += 1
		emily.metrics.vag += 1
		emily.metrics.partners.append(globals.player.id)
		emily.stress += 50
		emily.loyal += 15
		emily.lust += 50
		globals.charactergallery.emily.scenes[0].unlocked = true
		globals.charactergallery.emily.nakedunlocked = true
		buttons.append({text = "Close", function = 'closescene'})
	elif stage == 2:
		image = 'emilyshowerrape'
		globals.state.decisions.append("emilyseduced")
		text = textnode.EmilyShowerRape
		sprite = [['emilynakedneutral','pos1']]
		globals.main.savedtrack = globals.main.get_node("music").get_meta("currentsong")
		globals.main.music_set("intimate")
		emily.tags.erase('nosex')
		emily.consent = true
		emily.stress += 100
		emily.vagvirgin = false
		emily.metrics.vag += 1
		emily.metrics.partners.append(globals.player.id)
		emily.obed = 0
		globals.charactergallery.emily.scenes[1].unlocked = true
		globals.charactergallery.emily.nakedunlocked = true
		globals.state.upcomingevents.append({code = 'emilyescape', duration = 2})
		buttons.append({text = "Close", function = 'closescene'})
	elif stage == 3:
		text = textnode.EmilyMansion2
		sprite = [['emily2happy','pos1','opac']]
	globals.state.sidequests.emily = 6
	if stage in [1,2]:
		globals.main.scene(self, image, text, buttons)
		globals.main._on_mansion_pressed()
		closedialogue()
		return
	globals.main.dialogue(state,self,text,buttons,sprite)

func emilyescape():
	var emily
	for i in globals.slaves:
		if i.unique == 'Emily':
			emily = i
	if emily != null:
		if emily.brand == 'none':
			globals.slaves.erase(emily)
			globals.main.dialogue(true,self,'During the night Emily has escaped from the mansion in unknown direction.')

func tishaappearance():
	var emily = null
	var buttons = []
	var sprite
	for i in globals.slaves:
		if i.unique == 'Emily':
			emily = i
	if emily == null:
		return
	var text = textnode.TishaEncounter
	sprite = [['emily2normal','pos2','opac2'],['tishaangry','pos1','opac']]
	globals.charactergallery.tisha.unlocked = true
	if emily.loyal >= 25:
		text += globals.player.dictionary(textnode.TishaEmilyLoyal)
		sprite = [['emily2happy','pos2','opac2'],['tishashocked','pos1','opac']]
		emilystate = 'loyal'
		buttons.append(['Make Emily leave', 'tishadecision', 1])
		buttons.append(['Make Emily stay', 'tishadecision', 2])
	elif emily.brand != 'none':
		emilystate = 'brand'
		text += textnode.TishaEmilyBranded
		sprite = [['emily2normal','pos2','opac2'],['tishaangry','pos1','opac']]
		buttons.append(['Release Emily', 'tishadecision', 3])
		buttons.append(['Keep Emily', 'tishadecision', 4])
		buttons.append(['Offer Tisha to take her place', 'tishadecision', 5])
	else:
		text += textnode.TishaEmilyUnloyal
		emilystate = 'unloyal'
		buttons.append(['Let them leave', 'tishadecision', 6])
		if globals.resources.gold >= 50 && globals.resources.food >= 50:
			buttons.append(['Help them with gold and provision', 'tishadecision', 7])		
		else:
			buttons.append({text = 'Help them with gold and provisions',function = 'tishadecision',args = 7, disabled = true})
		buttons.append(['Ask for compensation', 'tishadecision', 8])
	globals.main.dialogue(false,self,text,buttons,sprite)

func tishadecision(number):
	var emily
	var tisha
	var image
	var buttons = []
	var state = true
	var sprite = []
	sprite = [['emily2normal','pos2'],['tishaangry','pos1']]
	for i in globals.slaves:
		if i.unique == 'Emily':
			emily = i
		elif i.unique == 'Tisha':
			tisha = i
	var text = ''
	if number == 1:
		text = textnode.TishaEmilyLeave
		buttons.append(['Let them leave', 'tishadecision', 6])
		if globals.resources.gold >= 50 && globals.resources.food >= 50:
			buttons.append(['Help them with gold and provision', 'tishadecision', 7])
		else:
			buttons.append({text = 'Help them with gold and provisions',function = 'tishadecision',args = 7, disabled = true})
		state = false
	elif number == 2:
		sprite = [['emily2normal','pos2'],['tishashocked','pos1']]
		text = textnode.TishaEmilyStay
	elif number == 3:
		globals.slaves.erase(emily)
		text = textnode.TishaEmilyLeaveFree
	elif number == 4:
		text = "You send Tisha off as you hold all the rights over Emily now. Having no choice, she curses you and leaves. "
	elif number == 5:
		text = textnode.TishaEmilyBrandCompensation
		sprite = [['tishanakedneutral','pos1']]
		image = 'tishatable'
		globals.charactergallery.tisha.scenes[0].unlocked = true
		globals.charactergallery.tisha.nakedunlocked = true
		buttons.append({text = 'Go with your word and release Emily', function = 'tishadecision', args = 10})
		buttons.append({text = 'Keep Emily anyway', function = 'tishadecision', args = 9})
		text += "\n\n[color=green]You've earned 15 mana.\n\nTisha now belongs to you. [/color]"
		globals.resources.mana += 15
		state = false
		var person = globals.characters.create("Tisha")
		globals.connectrelatives(person, emily, 'sibling')
		globals.slaves = person
	elif number == 6:
		text = textnode.TishaEmilyLeaveFree
		if emilystate == 'loyal':
			emily.away.at = 'hidden'
			emily.away.duration = -1
			emily.obed -= 20
			globals.state.upcomingevents.append({code = 'emilyreturn', duration = 5})
			globals.state.sidequests.emily = 10
		else:
			globals.slaves.erase(emily)
	elif number == 7:
		text = textnode.TishaEmilyLeaveHelp
		sprite = [['emily2normal','pos2'],['tishaneutral','pos1']]
		emily.away.at = 'hidden'
		emily.away.duration = -1
		emily.loyal += 15
		globals.state.upcomingevents.append({code = 'emilyreturn', duration = 5})
		globals.resources.food -= 50
		globals.resources.gold -= 50
		globals.state.reputation.wimborn += 5
		globals.state.sidequests.emily = 11
	elif number == 8:
		sprite = [['tishaangry','pos1']]
		text = textnode.TishaEmilyCompensation
		globals.state.decisions.append("tishatricked")
		text += "\n\n[color=green]You've earned 15 mana. [/color]"
		globals.slaves.erase(emily)
		globals.resources.mana += 15
	elif number == 9:
		globals.main.closescene()
		text = textnode.TishaEmilyKeepEmily
		globals.state.decisions.append("tishaemilytricked")
		sprite = [['tishashocked','pos1']]
		emily.loyal += -100
		emily.obed += -50
		tisha.obed += -75
		var effect = globals.effectdict.captured
		effect.duration = 15
		globals.state.reputation.wimborn -= 20
		emily.add_effect(effect)
		emily.tags.erase('nosex')
		tisha.add_effect(effect)
	elif number == 10:
		globals.main.closescene()
		text = textnode.TishaEmilyReleaseEmily
		globals.state.decisions.append("emilyreleased")
		sprite = [['emily2normal','pos2'],['tishaneutral','pos1']]
		globals.state.reputation.wimborn -= 10
		tisha.obed += 50
		globals.slaves.erase(emily)
	if number in [5]:
		globals.main.scene(self, image, text, buttons)
		globals.main._on_mansion_pressed()
		closedialogue()
		return
	globals.main.rebuild_slave_list()
	globals.main.dialogue(state,self,text,buttons,sprite)

func emilyreturn():
	var emily
	var sprite = [['emily2happy','pos1','opac']]
	for i in globals.slaves:
		if i.unique == 'Emily':
			emily = i
	if emily == null:
		return
	emily.away.at = ''
	emily.away.duration = 0
	var text = textnode.EmilyReturn
	if globals.state.sidequests.emily == 10:
		text += "Tisha probably thinks you are not a bad person after all."
	else:
		text += "I think she was really surprised that you still helped us, even with her being angry and taking me away… "
	text += "If I can, can I still stay at your place, $master?[/color]\n\nYou welcome Emily back and she excuses herself, returning to her previous duties. "
	emily.loyal += 10
	emily.obed += 80
	emily.add_trait("Grateful")
	globals.state.upcomingevents.append({code = 'tishadisappear', duration = round(rand_range(9,14))})
	globals.main.dialogue(true,self,text, null, sprite)
	globals.main._on_mansion_pressed()


func tishadisappear(stage = 0):
	var emily
	var buttons = []
	var sprite
	var text = ""
	var state = false
	for i in globals.slaves:
		if i.unique == 'Emily':
			emily = i
	if emily == null:
		return
	if stage == 0:
		sprite = [['emily2worried','pos1','opac']]
		text = textnode.EmilyTishaDisappear
		buttons.append(['Agree to help', 'tishadisappear', 1])
		buttons.append(['Deny', 'tishadisappear', 2])
		buttons.append(['Ask for additional service', 'tishadisappear', 3])
	if stage == 1:
		sprite = [['emily2happy','pos1']]
		text = textnode.TishaDisappearAgree
		globals.state.sidequests.emily = 12
		emily.loyal += 15
		emily.obed += 20
		state = true
	elif stage == 2:
		sprite = [['emily2worried','pos1']]
		text = textnode.TishaDisappearDeny
		globals.state.sidequests.emily = 100
		emily.obed -= 30
		emily.loyal -= 20
		emily.stress += 40
		state = true
	elif stage == 3:
		sprite = [['emily2worried','pos1']]
		text = textnode.TishaDisappearUnlock
		globals.state.sidequests.emily = 12
		emily.loyal -= 10
		emily.consent = true
		emily.tags.erase('nosex')
		state = true
	globals.main.dialogue(state,self,text,buttons,sprite)
	globals.main._on_mansion_pressed()

func tishadorms(stage=0):
	var emily
	var buttons = []
	var text = ""
	var state = false
	var sprite = null

	for i in globals.state.playergroup:
		if globals.state.findslave(i).unique == 'Emily':
			emily = globals.state.findslave(i)
	if stage == 0:
		text = textnode.TishaVisitArchives
		state = true
		buttons.append(['Move to Dorms', 'tishadorms', 1])
	if stage == 1:
		text = textnode.TishaDorms
		if emily != null:
			sprite = [['emily2worried','pos1']]
			text += textnode.TishaDormsEmilyPresent
			text += textnode.TishaDormsInfo
			globals.state.sidequests.emily = 13
			globals.main.get_node("outside").mageorder()
			state = true
		else:
			if globals.spelldict.domination.learned == true && globals.spells.spellcost(globals.spelldict.domination) <= globals.resources.mana:
				buttons.append(['Cast Domination', 'tishadorms', 2])
			buttons.append(['Threaten', 'tishadorms', 3])
			if globals.resources.gold >= 50:
				buttons.append(['Bribe', 'tishadorms', 4])
	elif stage == 2:
		globals.resources.mana -= globals.spells.spellcost(globals.spelldict.domination)
		text = textnode.TishaDormsDominate
		text += textnode.TishaDormsInfo
		state = true
	elif stage == 3:
		globals.state.reputation.wimborn -= 2
		text = textnode.TishaDormsThreat
		text += textnode.TishaDormsInfo
		state = true
	elif stage == 4:
		globals.resources.gold -= 50
		text = textnode.TishaDormsBribe
		text += textnode.TishaDormsInfo
		state = true
	if stage >= 2:
		globals.state.sidequests.emily = 13
		globals.main.get_node("outside").mageorder()
	globals.main.dialogue(state,self,text,buttons,sprite)

func tishabackstreets(stage = 0):
	var emily
	var buttons = []
	var text = ""
	var state = false
	var main = globals.main

	if stage == 0:
		text = textnode.TishaBackstreets
		buttons.append(['Fight', 'tishabackstreets', 1])
		buttons.append(['Leave', 'tishabackstreets', 2])
	elif stage == 1:
		main.get_node("explorationnode").buildenemies("tishaquestenemy")
		closedialogue()
		globals.main.exploration.launchonwin = 'tishabackstreetswin'
		globals.main.get_node("combat").nocaptures = true
		globals.main.exploration.enemyfight()
		return
	elif stage == 2:
		main.close_dialogue()
		globals.main.get_node("outside").backstreets()
		return

	globals.main.dialogue(state,self,text,buttons)

func tishabackstreetswin():
	var text = ""
	globals.state.sidequests.emily = 14
	text = textnode.TishaBackstreetsAftercombat
	globals.main.dialogue(true,self,text)
	globals.main.get_node("outside").backstreets()

func tishagornguild(stage = 0):
	var buttons = []
	var text = ""
	var state = false
	var sprite 
	var image
	
	var emily
	
	for i in globals.slaves:
		if i.unique == 'Emily':
			emily = i
	
	if stage == 0:
		sprite = [['tishaangry', 'pos1', 'opac']]
		if globals.state.sidequests.emily == 14:
			text = textnode.TishaGornGuild
			globals.state.sidequests.emily = 15
		else:
			text = textnode.TishaGornGuildRevisit
		if globals.resources.gold >= 500:
			buttons.append(['Pay', 'tishagornguild', 1])
		else:
			buttons.append({text = 'Pay',function = 'tishagornguild',args = 1, disabled = true})
		buttons.append(['Leave', 'tishagornguild', 2])
	elif stage == 1:
		text = textnode.TishaGornPay
		sprite = [['tishaneutral', 'pos1']]
		globals.resources.gold -= 500
		buttons.append(['Brand', 'tishagornguild', 3])
		buttons.append(['Refuse', 'tishagornguild', 4])
	elif stage == 2:
		closedialogue()
		globals.main.get_node("outside").slaveguild('gorn')
		return
	elif stage == 3:
		text = textnode.TishaGornBrand
		sprite = [['tishashocked', 'pos1']]
		globals.state.sidequests.emily = 101
		var person = globals.characters.create("Tisha")
		globals.connectrelatives(person, emily, 'sibling')
		emily.relations[person.id] = 250
		person.relations[emily.id] = 500
		person.brand = 'basic'
		globals.slaves = person
		state = true
		globals.main.get_node("outside").slaveguild('gorn')
	elif stage == 4:
		sprite = [['tishaneutral', 'pos1']]
		text = textnode.TishaGornRefuseBrand
		buttons.append(['Continue', 'tishagornguild', 5])
	elif stage == 5:
		sprite = [['tishaneutral', 'pos1']]
		globals.main._on_mansion_pressed()
		if OS.get_name() != "HTML5":
			yield(globals.main, 'animfinished')
		text = textnode.TishaAfterGorn
		buttons.append(['Ask for money', 'tishagornguild', 6])
		buttons.append(['Have sex', 'tishagornguild', 7])
		buttons.append(["Don't ask for anything", 'tishagornguild', 8])
	elif stage == 6:
		sprite = [['tishaneutral', 'pos1']]
		text = textnode.TishaAskPayment
		globals.state.sidequests.emily = 17
		globals.state.upcomingevents.append({code = "tishapay", duration = 7})
		state = true
	elif stage == 7:
		image = 'tishafinale'
		sprite = [['tishanakedhappy', 'pos1']]
		text = textnode.TishaSexSceneStart
		globals.charactergallery.tisha.nakedunlocked = true
		globals.charactergallery.tisha.scenes[1].unlocked = true
		if globals.player.penis != 'none':
			text += "\n\n" + textnode.TishaSexSceneEnd
		globals.resources.mana += 10
		buttons.append({text = 'Offer Tisha work for you',function = 'tishagornguild', args = 9})
		buttons.append({text ='Not bother her',function = 'tishagornguild', args = 10})
	elif stage == 8:
		image = 'tishafinale'
		sprite = [['tishanakedhappy', 'pos1']]
		globals.charactergallery.tisha.nakedunlocked = true
		globals.charactergallery.tisha.scenes[1].unlocked = true
		text = textnode.TishaRefusePayment + textnode.TishaSexSceneStart
		globals.resources.mana += 10
		if globals.player.penis != 'none':
			text += "\n\n" + textnode.TishaSexSceneEnd
		buttons.append({text = 'Offer Tisha work for you',function = 'tishagornguild', args = 9})
		buttons.append({text ='Not bother her',function = 'tishagornguild', args = 10})
	elif stage == 9:
		globals.main.closescene()
		text = textnode.TishaOfferJob
		sprite = [['tishanakedhappy', 'pos1']]
		var person = globals.characters.create("Tisha")
		globals.connectrelatives(person, emily, 'sibling')
		emily.relations[person.id] = 250
		person.relations[emily.id] = 500
		person.consent = true
		person.add_trait("Grateful")
		person.obed += 90
		person.loyal += 15
		globals.slaves = person
		state = true
		globals.state.sidequests.emily = 16
		globals.resources.upgradepoints += 10
		emily.consent = true
		emily.tags.erase("nosex")
	elif stage == 10:
		globals.main.closescene()
		sprite = [['tishaneutral', 'pos1']]
		emily.tags.erase('nosex')
		text = textnode.TishaLeave
		state = true
		globals.state.sidequests.emily = 16
		globals.resources.upgradepoints += 10
	if stage in [7,8]:
		globals.main.scene(self, image, text, buttons)
		globals.main._on_mansion_pressed()
		closedialogue()
		return
	globals.main.dialogue(state,self,text,buttons, sprite)

func tishapay():
	var text = "At the morning you receive a delivery: nice sum of gold from Tisha, who you helped previously. "
	globals.resources.gold += 500
	globals.main.popup(text)

func emilytishasex(stage = 0):
	var text
	var state
	var buttons = []
	var emily
	var tisha
	var sprite = []
	var image
	if stage == 0:
		image = 'tishaemily'
		text = globals.questtext.TishaEmilySex
		sprite = [['tishanakedhappy', 'pos1'], ['emilynakedhappy','pos2']]
		for i in globals.slaves:
			if i.unique == 'Emily':
				emily = i
			elif i.unique == 'Tisha':
				tisha = i
		emily.metrics.sex += 1
		tisha.metrics.sex += 1
		emily.metrics.partners.append(tisha.id)
		tisha.metrics.partners.append(emily.id)
		emily.away.duration = 7
		emily.away.at = 'vacation'
		tisha.away.duration = 7
		tisha.away.at = 'vacation'
		state = false
		globals.resources.mana += 25
		globals.charactergallery.emily.scenes[2].unlocked = true
		globals.charactergallery.tisha.scenes[2].unlocked = true
		globals.charactergallery.emily.nakedunlocked = true
		globals.charactergallery.tisha.nakedunlocked = true
		buttons.append({text = 'Continue',function = 'emilytishasex',args = 1})
		globals.main.scene(self, image, text, buttons)
	elif stage == 1:
		globals.main.closescene()
		sprite = [['tishahappy', 'pos1'], ['emily2happy','pos2']]
		text = globals.questtext.TishaEmilySex2
		state = true
		globals.main.dialogue(state,self,text,buttons, sprite)


### EVENT FUNCTIONS - PUBLIC FUNCTIONS
#Sex Scene Loader
func sexscene(value):
	var text = ''
	var image
	var sprite = []
	var buttons = []
	if value == 'emilyshowersex':
		image = 'emilyshower'
		text = textnode.EmilyShowerSex
	elif value == 'showerrape':
		image = 'emilyshowerrape'
		text = textnode.EmilyShowerRape
	elif value == 'tishaemilysex':
		text = globals.questtext.TishaEmilySex
		image = 'tishaemily'
	elif value == 'tishablackmail':
		image = 'tishatable'
		text = textnode.TishaEmilyBrandCompensation
	elif value == 'tishareward':
		image = 'tishafinale'
		text = textnode.TishaSexSceneStart + '\n\n' + textnode.TishaSexSceneEnd
	elif value == "calivirgin":
		image = 'calisex'
		text = textnode.CaliAcceptProposal + '\n' + textnode.CaliProposalSexMale
	elif value == 'yrisblowjob':
		image = 'yrisbj'
		text = textnode.GornYrisAccept1
	elif value == 'yrissex':
		image = 'yrissex'
		text = textnode.GornYrisAccept2
	elif value == 'yrissex2':
		image = 'yrissex'
		text = textnode.GornYrisAccept3
	elif value == "chloemana":
		image = 'chloebj'
		text = textnode.ChloeShaliqTakeMana
	elif value == 'chloeforest':
		image = 'chloewoods'
		text = textnode.ChloeGroveFound + '\n\n' + textnode.ChloeGroveSex
	elif value == "aynerispunish":
		image = 'aynerispunish'
		text = textnode.AynerisPunish1
	elif value == "aynerissex":
		image = 'aynerissex'
		text = textnode.AynerisPunish2
	elif value == "mapleflirt":
		image = 'maplebj'
		sprite = [['fairy', 'pos1']]
		text = textnode.MapleFlirt
	elif value == "mapleflirt2":
		image = 'maplesex'
		text = textnode.MapleFlirt2
	elif value == 'zoetentacle':
		image = 'zoetentacle1'
		text = textnode.zoebookdelivercontinue
		buttons.append({text = 'Continue', function = 'sexscene', args = 'zoetentacle2'})
		globals.main.scene(self, image, text, buttons)
		return
	elif value == 'zoetentacle2':
		image = 'zoetentacle2'
		text = textnode.zoebookwatch + '\n' + textnode.zoebookwatch2virgin + textnode.zoebookwatch3
	elif value == 'aydasex1':
		image = 'aydasex1'
		text = textnode.aydasexscene1
		buttons.append({text = 'Continue', function = 'sexscene', args = 'aydasex2'})
		globals.main.scene(self, image, text, buttons)
		return
	elif value == 'aydasex2':
		image = 'aydasex2'
		text = textnode.aydasexscene2
	if buttons.empty():
		buttons.append({text = "Close", function = 'closescene'})
		globals.main.scene(self, image, text, buttons)
		return
	globals.main.dialogue(true,self,text,[],sprite)

#Event Dialogue
func event_dialogue(text, buttons, sprite, state = true):
	globals.main.dialogue(state, self, text, buttons, sprite)

#Close Scene
func closescene():
	globals.main.closescene()		
		
### MAIN QUESTS

func closedialogue():
	globals.main.close_dialogue()	
	
func gornpalace():
	var text = ''
	var state = true
	var buttons = []
	var sprite = null
	if globals.state.mainquest == 12:
		sprite = [['garthor','pos1','opac']]
		globals.charactergallery.garthor.unlocked = true
		text = textnode.MainQuestGornPalace
		state = true
		globals.state.mainquest = 13
	elif globals.state.mainquest == 13:
		text = "You decide there's no point to return to Garthor withour bringing Ivran with you. "
	elif globals.state.mainquest == 14:
		text = "Garthor already told you to return tomorrow."
	elif globals.state.mainquest == 15:
		text = textnode.MainQuestGornPalaceReturn
		sprite = [['garthor','pos1','opac']]
		buttons = [['Execute','gornpalaceivran', 1],['Keep imprisoned','gornpalaceivran', 2],['Decide later','gornpalaceivran', 4]]
		if globals.state.sidequests.ivran != 'notaltered':
			buttons.insert(2, ['Leave him to you','gornpalaceivran', 3])
		state = false
	elif globals.state.mainquest == 37:
		text = textnode.MainQuestFinaleGorn
		globals.state.mainquest = 38
		state = true
		sprite = [['garthor','pos1','opac']]
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func gornpalaceivran(stage):
	var text
	var state = true
	var buttons = []
	var sprite = null
	
	if stage == 1:
		sprite = [['garthor','pos1']]
		text = textnode.MainQuestGornIvranExecute
		if !globals.state.sidequests.ivran in ['tobetaken','tobealtered','potionreceived','notaltered']:
			text += textnode.MainQuestGornAydaSolo
		globals.state.sidequests.ivran = 'killed'
		globals.state.mainquest = 16
		globals.main.exploration.zoneenter('gorn')
	elif stage == 2:
		sprite = [['garthor','pos1']]
		text = textnode.MainQuestGornIvranImprison
		if !globals.state.sidequests.ivran in ['tobetaken','tobealtered','potionreceived','notaltered']:
			text += textnode.MainQuestGornAydaSolo
		globals.state.sidequests.ivran = 'imprisoned'
		globals.state.mainquest = 16
		globals.main.exploration.zoneenter('gorn')
	elif stage == 3 && !globals.state.sidequests.ivran in ['tobetaken','tobealtered','potionreceived']:
		sprite = [['garthor','pos1']]
		text = textnode.MainQuestGornIvranKeep
		globals.state.sidequests.ivran = 'tobetaken'
		globals.main.exploration.zoneenter('gorn')
	elif stage == 3 && globals.state.sidequests.ivran in ['tobetaken','tobealtered']:
		text = "Garthor refuses to give you Ivran as is. You should find his acquaintance. "
	elif stage == 3 && globals.state.sidequests.ivran == 'potionreceived':
		text = textnode.MainQuestGornIvranChange
		sprite = [['garthor','pos1']]
		globals.state.sidequests.ivran = 'changed'
		globals.state.mainquest = 16
		globals.state.decisions.append('ivrantaken')
		ivran = globals.newslave('Tribal Elf', 'adult', 'female', 'rich')
		ivran.name = 'Ivran'
		ivran.surname = ''
		ivran.beautybase = 75
		ivran.haircolor = 'brown'
		ivran.hairlength = 'shoulder'
		ivran.hairstyle = 'straight'
		ivran.titssize = 'big'
		ivran.asssize = 'average'
		ivran.skin = 'brown'
		ivran.eyecolor = 'amber'
		ivran.vagvirgin = true
		ivran.stats.cour_base = 65
		ivran.stats.conf_base = 83
		ivran.stats.wit_base = 55
		ivran.stats.charm_base = 48
		ivran.height = 'tall'
		ivran.loyal = 0
		ivran.obed = 50
		ivran.stress = 60
		ivran.unique = 'Ivran'
		ivran.cleartraits()
		globals.main._on_mansion_pressed()
		buttons = [['Continue','ivranname']]
		state = false
	elif stage == 4:
		closedialogue()
		return
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func ivranname():
	globals.main.setname(ivran)
	closedialogue()
	
	globals.slaves = ivran

func garthorscene(stage = 0):
	var text
	var state = false
	var buttons = []
	var sprite = null
	if stage == 0:
		globals.main.animationfade(1.5)
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		globals.main.music_set('gorn')
		globals.main.backgroundinstant('gorn')
		globals.main.clearscreen()
		sprite = [['garthor','pos1'],['hadesillh','pos2']]
		text = textnode.garthorscene1
		buttons.append(['Continue','garthorscene',1])
	elif stage == 1:
		sprite = [['garthor','pos1'],['hadesillh','pos2']]
		text = textnode.garthorscene2
		buttons.append(['Continue','garthorscene',2])
	elif stage == 2:
		globals.main.animationfade(1.5)
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		sprite = [['hadesillh','pos2']]
		text = textnode.garthorscene3
		buttons.append(['Close', 'garthorscene',3])
	elif stage == 3:
		globals.main.animationfade(1.5)
		closedialogue()
		if OS.get_name() != "HTML5":
			yield(globals.main, 'animfinished')
		globals.main.backgroundinstant('mansion')
		globals.main._on_mansion_pressed()
		return
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func hadescene1(stage = 0):
	var text
	var state = false
	var buttons = []
	var sprite = null
	if stage == 0:
		globals.main.animationfade(1.5)
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		globals.main.music_set('explore')
		#globals.main.music_set('gorn')
		globals.main.backgroundinstant('mainorder')
		globals.main.clearscreen()
		sprite = [['hade2neutral','pos1']]
		text = textnode.hadepast1
		buttons.append(['Continue','hadescene1',1])
	elif stage == 1:
		sprite = [['hade2smile','pos1']]
		text = textnode.hadepast2
		buttons.append(['Close', 'hadescene1',2])
	elif stage == 2:
		globals.main.animationfade(1.5)
		closedialogue()
		if OS.get_name() != "HTML5":
			yield(globals.main, 'animfinished')
		globals.main.backgroundinstant('mansion')
		globals.main._on_mansion_pressed()
		return
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func hadescene2(stage = 0):
	var text
	var state = false
	var buttons = []
	var sprite = null
	if stage == 0:
		globals.main.animationfade(1.5)
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		globals.main.backgroundinstant('mainorder')
		globals.main.music_set('explore')
		globals.main.clearscreen()
		sprite = [['hade2angry','pos1']]
		text = textnode.hadepast3
		buttons.append(['Continue','hadescene2',1])
	elif stage == 1:
		sprite = [['hade2neutral','pos1']]
		text = textnode.hadepast4
		buttons.append(['Close', 'hadescene2',2])
	elif stage == 2:
		globals.main.animationfade(1.5)
		closedialogue()
		if OS.get_name() != "HTML5":
			yield(globals.main, 'animfinished')
		globals.main.backgroundinstant('mansion')
		globals.main._on_mansion_pressed()
		return
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func frostfordscene(stage = 0):
	var text
	var state = false
	var buttons = []
	var sprite = null
	if stage == 0:
		globals.main.animationfade(1.5)
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		globals.main.music_set('dungeon')
		globals.main.backgroundinstant('tunnels')
		globals.main.clearscreen()
		sprite = [['hadesillh','pos1']]
		if globals.state.decisions.has("theronfired"):
			text = textnode.hadefrostford
		elif globals.state.decisions.has("dryaddefeated"):
			text = textnode.hadefrostford3
		else:
			text = textnode.hadefrostford2
		buttons.append(['Close','frostfordscene',1])
	elif stage == 1:
		globals.main.animationfade(1.5)
		closedialogue()
		if OS.get_name() != "HTML5":
			yield(globals.main, 'animfinished')
		globals.main.backgroundinstant('mansion')
		globals.main._on_mansion_pressed()
		return
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func slaverguild(stage = 0):
	var text
	var state = false
	var buttons = []
	var sprite = null
	if stage == 0:
		globals.main.animationfade(1.5)
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		globals.main.music_set('dungeon')
		globals.main.backgroundinstant('slaverguild')
		globals.main.clearscreen()
		text = textnode.slaverguild
		buttons.append(['Continue','slaverguild',1])
	elif stage == 1:
		text = textnode.slaverguild2
		buttons.append(['Close', 'slaverguild',2])
	elif stage == 2:
		globals.main.animationfade(1.5)
		closedialogue()
		if OS.get_name() != "HTML5":
			yield(globals.main, 'animfinished')
		globals.main.backgroundinstant('mansion')
		globals.main._on_mansion_pressed()
		return
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func hademelissa(stage = 0):
	var text
	var state = false
	var buttons = []
	var sprite = null
	if stage == 0:
		globals.main.animationfade(1.5)
		sprite = [['hadeneutral','pos1'],['melissaworried','pos2']]
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		globals.main.music_set('stop')
		globals.main.backgroundinstant('nightdesert')
		globals.main.clearscreen()
		text = textnode.hademelissaend
		buttons.append(['Close','hademelissa',1])
#	elif stage == 1:
#		text = textnode.slaverguild2
#		buttons.append(['Close', 'slaverguild',2])
	elif stage == 1:
		globals.main.animationfade(1.5)
		closedialogue()
		if OS.get_name() != "HTML5":
			yield(globals.main, 'animfinished')
		globals.main.music_set('start')
		globals.main.backgroundinstant('mansion')
		globals.main._on_mansion_pressed()
		return
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func gornivran():
	var text = textnode.MainQuestGornIvranFind
	var sprite = null
	var buttons = [['Attack','gornivranfight'],['Leave','gornivranleave']]
	globals.main.exploration.buildenemies("ivranquestenemy")
	globals.main.dialogue(false, self, text, buttons, sprite)

func gornivranfight():
	closedialogue()
	globals.main.exploration.launchonwin = 'gornivranwin'
	globals.main.get_node("combat").nocaptures = true
	globals.main.exploration.enemyfight()

func gornivranleave():
	closedialogue()

func gornivranwin():
	var text 
	var sprite = null
	var buttons = []
	text = textnode.MainQuestGornIvranWin
	globals.state.sidequests.ivran = ''
	globals.state.upcomingevents.append({code = 'gornwaitday', duration = 1})
	globals.state.mainquest = 14
	globals.main.exploration.zoneenter('gorn')
	globals.main.dialogue(true, self, text, buttons, sprite)

func gornwaitday():
	globals.state.mainquest = 15

func gornayda():
	var text = ''
	var state = true
	var sprite = null
	var buttons = []
	if globals.state.mainquest < 37 || globals.state.mainquestcomplete && globals.state.decisions.has("mainquestelves"):
		outside.setcharacter('aydanormal')
		if globals.state.mainquest == 15 && !globals.state.sidequests.ivran in ['tobealtered','potionreceived']:
			text = textnode.MainQuestGornAydaIvran
			state = false
			buttons = [{name = 'Accept', function = 'gornaydaivran', args = 1}, {name = 'Reject',function = 'gornaydaivran', args = 2}]
		elif globals.state.mainquest == 15 && globals.state.sidequests.ivran == 'tobealtered':
			text = "Ayda asked you to provide her with someone of high magic affinity. "
			buttons = [{name = 'Select', function = 'gornaydaselect'}]
		else:
			if globals.state.sidequests.ayda == 0:
				text = textnode.MainQuestGornAydaFirstMeet
				globals.state.sidequests.ayda = 1
			else:
				text = textnode.GornAydaReturn
			if globals.state.sidequests.ayda == 1:
				buttons.append({name = 'Ask Ayda about herself', function = 'gornaydatalk', args = 1})
			elif globals.state.sidequests.ayda == 2:
				buttons.append({name = 'Ask Ayda about monster races',function = 'gornaydatalk', args = 2})
	
			elif globals.state.sidequests.ayda >= 3:
				buttons.append({name = "See Ayda's assortments", function = 'aydashop'})
		if globals.state.sidequests.yris == 4:
			buttons.append({name = "Ask about the found ointment", function = "gornaydatalk", args = 3})
		if state == true:
			buttons.append({name = "Leave", function = 'leaveayda'})
		outside.get_node("charactersprite").visible = true
		globals.main.maintext = globals.player.dictionary(text)
		outside.buildbuttons(buttons, self)
	elif globals.state.mainquest == 38:
		text = textnode.MainQuestFinaleAydaShop
		globals.state.mainquest = 39
		globals.main.dialogue(true, self, text, buttons, sprite)
	else:
		text = "You try to enter Ayda's shop but she does not appear to be around. "
		globals.main.dialogue(true, self, text, buttons, sprite)

func leaveayda():
	outside.togorn()
	globals.main.exploration.zoneenter('gorn')

func aydashop():
	outside.shopinitiate("aydashop")

func gornaydatalk(stage = 0):
	var text = ''
	var buttons = []
	outside.setcharacter('aydanormal2')
	if stage == 1:
		text = textnode.GornAydaTalk
		globals.state.sidequests.ayda = 2
	elif stage == 2:
		text = textnode.GornAydaTalkMonsters
		globals.state.sidequests.ayda = 3
	elif stage == 3:
		text = textnode.GornYrisAydaReport
		globals.state.sidequests.yris += 1
	
	buttons.append({name = "Continue", function = "gornayda"})
	
	globals.main.maintext = globals.player.dictionary(text)
	outside.buildbuttons(buttons, self)

func gornaydaselect(person = null):
	var text
	var state = true
	var sprite
	var buttons = []
	if person == null:
		globals.main.selectslavelist(true, 'gornaydaselect', self, 'globals.currentslave.smaf >= 4')
	else:
		text = textnode.MainQuestGornAydaIvranReturn
		globals.state.sidequests.ayda = 1
		person.away.duration = 15
		person.away.at = 'away'
		globals.state.sidequests.ivran = 'potionreceived'
		buttons.append({name = "Continue", function = "gornayda"})
		globals.main.maintext = globals.player.dictionary(text)
		outside.buildbuttons(buttons, self)
		#globals.main.dialogue(state, self, text, buttons, sprite)

func gornaydaivran(stage = 0):
	var text
	var sprite
	var buttons = []
	var state = true
	if stage == 0:
		text = textnode.MainQuestGornAydaIvran
		state = false
		buttons = [['Accept','gornaydaivran',1], ['Reject','gornaydainvran',2]]
	elif stage == 1:
		text = textnode.MainQuestGornAydaIvranAccept
		globals.state.sidequests.ivran = 'tobealtered'
	elif stage == 2:
		text = textnode.MainQuestGornAydaIvranReject
	
	buttons.append({name = "Continue", function = "gornayda"})
	globals.main.maintext = globals.player.dictionary(text)
	outside.buildbuttons(buttons, self)
	#globals.main.dialogue(state, self, text, buttons, sprite)

func undercitybosswin():
	var reward
	var text = ''
	if globals.state.mainquest == 24:
		text += "After defeating the awoken golem, you spend some time searching around, until one of the piles reveals an ancient looking documents. Being unable to read them due to magical protection and unknown language, you decide to bring it back to Melissa.\n\n[color=yellow]There might be some additional treasures, but you'd have to come for them next time. [/color]\n\n"
		globals.state.mainquest = 25
	else:
		pass
	if globals.state.lorefound.find('amberguardlog3') < 0:
		globals.state.lorefound.append('amberguardlog3')
		text += "[color=yellow]You've found some old writings in the ruins. Does not look like what you came for, but you can read them later.[/color]"
	globals.main.exploration.zoneenter('undercityruins')
	globals.main.dialogue(true, self, text)
	globals.main.exploration.winscreenclear()
	globals.main.exploration.generaterandomloot([], {number = 0}, rand_range(1,3), [1,3])
	globals.main.exploration.generateloot([globals.weightedrandom([['armorplate',1],["armorplate+",1],['weaponcursedsword', 1]]), 1], '')

func frostfordcityhall(stage = 0):
	var text 
	var state = true
	var sprite
	var buttons = []
	if stage == 0:
		if globals.state.mainquest == 28:
			globals.charactergallery.theron.unlocked = true
			sprite = [['theron','pos1','opac']]
			text = textnode.MainQuestFrostfordCityhall
			globals.state.mainquest = 28.1
		elif globals.state.mainquest == 29:
			sprite = [['theron','pos1','opac']]
			text = textnode.MainQuestFrostfordCityhallReturn
			globals.state.mainquest = 30
			if globals.state.reputation.frostford >= 20:
				state = false
				buttons.append({text = "Continue", function = "frostfordcityhall", args = 1})
		elif globals.state.mainquest == 30:
			text = textnode.MainQuestFrostfordCityhallReturn2
			if globals.state.sidequests.zoe == 0:
				text += "\n\n[color=yellow]You might discover new way to solve this if your Frostford reputation will get better.[/color]"
			state = false
			buttons.append({text = "Fire Theron", function = 'frostfordcityhall', args = 5})
			buttons.append({text = "Leave", function = 'frostfordcityhall', args = 4})
		elif globals.state.mainquest == 31:
			sprite = [['theron','pos1','opac']]
			text = textnode.MainQuestFrostfordTheronZoeReturn
			globals.state.mainquest = 32
		elif globals.state.mainquest == 33:
			text = textnode.MainQuestFrostfordZoeAliveReturn
			sprite = [['zoeneutral','pos1','opac']]
			state = false
			buttons.append({text = "Invite Zoe to join you", function = "frostfordcityhall", args = 7})
			buttons.append({text = "Say her goodbye", function = "frostfordcityhall", args = 8})
			globals.state.decisions.append("zoesaved")
			globals.state.mainquest = 36
			if globals.state.decisions.find('zoeselfsacrifice') >= 0:
				text += "[color=aqua]When you offered your life for me... that was very unexpected, and I wish I could pay you back some day."
		elif globals.state.mainquest == 34:
			text = textnode.MainQuestFrostfordZoeDeadReturn
			sprite = [['theron','pos1','opac']]
			globals.state.decisions.append("zoedied")
			globals.state.mainquest = 36
		elif globals.state.mainquest == 35:
			text = textnode.MainQuestFrostfordForestWinReturn
			sprite = [['theron','pos1','opac']]
			globals.state.decisions.append("dryaddefeated")
			globals.state.mainquest = 36
	elif stage == 1:
		text = textnode.MainQuestFrostfordCityhallZoe
		sprite = [['zoeneutral','pos1','opac']]
		state = false
		globals.charactergallery.zoe.unlocked = true
		buttons.append({text = 'Accept', function = "frostfordcityhall", args = 2})
		buttons.append({text = 'Refuse', function = "frostfordcityhall", args = 3})
	elif stage == 2:
		text = textnode.MainQuestFrostfordCityhallZoeAccept
		sprite = [['zoehappy','pos1']]
		globals.state.sidequests.zoe = 1
	elif stage == 3:
		text = textnode.MainQuestFrostfordCityhallZoeRefuse
		sprite = [['zoesad','pos1']]
		globals.state.sidequests.zoe = 100
	elif stage == 4:
		closedialogue()
		return
	elif stage == 5:
		sprite = [['theron','pos1']]
		text = textnode.MainQuestFrostfordCityhallFireTheron
		state = false
		buttons.append({text = "Continue", function = "frostfordcityhall", args = 6})
	elif stage == 6:
		sprite = [['theron','pos1']]
		text = textnode.MainQuestFrostfordCityhallFireTheron2
		state = true
		globals.state.decisions.append("theronfired")
		globals.resources.day += 1
		globals.state.mainquest = 36
	elif stage == 7:
		text = textnode.MainQuestFrostfordZoeJoin
		sprite = [['zoehappy','pos1']]
		var person = globals.characters.create("Zoe")
		globals.state.sidequests.zoe = 3
		globals.slaves = person
	elif stage == 8:
		sprite = [['zoeneutral','pos1']]
		text = textnode.MainQuestFrostfordZoeLeave
		globals.state.decisions.append('zoewander')
	globals.main.exploration.zoneenter('frostford')
	globals.main.dialogue(state, self, text, buttons, sprite)

func frostforddryad():
	var text 
	var sprite = [['forestspirit','pos1','opac']]
	var state = true
	var buttons = []
	if str(globals.state.mainquest) == '28.1':
		text = textnode.MainQuestFrostfordForest
		globals.state.mainquest = 29
	elif globals.state.mainquest == 30:
		if globals.state.sidequests.zoe < 1 || globals.state.sidequests.zoe == 100:
			text = textnode.MainQuestFrostfordForestReturn
			sprite = [['forestspirit','pos1','opac']]
			if globals.state.sidequests.zoe == 0:
				text += "\n\n[color=yellow]You might discover new way to solve this if your Frostford reputation will get better.[/color]"
			state = true
			buttons.append({text = "Fight", function = 'dryadfight', args = 0})
		else:
			text = textnode.MainQuestFrostfordForestReturnWithZoe
			sprite = [['zoeneutral','pos2','opac'],['forestspirit','pos1','opac']]
			state = false
			globals.state.mainquest = 31
			buttons.append({text = 'Continue', function = "frostforddryadzoe", args = 0})
	elif globals.state.mainquest == 32:
		if globals.state.getCountStackableItem('natureessenceing','any') >= 15 && globals.state.getCountStackableItem('fluidsubstanceing','any') >= 5 && globals.resources.food >= 500:
			globals.state.removeStackableItem('natureessenceing', 15, 'any')
			globals.state.removeStackableItem('fluidsubstanceing', 5, 'any')
			globals.resources.food -= 500
			text = textnode.MainQuestFrostfordForestReturnZoe
			sprite = [['zoeneutral','pos2','opac'], ['forestspirit','pos1','opac']]
			buttons.append({text = "Fight", function = 'dryadfight', args = 2})
			state = false
		else:
			text = "You don't have everything Zoe asked you to bring. "
	globals.main.exploration.zoneenter('frostfordoutskirts')
	globals.main.dialogue(state, self, text, buttons, sprite)

func frostforddryadzoe(stage = 0):
	var text 
	var sprite
	var state = true
	var buttons = []
	if stage == 0:
		text = textnode.MainQuestFrostfordForestReturnWithZoe2
		sprite = [['zoeneutral','pos1','opac']]
	globals.main.dialogue(state, self, text, buttons, sprite)

func dryadfight(stage = 0):
	var text 
	var sprite
	var buttons = []
	if stage == 0:
		text = textnode.MainQuestFrostfordForestFight
		sprite = [['forestspirit','pos1','opac']]
		buttons.append({text = "Continue", function = 'dryadfight', args = 1})
		globals.main.dialogue(false, self, text, buttons, sprite)
	elif stage == 1:
		closedialogue()
		globals.main.exploration.buildenemies("frostforddryadquest")
		globals.main.exploration.launchonwin = 'dryadfightwin'
		globals.main.get_node("combat").nocaptures = true
		globals.main.exploration.enemyfight()
	elif stage == 2:
		closedialogue()
		globals.main.exploration.buildenemies("frostfordzoequest")
		globals.main.exploration.launchonwin = 'zoefightwin'
		globals.main.get_node("combat").nocaptures = true
		globals.main.exploration.enemyfight()

func dryadfightwin():
	var text  = ''
	var sprite = null
	var buttons = []
	text = textnode.MainQuestFrostfordForestWin
	globals.state.mainquest = 35
	globals.main.exploration.zoneenter('frostfordoutskirts')
	globals.main.dialogue(true, self, text, buttons, sprite)

func zoefightwin(stage = 0):
	var state = false
	var text  = ''
	var sprite = [['forestspirit', 'pos1', 'opac']]
	var buttons = []
	text = textnode.MainQuestFrostfordForestReturnZoeWin
	globals.main.exploration.zoneenter('frostfordoutskirts')
	buttons.append({text = "Select party member", function = 'zoechooseslave', args = null})
	buttons.append({text = "Refuse", function = "zoerefusehelp", args = 0})
	globals.main.dialogue(state, self, text, buttons, sprite)

func zoechooseslave(person = null):
	var state = false
	var text  = ''
	var sprite = null
	var buttons = []
	text = textnode.MainQuestFrostfordForestReturnZoeWin
	if person == null:
		globals.main.selectslavelist(false, 'zoechooseslave', self, 'true', true, true)
	else:
		if person == globals.player:
			buttons.append({text = "Sacrifice self", function = 'zoesacrifice', args = person})
		else:
			buttons.append({text = "Sacrifice " + person.name_short(), function = 'zoesacrifice', args = person})
	buttons.append({text = "Select party member", function = 'zoechooseslave', args = null})
	buttons.append({text = "Refuse", function = "zoerefusehelp", args = 0})
	globals.main.dialogue(state, self, text, buttons, sprite)

func zoerefusehelp(stage = 0):
	var state = true
	var text = textnode.MainQuestFrostfordZoeDie
	var sprite = null
	var buttons = []
	text += "\n\n" + textnode.MainQuestFrostfordZoeHostage
	
	globals.state.mainquest = 34
	globals.main.dialogue(state, self, text, buttons, sprite)

func zoesacrifice(person):
	var state = true
	var text  = ''
	var sprite
	var buttons = []
	var condition
	var zoealive = false
	if person == globals.player:
		condition = 'self'
		globals.state.decisions.append('zoeselfsacrifice')
		zoealive = true
	else:
		if person.send + person.smaf < 4:
			condition = 'bad'
		elif person.send + person.smaf < 7:
			condition = 'medium'
		else:
			condition = 'strong' 
	if condition == 'self':
		text = textnode.MainQuestFrostfordZoeSelf
	elif condition == 'bad':
		text = textnode.MainQuestFrostfordZoeWeak
		globals.slaves.erase(person)
	elif condition == 'medium':
		text = textnode.MainQuestFrostfordZoeMed
		globals.slaves.erase(person)
		zoealive = true
	elif condition == 'strong':
		text = textnode.MainQuestFrostfordZoeStrong
		zoealive = true
	
	if zoealive == true:
		globals.state.mainquest = 33
		text += textnode.MainQuestFrostfordZoeAlive
		sprite = [['zoesad','pos1','opac']]
	else:
		globals.state.mainquest = 34
	
	text = person.dictionary(text) + "\n\n" + textnode.MainQuestFrostfordZoeHostage
	globals.main.dialogue(state, self, text, buttons, sprite)
	globals.main.exploration.zoneenter('frostfordoutskirts')

func mountainelfcamp(stage = 0):
	var state = false
	var text
	var buttons = []
	var sprite = []
	if stage == 0:
		text = textnode.MainQuestFinaleMountainCave
		buttons.append({text = "Side with Elves", function = 'mountainelfcamp', args = 1})
		buttons.append({text = "Side with Slavers", function = 'mountainelfcamp', args = 2})
		globals.main.dialogue(state, self, text, buttons, sprite)
	elif stage == 1:
		globals.state.mainquest = 40
		globals.state.decisions.append("mainquestelves")
		closedialogue()
		globals.state.sidequests.ayda = 5
		globals.main.exploration.buildenemies("finaleslavers")
		globals.main.exploration.launchonwin = 'mountainwin'
		globals.main.get_node("combat").nocaptures = true
		globals.main.exploration.enemyfight()
		
	elif stage == 2:
		globals.state.mainquest = 40
		globals.state.decisions.append("mainquestslavers")
		globals.state.sidequests.ayda = 100
		closedialogue()
		globals.main.exploration.buildenemies("finaleelves")
		globals.main.exploration.launchonwin = 'mountainwin'
		globals.main.get_node("combat").nocaptures = true
		globals.main.exploration.enemyfight()


#Main Quest Finale
func mountainwin(stage = 0):
	var state = false
	var text = ''
	var buttons = []
	var sprite = []
	if stage == 0:
		globals.charactergallery.hade.unlocked = true
		if globals.state.decisions.has("mainquestelves"):
			text = textnode.MainQuestFinaleElfWin
		elif globals.state.decisions.has("mainquestslavers"):
			text = textnode.MainQuestFinaleMercWin
		buttons.append({text = "Continue", function = 'mountainwin', args = 1})
	elif stage == 1:
		text += textnode.MainQuestFinaleHadeSpeech
		sprite = [['hadeneutral','pos1','opac']]
		if globals.player.race == 'Human':
			text += '\n\n' + textnode.MainQuestFinaleHadeSpeechHuman
		buttons.append({text = "Continue", function = 'mountainwin', args = 2})
	elif stage == 2:
		var counter = 0
		sprite = [['hadeneutral','pos1']]
		text += "[color=yellow]— I propose you join with us against The Old Order. You will be able to achieve greatness beyond what could ever be possible if you choose to stick to the old ways. I promise, once we reform the old fools at The Order’s main branch we can give the capable people like you far more power, real power, and not be beholden to stupid, obsolete laws.[/color]\n\n[color=#ff5df8]— I know you love power and you wish to achieve more with it. We are the same in that regard. After all, you did force all those people into servitude. "
		if globals.state.decisions.has("emilyseduced"):
			text += "You didn’t hesitate to force yourself on that orphan girl. "
			counter += 1
		if globals.state.decisions.has("tishaemilytricked"):
			counter += 2
			text += "You tricked that Tisha girl into offering herself to you and also kept her sister despite your promise. "
		elif globals.state.decisions.has("tishatricked"):
			counter += 1
			text += "You tricked that Tisha girl into offering herself to you. "
		if globals.state.decisions.has("chloebrothel"):
			counter += 1
			text += "You also broken and sold that gnome girl to brothel. "
		elif globals.state.decisions.has("chloeamnesia"):
			text += "You also brainwashed that gnome girl, for your own benefit. "
			counter += 1
		elif globals.state.decisions.has("chloeaphrodisiac"):
			text += "You also broken that gnome girl for your own amusement before enslaving her. "
			counter += 1
		if globals.state.decisions.has('tiataken'):
			text += "I remember you kidnapped that village girl, as well. "
			counter += 1
		elif globals.state.decisions.has('tiatricked'):
			text += "I remember you brainwashed that village girl into joining you, as well. "
			counter += 1
		if globals.state.decisions.has("ivrantaken"):
			text += "You went so far as to take possession of a dark elf leader. "
			counter += 1
		if globals.state.decisions.has("calisexforced"):
			text += "You even forced that wolf girl to sleep with a stranger just to save you some cash. "
			counter += 1
		text += "[/color]"
		
		globals.state.mainquest = 40
		
		if counter >= 3:
			text += '\n\n' + textnode.MainQuestFinaleHadeSpeechAdditional
		buttons.append({text = "Refuse", function = 'mountainwin', args = 4})
		buttons.append({text = "Join Hade", function = 'mountainwin', args = 3})
	elif stage == 3:
		state = true
		globals.state.decisions.append('badroute')
		sprite = [['hadesmile','pos1']]
		text = textnode.MainQuestFinaleBadAccept
		globals.main.exploration.zoneenter('mountaincave')
	elif stage == 4:
		state = true
		globals.state.decisions.append('goodroute')
		sprite = [['hadeangry','pos1']]
		text = textnode.MainQuestFinaleGoodChoice
		globals.main.exploration.zoneenter('mountaincave')
		
	globals.main.dialogue(state, self, text, buttons, sprite)

func garthorencounter(stage = 0):
	var sprite = [['garthor','pos1','opac']]
	var buttons = []
	var text = textnode.MainQuestFinaleGoodGarthor
	globals.state.mainquest = 41
	buttons.append({text = "Fight", function = 'semifinalfight'})
	globals.main.dialogue(false, self, text, buttons, sprite)

func davidencounter(stage = 0):
	var sprite = null
	var buttons = []
	var text = textnode.MainQuestFinaleBadDavid
	globals.state.mainquest = 41
	buttons.append({text = "Fight", function = 'semifinalfight'})
	globals.main.dialogue(false, self, text, buttons, sprite)

func semifinalfight():
	if globals.state.decisions.has("goodroute"):
		globals.main.exploration.buildenemies("finalegarthor")
	elif globals.state.decisions.has("badroute"):
		globals.main.exploration.buildenemies("finaledavid")
	
	globals.main.exploration.launchonwin = 'semifinalewin'
	globals.main.get_node("combat").nocaptures = true
	closedialogue()
	globals.main.exploration.enemyfight()

func semifinalewin():
	var text = ''
	var state = true
	var buttons = []
	var sprite = []
	if globals.state.decisions.has("goodroute"):
		sprite = [['garthor','pos1','opac']]
		state = false
		text = textnode.MainQuestFinaleGoodChoiceWin
		buttons.append({text = "Kill Garthor", function = 'garthordecide', args = 1})
		buttons.append({text = "Leave", function = 'garthordecide', args = 2})
	elif globals.state.decisions.has("badroute"):
		text = "As David's body drops on the ground you continue on your way paying it no additional attention. "
		globals.main.exploration.zoneenter('gornoutskirts')
	globals.main.dialogue(state, self, text, buttons, sprite)

func garthordecide(stage = 0):
	var text = ''
	var state = true
	var buttons = []
	var sprite = []
	
	if stage == 1:
		globals.state.decisions.append("killgarthor")
		text = textnode.MainQuestFinaleGoodChoiceKillGarthor
	elif stage == 2:
		text = textnode.MainQuestFinaleGoodChoiceLeaveGarthor
	globals.main.exploration.zoneenter('mountains')
	globals.main.dialogue(state, self, text, buttons, sprite)

func orderfinale(stage = 0):
	var state = false
	var text = ''
	var buttons = []
	var sprite = []
	var background = null
	globals.main.music_set('combat2')
	if stage != 0:
		background = 'mainorderfinale'
	if globals.state.decisions.has('goodroute'):
		if stage == 0:
			text = textnode.MainQuestFinaleGoodWimborn
			text += "\n\n[color=yellow]Party's health and energy restored.[/color]"
			globals.player.health += 400
			globals.player.energy = 200
			for i in globals.slaves:
				i.health += 400
				i.energy = 200
			buttons.append({text = "Continue", function = 'orderfinale', args = 1})
		elif stage == 1:
			globals.main.background_set('mainorderfinale')
			if OS.get_name() != "HTML5":
				yield(globals.main, 'animfinished')
			outside.clearbuttons()
			globals.main.maintext = ''
			text = textnode.MainQuestFinaleGoodMainOrder
			buttons.append({text = "Continue", function = 'orderfinale', args = 2})
		elif stage == 2:
			sprite = [['hadeangry','pos1','opac']]
			text = textnode.MainQuestFinaleGoodHade
			buttons.append({text = "Engage Hade", function = 'orderfinale', args = 3})
		elif stage == 3:
			globals.main.exploration.buildenemies("finalehade")
			globals.main.exploration.launchonwin = 'finalemelissa'
			globals.main.get_node("combat").nocaptures = true
			closedialogue()
			globals.main.exploration.enemyfight(true)
			return
	elif globals.state.decisions.has('badroute'):
		if stage == 0:
			text = textnode.MainQuestFinaleBadWimborn
			text += "\n\n[color=yellow]Party's health and energy restored.[/color]"
			globals.player.health += 400
			globals.player.energy = 200
			for i in globals.slaves:
				i.health += 400
				i.energy = 200
			buttons.append({text = "Continue", function = 'orderfinale', args = 1})
		elif stage == 1:
			globals.main.background_set('mainorderfinale')
			if OS.get_name() != "HTML5":
				yield(globals.main, 'animfinished')
			outside.clearbuttons()
			globals.main.maintext = ''
			text = textnode.MainQuestFinaleBadOrder
			sprite = [['hadesmile','pos1','opac']]
			buttons.append({text = "Continue", function = 'orderfinale', args = 2})
		elif stage == 2:
			text = textnode.MainQuestFinaleBadOrder2
			buttons.append({text = "Fight", function = 'orderfinale', args = 3})
		elif stage == 3:
			globals.main.exploration.buildenemies("finalecouncil")
			globals.main.exploration.launchonwin = 'finalebadroute'
			globals.main.get_node("combat").nocaptures = true
			closedialogue()
			globals.main.exploration.enemyfight(true)
			return
	globals.main.dialogue(state, self, text, buttons, sprite, background)

func finalebadroute():
	var state = false
	var text = textnode.MainQuestFinaleBadOrderWin
	var buttons = [{text = "...", function = 'ending'}]
	var sprite = [['hadesmile','pos1','opac']]
	var background = 'mainorderfinale'
	globals.main.dialogue(state, self, text, buttons, sprite, background)

func finalemelissa(stage = 0):
	var text = ''
	var state = false
	var buttons = []
	var slavelist = []
	var image = 'finale'
	for i in globals.slaves:
		var score = i.metrics.ownership + i.metrics.sex*3 + i.metrics.win*2 + i.level*7
		slavelist.append({person = i, score = score})
	slavelist.sort_custom(self, 'bestslave')
	if globals.slaves.size() == 0:
		stage = 5
	if stage == 0:
		finaleperson = slavelist[0].person
		text = finaleperson.dictionary(textnode.MainQuestFinaleGoodHadeDefeat)
		buttons.append({text = "Let Hade go", function = 'finalemelissa', args = 1})
		buttons.append({text = finaleperson.dictionary("Let $name die"), function = 'finalemelissa', args = 2})
	elif stage == 1:
		text = finaleperson.dictionary(textnode.MainQuestFinaleGoodReleaseHade)
		buttons.append({text = "Continue", function = 'finalemelissa', args = 3})
		globals.state.decisions.append("haderelease")
	elif stage == 2:
		text = finaleperson.dictionary(textnode.MainQuestFinaleGoodTakeHade)
		globals.main.sound('stab')
		image = 'finale2'
		buttons.append({text = "Subdue Melissa", function = 'finalemelissa', args = 4})
		globals.state.decisions.append("hadekeep")
		globals.main.music_set('stop')
		finaleperson.removefrommansion()
	elif stage == 3:
		text = finaleperson.dictionary(textnode.MainQuestFinaleGoodReleaseHade2)
		globals.main.closescene()
		var sprite = [["melissaworried", 'pos1', 'opac']]
		buttons.append({text = finaleperson.dictionary("Rush to $name"), function = 'ending'})
		globals.main.dialogue(state, self, text, buttons, sprite)
		return
	elif stage == 4:
		text = finaleperson.dictionary("You subdue and capture Melissa, but $name is above saving... ")
		globals.main.closescene()
		var sprite = [["melissaworried", 'pos1', 'opac'], ['hadeneutral','pos2','opac']]
		buttons.append({text = "...", function = 'ending'})
		globals.main.dialogue(state, self, text, buttons, sprite)
		return
	elif stage == 5:
		text = "With Hade's defeat you secure this victory..."
		globals.main.closescene()
		globals.state.decisions.append("melissanoslave")
		var sprite = [['hadeneutral','pos1','opac']]
		buttons.append({text = "...", function = 'ending'})
		globals.main.dialogue(state, self, text, buttons, sprite)
		return
	globals.main.scene(self, image, text, buttons)

func ending():
	globals.state.mainquest = 42
	globals.main.startending()


func bestslave(first, second):
	if first.score > second.score:
		return true
	else:
		return false


### SIDE QUESTS

#Cali Side Quest
func mapletimepass():
	globals.state.sidequests.maple = 3

func calievent1():
	var cali = null
	for i in globals.slaves:
		if i.unique == 'Cali':
			cali = i
	if cali == null:
		globals.state.sidequests.cali = 100
	elif (cali.stress >= 65 && cali.loyal < 25) || cali.obed < 30:
		if cali.sleep == 'jail' || cali.sleep == 'farm' || cali.brand == 'advanced':
			cali.cour = rand_range(5,15)
			cali.conf = rand_range(5,15)
			cali.wit = rand_range(5,15)
			cali.charm = rand_range(5,15)
			globals.main.dialogue(true,self,'Unable to escape, Cali breaks down by harsh living conditions. It does not seem like she has any interest in looking for her family anymore. ')
			globals.state.sidequests.cali = 101
		else:
			globals.main.dialogue(true,self,'Unable to bear with your treatment, Cali escaped from mansion.')
			globals.slaves.erase(cali)
			globals.state.sidequests.cali = 100
	else:
		globals.state.sidequests.cali = 13
		return '\n[color=yellow]Cali seems to be concerned about something, maybe you should talk to her.[/color]'

func calirun():
	var cali = null
	for i in globals.slaves:
		if i.unique == 'Cali':
			cali = i
	if cali == null:
		return
	globals.slaves.erase(cali)
	globals.main.dialogue(true,self,'During the night Cali has escaped from the mansion in unknown direction.')

func calitalk0():
	var sprite = [['calineutral','pos1', 'opac']]
	var text
	var buttons = null
	var cali
	var state = true

	for i in globals.slaves:
		if i.unique == "Cali":
			cali = i

	if globals.state.sidequests.cali == 13:
		cali.tags.append('noescape')
		text = textnode.CaliTalkRequest
		buttons = [['Offer to look into it','calitalk1',1],['Dismiss her concerns','calitalk1',2]]
	elif globals.state.sidequests.cali == 12:
		cali.tags.append('noescape')
		text = textnode.CaliTalkHelp
		globals.state.sidequests.cali = 14
	elif globals.state.sidequests.cali == 22:
		text = textnode.CaliTalk2
		buttons = [['Take her with you','calitalk2',1],['Decline her offer','calitalk2',2]]
	if buttons != null:
		state = false
	
	globals.main.dialogue(state, self, text, buttons, sprite)

func calitalk1(response): # 1 - agree, 2 - refuse
	var sprite
	if response == 1:
		globals.state.sidequests.cali = 14
		sprite = [['calihappy','pos1']]
		for i in globals.slaves:
			if i.unique == 'Cali':
				i.loyal += 10
		globals.main.dialogue(true,self, textnode.CaliTalkAccept, null, sprite)
	elif response == 2:
		globals.state.sidequests.cali = 100
		sprite = [['calineutral','pos1']]
		globals.main.dialogue(true,self, textnode.CaliTalkRefuse, null, sprite)
		globals.state.upcomingevents.append({code = 'calirun', duration = 1})

func calitalk2(response): # 1 - accept, 2 - refuse
	var sprite
	if response == 1:
		globals.state.sidequests.cali = 23
		sprite = [['calihappy','pos1']]
		globals.main.dialogue(true,self, textnode.CaliTalk2Accept, null, sprite)
	elif response == 2:
		sprite = [['calineutral','pos1']]
		globals.state.sidequests.cali = 24
		globals.main.dialogue(true,self, textnode.CaliTalk2Refuse, null, sprite)

func caliproposal(stage = 0):
	var sprite = [['calineutral','pos1', 'opac']]
	var text
	var buttons = null
	var cali
	var state = true
	var image
	for i in globals.slaves:
		if i.unique == 'Cali':
			cali = i
	if cali == null:
		globals.state.sidequests.cali = 100
		return
	if cali.vagvirgin == false || cali.loyal <= 50 || (stage == 0 && globals.state.decisions.has('caliproposalseen')):
		return
	if cali.away.duration != 0:
		globals.state.upcomingevents.append({code = 'caliproposal', duration = cali.away.duration + 2})
		return
	
	if stage == 0:
		globals.state.decisions.append("caliproposalseen")
		text = textnode.CaliProposal
		buttons = [["Accept Cali's feelings",'caliproposal',1],['Stay friends','caliproposal',2]]
		state = false
	elif stage == 1:
		closedialogue()
		image = 'calisex'
		sprite = [['calinakedhappy','pos1']]
		text = textnode.CaliAcceptProposal
		globals.charactergallery.cali.scenes[0].unlocked = true
		globals.charactergallery.cali.nakedunlocked = true
		if globals.player.penis != 'none':
			cali.vagvirgin = false
			cali.metrics.vag += 1
			text += textnode.CaliProposalSexMale
		cali.loyal += 25
		cali.obed += 50
		cali.metrics.sex += 1
		cali.metrics.orgasm += 1
		cali.metrics.partners.append(globals.player.id)
		globals.state.decisions.append("calilove")
	elif stage == 2:
		sprite = [['calineutral','pos1']]
		text = textnode.CaliDenyProposal
	if stage == 1:
		buttons = [{text = "Close", function = 'closescene'}]
		globals.main.scene(self, image, text, buttons)
	else:
		globals.main.dialogue(state, self, text, buttons, sprite)

func calibar():
	var buttons = []
	var text = ''
	var sprite
	if globals.state.sidequests.cali == 14:
		sprite = [['calineutral','pos1', 'opac']]
		text = textnode.CaliBarEntrance
		globals.state.sidequests.calibarsex = 'none'
		globals.state.sidequests.cali = 15
	elif globals.state.sidequests.cali == 15:
		sprite = [['calineutral','pos1']]
		text = textnode.CaliBarRepeat
	elif globals.state.sidequests.cali == 16:
		sprite = [['calineutral','pos1']]
		text = textnode.CaliBarLastpay
	if !globals.state.sidequests.calibarsex in ['disliked','liked','sebastianfinish'] && globals.resources.gold >= 500:
		buttons.append(['Pay 500 gold for information', 'calibar1', 1])
	if !globals.state.sidequests.calibarsex in ['disliked','liked','agreed','forced','sebastian','sebastianfinish']:
		buttons.append(['Talk to Cali', 'calibar1', 2])
	if globals.state.sidequests.calibarsex in ['disliked','liked','sebastianfinish'] && globals.resources.gold >= 100 && globals.state.sidequests.cali < 17:
		buttons.append(['Pay 100 gold for information', 'calibar1', 3])
	if globals.state.sidequests.calibarsex == 'sebastian':
		buttons.append(["Show Jason Sebastian's note", 'calibar1', 9])
	if globals.state.sidequests.calibarsex in ['agreed','forced']:
		buttons.append(['Let him fuck Cali', 'calibar1',5])
	if globals.state.sidequests.calibarsex in ['forced','disliked']:
		sprite = [['calisad','pos1']]
	if globals.state.sidequests.cali == 17:
		if globals.state.sidequests.calibarsex in ['forced','disliked']:
			sprite = [['calisad','pos1']]
		else:
			sprite = [['calineutral','pos1']]
		text = textnode.CaliBarLeave
		globals.main.get_node("outside").backstreets()
		globals.main.dialogue(true, self, text, buttons, sprite)
		return
	buttons.append(['Excuse yourself and leave', 'calibar1', 4])

	globals.main.dialogue(false,self, text, buttons, sprite)

func calibar1(value):
	var cali = null
	for i in globals.slaves:
		if i.unique == 'Cali':
			cali = i
	var buttons = []
	var text = ''
	var sprite 
	if globals.state.sidequests.calibarsex in ['forced','disliked']:
		sprite = [['calisad','pos1']]
	else:
		sprite = [['calineutral','pos1']]
	if value == 1:
		globals.resources.gold -= 500
		text = textnode.CaliBarPay500
		globals.state.sidequests.cali = 17
		buttons.append(['Leave', 'calibar1', 4])
	elif value == 2:
		text = textnode.CaliBarTalk
		buttons.append(["Tell her it's the only way", 'calibar1', 6])
		if globals.state.sidequests.calibarsex != 'reject':
			text += "\n\n[color=yellow]— What? You are not trying to make me... — she cringes — He's disgusting, have you seen how he looks at me?[/color]\n\nCali looks completely repulsed by the whole suggestion, but perhaps you could change her mind. With the right word here and there she may open to the idea."
			buttons.append(["Try talk her into it", 'calibar1', 7])
		else:
			text += "\n\n[color=yellow]— I don’t know what to do… Maybe there’s another way?[/color] "
		buttons.append(["Agree and don't press the issue further", 'calibar1', 8])
	elif value == 3:
		globals.resources.gold -= 100
		text = textnode.CaliBarPay100
		globals.state.sidequests.cali = 17
		buttons.append(['Leave', 'calibar1', 4])
	elif value == 4:
		text = textnode.CaliBarLeave
		globals.main.dialogue(true, self, text, buttons, sprite)
		globals.main.get_node("outside").backstreets()
		return
	elif value == 5:
		if globals.state.sidequests.calibarsex == 'agreed':
			text = textnode.CaliBarFuckWilling
			globals.state.sidequests.calibarsex = 'liked'
			cali.metrics.sex += 1
			cali.metrics.vag += 1
			cali.metrics.randompartners += 1
			cali.metrics.orgasm += 1
			globals.state.sidequests.cali = 17
			cali.lust -= 15
			cali.loyal -= 5
			cali.energy = -50
			cali.vagvirgin = false
			cali.add_trait('Fickle')
		elif globals.state.sidequests.calibarsex == 'forced':
			sprite = [['calisad','pos1']]
			globals.state.decisions.append("calisexforced")
			text = textnode.CaliBarFuckUnwilling
			cali.metrics.sex += 1
			cali.metrics.vag += 1
			cali.metrics.randompartners += 1
			cali.metrics.roughsex += 1
			cali.loyal -= 50
			cali.obed -= 60
			cali.stress += 75
			cali.health = -15
			cali.energy = -50
			cali.vagvirgin = false
			globals.state.sidequests.calibarsex = 'disliked'
			globals.state.sidequests.cali = 16
		buttons.append(['Continue','calibar'])
	elif value == 6:
		sprite = [['calisad','pos1']]
		text = textnode.CaliBarForce
		cali.loyal -= 30
		cali.obed -= 30
		globals.state.sidequests.calibarsex = 'forced'
		buttons.append(['Return','calibar'])
	elif value == 7:
		if cali.lewdness >= 30 && cali.consent == true:
			text = textnode.CaliBarPersuadeSuccess
			globals.state.sidequests.calibarsex = 'agreed'
			buttons.append(['Return','calibar'])
		else:
			text = textnode.CaliBarPersuadeFail
			sprite = [['caliangry','pos1']]
			globals.state.sidequests.calibarsex = 'reject'
			cali.loyal -= 15
			cali.obed -= 25
			buttons.append(['Return','calibar1', 2])
	elif value == 8:
		text = textnode.CaliBarDeny
		buttons.append(['Return','calibar'])
	elif value == 9:
		text = textnode.CaliBarUseSebastian
		globals.state.sidequests.calibarsex = 'sebastianfinish'
		buttons.append(['Return','calibar'])
	globals.main.dialogue(false, self, text, buttons, sprite)

func calivillage():
	globals.main.dialogue(true,self,textnode.CaliVillageEnter1)
	globals.state.sidequests.cali = 18
	globals.main.exploration.zoneenter('shaliq')

func calivillage2():
	var text = ''
	var buttons = []
	var state = false
	if globals.state.sidequests.cali == 20:
		text = textnode.CaliVillageEnter2
		state = true
	elif globals.state.sidequests.cali == 21:
		text = textnode.CaliVillageEnter3
		buttons.append(['Gratefully accept','calivillage3', 1])
		buttons.append(['Respectfully decline','calivillage3', 2])
	globals.state.sidequests.cali = 22
	globals.main.dialogue(state,self,text,buttons)

func calivillage3(stage):
	var text = ""
	if stage == 1:
		text = textnode.CaliVillageAcceptReward
		globals.resources.gold += 300
	elif stage == 2:
		text = textnode.CaliVillageRefuseReward
		globals.resources.upgradepoints += 4
	globals.main.dialogue(true,self,text)

var calibanditcampstage = 0 #0 - nothing, 1 - poisoned mead, 2 - dominated, 3 - both

func calibanditcamp():
	var text = ''
	var buttons = []
	if calibanditcampstage == 0:
		text = "You find your way to the Bandit Camp. As you carefully scout out the situation you realize that there’s probably more here than you can easily handle at once.  Two bandits are in the center of the camp arguing over who gets to be to rape the terrified girl tied up near them. Two more are drinking heavily from an open cask of mead, and one more is making a slow circuit of the camp, keeping a close eye on the surrounding woods. "
	elif calibanditcampstage == 1:
		text = "As you carefully scout out the situation you realize that there’s probably more here than you can easily handle at once.  Two bandits are in the center of the camp arguing over who gets to be to rape the terrified girl tied up near them.  Two bandits are lying in a drunken stupor near the mead cask and one more is making a slow circuit of the camp, keeping a close eye on the surrounding woods."
	elif calibanditcampstage == 2:
		text = "As you carefully scout out the situation you realize that there’s probably more here than you can easily handle at once. A bandit is examining the captive girl with interest, while another is trying to bandage up a nasty body wound. Two more are drinking heavily from an open cask of mead, and and the body of a stabbed bandit lies dead near the center of the camp."
	elif calibanditcampstage == 3:
		text = "As you carefully scout out the situation you realize that there’s probably more here than you can easily handle at once. A bandit is examining the captive girl with interest, while another is trying to bandage up a nasty stomach wound. Two bandits are lying in a drunken stupor near the mead cask and the body of a stabbed bandit lies dead near the center of the camp."
	if globals.main.exploration.scout.wit >= 70 && calibanditcampstage != 1 && calibanditcampstage != 3 && globals.main.exploration.scout != globals.player:
		buttons.append(["Poison the bandit’s mead", 'calibanditcampaction', 1])
	if globals.spelldict.domination.learned == true && calibanditcampstage != 2 && calibanditcampstage != 3 && globals.spells.spellcost(globals.spelldict.domination) <= globals.resources.mana:
		buttons.append(["Dominate the wandering sentry", 'calibanditcampaction', 2])
		globals.resources.mana -= globals.spells.spellcost(globals.spelldict.domination)
	buttons.append(['Attack the camp', 'calibanditcampattack'])
	globals.main.dialogue(false,self,text,buttons)


func calibanditcampaction(action):
	var buttons = []
	var text = ''
	if action == 1:
		text = textnode.CaliPoisonBandits
		if calibanditcampstage == 2:
			calibanditcampstage = 3
		elif calibanditcampstage == 0:
			calibanditcampstage = 1
	elif action == 2:
		text = textnode.CaliDominateBandits
		if calibanditcampstage == 1:
			calibanditcampstage = 3
		elif calibanditcampstage == 0:
			calibanditcampstage = 2
	buttons.append(['Continue', 'calibanditcamp'])
	globals.main.dialogue(false,self,text,buttons)


func calibanditcampattack():
	var main = globals.main
	var text = "You decide it’s time to attack and charge the camp with your group. "
	if calibanditcampstage == 0:
		main.get_node("explorationnode").buildenemies("banditshard")
	elif calibanditcampstage == 1 || calibanditcampstage == 2:
		main.get_node("explorationnode").buildenemies("banditsmedium")
	elif calibanditcampstage == 3:
		main.get_node("explorationnode").buildenemies("banditseasy")
	var buttons = [["Continue", 'calibanditcampfight']]
	main.dialogue(false,self,text,buttons)

func calibanditcampfight():
	closedialogue()
	globals.main.exploration.launchonwin = 'calibanditcampwin'
	globals.main.get_node("combat").nocaptures = true
	globals.main.exploration.enemyfight()

func calibanditcampwin():
	var buttons = []
	buttons.append(['Return the girl', 'calibanditcampchoice', 1])
	buttons.append(['Kidnap the girl', 'calibanditcampchoice', 2])
	if globals.spelldict.entrancement.learned == true && globals.spells.spellcost(globals.spelldict.entrancement) <= globals.resources.mana:
		buttons.append(['Seduce the girl', 'calibanditcampchoice', 3])
		globals.resources.mana -= globals.spells.spellcost(globals.spelldict.entrancement)
	globals.main.dialogue(false,self,textnode.CaliBanditCampVictory,buttons)

func calibanditcampchoice(choice):
	var texttemp
	if choice == 1:
		texttemp = textnode.CaliReturnGirl
		globals.state.sidequests.cali = 21
		globals.main.dialogue(true,self,texttemp)
		globals.main.exploration.zoneenter('shaliq')
		return
	var person = globals.characters.create("Tia")
	if choice == 2:
		texttemp = textnode.CaliKidnapGirl
		globals.state.decisions.append("tiataken")
		person.obed += -100
		person.sleep = 'jail'
		globals.main.exploration.captureeffect(person)
		globals.state.sidequests.cali = 20
	elif choice == 3:
		texttemp = textnode.CaliSeduceGirl
		globals.state.decisions.append("tiatricked")
		person.obed += 75
		person.loyal += 20
		globals.slaves = person
		globals.state.sidequests.cali = 20
	globals.main.dialogue(true,self,texttemp)
	globals.main._on_mansion_pressed()
	globals.resources.energy = -100

func calislavercamp():
	var cali = null
	var text = ""
	var buttons = []
	var state
	var sprite
	for i in globals.state.playergroup:
		if globals.state.findslave(i).unique == 'Cali':
			cali = globals.state.findslave(i)
	if globals.state.sidequests.cali == 23 && cali == null:
		text = "You said that you would bring Cali along to help, you’ll need her as a companion."
		state = true
	elif globals.state.sidequests.cali == 23:
		text = textnode.CaliSlaversTaken
		state = false
		buttons.append(['Continue', 'calislaver', 1])
		sprite = [['calineutral','pos1','opac']]
	elif globals.state.sidequests.cali == 24:
		text = textnode.CaliSlaversLeft
		state = false
		if globals.resources.gold >= 100:
			buttons.append(['Pay the fee','calislavercamppay',1])
		buttons.append(['Walk away','calislavercamppay',2])
	globals.main.dialogue(state,self,text, buttons, sprite)



func calislavercamppay(choice):
	var text = ''
	var buttons = []
	var state = true
	if choice == 1:
		globals.resources.gold -= 100
		state = false
		text = textnode.CaliSlaversPay
		buttons.append(['Ask about buying', 'calislaver',2])
		buttons.append(['Attack','calislaver',5])
		globals.main.dialogue(state, self, text, buttons)
	elif choice == 2:
		closedialogue()

func calislaver(choice):
	var text = ""
	var buttons = []
	var sprite
	if choice == 1:
		text = textnode.CaliSlaversOffer
		sprite = [['calineutral','pos1']]
		buttons.append(['Sell Cali', 'calislaver',3])
		buttons.append(['Decline','calislaver',4])
		buttons.append(['Attack','calislaver',5])
	elif choice == 2:
		text = textnode.CaliSlaversNoOffer
		buttons.append(['Leave', 'calislaver',6])
	elif choice == 3:
		sprite = [['caliangry','pos1']]
		text = textnode.CaliSlaverSell
		for i in globals.slaves:
			if i.unique == 'Cali':
				globals.slaves.erase(i)
		globals.resources.gold += 350
		buttons.append(['Leave', 'calislaver',7])
	elif choice == 4:
		text = textnode.CaliSlaverNoSell
		buttons.append(['Leave', 'calislaver',6])
	elif choice == 5:
		closedialogue()
		globals.main.exploration.buildenemies("CaliBossSlaver")
		globals.main.get_node("combat").nocaptures = true
		globals.main.exploration.launchonwin = 'calislaverscampwin'
		globals.main.exploration.enemyfight()
		return
	elif choice == 6:
		closedialogue()
		globals.state.sidequests.cali = 25
		globals.main.exploration.zoneenter('wimbornoutskirts')
		return
	elif choice == 7:
		closedialogue()
		globals.state.sidequests.cali = 100
		globals.main.exploration.zoneenter('wimbornoutskirts')
		return
	globals.main.dialogue(false, self, text, buttons, sprite)


func calislaverscampwin():
	var cali = null
	var text = ""
	var buttons = []
	var state
	var sprite
	for i in globals.state.playergroup:
		if globals.state.findslave(i).unique == 'Cali':
			cali = globals.state.findslave(i)
	if cali != null:
		sprite = [['calihappy','pos1']]
		text = textnode.CaliSlaversFightWinTogether
	else:
		text = textnode.CaliSlaversFightWinWithout
	globals.state.sidequests.cali = 25
	globals.main.dialogue(true, self, text, null, sprite)
	globals.main.exploration.zoneenter('wimbornoutskirts')


func calistraybandit():
	var cali = null
	var text = ""
	var buttons = []
	var state
	for i in globals.state.playergroup:
		if globals.state.findslave(i).unique == 'Cali':
			cali = globals.state.findslave(i)
	if cali == null:
		globals.main.popup("You should probably bring Cali along for this, she could confirm if this is in fact the bandit that captured her.")
		return
	closedialogue()
	globals.main.exploration.buildenemies("CaliStrayBandit")
	globals.main.get_node("combat").nocaptures = true
	globals.main.exploration.launchonwin = 'calistraybanditwin'
	globals.main.exploration.enemyfight()

func calistraybanditwin():
	var sprite = [['calineutral','pos1','opac']]
	globals.main.exploration.zoneenter('wimbornoutskirts')
	globals.main.dialogue(true,self,textnode.CaliStrayBanditWin, null, sprite)
	globals.state.sidequests.cali = 26
	if globals.state.sidequests.calibarsex in ['none','sebastianfinish']:
		globals.state.upcomingevents.append({code = 'caliproposal', duration = 1})


func calireturnhome():
	var text = ""
	var buttons = []
	var state
	var sprite
	if globals.state.sidequests.caliparentsdead == true:
		text = textnode.CaliBadEnd
		sprite = [['calisad','pos1','opac']]
		buttons.append(['Let her be','calireturnhome1',1])
		buttons.append(['Comfort her','calireturnhome1',2])
	else:
		text = textnode.CaliGoodEnd
		sprite = [['calihappy','pos1','opac']]
		buttons.append(['Tell them no reward is necessary','caligoodend',1])
		buttons.append(['Tell them anything would be fine','caligoodend',2])
		buttons.append(['Ask if Cali could continue working for you','caligoodend',3])
	globals.main.dialogue(false,self,text,buttons,sprite)


func calireturnhome1(choice):
	var text = ""
	var buttons = []
	var cali = null
	var sprite = [['calihappy','pos1']]
	for i in globals.slaves:
		if i.unique == 'Cali':
			cali = i
	if choice == 1:
		text = textnode.CaliBadEndStay
	else:
		text = textnode.CaliBadEndComfort
		cali.loyal += 10
		cali.obed += 20
	buttons.append(['Offer to let her stay with you','calibadend',1])
	buttons.append(['Tell her to be your slave','calibadend',2])
	buttons.append(['Tell her to become your plaything','calibadend',3])
	buttons.append(['Leave her alone','calibadend',4])
	globals.main.dialogue(false,self,text,buttons,sprite)

func calibadend(choice):
	var text = ''
	var cali = null
	for i in globals.slaves:
		if i.unique == 'Cali':
			cali = i

	var sprite = [['calineutral','pos1']]
	if choice == 1:
		cali.loyal += 100
		cali.conf -= 20
		text = textnode.CaliStay
		globals.state.decisions.append('calibadstayed')
		
	elif choice == 2:
		text = textnode.CaliSlave
		cali.obed += 100
		cali.conf -= 20
		globals.state.decisions.append('calibadstayed')
	elif choice == 3:
		if cali.loyal >= 50:
			cali.obed += 100
			cali.lewdness = 50
			globals.state.decisions.append('calibadstayed')
			for i in ['cour','conf','wit','charm']:
				cali[i] = 0
				cali[i] = rand_range(5,15)
			text = textnode.CaliPlaythingSuccess
		else:
			text = textnode.CaliPlaythingFailure
			globals.resources.gold += 150
			cali.removefrommansion()
			globals.state.playergroup.erase(cali.id)
			globals.state.decisions.append('calibadleft')

	elif choice == 4:
		text = textnode.CaliLeave
		globals.state.playergroup.erase(cali.id)
		cali.removefrommansion()
		globals.state.decisions.append('calibadleft')
	globals.resources.upgradepoints += 10
	cali.add_trait("Grateful")
	globals.main.exploration.zoneenter('grove')
	globals.main.dialogue(true,self,text,null,sprite)
	globals.state.sidequests.cali = 102


func caligoodend(choice):
	var text = ''
	var cali = null
	for i in globals.slaves:
		if i.unique == 'Cali':
			cali = i
	var sprite = [['calihappy','pos1']]
	if choice == 1:
		text = textnode.CaliGoodEndNoReward
		cali.away.at = 'hidden'
		cali.away.duration = -1
		globals.state.upcomingevents.append({code = 'calireturn', duration = 7})
		globals.state.decisions.append('calistayedwithyou')
	elif choice == 2:
		text = textnode.CaliGoodEndReward
		globals.itemdict.hairgrowthpot.amount += 3
		globals.itemdict.stimulantpot.amount += 2
		globals.itemdict.oblivionpot.amount += 1
		globals.itemdict.youthingpot.amount += 1
		cali.removefrommansion()
		globals.state.decisions.append('calireturnedhome')
	elif choice == 3:
		text = textnode.CaliGoodEndKeep
		cali.add_trait('Pliable')
		cali.loyal += 100
		globals.main._on_mansion_pressed()
		globals.state.decisions.append('calistayedwithyou')
	if choice != 3:
		globals.main.exploration.zoneenter('grove')
	globals.resources.upgradepoints += 15
	cali.add_trait("Grateful")
	globals.main.dialogue(true,self,text,null,sprite)
	globals.state.sidequests.cali = 103

func calireturn():
	var cali = null
	for i in globals.slaves:
		if i.unique == 'Cali':
			cali = i
	if cali == null:
		return
	var sprite = [['calihappy','pos1']]
	cali.away.at = ''
	cali.away.duration = 0
	globals.main.dialogue(true,self,textnode.CaliGoodEndNoRewardReturn,null,sprite)
	globals.main._on_mansion_pressed()


func caliparentsdie():
	globals.state.sidequests.caliparentsdead = true

		
#Chloe Side Quest

func chloeforest(stage = 0):
	var text = ''
	var state = false
	var sprite = [['chloehappy', 'pos1']]
	var buttons = []
	if stage == 0:
		sprite = [['chloeneutral', 'pos1', 'opac']]
		if globals.state.sidequests.chloe == 1:
			chloeforest(3)
			return
		else:
			var havegnomemember = false
			for i in globals.state.playergroup:
				var person = globals.state.findslave(i)
				if person.race == 'Gnome':
					havegnomemember = true
			if havegnomemember == false:
				text = textnode.ChloeEncounter
				if globals.spelldict.sedation.learned == true && globals.spells.spellcost(globals.spelldict.sedation) <= globals.resources.mana:
					buttons.append({text = 'Cast Sedation',function = 'chloeforest',args = 1, disabled = false})
				elif globals.spelldict.sedation.learned == true:
					buttons.append({text = 'Cast Sedation',function = 'chloeforest',args = 1, disabled = true, tooltip = 'Not enough mana'})
				else:
					buttons.append({text = "You have no other available options yet",function = 'chloeforest',args = 1, disabled = true})
			else:
				text = textnode.ChloeEncounterGnome
				buttons.append({text = 'Talk with her',function = 'chloeforest',args = 2, disabled = false})
			buttons.append({text = 'Leave her alone',function = 'chloeforest',args = 6})
	
	
	
	elif stage == 1:
		globals.resources.mana -= globals.spells.spellcost(globals.spelldict.sedation)
		text = textnode.ChloeSedate + textnode.ChloeEncounterTalk
		globals.state.sidequests.chloe = 1
		buttons.append({text = 'Lead her to the Shaliq',function = 'chloeforest',args = 4})
		buttons.append({text = "Tell her you can't help",function = 'chloeforest',args = 5})
	elif stage == 2:
		text = textnode.ChloeEncounterTalk
		globals.state.sidequests.chloe = 1
		buttons.append({text = 'Lead her to the Shaliq',function = 'chloeforest',args = 4})
		buttons.append({text = "Tell her you can't help",function = 'chloeforest',args = 5})
	elif stage == 3:
		text = textnode.ChloeEncounterRepeat
		buttons.append({text = 'Lead her to the Shaliq',function = 'chloeforest',args = 4})
		buttons.append({text = "Tell her you can't help",function = 'chloeforest',args = 5})
	elif stage == 4:
		text = textnode.ChloeEncounterHelp
		buttons.append({text = 'Proceed to Shaliq with Chloe',function = 'chloeforest',args = 7})
	elif stage == 5:
		text = textnode.ChloeEncounterRefuse
		buttons.append({text = 'Continue',function = 'chloeforest',args = 6})
	elif stage == 6:
		globals.main.exploration.zoneenter('forest')
		closedialogue()
		return
	elif stage == 7:
		text = textnode.ChloeShaliq
		globals.state.sidequests.chloe = 2
		globals.main.exploration.progress = 0
		globals.main.exploration.zoneenter('shaliq')
		yield(globals.main, 'animfinished')
		buttons.append({text = 'Leave',function = 'chloevillage',args = 0})
	globals.main.dialogue(state,self,text,buttons,sprite)

func chloevillage(stage = 0):
	var text = ''
	var state = true
	var sprite = [['chloehappy2', 'pos1','opac']]
	var buttons = []
	if stage == 0:
		globals.main.exploration.zoneenter('shaliq')
		closedialogue()
		globals.main.closescene()
		return
	elif stage == 1:
		text = textnode.ChloeShaliqOffer
		globals.charactergallery.chloe.unlocked = true
		globals.state.sidequests.chloe = 3
		state = false
		if globals.resources.mana >= 25:
			buttons.append({text = 'Agree',function = 'chloevillage',args = 3})
		else:
			buttons.append({text = 'Agree',function = 'chloevillage',args = 3, disabled = true})
		buttons.append({text = 'Leave',function = 'chloevillage',args = 0})
	elif stage == 2:
		text = textnode.ChloeShaliqReturn
		state = false
		if globals.resources.mana >= 25:
			buttons.append({text = 'Agree',function = 'chloevillage',args = 3})
		else:
			buttons.append({text = 'Agree',function = 'chloevillage',args = 3, disabled = true})
		buttons.append({text = 'Leave',function = 'chloevillage',args = 0})
	elif stage == 3:
		globals.main.exploration.zoneenter('shaliq')
		yield(globals.main, "animfinished")
		sprite = [['chloeshy2', 'pos1']]
		globals.charactergallery.chloe.scenes[0].unlocked = true
		globals.resources.mana -= 25
		globals.state.sidequests.chloe = 4
		globals.spelldict.entrancement.learned = true
		globals.state.upcomingevents.append({code = 'chloemissing', duration = 7})
		if globals.abilities.abilitydict.has('entrancement') == true:
			globals.player.ability.append('entrancement')
		if globals.player.penis != 'none':
			text = textnode.ChloeShaliqTakeMana
		else:
			text = "Chloe gleams with joy, happily smiling as she runs off to put her new possession away.\n\n[color=aqua]You have learned the Entrancement Spell.[/color]"
		var image = 'chloebj'
		buttons.append({text = 'Continue',function = 'chloevillage',args = 0})
		globals.main.scene(self, image, text, buttons)
		return
	elif stage == 4:
		if globals.state.sidequests.chloe == 4:
			text = textnode.ChloeShaliqBusy
		elif globals.state.sidequests.chloe == 5:
			text = textnode.ChloeShaliqMissing
			sprite = []
			globals.state.sidequests.chloe = 6
		elif globals.state.sidequests.chloe == 6:
			sprite = []
			text = textnode.ChloeShaliqMissingRepeat
	elif stage == 5:
		if globals.state.sidequests.chloe == 7:
			text = textnode.ChloeVillageHelp
			globals.state.sidequests.chloe = 8
			sprite = [['chloeshy2', 'pos1','opac']]
		elif globals.state.sidequests.chloe == 8:
			text = textnode.ChloeHelpReturn
		elif globals.state.sidequests.chloe == 9:
			globals.state.sidequests.chloe = 10
			globals.resources.upgradepoints += 10
			if globals.state.decisions.find('chloeaphrodisiac') >= 0:
				text = textnode.ChloeAphrodisiac
				sprite = [['chloeshy2', 'pos1']]
				state = false
				globals.state.reputation.wimborn -= 20
				buttons.append({text = 'Sell her to brothel',function = 'chloevillage',args = 6})
				buttons.append({text = 'Keep her to self',function = 'chloevillage',args = 7})
			if globals.state.decisions.find('chloeamnesia') >= 0:
				text = textnode.ChloeAmnesia
				globals.state.reputation.wimborn -= 10
				var chloe = globals.characters.create("Chloe")
				chloe.loyal += 25
				globals.slaves = chloe
			if globals.state.decisions.find('chloecure') >= 0:
				text = textnode.ChloeCure
				globals.spelldict.domination.learned = true
				text += "\n\n[color=aqua]You've learned Domination spell[/color]"
	elif stage == 6:
		text = textnode.ChloeBrothel
		globals.state.decisions.append("chloebrothel")
		sprite = [['chloenakedhappy', 'pos1']]
		globals.resources.gold += 500
	elif stage == 7:
		text = textnode.ChloeTakeSelf
		var chloe = globals.characters.create("Chloe")
		chloe.loyal += 25
		chloe.lewdness = 100
		chloe.add_trait('Sex-crazed')
		sprite = [['chloehappy2', 'pos1']]
		globals.slaves = chloe
	elif stage == 8:
		if globals.state.decisions.find('chloecure') >= 0 && globals.state.decisions.find("chloeleft") < 0:
			if globals.resources.day == chloevisit:
				text = "You have already visited Chloe today."
			else:
				if randf() >= 0.7:
					state = false
					sprite = [['chloenakedhappy', 'pos1']]
					buttons.append({text = "Take Chloe's Offer",function = 'chloevillage',args = 9})
					buttons.append({text = "Refuse Chloe's Offer",function = 'chloevillage',args = 0})
					text = textnode.ChloeVisit2
					globals.resources.mana += 10
				else:
					text = textnode.ChloeVisit
				chloevisit = globals.resources.day
		else:
			sprite = []
			text = textnode.ChloeEmpty
	elif stage == 9:
		text = textnode.ChloeVisitAccept
		var person = globals.characters.create("Chloe")
		person.loyal = 35
		globals.slaves = person
		globals.state.decisions.append('chloeleft')
	globals.main.dialogue(state,self,text,buttons,sprite)

var chloevisit = 0

func chloemissing():
	globals.state.sidequests.chloe = 5

func chloegrove(stage = 0):
	var text = ''
	var state = false
	var sprite = [['chloenakedhappy', 'pos1','opac']]
	var buttons = []
	var image
	
	if stage == 0:
		globals.state.sidequests.chloe = 7
		globals.charactergallery.chloe.nakedunlocked = true
		text = textnode.ChloeGroveFound
		buttons.append({text = 'Have sex with Chloe',function = 'chloegrove',args = 1})
		buttons.append({text = 'Masturbate Chloe',function = 'chloegrove',args = 2})
	elif stage in [1,2]:
		globals.resources.mana += 15
		sprite = [['chloenakedneutral', 'pos1']]
		buttons.append({text = 'Continue',function = 'chloegrove',args = 3})
		if stage == 1:
			image = 'chloewoods'
			sprite = [['chloenakedshy', 'pos1']]
			globals.charactergallery.chloe.scenes[1].unlocked = true
			text = textnode.ChloeGroveSex
			globals.main.scene(self, image, text, buttons)
			return
		elif stage == 2:
			text = textnode.ChloeGroveMasturbate
	elif stage == 3:
		closedialogue()
		globals.main.closescene()
		globals.main.exploration.zoneenter('shaliq')
		
		return
		
	
	globals.main.dialogue(state,self,text,buttons,sprite)

func chloealchemy(stage = 0):
	var buttons = []
	var text = 'As you prepare to make the required antidote, your experience says you can take advantage of the situation. Perhaps you could try adding some additional potion for differnt effect, providing you have them. '
	if stage == 0:
		buttons.append(['Make an antidote for Chloe','chloealchemy',1])
		if globals.state.getCountStackableItem('amnesiapot') >= 1:
			buttons.append({text = 'Mix antidote with amnesia potion', function = 'chloealchemy', args = 2})
		else:
			buttons.append({text = 'Mix antidote with amnesia potion', function = 'chloealchemy', args = 2, disabled = true, tooltip = 'Amnesia Potion Required'})
		if globals.state.getCountStackableItem('aphrodisiac') >= 1 && globals.state.getCountStackableItem('stimulantpot') >= 1: 
			buttons.append({text = 'Replace antidote with high grade stimulant', function = 'chloealchemy', args = 3})
		else:
			buttons.append({text = 'Replace antidote with high grade stimulant', function = 'chloealchemy', args = 3, disabled = true, tooltip = 'Aphrodisiac and Stimulant Required'})
	elif stage == 1:
		globals.state.decisions.append("chloecure")
	elif stage == 2:
		globals.state.decisions.append("chloeamnesia")
		globals.state.removeStackableItem('amnesiapot')
	elif stage == 3:
		globals.state.decisions.append("chloeaphrodisiac")
		globals.state.removeStackableItem('aphrodisiac')
		globals.state.removeStackableItem('stimulantpot')
	if stage in [1,2,3]:
		text = 'After half-hour you finish preparations and now can return back to Chloe.'
		globals.state.sidequests.chloe = 9
	globals.main.dialogue(true, self, text, buttons)


#Ayneris Side Quest
func aynerisforest(stage = 0):
	var state = false
	var text = ''
	var buttons = []
	var image
	var sprites = [['aynerispissed','pos1']]
	if stage == 0:
		if globals.state.sidequests.ayneris == 0:
			text = textnode.AynerisMeet1
		elif globals.state.sidequests.ayneris in [1,2]:
			text = textnode.AynerisMeet2
			if globals.state.sidequests.ayneris == 1:
				text += "\n\n[color=yellow]— It's him again! You thought you could get away after defeating me? This time you won't be so lucky. [/color]"
			else:
				text += "\n\n[color=yellow]— It's you, bastard! After what you did, you dare come here again? Get him! [/color]"
		buttons.append({text = 'Fight', function = 'aynerisforest', args = 1})
	elif stage == 1:
		if globals.state.sidequests.ayneris == 0:
			globals.main.exploration.buildenemies("ayneris1")
		else:
			globals.main.exploration.buildenemies("ayneris2")
		closedialogue()
		globals.main.exploration.launchonwin = 'ayneriswin'
		globals.main.get_node("combat").nocaptures = true
		globals.main.exploration.enemyfight()
		return
	elif stage == 2:
		image = 'aynerispunish'
		text = textnode.AynerisPunish1
		globals.charactergallery.ayneris.scenes[0].unlocked = true
		globals.state.sidequests.ayneris = 2
		globals.resources.mana += 10
		state = true
	elif stage == 3:
		text = textnode.AynerisLeave
		state = true
	elif stage == 4:
		image = 'aynerissex'
		text = textnode.AynerisPunish2
		globals.charactergallery.ayneris.scenes[1].unlocked = true
		globals.state.sidequests.ayneris = 3
		globals.state.upcomingevents.append({code = 'aynerisnextstage', duration = 3})
		globals.resources.mana += 15
		state = true
	if stage in [2,4]:
		buttons = [{text = "Leave", function = 'closescene'}]
		closedialogue()
		globals.main.scene(self, image, text, buttons)
		return
	globals.main.dialogue(state, self, text, buttons, sprites)

func ayneriswin():
	var state = false
	var text = ''
	var buttons = []
	var sprites = []
	globals.main.exploration.zoneenter("amberguardforest")
	if globals.state.sidequests.ayneris == 0:
		sprites = [['aynerisangry','pos1']]
		globals.charactergallery.ayneris.unlocked = true
		globals.state.sidequests.ayneris = 1
		text = textnode.AynerisWin1
		buttons.append({text = 'Punish', function = 'aynerisforest', args = 2})
		buttons.append({text = 'Leave', function = 'aynerisforest', args = 3})
	elif globals.state.sidequests.ayneris in [1,2]:
		text = textnode.AynerisWin2
		sprites = [['aynerisangry','pos1']]
		if globals.state.sidequests.ayneris == 1:
			buttons.append({text = 'Punish', function = 'aynerisforest', args = 2})
		else:
			buttons.append({text = 'Punish', function = 'aynerisforest', args = 4})
		buttons.append({text = 'Leave', function = 'aynerisforest', args = 3})
		
	globals.main.dialogue(state, self, text, buttons, sprites)

func aynerismarket(stage = 0):
	var state = true
	var text = ''
	var buttons = []
	var sprites = []
	if stage == 0:
		state = false
		text = textnode.AynerisMeet3
		sprites = [['aynerispissed','pos1']]
		buttons.append({text = 'Accept', function = 'aynerismarket', args = 1})
		buttons.append({text = 'Refuse', function = 'aynerismarket', args = 2})
	elif stage == 1:
		sprites = [['aynerisneutral','pos1']]
		text = textnode.AynerisOfferJoin
		var person = globals.characters.create("Ayneris")
		globals.slaves = person
		globals.state.sidequests.ayneris = 5
		globals.state.upcomingevents.append({code = "aynerisrapierstart", duration = 10})
	elif stage == 2:
		sprites = [['aynerisangry','pos1']]
		text = textnode.AynerisIgnore
		globals.state.sidequests.ayneris = 100
		
	globals.main.dialogue(state, self, text, buttons, sprites)

func aynerisnextstage():
	globals.state.sidequests.ayneris += 1

func aynerisrapierstart(stage = 0):
	var state = false
	var text = ''
	var ayneris
	var buttons = []
	var sprites = []
	for i in globals.slaves:
		if i.unique == 'Ayneris':
			ayneris = i
	if ayneris == null:
		globals.state.sidequests.ayneris = 100
		return
	
	
	if stage == 0:
		sprites = [['aynerispissed','pos1']]
		text = textnode.AynerisContinue
		buttons.append(['Agree','aynerisrapierstart',1])
		buttons.append(['Refuse','aynerisrapierstart',2])
	elif stage == 1:
		sprites = [['aynerisneutral','pos1']]
		text = textnode.AynerisRapierAgree
		state = true
		globals.state.sidequests.ayneris = 6
	elif stage == 2:
		sprites = [['aynerisangry', 'pos1']]
		ayneris.obed -= 50
		ayneris.loyal -= 20
		state = true
		globals.state.sidequests.ayneris = 100
		text = textnode.AynerisRapierRefuse
	
	globals.main.dialogue(state, self, text, buttons, sprites)

func aynerisrapieramberguard(stage = 0):
	var state = false
	var text = ''
	var ayneris
	var buttons = []
	var sprites = []
	for i in globals.slaves:
		if i.unique == 'Ayneris':
			ayneris = i
	if stage == 0:
		globals.state.sidequests.ayneris = 7
		sprites = [['aynerisneutral','pos1']]
		text = textnode.AynerisRapierAmberguard
		buttons.append(['Continue', 'aynerisrapieramberguard', 1])
	elif stage == 1:
		globals.main.animationfade()
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		sprites = [['aynerispissed','pos1']]
		text = textnode.AynerisRapierAmberguardCleaner
		buttons.append(['Make Ayneris expose herself','aynerisrapieramberguard',2])
		buttons.append({text = 'Give 200 gold', function = 'aynerisrapieramberguard', args = 3, disabled = globals.resources.gold < 200})
	elif stage == 2:
		sprites = [['aynerisangry','pos1']]
		text = textnode.AynerisRapierShow
		ayneris.lewdness += 10
		ayneris.lust += 20
		ayneris.obed -= 35
		buttons.append(['Continue', 'aynerisrapieramberguard', 4])
	elif stage == 3:
		sprites = [['aynerisneutral','pos1']]
		globals.resources.gold -= 200
		ayneris.obed += 25
		ayneris.loyal += 15
		text = textnode.AynerisRapierPay
		buttons.append(['Continue', 'aynerisrapieramberguard', 5])
	elif stage == 4:
		sprites = [['ayneristopless','pos1']]
		text = textnode.AynerisRapierShow2
		buttons.append(['Continue', 'aynerisrapieramberguard', 5])
	elif stage == 5:
		globals.main.animationfade()
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		sprites = [['aynerispissed','pos1']]
		text = textnode.AynerisRapierFall
		buttons.append(['Try catch her', 'aynerisrapieramberguard', 6])
		buttons.append(['Let her fall', 'aynerisrapieramberguard', 7])
	elif stage == 6:
		sprites = [['aynerispissed','pos1']]
		buttons.append(['Continue', 'aynerisrapieramberguard', 8])
		text = textnode.AynerisRapierCatch
		globals.main.shake(0.5)
	elif stage == 7:
		sprites = [['aynerisangry','pos1']]
		buttons.append(['Continue', 'aynerisrapieramberguard', 9])
		text = textnode.AynerisRapierIgnore
		globals.main.shake(0.5)
	elif stage == 8:
		ayneris.away.duration = 1
		ayneris.away.at = 'rest'
		globals.main._on_mansion_pressed()
		ayneris.stress += 25
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		state = true
		text = textnode.AynerisRapierCatchContinue
		ayneris.add_trait('Grateful')
		var item = globals.items.createunstackable('weaponaynerisrapier')
		globals.state.unstackables[str(item.id)] = item
	elif stage == 9:
		ayneris.away.duration = 1
		ayneris.away.at = 'rest'
		ayneris.stress += 40
		globals.main._on_mansion_pressed()
		if OS.get_name() != 'HTML5':
			yield(globals.main, 'animfinished')
		state = true
		var item = globals.items.createunstackable('weaponaynerisrapier')
		globals.state.unstackables[str(item.id)] = item
		text = textnode.AynerisRapierIgnoreContinue
	
	globals.main.dialogue(state, self, text, buttons, sprites)

func undercitylibrarywin():
	globals.main.exploration.undercitylibrarywin()

	
#Zoe Side Quest
func zoebookevent(stage = 0):
	var zoe = null
	var text = ''
	var buttons = []
	var state = false
	var sprite = []
	for i in globals.slaves:
		if i.unique == 'Zoe':
			zoe = i
	if zoe != null:
		if stage == 0:
			text = textnode.zoebookdiscover
			sprite = [['zoehappy','pos1','opac']]
			buttons = [['Let Zoe borrow the book', 'zoebookevent',1], ['Refuse to let Zoe translate it','zoebookevent',2]]
		elif stage == 1:
			state = true
			text = textnode.zoebookallow
			sprite = [['zoehappy','pos1']]
			globals.itemdict.zoebook.amount = 0
			globals.state.sidequests.zoe = 4
			globals.state.upcomingevents.append({code = 'zoebookproceed', duration = 4})
			zoe.away.duration = 3
			zoe.away.at = 'study'
		elif stage == 2:
			state = true
			text = textnode.zoebookrefuse
			sprite = [['zoesad','pos1']]
			globals.state.sidequests.zoe = 100
		
		globals.main.dialogue(state, self, text, buttons, sprite)

func zoebookproceed():
	var text = ''
	var buttons = []
	var state = true
	var sprite = []
	text = textnode.zoebooktimepass + "\n\n" + textnode.zoeitemlist
	sprite = [['zoehappy','pos1','opac']]
	globals.state.sidequests.zoe = 5
	globals.main.dialogue(state, self, text, buttons, sprite)

func zoepassitems(stage = 0):
	var text = ''
	var buttons = []
	var state = false
	var zoe = null
	var sprite = []
	var image
	
	for i in globals.slaves:
		if i.unique == 'Zoe':
			zoe = i
	globals.state.sidequests.zoe = 6
	globals.spelldict.summontentacle.learned = true
	if stage == 0:
		text = textnode.zoebookdeliveritems
		sprite = [['zoehappy','pos1','opac']]
		buttons.append(['Continue', 'zoepassitems', 1])
	elif stage == 1:
		image = 'zoetentacle1'
		globals.main.animationfade(1,0.5)
		yield(globals.main, "animfinished")
		globals.main.savedtrack = globals.main.get_node("music").get_meta("currentsong")
		globals.main.music_set("intimate")
		text = textnode.zoebookdelivercontinue
		sprite = [['zoesadnaked','pos1','opac']]
		buttons = [{text = 'Save Zoe', function = 'zoepassitems', args = 2},{text = 'Hold back and wait', function =  'zoepassitems', args = 3}]
	elif stage == 2:
		text = textnode.zoebooksave
		globals.main.closescene()
		text += "\n\n[color=green]Learned new spell: Summon Tentacles[/color]"
		zoe.loyal += 10
		globals.charactergallery.zoe.nakedunlocked = true
		sprite = [['zoeneutralnaked','pos1','opac']]
		state = true
	elif stage == 3:
		image = 'zoetentacle2'
		sprite = [['zoesadnaked','pos1','opac']]
		text = textnode.zoebookwatch
		globals.state.decisions.append("zoeraped")
		zoe.stress += 70
		zoe.loyal -= 25
		zoe.obed -= 60
		globals.charactergallery.zoe.scenes[0].unlocked = true
		globals.charactergallery.zoe.nakedunlocked = true
		if zoe.vagvirgin == true:
			zoe.vagvirgin = false
			text += textnode.zoebookwatch2virgin
		else:
			text += textnode.zoebookwatch2nonvirgin
		buttons = [{text = 'Continue', function  = 'zoepassitems', args = 4}]
	elif stage == 4:
		state = true
		globals.main.closescene()
		sprite = [['zoesadnaked','pos1','opac']]
		text = textnode.zoebookwatch3
		text += "\n\n[color=green]Learned new spell: Summon Tentacles[/color]"
		
	
	
	if stage in [0,2,4]:
		globals.main.dialogue(state, self, text, buttons, sprite)
	else:
		globals.main.scene(self, image, text, buttons)

func aydatimepass():
	globals.state.sidequests.ayda = 7

func aydapersonaltalk():
	var state = true
	var text
	var buttons = []
	var sprites = [['aydanormal','pos1','opac']]
	
	var ayda
	for i in globals.slaves:
		if i.unique == 'Ayda':
			ayda = i
	
	match int(globals.state.sidequests.ayda):
		9:
			text = textnode.aydareturn1
			globals.itemdict.aydabrandy.amount = 0
			ayda.loyal += 5
			ayda.obed += 10
			globals.state.sidequests.ayda = 10
		12:
			globals.itemdict.aydabook.amount = 0
			ayda.loyal += 10
			ayda.obed += 20
			text = textnode.aydareturn2
			globals.state.sidequests.ayda = 13
		15:
			globals.itemdict.aydajewel.amount = 0
			ayda.loyal += 25
			ayda.tags.erase('nosex')
			ayda.consent = true
			text = textnode.aydareturn3
			globals.state.sidequests.ayda = 16
			ayda.add_trait("Grateful")
			state = false
			buttons = [{text = 'Embrace',function = 'aydasex',args = 1},{text = 'Reject',function = 'aydasex',args = 2}]
	
	globals.main.dialogue(state, self, text, buttons, sprites)

#func aydapersonaltalk():
#	var text = ''
#	var state = true
#	var sprite = [['aydanormal','pos1','opac']]
#	var buttons = []
#
#	match globals.state.sidequests.ayda:
#		9:
#			text = textnode.aydareturn1
#			globals.state.sidequests.ayda = 10
#		12:
#			text = textnode.aydareturn2
#			globals.state.sidequests.ayda = 13
#		15:
#			text = textnode.aydareturn3
#			globals.state.sidequests.ayda = 16
#
#	if globals.state.sidequests.ayda == 15:
#		globals.main.scene(self, 'aydascene', text, buttons)
#	else:
#		globals.main.dialogue(state, self, text, buttons, sprite)
func aydasex(stage = 1):
	var state = true
	var text
	var buttons = []
	var sprites = [['aydanormal','pos1']]
	var image = 'aydasex1'
	if stage == 1:
		globals.charactergallery.ayda.scenes[0].unlocked = true
		globals.charactergallery.ayda.nakedunlocked = true
		text = textnode.aydasexscene1
		buttons = [{text = "Continue", function = 'aydasex', args = 3}]
	elif stage == 2:
		text = textnode.aydesexrefuse
	elif stage == 3:
		image = 'aydasex2'
		text = textnode.aydasexscene2
		closedialogue()
		buttons = [{text = "Close", function = 'closescene'}]
	
	if stage != 2:
		globals.main.scene(self, image, text, buttons)
	else:
		globals.main.dialogue(state, self, text, buttons, sprites)

#Starting slave quests

var ssnode = load("res://files/scripts/startslavequesttext.gd").new()

func ssinitiate(stage = 0):
	var state = true
	var text
	var buttons = []
	var sprites = []
	var startslave
	for i in globals.slaves:
		if i.unique == 'startslave':
			startslave = i
	if startslave == null:
		return
	if startslave.imagefull != null:
		if stage == 0:
			sprites = [[startslave.imagefull,'pos1','opac']]
		else:
			sprites = [[startslave.imagefull,'pos1']]
	globals.state.sidequests.startslave = 1
	
	match stage:
		0:
			text = ssnode.ssqueststart
			state = false
			buttons.append({text = startslave.dictionary("You will treat $him fairly"), function = 'ssinitiate', args = 1})
			buttons.append({text = startslave.dictionary("$He will have to follow your orders"), function = 'ssinitiate', args = 2})
			buttons.append({text = startslave.dictionary("You hope $he will be helping you"), function = 'ssinitiate', args = 3})
			buttons.append({text = startslave.dictionary("Shrug it off (disable further events)"), function = 'ssinitiate', args = 4})
		1:
			text = ssnode.ssquestresponsefair
			startslave.loyal += 10
			globals.state.decisions.append('ssfair')
		2:
			if startslave.memory == 'Servant':
				text = ssnode.ssquestresponsestrictservant
			elif startslave.memory == '$sibling':
				text = ssnode.ssquestresponsestrictsibling
			else:
				text = ssnode.ssquestresponsestrictfriend
			startslave.obed += 25
			startslave.stress += 10
			globals.state.decisions.append('ssstrict')
			
		3:
			if startslave.memory == 'Childhood Friend':
				text = ssnode.ssquestresponseweakfriend
			else:
				text = ssnode.ssquestresponseweakall
			startslave.obed -= 10
			startslave.stress -= 10
			globals.state.decisions.append('ssweak')
		4:
			text = ssnode.ssquestresponsecancel
			globals.state.decisions.append('ssignore')
			startslave.add_trait("Grateful")
			globals.state.sidequests.startslave = 100
	if !stage in [0,4]:
		globals.state.upcomingevents.append({code = 'ssmassage', duration = round(rand_range(5,9))})
	
	globals.main.dialogue(state, self, startslave.dictionary(text), buttons, sprites)

func ssmassage(stage = 0):
	var state = true
	var text
	var buttons = []
	var sprites = []
	var startslave
	for i in globals.slaves:
		if i.unique == 'startslave':
			startslave = i
	if startslave == null:
		return
	
	var textdict 
	if startslave.imagefull != null:
		if stage == 0:
			sprites = [[startslave.imagefull,'pos1','opac']]
		else:
			sprites = [[startslave.imagefull,'pos1']]
	globals.state.sidequests.startslave = 2
	
	match stage:
		0:
			state = false
			textdict = {ssfair = ssnode.ssmassagefair, ssstrict = ssnode.ssmassagestrict, ssweak = ssnode.ssmassageweak}
			for i in textdict:
				if globals.state.decisions.has(i):
					text = textdict[i]
					break
			buttons.append({text = 'Do it obediently', function = 'ssmassage', args = 1})
			buttons.append({text = 'Do it possessively', function = 'ssmassage', args = 2})
			buttons.append({text = 'Refuse', function = 'ssmassage', args = 3})
		1:
			text = ssnode.ssmassageobedient
			globals.state.decisions.append("ssmassagefair")
			startslave.loyal += 10
		2:
			if startslave.memory == '$sibling':
				text = ssnode.ssmassageroughsibling
			else:
				text = ssnode.ssmassageroughfriend
			globals.state.decisions.append("ssmassagestrict")
			startslave.obed += 20
		3:
			textdict = {ssfair = ssnode.ssmassagerefusefair, ssstrict = ssnode.ssmassagerefusestrict, ssweak = ssnode.ssmassagerefuseweak}
			startslave.obed -= 10
			for i in textdict:
				if globals.state.decisions.has(i):
					text = textdict[i]
					break
			globals.state.decisions.append("ssmassageweak")
	
	if stage != 0:
		globals.state.upcomingevents.append({code = 'sspotion', duration = 3})
	
	globals.main.dialogue(state, self, startslave.dictionary(text), buttons, sprites)

func sspotion(stage = 0):
	if globals.state.mansionupgrades.mansionalchemy == 0: #check every 3 days if alchemy room has been purchased
		globals.state.upcomingevents.append({code = 'sspotion', duration = 3})
		return
	
	var state = false
	var text
	var buttons = []
	var sprites = []
	var startslave
	for i in globals.slaves:
		if i.unique == 'startslave':
			startslave = i
	if startslave == null:
		return
	
	var textdict 
	
	if startslave.imagefull != null:
		if stage == 0:
			sprites = [[startslave.imagefull,'pos1','opac']]
		else:
			sprites = [[startslave.imagefull,'pos1']]
	globals.state.sidequests.startslave = 3
	
	match stage:
		0:
			if startslave.sex == 'male':
				text = ssnode.sspotionmale
			else:
				text = ssnode.sspotionfemale
			state = false
			buttons.append({text = 'Help out', function = 'sspotion', args = 1})
			buttons.append({text = 'Scold', function = 'sspotion', args = 2})
			buttons.append({text = 'Pass Towel and Leave', function = 'sspotion', args = 3})
		1:
			startslave.loyal += 10
			globals.state.decisions.append("sspotionfair")
			buttons.append({text = 'Continue', function = 'sspotionaftermatch', args = 0})
			if startslave.sex == 'male':
				text = ssnode.sspotionfairmale 
			else:
				text = ssnode.sspotionfairfemale 
		2:
			startslave.obed += 25
			globals.state.decisions.append("sspotionstrict")
			if startslave.sex == 'male':
				text = ssnode.sspotionstrictmale
			else:
				text = ssnode.sspotionstrictfemale
			buttons.append({text = 'Continue', function = 'sspotionaftermatch', args = 0})
		3:
			var yandere = false
			buttons.append({text = 'Continue', function = 'sspotionaftermatch', args = 0})
			globals.state.decisions.append("sspotionweak")
			if globals.state.decisions.has('ssweak') && globals.state.decisions.has("ssmassageweak"):
				yandere = true
			if yandere == false:
				text = ssnode.sspotionleave
			else:
				globals.state.decisions.append('ssyandere')
				if startslave.sex == 'male':
					text = ssnode.sspotionleaveyanderemale
				else:
					text = ssnode.sspotionleaveyanderefemale
	
	
	globals.main.dialogue(state, self, startslave.dictionary(text), buttons, sprites)

func sspotionaftermatch(stage = 0):
	var state = true
	var text
	var buttons = []
	var sprites = []
	var startslave
	for i in globals.slaves:
		if i.unique == 'startslave':
			startslave = i
	if startslave == null:
		return
	
	if startslave.imagefull != null:
		sprites = [[startslave.imagefull,'pos1','opac']]
	
	globals.main.animationfade(1.5)
	yield(globals.main, 'animfinished')
	
	var yandere = false
	if globals.state.decisions.has('ssyandere'):
		yandere = true
	
	if yandere == true:
		if startslave.sex == 'male':
			text = ssnode.sspotioncontyanderem
		else:
			text = ssnode.sspotioncontyanderef
	else:
		var weak = 0
		var strict = 0
		var fair = 0
		
		var weakdict = ['ssweak','ssmassageweak','sspotionweak']
		var fairdict = ['ssfair','ssmassagefair','sspotionfair']
		var strictdict = ['ssstrict','ssmassagestrict','sspotionstrict']
		
		
		for i in globals.state.decisions:
			if weakdict.has(i):
				weak += 1
			if fairdict.has(i):
				fair += 1
			if strictdict.has(i):
				strict += 1
		
		var character
		
		if weak >= 2:
			character = 'dominant'
		elif strict >= 2:
			character = 'submissive'
		
		if character == 'dominant':
			startslave.add_trait('Dominant')
			if startslave.sex == 'male':
				text = ssnode.sspotioncontdomm
			else:
				text = ssnode.sspotioncontdomf
		elif character == 'submissive':
			startslave.add_trait('Submissive')
			if startslave.sex == 'male':
				text = ssnode.sspotioncontsubm
			else:
				text = ssnode.sspotioncontsubf
		else:
			if startslave.sex == 'male':
				text = ssnode.sspotioncontnormm
			else:
				text = ssnode.sspotioncontnormf
	
	
	
	
	
	
	
	globals.state.upcomingevents.append({code = 'sssexscene', duration = 5})
	
	globals.main.dialogue(state, self, startslave.dictionary(text), buttons, sprites)

func sssexscene(stage = 0):
	var state = true
	var text
	var buttons = []
	var sprites = []
	var startslave
	for i in globals.slaves:
		if i.unique == 'startslave':
			startslave = i
	if startslave == null:
		return
	if startslave.imagefull != null:
		if stage == 0:
			sprites = [[startslave.imagefull,'pos1','opac']]
		else:
			sprites = [[startslave.imagefull,'pos1']]
	match stage:
		0:
			state = false
			text = ssnode.ssfinale
			buttons.append({text = 'Check in', function = 'sssexscene', args = 1})
			buttons.append({text = 'Ignore', function = 'sssexscene', args = 2})
		1:
			var playersex = globals.player.sex
			var slavesex = startslave.sex
			if playersex == 'futanari':
				playersex = 'male'
			if slavesex == 'futanari':
				slavesex = 'female'
			
			var textvar = slavesex[0] + playersex[0] #Selecting scene category
			
			var category # Selecting relationship category
			if startslave.traits.has("Dominant"):
				category = 'dom'
			elif startslave.traits.has("Submissive"):
				category = 'sub'
			elif globals.state.decisions.has("ssyandere"):
				category = 'yandere'
			else:
				category = 'neutral'
			
			var sexdict = {
				dom = {
					fm = ssnode.sssexdomfm,
					mm = ssnode.sssexdommm,
					ff = ssnode.sssexdomff,
					mf = ssnode.sssexdommf,
					},
				sub = {
					fm = ssnode.sssexsubfm,
					mm = ssnode.sssexsubmm,
					ff = ssnode.sssexsubff,
					mf = ssnode.sssexsubmf,
					},
				yandere = {
					fm = ssnode.sssexyanfm,
					mm = ssnode.sssexyanmm,
					ff = ssnode.sssexyanff,
					mf = ssnode.sssexyanmf,
					},
				neutral = {
					fm = ssnode.sssexneufm,
					mm = ssnode.sssexneumm,
					ff = ssnode.sssexneuff,
					mf = ssnode.sssexneumf,
					},
			}
			text = sexdict[category][textvar]
			startslave.add_trait("Grateful")
			startslave.loyal += 25
			startslave.obed += 20
		2:
			text = ssnode.sssexignore
	
	
	
	globals.main.dialogue(state, self, startslave.dictionary(text), buttons, sprites)

func umbraportalenc():
	var state = true
	var text = textnode.umbrateleportenc
	var buttons = []
	globals.state.portals.dragonnests = {'enabled' : true, 'code' : 'dragonnests'}
	text += "\n\n[color=yellow]New Portal unlocked[/color]"
	globals.main.dialogue(state, self, text, buttons)

func dragonbossenc():
	var state = false
	var text = textnode.dragonbossenc
	var buttons = []
	
	buttons.append({text = 'Fight', function = 'dragonbossfight'})
	globals.main.dialogue(state, self, text, buttons)

func dragonbossfight():
	closedialogue()
	globals.main.exploration.buildenemies("bossdragon")
	globals.main.exploration.launchonwin = 'dragonbosswin'
	globals.main.get_node("combat").nocaptures = true
	globals.main.exploration.enemyfight()

func dragonbosswin():
	var state = true
	var text = textnode.dragonbosswin
	var buttons = []
	globals.state.decisions.append("dragonkilled")
	globals.main.dialogue(state, self, text, buttons)
	globals.main.exploration.progress = 9
	globals.main.exploration.winscreenclear()
	globals.main.exploration.generaterandomloot([], {number = 0}, rand_range(1,3), [1,3])
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')

func cultbossenc():
	var state = false
	var text = textnode.cultbossenc
	var buttons = []
	
	buttons.append({text = 'Fight', function = 'cultbossfight'})
	globals.main.dialogue(state, self, text, buttons)

func cultbossfight():
	closedialogue()
	globals.main.music_set('combat2')
	globals.main.exploration.buildenemies("bosscultist")
	globals.main.exploration.launchonwin = 'cultbosswin'
	globals.main.get_node("combat").nocaptures = true
	globals.main.exploration.enemyfight(true)

func cultbosswin():
	var state = true
	var text = textnode.cultbosswin
	var buttons = []
	globals.state.decisions.append("cultbosskilled")
	globals.main.dialogue(state, self, text, buttons)
	globals.main.exploration.progress = 9
	globals.main.exploration.winscreenclear()
	globals.main.exploration.generaterandomloot([], {number = 0}, rand_range(1,4), [1,4])
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')

func cavelakedoor():
	var state = true
	var text = "As you make it to the other end, you find yourself at the large stone gates. There's no clear way to open it right now, so you should try to scout another area. "
	var buttons = []
	globals.main.dialogue(state, self, text, buttons)

func finalbossenc(stage = 0):
	var state = false
	var text = textnode.finalbossenc
	var buttons = []
	match stage:
		0:
			if !globals.state.decisions.has("joindarkness"):
				buttons.append({text = 'Ask about its nature', function = 'finalbossenc', args = 1})
				buttons.append({text = 'Try to negotiate', function = 'finalbossenc', args = 2})
				buttons.append({text = 'Fight', function = 'finalbossenc', args = 5})
			else:
				text = 'You can sacrifice your party to gain more power. '
				if globals.state.playergroup.size() >= 1:
					buttons.append({text = 'Sacrifice your party', function = 'finalbossenc', args = 7})
				buttons.append({text = 'Leave', function = 'finalbossenc', args = 6})
		1:
			text = textnode.finalbosstalk
			buttons.append({text = 'Try to negotiate', function = 'finalbossenc', args = 2})
			buttons.append({text = 'Fight', function = 'finalbossenc', args = 5})
		2:
			text = textnode.finalbossnegotiate
			buttons.append({text = 'Accept', function = 'finalbossenc', args = 3})
			buttons.append({text = 'Refuse', function = 'finalbossenc', args = 4})
		3:
			text = textnode.finalbossnegotiateaccept
			var names = ''
			var counter = 0
			for i in globals.state.playergroup:
				var _slave = globals.state.findslave(i)
				_slave.removefrommansion()
				names += _slave.name_short()
				counter += 1
				if globals.state.playergroup.size() == counter+1:
					names += ' and '
				elif globals.state.playergroup.size() > counter:
					names += ', '
			globals.state.playergroup.clear()
			globals.main.get_node("outside").playergrouppanel()
			globals.state.decisions.append('joindarkness')
			text = text.replace('[names]', names)
			while counter > 0:
				for i in ['str','agi','maf','end']:
					globals.player.stats[i+'_base'] += 1
				counter -= 1
			buttons.append({text = 'Leave', function = 'finalbossenc', args = 6})
		4:
			text = textnode.finalbossnegotiaterefuse
			buttons.append({text = 'Ask about its nature', function = 'finalbossenc', args = 1})
			buttons.append({text = 'Fight', function = 'finalbossenc', args = 5})
		5:
			text = textnode.finalbossfight
			buttons.append({text = 'Fight', function = 'finalbossfight'})
		6:
			closedialogue()
			return
		7:
			var counter = 0
			var names = ''
			text = "After sacrificing your party, your power grows again. "
			for i in globals.state.playergroup:
				var _slave = globals.state.findslave(i)
				_slave.removefrommansion()
				names += _slave.name_short()
				counter += 1
				if globals.state.playergroup.size() == counter+1:
					names += ' and '
				elif globals.state.playergroup.size() > counter:
					names += ', '
			globals.state.playergroup.clear()
			globals.main.get_node("outside").playergrouppanel()
			while counter > 0:
				for i in ['str','agi','maf','end']:
					globals.player.stats[i+'_base'] += 1
				counter -= 1
			buttons.append({text = 'Leave', function = 'finalbossenc', args = 6})
		
		
	globals.main.dialogue(state, self, text, buttons)

func finalbossfight():
	closedialogue()
	globals.main.music_set('combat2')
	globals.main.exploration.buildenemies("finalboss")
	globals.main.exploration.launchonwin = 'finalbosswin'
	globals.main.get_node("combat").nocaptures = true
	globals.main.exploration.enemyfight(true)

func finalbosswin():
	var state = true
	var text = textnode.finalbosswin
	var buttons = []
	globals.state.decisions.append('darknessdefeated')
	globals.main.dialogue(state, self, text, buttons)
	globals.main.exploration.generaterandomloot([], {number = 0}, rand_range(2,5), [2,5])
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')
	globals.main.exploration.generateloot([globals.weightedrandom(bossloot), 1], '')

func randombossdrop():
	var item = globals.weightedrandom(bossloot)
	return item

var bossloot = [["armorplate+",1],['weaponsword+',1],['weaponclaymore+',1],['weaponcursedsword',1],['weaponhammer+',1], ['weaponkatana+',1],['weaponshortsword+',1],['armorcarapace',1],['armorredcloak',1], ['accessoryneck+',1],['armorrogue',1],['armortentacle',1], ['weaponelvensword+', 1] ]

