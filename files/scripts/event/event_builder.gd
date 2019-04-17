####Ku-Ku-Ku-Kurapanda!!!
#### EventBuilder - Workspace for event creation and testing
#
####Resources
#const Quest = preload("res://files/scripts/event/quest.gd")
#
####Variables
#var buildQuest
#var mainquestTexts
#var sidequestTexts
#
#
####Public Functions
#func quest_maker(questName): 
#	#Load quest text files
#	var questTextFile = File.new()
#
#	questTextFile.open("res://files/data/quest/text/mainquest_text.json", File.READ)
#	mainquestTexts = JSON.parse(questTextFile.get_as_text()).result
#	questTextFile.close()
#
#	questTextFile.open("res://files/data/quest/text/sidequest_text.json", File.READ)
#	sidequestTexts = JSON.parse(questTextFile.get_as_text()).result
#	questTextFile.close()
#
#	#Build Quest
#	match questName:
#		'emily':
#			_quest_maker_emily()
#		'tisha':
#			_quest_maker_tisha()
#
#	return buildQuest
#
#func quest_loader():
#	### Load Emily Quest
#	var emilyQuestFile = File.new()
#	emilyQuestFile.open("res://files/data/quest/emilyQuest.json", File.READ)
#
#	var emilyQuestDict = JSON.parse(emilyQuestFile.get_as_text()).result
#	emilyQuestFile.close()
#	buildQuest.from_dict(emilyQuestDict)
#
#	return buildQuest
#
#
##Emily Quest Maker
#func _quest_maker_emily():
#	### Create Quest Event
#	buildQuest = Quest.new()
#	buildQuest.uid = 'emily'
#	buildQuest.state = {stage = 0, branch = -1}
#
#	#Add meetEmilyEvent
#	var emilyEvent = _quest_maker_emily_01()
#	buildQuest.add_event(emilyEvent)
#
#	#Add emilyMansionEvent
#	emilyEvent = _quest_maker_emily_02()
#	buildQuest.add_event(emilyEvent)
#
#	#Add emilyEscapeEvent
#	emilyEvent = _quest_maker_emily_03()
#	buildQuest.add_event(emilyEvent)
#
#
#
#	#Convert quest to json file
#	var sidequestFile = File.new()
#	sidequestFile.open("res://files/data/quest/emilyQuest.json", File.WRITE)
#	sidequestFile.store_string(JSON.print(buildQuest.to_dict(), "    "))
#	sidequestFile.close()
#
#func _quest_maker_emily_01():
#	#Create meetEmilyEvent
#	var meetEmilyEvent = Quest.Event.new()
#	var reqs = {'sidequests' : {'emily' : {'state': {'stage' : 0, 'branch' : -1}}}}
#	meetEmilyEvent.name = 'meetEmily'
#	meetEmilyEvent.startType = 'hook'
#	meetEmilyEvent.activateChance = 100
#	meetEmilyEvent.place = {region = 'wimborn', area = 'wimbornCity', location = 'backstreets'}
#	meetEmilyEvent.requirements = reqs
#
#	#Create start action
#	var meetEmilyAction = Quest.Event.EventAction.new()
#	meetEmilyAction.text = "You see an urchin girl trying to draw your attention"
#	meetEmilyAction.add_button("Respond to the urchin girl", '1.meet', {'requirements' : {}, 'result' : {}})	
#	meetEmilyEvent.add_action('start', meetEmilyAction)
#
#	#Add Step01, '1.meet' action
#	meetEmilyAction = Quest.Event.EventAction.new()
#	meetEmilyAction.text = sidequestTexts.emilyQuest.EmilyMeet
#	meetEmilyAction.sprites.append(['emilynormal','pos1','opac'])
#	meetEmilyAction.add_button("Give her food", '2.foodGiven', {'requirements' : {'resources' : {'food' : 10}}, 'result' : {'resources' : {'food' : -10}, 'progress' : {'gallery' : {'emily' : {'unlock' : 'basic'}}}}})
#	meetEmilyAction.add_button("Shoo her away", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 5, 'branch' : -1}}}}})
#	meetEmilyAction.add_button("Make an excuse and tell her you'll bring some later", 'reset', {'requirements' : {}, 'result' : {}})
#	meetEmilyEvent.add_action('1.meet', meetEmilyAction)
#
#	#Step02, '2.foodGiven'
#	meetEmilyAction = Quest.Event.EventAction.new()
#	meetEmilyAction.text = sidequestTexts.emilyQuest.EmilyFeed
#	meetEmilyAction.sprites.append(['emilynormal','pos1'])
#	meetEmilyAction.add_button("Offer to take her as a servant", '3.emilyTake', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state': {'stage' : 3, 'branch' : -1}}}, 'world' : {'addSlaves' :[{'id': {'unique' : 'Emily'}}], 'scheduleEvent' : {'tishaappearance' : 7}}}})
#	meetEmilyAction.add_button("Leave her alone", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 5, 'branch' : -1}}}}})
#	meetEmilyEvent.add_action('2.foodGiven', meetEmilyAction)
#
#	#Step03, '3.emilyTake'
#	meetEmilyAction = Quest.Event.EventAction.new()
#	meetEmilyAction.text = sidequestTexts.emilyQuest.EmilyTake
#	meetEmilyAction.sprites.append(['emilyhappy','pos1'])
#	meetEmilyAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {}})
#	meetEmilyEvent.add_action('3.emilyTake', meetEmilyAction)
#
#	return meetEmilyEvent
#
#func _quest_maker_emily_02():
#	#Create emilyMansionEvent
#	var emilyMansionEvent = Quest.Event.new()
#	var reqs = {'sidequests' : {'emily' : {'state' : {stage = 3, branch = -1}}}}
#	emilyMansionEvent.name = 'emilyMansion'
#	emilyMansionEvent.startType = 'trigger'
#	emilyMansionEvent.activateChance = 100
#	emilyMansionEvent.place = {region = 'any', area = 'mansion', location = 'foyer'}
#	emilyMansionEvent.requirements = reqs
#
#	#Create start action
#	var emilyMansionAction = Quest.Event.EventAction.new()
#	emilyMansionAction.text = sidequestTexts.emilyQuest.EmilyMansion
#	emilyMansionAction.sprites.append(['emilynormal','pos1','opac'])
#
#	var peopleMods = [{'id' : {'unique': 'emily'}, 'consent' : true, 'tags' : {'nosex' : 'erase'}, 'virgin' : {'vagina' : false}, 'metrics' : {'orgasm' : 1, 'vag' : 1, 'partners' : ['player']}, 'meters' : {'stress' : 50, 'loyal' : 15, 'lust' : 50}}]
#	emilyMansionAction.add_button("Spike her with aphrodisiac", '1.aphrodisiac', {'requirements' : {'items' : {'aphrodisiac' : 1}}, 'result' : {'items' : {'aphrodisiac' : -1}, 'progress' : {'decisions' : ['emilyseduced'], 'people' : peopleMods, 'gallery' : {'emily' : {'unlock' : 'naked', 'scenes' : 0}}}}})
#
#	peopleMods = [{'id' : {'unique': 'emily'}, 'consent' : true, 'tags' : {'nosex' : 'erase'}, 'virgin' : {'vagina' : false}, 'metrics' : {'vag' : 1, 'partners' : ['player']}, 'meters' : {'stress' : 100, 'obedience' : -100}}]
#	emilyMansionAction.add_button("Assault her after bath", '1.sexAssault', {'requirements' : {}, 'result' : {'progress' : {'decisions' : ['emilyseduced'], 'people' : peopleMods, 'gallery' : {'emily' : {'unlock' : 'naked', 'scenes' : 1}}, 'world' : {'scheduleEvent' : {'emilyEscape' : 2}}}}})
#	emilyMansionAction.add_button("Wait patiently", '1.wait', {'requirements' : {}, 'result' : {}})
#	emilyMansionEvent.add_action('start', emilyMansionAction)
#
#	#Step01, '1.aphrodisiac'
#	emilyMansionAction = Quest.Event.EventAction.new()
#	emilyMansionAction.actionType = 'scene'
#	emilyMansionAction.text = sidequestTexts.emilyQuest.EmilyShowerSex
#	emilyMansionAction.image = 'emilyshower'
#	emilyMansionAction.sprites.append(['emilynakedhappy','pos1'])
#	emilyMansionAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 6, 'branch' : -1}}}}})
#	emilyMansionEvent.add_action('1.aphrodisiac', emilyMansionAction)	
#
#	#Step01, '1.sexAssault'
#	emilyMansionAction = Quest.Event.EventAction.new()
#	emilyMansionAction.actionType = 'scene'
#	emilyMansionAction.text = sidequestTexts.emilyQuest.EmilyShowerRape
#	emilyMansionAction.image = 'emilyshowerrape'
#	emilyMansionAction.sprites.append(['emilynakedneutral','pos1'])
#	emilyMansionAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 6, 'branch' : -1}}}}})	
#	emilyMansionEvent.add_action('1.sexAssault', emilyMansionAction)
#
#	#Step01, '1.wait'
#	emilyMansionAction = Quest.Event.EventAction.new()	
#	emilyMansionAction.text = sidequestTexts.emilyQuest.EmilyShowerWait	
#	emilyMansionAction.sprites.append(['emily2happy','pos1','opac'])
#	emilyMansionAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 6, 'branch' : -1}}}}})	
#	emilyMansionEvent.add_action('1.wait', emilyMansionAction)
#
#	return emilyMansionEvent
#
#func _quest_maker_emily_03():
#	#Create emilyEscapeEvent
#	var emilyEscapeEvent = Quest.Event.new()
#	var reqs = {}
#	emilyEscapeEvent.name = 'emilyEscape'
#	emilyEscapeEvent.startType = 'schedule'
#	emilyEscapeEvent.activateChance = 100
#	emilyEscapeEvent.place = {region = 'any', area = 'mansion', location = 'foyer'}
#	emilyEscapeEvent.requirements = reqs
#
#	#Create start action
#	var emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.actionType = 'decision'
#	emilyEscapeAction.add_node({'eventState' : '1.headslave', 'meta' : {'requirements' : {'world' : {'staff' : {'hasHeadslave' : true}}}, 'result' : {}}})
#	emilyEscapeAction.add_node({'eventState' : '1.noHeadslave', 'meta' : {'requirements' : {}, 'result' : {}}})	
#	emilyEscapeEvent.add_action('start', emilyEscapeAction)
#
#	#Add Step01, '1.headslave'
#	emilyEscapeAction = Quest.Event.EventAction.new()	
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeHeadslave
#	var peopleMods = [{'id' : {'unique' :'emily'}, 'meters' : {'stress' : 25, 'loyal' : 10, 'health' : -10}}]
#	emilyEscapeAction.add_button("Activate Emily's brand", '2.brandSuccess', {'requirements' : {'resources' : {'mana' : 10}, 'people' : [{'id' : {'unique' : 'emily'}, 'brand' : 'any'}]}, 'result' : {'resources' : {'mana' : -10}, 'people' : peopleMods}})	
#	emilyEscapeAction.add_button("Chase after her", '2.headChase')
#	emilyEscapeEvent.add_action('1.headslave', emilyEscapeAction)
#
#	#Add Step02, '2.brandSuccess'
#	emilyEscapeAction = Quest.Event.EventAction.new()	
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeBrandSuccess
#	emilyEscapeAction.add_button("Approach the Gardens", '3.gardenCapture')
#	emilyEscapeEvent.add_action('2.brandSuccess', emilyEscapeAction)
#
#	#Add Step03, '3.gardenCapture'
#	emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeGardenCapture
#	emilyEscapeAction.add_button("Close", 'finish')
#	emilyEscapeEvent.add_action('3.gardenCapture', emilyEscapeAction)
#
#	#Add Step02, '2.headChase'
#	emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeHeadChase
#	emilyEscapeAction.add_button("Cautiously follow after the duo...", '3.headCapture')
#	emilyEscapeEvent.add_action('2.headChase', emilyEscapeAction)
#
#	#Add Step03, '3.headCapture'
#	emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeHeadCapture
#	emilyEscapeAction.add_button("Close", 'finish')
#	emilyEscapeEvent.add_action('3.headCapture', emilyEscapeAction)
#
#	#Add Step01, '1.noHeadslave'
#	emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeNoHeadslave
#	emilyEscapeAction.add_button("Activate Emily's brand [10 mana]", '2.brandEscape', {'requirements' : {'resources' : {'mana' : 10}, 'people' : [{'id' : {'unique' : 'emily'}, 'brand' : 'any'}]}, 'result' : {'resources' : {'mana' : -10}}})
#	emilyEscapeAction.add_button("Search within the Manor", '2.searchManorClue', {'requirements' : {}, 'result' : {}})
#	emilyEscapeAction.add_button("Search the Courtyard", '2.searchCourtyard', {'requirements' : {}, 'result' : {}})
#	emilyEscapeAction.add_button("Search the Gardens", '2.searchGardens')
#	emilyEscapeEvent.add_action('1.noHeadslave', emilyEscapeAction)
#
#	#Add Step02, '2.brandEscape'
#	emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeBrandEscape
#	emilyEscapeAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'world' : {'removeSlaves' : [{'id': {'unique' : 'Emily'}}]}}})
#	emilyEscapeEvent.add_action('2.brandEscape', emilyEscapeAction)
#
#	#Add Step02, '2.searchManorClue'
#	emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeSearchManorClue
#	emilyEscapeAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'world' : {'removeSlaves' : [{'id': {'unique' : 'Emily'}}]}}})
#	emilyEscapeEvent.add_action('2.searchManorClue', emilyEscapeAction)
#
#	#Add Step02, '2.searchCourtyard'
#	emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeSearchCourtyard
#	emilyEscapeAction.add_button("Rush to rear Gardens", '2.searchGardens')
#	emilyEscapeEvent.add_action('2.searchCourtyard', emilyEscapeAction)
#
#	#Add Step02, '2.searchGardens'
#	emilyEscapeAction = Quest.Event.EventAction.new()
#	emilyEscapeAction.text = sidequestTexts.emilyQuest.EscapeSearchGardens
#	emilyEscapeAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'people' : [{'id' : {'unique' : 'emily'}, 'meters' : {'obedience' : 20}}]}})
#	emilyEscapeEvent.add_action('2.searchGardens', emilyEscapeAction)
#
#	return emilyEscapeEvent
#
#func _quest_maker_emily_04():
#	#Create emilyReturnsEvent
#	var emilyReturnsEvent = Quest.Event.new()
#	var reqs = {}
#	emilyReturnsEvent.name = 'emilyReturns'
#	emilyReturnsEvent.startType = 'schedule'
#	emilyReturnsEvent.activateChance = 100
#	emilyReturnsEvent.place = {region = 'any', area = 'mansion', location = 'foyer'}
#	emilyReturnsEvent.requirements = reqs
#
#	#Create start action
#	var emilyReturnsAction = Quest.Event.EventAction.new()
#	emilyReturnsAction.actionType = 'decision'
#	emilyReturnsAction.add_node({'eventState' : '1.noHelp', 'meta' : {'requirements' : {}, 'result' : {}}})
#	emilyReturnsAction.add_node({'eventState' : '1.helped', 'meta' : {'requirements' : {'sidequest' : {'emilyQuest' : {'stage' : 11, 'branch' : -1}}}, 'result' : {}}})
#	emilyReturnsEvent.add_action('start', emilyReturnsAction)
#
#	#Step01, '1.noHelp'
#	emilyReturnsAction = Quest.Event.EventAction.new()
#	emilyReturnsAction.actionType = 'dialogue'
#	emilyReturnsAction.text = sidequestTexts.emilyQuest.EmilyReturns_NoHelp
#	emilyReturnsAction.sprites = [['emily2happy','pos1','opac']]
#	emilyReturnsAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'world' : {'scheduleEvent' : {'tishaDisappears' : [9,14]}}, 'people' : [{'id' : {'unique' : 'emily'}, 'traits' : {'grateful' : 'add'}, 'away' : {'at' : 'none', 'duration' : 0}, 'meters' : {'loyal' : 10, 'obed' : 80}}]}})
#	emilyReturnsEvent.add_action('1.noHelp', emilyReturnsAction)
#
#	#Step01, '1.helped'
#	emilyReturnsAction = Quest.Event.EventAction.new()
#	emilyReturnsAction.actionType = 'dialogue'
#	emilyReturnsAction.text = sidequestTexts.emilyQuest.EmilyReturns_Helped
#	emilyReturnsAction.sprites = [['emily2happy','pos1','opac']]
#	emilyReturnsAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'world' : {'scheduleEvent' : {'tishaDisappears' : [9,14]}}, 'people' : [{'id' : {'unique' : 'emily'}, 'traits' : {'grateful' : 'add'}, 'away' : {'at' : 'none', 'duration' : 0}, 'meters' : {'loyal' : 10, 'obed' : 80}}]}})
#	emilyReturnsEvent.add_action('1.helped', emilyReturnsAction)
#
#	return emilyReturnsEvent
#
#
#
#
#
#
##Tisha Quest Maker
#func _quest_maker_tisha():
#	### Create Quest Event
#	buildQuest = Quest.new()
#	buildQuest.uid = 'tisha'
#	buildQuest.state = {stage = 0, branch = -1}
#
#	#Add tishaAppearanceEvent
#	var tishaEvent = _quest_maker_tisha_01()	
#	buildQuest.add_event(tishaEvent)
#
#	#Add tishaDisappearsEvent
#	tishaEvent = _quest_maker_tisha_02()
#	buildQuest.add_event(tishaEvent)
#
#	#Add tishaMageOrderEvent
#	tishaEvent = _quest_maker_tisha_03()
#	buildQuest.add_event(tishaEvent)
#
#	#Add tishaBackstreetsEvent
#	tishaEvent = _quest_maker_tisha_04()
#	buildQuest.add_event(tishaEvent)
#
#	#Add tishaGornGuildEvent
#	tishaEvent = _quest_maker_tisha_05()
#	buildQuest.add_event(tishaEvent)
#
#	#Add tishaRepaysDebtEvent
#	tishaEvent = _quest_maker_tisha_06()
#	buildQuest.add_event(tishaEvent)
#
#	#Add tishaPaymentEvent
#	tishaEvent = _quest_maker_tisha_07()
#	buildQuest.add_event(tishaEvent)
#
#	#Add tishaEmilySexEvent
#
#
#	#Convert quest to json file
#	var sidequestFile = File.new()
#	sidequestFile.open("res://files/data/quest/tishaQuest.json", File.WRITE)
#	sidequestFile.store_string(JSON.print(buildQuest.to_dict(), "    "))
#	sidequestFile.close()
#
#func _quest_maker_tisha_01():
#	#Create tishaAppearanceEvent
#	var tishaAppearanceEvent = Quest.Event.new()
#	var reqs = {'sidequests' : {'tisha': {'state' : {'stage' : 0, 'branch' : -1}}}}
#	tishaAppearanceEvent.name = 'tishaAppearance'
#	tishaAppearanceEvent.startType = 'schedule'
#	tishaAppearanceEvent.activateChance = 100
#	tishaAppearanceEvent.place = {region = 'any', area = 'mansion', location = 'foyer'}
#	tishaAppearanceEvent.requirements = reqs
#
#	#Create start action
#	var tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'decision'
#	tishaAppearanceAction.add_node({'eventState' : '1.hasEmily', 'meta' : {'requirements' : {'people' : [{'id' : {'unique' : 'emily'}}]}, 'result' : {}}})
#	tishaAppearanceAction.add_node({'eventState' : 'finish', 'meta' : {'requirements' : {}, 'result' : {}}})
#	tishaAppearanceEvent.add_action('start', tishaAppearanceAction)
#
#	#Step01, '1.hasEmily'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = 'frog'#sidequestTexts.tishaQuest.MeetTisha
#	tishaAppearanceAction.sprites = [['emily2normal','pos2','opac2'],['tishaangry','pos1','opac']]
#	tishaAppearanceAction.add_button("Continue", '2.emilyCondition', {requirements = {}, result = {'progress' : {'gallery' : {'id' : {'unique' : 'Tisha'}, 'unlock' : true}}}})
#	tishaAppearanceEvent.add_action('1.hasEmily', tishaAppearanceAction)
#
#	#Step02, '2.emilyCondition'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'decision'	
#	tishaAppearanceAction.add_node({'eventState' : '3.loyalEmily', 'meta' : {'requirements' : {'people' : [{'id' : {'unique' : 'emily'}, 'meters' : {'loyal' : {'value' : 25}}}]}, 'result' : {}}})
#	tishaAppearanceAction.add_node({'eventState' : '3.brandedEmily', 'meta' : {'requirements' : {'people' : [{'id' : {'unique' : 'emily'}, 'brand' : 'any', 'meters' : {'loyal' : {'value' : 25, 'compare' : '<'}}}]}, 'result' : {}}})
#	tishaAppearanceAction.add_node({'eventState' : '3.disloyalEmily', 'meta' : {'requirements' : {'people' : [{'id' : {'unique' : 'emily'}}]}, 'result' : {}}})	
#	tishaAppearanceEvent.add_action('2.emilyCondition', tishaAppearanceAction)
#
#	#Step03, '3.loyalEmily'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_EmilyLoyal
#	tishaAppearanceAction.sprites = [['emily2happy','pos2','opac2'],['tishashocked','pos1','opac']]
#	tishaAppearanceAction.add_button("Tell Emily to leave", '4.choseEmilyLeave')
#	tishaAppearanceAction.add_button("Make Emily stay", '4.choseEmilyStay')
#	tishaAppearanceEvent.add_action('3.loyalEmily', tishaAppearanceAction)
#
#	#Step04, '4.choseEmilyLeave'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_ChoseEmilyLeave
#	tishaAppearanceAction.sprites = [['emily2normal','pos2'],['tishaangry','pos1']]
#	tishaAppearanceAction.add_button("Let them leave", '5.emilyLeave')
#	tishaAppearanceAction.add_button("Help them with gold[50] and provisions[50]", '5.emilyLeaveHelp', {requirements = {'resources' : {'gold' : 50, 'food' : 50}}, result = {'resources' : {'gold' : -50, 'food' : -50}}})
#	tishaAppearanceEvent.add_action('4.choseEmilyLeave', tishaAppearanceAction)
#
#	#Step05, '5.emilyLeave'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_EmilyLeave
#	tishaAppearanceAction.sprites = [['emily2normal','pos2'],['tishaangry','pos1']]
#	tishaAppearanceAction.add_button("Close", '6.emilyAwayOrGone')
#	tishaAppearanceEvent.add_action('5.emilyLeave', tishaAppearanceAction)
#
#	#Step06, '6.emilyAwayOrGone'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'decision'
#	tishaAppearanceAction.add_node({'eventState' : 'finish', 'meta' : {'requirements' : {'people' : [{'id' : {'unique' : 'emily'}, 'meters' : {'loyal' : {'value' : 25}}}]}, 'result' : {'people' : [{'id' : {'unique' : 'emily'}, 'away' : {'at' : 'hidden', 'duration' : -1}, 'meters' : {'obed' : -20}}], 'world' : {'scheduleEvent' : {'emilyReturns' : 5}}, 'sidequests' : {'emily' : {'state' : {'stage' : 10, 'branch' : -1}}}}}})
#	tishaAppearanceAction.add_node({'eventState' : 'finish', 'meta' : {'requirements' : {}, 'result' : {'world' : {'removeSlaves' : [{'id' : {'unique' : 'emily'}}]}}}})
#	tishaAppearanceEvent.add_action('6.emilyAwayOrGone', tishaAppearanceAction)
#
#	#Step05, '5.emilyLeaveHelp'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_EmilyLeaveHelp
#	tishaAppearanceAction.sprites = [['emily2normal','pos2'],['tishaneutral','pos1']]
#	tishaAppearanceAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'people' : [{'id' : {'unique' : 'emily'}, 'away' : {'at' : 'hidden', 'duration' : -1}, 'meters' : {'loyal' : 15}}], 'world' : {'scheduleEvent' : {'emilyReturns' : 5}, 'reputation' : {'wimborn' : 5}}, 'sidequests' : {'emily' : {'state' : {'stage' : 11, 'branch' : -1}}}}})
#	tishaAppearanceEvent.add_action('5.emilyLeavelHelp', tishaAppearanceAction)
#
#	#Step04, '4.choseEmilyStay'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_ChoseEmilyStay
#	tishaAppearanceAction.sprites = [['emily2happy','pos2','opac2'],['tishashocked','pos1','opac']]
#	tishaAppearanceAction.add_button("Close", 'finish')
#	tishaAppearanceEvent.add_action('4.choseEmilyStay', tishaAppearanceAction)	
#
#	#Step03, '3.brandedEmily'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_EmilyBranded
#	tishaAppearanceAction.sprites = [['emily2normal','pos2','opac2'],['tishaangry','pos1','opac']]
#	tishaAppearanceAction.add_button("Release Emily", '4.brandedLeave')
#	tishaAppearanceAction.add_button("Keep Emily", '4.brandedKeep')
#	tishaAppearanceAction.add_button("Make an offer: Tisha may take Emily's place", '4.brandedSwap', {'requirements' : {}, 'result' : {'progress' : {'gallery' : {'tisha' : {'unlock' : 'naked', 'scenes' : 0}}}}, 'world' : {'addSlaves' : [{'id' : {'unique' : 'tisha'}}]}, 'resources' : {'mana' : 15}})
#	tishaAppearanceEvent.add_action('3.brandedEmily', tishaAppearanceAction)
#
#	#Step04, '4.brandedLeave'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_BrandedLeave
#	tishaAppearanceAction.sprites = [['emily2normal','pos2'],['tishaangry','pos1']]
#	tishaAppearanceAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'world' : {'removeSlaves' : [{'id' : {'unique': 'emily'}}]}}})
#	tishaAppearanceEvent.add_action('4.brandedLeave', tishaAppearanceAction)
#
#	#Step04, '4.brandedKeep'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_BrandedKeep
#	tishaAppearanceAction.sprites = [['emily2normal','pos2'],['tishaangry','pos1']]
#	tishaAppearanceAction.add_button("Close", 'finish')
#	tishaAppearanceEvent.add_action('4.brandedKeep', tishaAppearanceAction)
#
#	#Step04, '4.brandedSwap'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'scene'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_BrandedSwap
#	tishaAppearanceAction.sprites = [['tishanakedneutral','pos1']]
#	tishaAppearanceAction.image = 'tishatable'
#	tishaAppearanceAction.add_button("Go with your word and release Emily", '5.brandedSwapHonored', {'requirements' : {}, 'result' : {'progress' : {'decisions' : ['emilyreleased']}, 'world' : {'reputation' : {'wimborn' : -10}, 'removeSlaves' : [{'id' : {'unique': 'emily'}}]}, 'people' : [{'id' : {'unique' : 'tisha'}, 'meters' : {'obed' : 50}}]  }})
#	tishaAppearanceAction.add_button("Keep Emily anyway", '5.brandedKeepBoth', {'requirements' : {}, 'result' : {'progress' : {'decisions' : ['tishaemilytricked']}, 'world' : {'reputation' : {'wimborn' : -20}}, 'people' : [{'id' : {'unique' : 'emily'}, 'effects' : [{'code' : 'captured', 'duration' : 15}], 'tags' : {'nosex' : 'erase'}, 'meters' : {'loyal' : -100, 'obed' : -50}}, {'id' : {'unique' : 'tisha'}, 'meters' : {'obed' : -75}}]}})
#	tishaAppearanceEvent.add_action('4.brandedSwap', tishaAppearanceAction)
#	##### TOOOO FIIIIX - Connect Relatives Emily & Tisha should be in custom character creation (check for existence of relative) - globals.connectrelatives(person, emily, 'sibling')
#
#	#Step05, '5.brandedSwapHonored'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_BrandedSwapHonored
#	tishaAppearanceAction.sprites = [['emily2normal','pos2'],['tishaneutral','pos1']]
#	tishaAppearanceAction.add_button("Close", 'finish')
#	tishaAppearanceEvent.add_action('5.brandedSwapHonored', tishaAppearanceAction)
#
#	#Step05, '5.brandedKeepBoth'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_BrandedKeepBoth	
#	tishaAppearanceAction.sprites = [['tishashocked','pos1']]	
#	tishaAppearanceAction.add_button("Close", 'finish')
#	tishaAppearanceEvent.add_action('5.brandedKeepBoth', tishaAppearanceAction)	
#
#	#Step03, '3.disloyalEmily'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_EmilyDisloyal
#	tishaAppearanceAction.sprites = [['emily2normal','pos2','opac2'],['tishaangry','pos1','opac']]
#	tishaAppearanceAction.add_button("Let them leave", '5.emilyLeave', {requirements = {}, result = {}})
#	tishaAppearanceAction.add_button("Help them with gold[50] and provisions[50]", '5.emilyLeaveHelp', {requirements = {'resources' : {'gold' : 50, 'food' : 50}}, result = {'resources' : {'gold' : -50, 'food' : -50}}})
#	tishaAppearanceAction.add_button("Discuss compensation for returning Emily", '4.disloyalCompensation', {requirements = {}, result = {}})
#	tishaAppearanceEvent.add_action('3.disloyalEmily', tishaAppearanceAction)
#
#	#Step04, '4.disloyalCompensation'
#	tishaAppearanceAction = Quest.Event.EventAction.new()
#	tishaAppearanceAction.actionType = 'dialogue'
#	tishaAppearanceAction.text = sidequestTexts.tishaQuest.MeetTisha_Compensation
#	tishaAppearanceAction.sprites = [['tishaangry','pos1']]
#	tishaAppearanceAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'progress' : {'decisions' : ['tishatricked']}, 'world' : {'removeSlaves' : [{'id' : {'unique' : 'emily'}}]}, 'resources' : {'mana' : 15}}})
#	tishaAppearanceEvent.add_action('4.disloyalCompensation', tishaAppearanceAction)
#
#	return tishaAppearanceEvent
#
#func _quest_maker_tisha_02():
#	#Create tishaDisappearsEvent
#	var tishaDisappearsEvent = Quest.Event.new()
#	var reqs = {}
#	tishaDisappearsEvent.name = 'tishaDisappears'
#	tishaDisappearsEvent.startType = 'schedule'
#	tishaDisappearsEvent.activateChance = 100
#	tishaDisappearsEvent.place = {region = 'any', area = 'mansion', location = 'foyer'}
#	tishaDisappearsEvent.requirements = reqs
#
#	#Create start action
#	var tishaDisappearsAction = Quest.Event.EventAction.new()
#	tishaDisappearsAction.actionType = 'decision'
#	tishaDisappearsAction.add_node({'eventState' : '1.tishaDisappears', 'meta' : {'requirements' : {'people' : [{'id' : {'unique' : 'emily'}}]}, 'result' : {}}})
#	tishaDisappearsAction.add_node({'eventState' : 'finish', 'meta' : {'requirements' : {}, 'result' : {}}})
#	tishaDisappearsEvent.add_action('start', tishaDisappearsAction)
#
#	#Step01, '1.tishaDisappears'
#	tishaDisappearsAction = Quest.Event.EventAction.new()
#	tishaDisappearsAction.actionType = 'dialogue'
#	tishaDisappearsAction.text = sidequestTexts.tishaQuest.TishaDisappears
#	tishaDisappearsAction.sprites = [['emily2worried','pos1','opac']]
#	tishaDisappearsAction.add_button("Agree to help", '2.help', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 12, 'branch' : -1}}}, 'people' : [{'id' : {'unique' : 'emily'}, 'meters' : {'loyal' : 15, 'obed' : 20}}]}})
#	tishaDisappearsAction.add_button("Deny", '2.deny', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 100, 'branch' : -1}}}, 'people' : [{'id' : {'unique' : 'emily'}, 'meters' : {'loyal' : -30, 'obed' : -20, 'stress' : 40}}]}}) #ToFix - QuestEnd should be defined, no stage = 100
#	tishaDisappearsAction.add_button("Ask for 'special service'", '2.specialService', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 12, 'branch' : -1}}}, 'people' : [{'id' : {'unique' : 'emily'}, 'consent' : true, 'tags' : {'nosex' : 'erase'}, 'meters' : {'loyal' : -10, 'obed' : -10}}]}})
#	tishaDisappearsEvent.add_action('1.tishaDisappears', tishaDisappearsAction)
#
#	#Step02, '2.help'
#	tishaDisappearsAction = Quest.Event.EventAction.new()
#	tishaDisappearsAction.actionType = 'dialogue'
#	tishaDisappearsAction.text = sidequestTexts.tishaQuest.TishaDisappears_Help
#	tishaDisappearsAction.sprites = [['emily2happy','pos1']]
#	tishaDisappearsAction.add_button('Close', 'finish')
#	tishaDisappearsEvent.add_action('2.help', tishaDisappearsAction)
#
#	#Step02, '2.deny'
#	tishaDisappearsAction = Quest.Event.EventAction.new()
#	tishaDisappearsAction.actionType = 'dialogue'
#	tishaDisappearsAction.text = sidequestTexts.tishaQuest.TishaDisappears_Deny
#	tishaDisappearsAction.sprites = [['emily2worried','pos1']]
#	tishaDisappearsAction.add_button('Close', 'finish')
#	tishaDisappearsEvent.add_action('2.deny', tishaDisappearsAction)
#
#	#Step02, '2.specialService'
#	tishaDisappearsAction = Quest.Event.EventAction.new()
#	tishaDisappearsAction.actionType = 'dialogue'
#	tishaDisappearsAction.text = sidequestTexts.tishaQuest.TishaDisappears_SpecialService
#	tishaDisappearsAction.sprites = [['emily2worried','pos1']]
#	tishaDisappearsAction.add_button('Close', 'finish')
#	tishaDisappearsEvent.add_action('2.specialService', tishaDisappearsAction)	
#
#	return tishaDisappearsEvent
#
#func _quest_maker_tisha_03():
#	#Create tishaMageOrderEvent
#	var tishaMageOrderEvent = Quest.Event.new()
#	var reqs = {'sidequests' : {'emily' : {'state': {'stage' : 12, 'branch' : -1}}}}
#	tishaMageOrderEvent.name = 'tishaMageOrder'
#	tishaMageOrderEvent.startType = 'hook'
#	tishaMageOrderEvent.activateChance = 100
#	tishaMageOrderEvent.place = {region = 'wimborn', area = 'mageOrder', location = 'lobby'}
#	tishaMageOrderEvent.requirements = reqs
#
#	#Create start action
#	var tishaMageOrderAction = Quest.Event.EventAction.new()
#	tishaMageOrderAction.actionType = 'dialogue'
#	tishaMageOrderAction.add_button("Visit Tisha's workplace", '1.visitArchives')
#	tishaMageOrderEvent.add_action('start', tishaMageOrderAction)
#
#	#Steo01, '1.visitArchives'
#	tishaMageOrderAction = Quest.Event.EventAction.new()
#	tishaMageOrderAction.actionType = 'dialogue'
#	tishaMageOrderAction.text = sidequestTexts.tishaQuest.MageOrder_VisitArchives
#	tishaMageOrderAction.add_button("Investigate Dorms", '2.dormDecision')
#	tishaMageOrderEvent.add_action('1.visitArchives', tishaMageOrderAction)
#
#	#Step02, '2.dormdecision'
#	tishaMageOrderAction = Quest.Event.EventAction.new()
#	tishaMageOrderAction.actionType = 'decision'	
#	tishaMageOrderAction.add_node({'eventState' : '2.dormsEmily', 'meta' : {'requirements' : {'world' : {'party' : [{'id' : {'unique' : 'emily'}}]}}, 'result' : {}}})
#	tishaMageOrderAction.add_node({'eventState' : '2.dorms', 'meta' : {'requirements' : {}, 'result' : {}}})	
#	tishaMageOrderEvent.add_action('2.dormDecision', tishaMageOrderAction)
#
#	#Step03, '3.dormsEmily'	
#	tishaMageOrderAction = Quest.Event.EventAction.new()
#	tishaMageOrderAction.actionType = 'dialogue'
#	tishaMageOrderAction.text = sidequestTexts.tishaQuest.MageOrder_DormsEmily
#	tishaMageOrderAction.sprites = [['emily2worried','pos1']]
#	tishaMageOrderAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 13, 'branch' : -1}}}}})
#	tishaMageOrderEvent.add_action('3.dormsEmily', tishaMageOrderAction)
#
#	#Step03, '3.dorms'
#	tishaMageOrderAction = Quest.Event.EventAction.new()
#	tishaMageOrderAction.actionType = 'dialogue'
#	tishaMageOrderAction.text = sidequestTexts.tishaQuest.MageOrder_Dorms	
#	tishaMageOrderAction.add_button("Cast Domination", '4.dormsDomination', {'requirements' : {'world' : {'spells' : ['domination']}, 'resources' : {'mana' : 40}}, 'result' : {'resources' : {'mana' : -40}}})
#	tishaMageOrderAction.add_button("Threaten", '4.dormsThreaten')
#	tishaMageOrderAction.add_button("Investigate Dorms", '4.dormsBribe', {'requirements' : {'resources' : {'gold' : 50}}, 'result' : {'resources' : {'gold' : -50}}})	
#	tishaMageOrderEvent.add_action('3.dorms', tishaMageOrderAction)
#
#	#Step04, '4.dormsDomination'
#	tishaMageOrderAction = Quest.Event.EventAction.new()
#	tishaMageOrderAction.actionType = 'dialogue'
#	tishaMageOrderAction.text = sidequestTexts.tishaQuest.MageOrder_DormsDomination
#	tishaMageOrderAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 13, 'branch' : -1}}}}})
#	tishaMageOrderEvent.add_action('4.dormsDomination', tishaMageOrderAction)
#
#	#Step04, '4.dormsThreaten'
#	tishaMageOrderAction = Quest.Event.EventAction.new()
#	tishaMageOrderAction.actionType = 'dialogue'
#	tishaMageOrderAction.text = sidequestTexts.tishaQuest.MageOrder_DormsThreaten
#	tishaMageOrderAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 13, 'branch' : -1}}}}})
#	tishaMageOrderEvent.add_action('4.dormsThreaten', tishaMageOrderAction)
#
#	#Step04, '4.dormsBribe'
#	tishaMageOrderAction = Quest.Event.EventAction.new()
#	tishaMageOrderAction.actionType = 'dialogue'
#	tishaMageOrderAction.text = sidequestTexts.tishaQuest.MageOrder_DormsBribe
#	tishaMageOrderAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 13, 'branch' : -1}}}}})
#	tishaMageOrderEvent.add_action('4.dormsBribe', tishaMageOrderAction)
#
#	return tishaMageOrderEvent
#
#func _quest_maker_tisha_04():
#	#Create tishaBackstreetsEvent
#	var tishaBackstreetsEvent = Quest.Event.new()
#	var reqs = {'sidequests' : {'emily' : {'state' : {'stage' : 13, 'branch' : -1}}}}
#	tishaBackstreetsEvent.name = 'tishaBackstreets'
#	tishaBackstreetsEvent.startType = 'hook'
#	tishaBackstreetsEvent.activateChance = 100
#	tishaBackstreetsEvent.place = {region = 'wimborn', area = 'wimbornCity', location = 'backstreets'}
#	tishaBackstreetsEvent.requirements = reqs
#
#	#Create start action
#	var tishaBackstreetsAction = Quest.Event.EventAction.new()
#	tishaBackstreetsAction.actionType = 'dialogue'
#	tishaBackstreetsAction.text = sidequestTexts.tishaQuest.TishaBackstreets
#	tishaBackstreetsAction.add_button("Fight", '1.fight', {'requirements' : {}, 'result' : {}})
#	tishaBackstreetsAction.add_button("Leave", 'finish')
#	tishaBackstreetsEvent.add_action('start', tishaBackstreetsAction)
#
#	#Step01, '1.fight'
#	tishaBackstreetsAction = Quest.Event.EventAction.new()
#	tishaBackstreetsAction.actionType = 'combat'
#	tishaBackstreetsAction.add_combat({'combat' : {'enemies' : 'tishaquestenemy', 'hasCaptures' : false}}, {'win' : {'eventState' : '2.fightWin', 'result' : {}}})
#	tishaBackstreetsEvent.add_action('1.fight', tishaBackstreetsAction)
#
#	#Step02, '2.fightWin'
#	tishaBackstreetsAction = Quest.Event.EventAction.new()
#	tishaBackstreetsAction.actionType = 'dialogue'
#	tishaBackstreetsAction.text = sidequestTexts.tishaQuest.TishaBackstreets_FightWin
#	tishaBackstreetsAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 14, 'branch' : -1}}}}})
#	tishaBackstreetsEvent.add_action('2.fightWin', tishaBackstreetsAction)
#
#	return tishaBackstreetsEvent
#
#func _quest_maker_tisha_05():
#	#Create tishaGornGuildEvent
#	var tishaGornGuildEvent = Quest.Event.new()
#	var reqs = {'sidequests' : {'emily' : {'state' : {'stage' : [14,15], 'branch' : [-1]}}, 'compare' : 'inSet'}}
#	tishaGornGuildEvent.name = 'tishaGornSlaveGuild'
#	tishaGornGuildEvent.startType = 'hook'
#	tishaGornGuildEvent.activateChance = 100
#	tishaGornGuildEvent.place = {region = 'gorn', area = 'slaveGuild', location = 'lobby'}
#	tishaGornGuildEvent.requirements = reqs
#
#	#Create start action
#	var tishaGornGuildAction = Quest.Event.EventAction.new()
#	tishaGornGuildAction.actionType = 'dialogue'
#	tishaGornGuildAction.add_button("Search for Tisha", '1.gornGuildDecision')
#	tishaGornGuildEvent.add_action('start', tishaGornGuildAction)
#
#	#Step01, '1.gornGuildDecision'
#	tishaGornGuildAction = Quest.Event.EventAction.new()
#	tishaGornGuildAction.actionType = 'decision'
#	tishaGornGuildAction.add_node({'eventState' : '2.gornGuildFirstVisit'})
#	tishaGornGuildAction.add_node({'eventState' : '2.gornGuildRevisit', 'meta' : {'requirements' : {'sidequests' : {'emily' : {'state' : {'stage' : 15, 'branch' : -1}}}}, 'result' : {}}})
#	tishaGornGuildEvent.add_action('1.gornGuildDecision', tishaGornGuildAction)
#
#	#Step02, '2.gornGuildFirstVisit'
#	tishaGornGuildAction = Quest.Event.EventAction.new()
#	tishaGornGuildAction.actionType = 'dialogue'
#	tishaGornGuildAction.text = sidequestTexts.tishaQuest.GornGuild_FirstVisit
#	tishaGornGuildAction.sprites = [['tishaangry', 'pos1', 'opac']]
#	tishaGornGuildAction.add_button("Pay gold[500]", '3.gornGuildPay', {'requirements' : {'resources' : {'gold' : 500}}, 'result' : {'resources' : {'gold' : -500}, 'world' : {'addSlaves' : [{'id' : {'unique' : 'tisha'}}]}}})
#	tishaGornGuildAction.add_button("Leave", 'reset')
#	tishaGornGuildEvent.add_action('2.gornGuildFirstVisit', tishaGornGuildAction)
#
#	#Step02, '2.gornGuildRevisit'
#	tishaGornGuildAction = Quest.Event.EventAction.new()
#	tishaGornGuildAction.actionType = 'dialogue'
#	tishaGornGuildAction.text = sidequestTexts.tishaQuest.GornGuild_Revisit
#	tishaGornGuildAction.sprites = [['tishaangry', 'pos1', 'opac']]
#	tishaGornGuildAction.add_button("Pay gold[500]", '3.gornGuildPay', {'requirements' : {'resources' : {'gold' : 500}}, 'result' : {'resources' : {'gold' : -500}, 'world' : {'addSlaves' : [{'id' : {'unique' : 'tisha'}}]}}})
#	tishaGornGuildAction.add_button("Leave", 'reset')
#	tishaGornGuildEvent.add_action('2.gornGuildRevisit', tishaGornGuildAction)
#
#	#Step03, '3.gornGuildPay'
#	tishaGornGuildAction = Quest.Event.EventAction.new()
#	tishaGornGuildAction.actionType = 'dialogue'
#	tishaGornGuildAction.text = sidequestTexts.tishaQuest.GornGuild_Pay
#	tishaGornGuildAction.sprites = [['tishaneutral', 'pos1']]
#	tishaGornGuildAction.add_button("Brand", '4.gornGuildBrand', {'requirements' : {}, 'result' : {'world' : {'addSlaves' : [{'id' : {'unique' : 'tisha'}}]}}})
#	tishaGornGuildAction.add_button("Refuse", '4.gornGuildNoBrand')
#	tishaGornGuildEvent.add_action('3.gornGuildPay', tishaGornGuildAction)
#
#	#Step04, '4.gornGuildBrand'
#	tishaGornGuildAction = Quest.Event.EventAction.new()
#	tishaGornGuildAction.actionType = 'dialogue'
#	tishaGornGuildAction.text = sidequestTexts.tishaQuest.GornGuild_Brand
#	tishaGornGuildAction.sprites = [['tishashocked', 'pos1']]
#	tishaGornGuildAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'sidequests' : {'emily' : {'state' : {'stage' : 101, 'branch' : -1}}}, 'people' : [{'id' : {'unique' : 'tisha'}, 'brand' : 'basic'}] }})
#	tishaGornGuildEvent.add_action('4.gornGuildBrand', tishaGornGuildAction)
#
#	#Step04, '4.gornGuildNoBrand'
#	tishaGornGuildAction = Quest.Event.EventAction.new()
#	tishaGornGuildAction.actionType = 'dialogue'
#	tishaGornGuildAction.text = sidequestTexts.tishaQuest.GornGuild_NoBrand
#	tishaGornGuildAction.sprites = [['tishaneutral', 'pos1']]
#	tishaGornGuildAction.add_button("Continue", '5.gornGuildAfter', {'requirements' : {}, 'result' : {}})  
#	tishaGornGuildEvent.add_action('4.gornGuildNoBrand', tishaGornGuildAction)
#
#	#Step05, '5.gornGuildAfter'
#	tishaGornGuildAction = Quest.Event.EventAction.new()
#	tishaGornGuildAction.actionType = 'dialogue'
#	tishaGornGuildAction.text = sidequestTexts.tishaQuest.GornGuild_After
#	tishaGornGuildAction.sprites = [['tishaneutral', 'pos1']]
#	tishaGornGuildAction.add_button("Close", 'finish', {'requirements' : {} , 'result' : {'world' : {'scheduleEvent' : {'tishaRepaysDebt' : 5}}}})	
#	tishaGornGuildEvent.add_action('5.gornGuildAfter', tishaGornGuildAction)
#
#	return tishaGornGuildEvent
#
#func _quest_maker_tisha_06():
#	#Create tishaRepaysDebtEvent
#	var tishaRepaysDebtEvent = Quest.Event.new()
#	var reqs = {}
#	tishaRepaysDebtEvent.name = 'tishaRepaysDebt'
#	tishaRepaysDebtEvent.startType = 'schedule'
#	tishaRepaysDebtEvent.activateChance = 100
#	tishaRepaysDebtEvent.place = {region = 'any', area = 'mansion', location = 'foyer'}
#	tishaRepaysDebtEvent.requirements = reqs
#
#	#Create start action
#	var tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'dialogue'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.TishaRepaysDebt
#	tishaRepaysDebtAction.sprites = [['tishaneutral', 'pos1']]
#	tishaRepaysDebtAction.add_button("Give her another week for payment", '1.acceptPayment', {'requirements' : {}, 'result' : {'resources' : {'gold' : 200}}})
#	tishaRepaysDebtAction.add_button("Refuse payment", '1.refusePayment')
#	tishaRepaysDebtAction.add_button("Counteroffer: Sex for remaining debt", '1.counterofferSex')
#	tishaRepaysDebtEvent.add_action('start', tishaRepaysDebtAction)
#
#	#Step01, '1.acceptPayment'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'dialogue'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_AcceptPayment
#	tishaRepaysDebtAction.sprites = [['tishaneutral', 'pos1']]
#	tishaRepaysDebtAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'world' : {'scheduleEvent' : {'tishaPayment' : 8}}, 'sidequests' : {'emily' : {'state' : {'stage' : 17, 'branch' : -1}}}}})
#	tishaRepaysDebtEvent.add_action('1.acceptPayment', tishaRepaysDebtAction)
#
#	#Step01, '1.refusePayment'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'dialogue'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_RefusePayment
#	tishaRepaysDebtAction.sprites = [['tishanakedhappy', 'pos1']]
#	tishaRepaysDebtAction.add_button("Continue", '2.sexDecision', {'requirements' : {}, 'result' : {'progress' : {'gallery' : {'tisha' : {'unlock' : 'naked', 'scenes' : 1}}}}})
#	tishaRepaysDebtEvent.add_action('1.refusePayment', tishaRepaysDebtAction)
#
#	#Step01, '1.counterOfferSex'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'dialogue'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_CounterofferSex
#	tishaRepaysDebtAction.sprites = [['tishanakedhappy', 'pos1']]
#	tishaRepaysDebtAction.add_button("Continue", '2.sexDecision', {'requirements' : {}, 'result' : {'progress' : {'gallery' : {'tisha' : {'unlock' : 'naked', 'scenes' : 1}}}, 'resources' : {'gold' : 200}}})
#	tishaRepaysDebtEvent.add_action('1.counterofferSex', tishaRepaysDebtAction)
#
#	#Step02, '2.sexDecision'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'decision'
#	tishaRepaysDebtAction.add_node({'eventState' : '3.sexNoCock', 'meta' : {'requirements' : {'people' : [{'id' : {'unique' : 'player'}, 'sexParts' : {'penis' : false}}]}, 'result' : {}}})
#	tishaRepaysDebtAction.add_node({'eventState' : '3.sexCock'})
#	tishaRepaysDebtEvent.add_action('2.sexDecision', tishaRepaysDebtAction)
#
#	#Step03, '3.sexNoCock'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'scene'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_SexNoCock
#	tishaRepaysDebtAction.image = 'tishafinale'
#	tishaRepaysDebtAction.sprites = [['tishanakedhappy', 'pos1']]
#	tishaRepaysDebtAction.add_button("Continue", '4.sexNoCockEnd')
#	tishaRepaysDebtEvent.add_action('3.sexNoCock', tishaRepaysDebtAction)
#
#	#Step04, '4.sexNoCockEnd'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'scene'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_SexNoCock
#	tishaRepaysDebtAction.image = 'tishafinale'
#	tishaRepaysDebtAction.sprites = [['tishanakedhappy', 'pos1']]
#	tishaRepaysDebtAction.add_button("Offer to take in Tisha", '5.offerStay', {'requirements' : {}, 'result' : {'world' : {'addSlaves' : [{'id' : {'unique' : 'tisha'}}]}}})
#	tishaRepaysDebtAction.add_button("Say nothing", "5.noStay")
#	tishaRepaysDebtEvent.add_action('4.sexNoCockEnd', tishaRepaysDebtAction)
#
#	#Step03, '3.sexCock'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'scene'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_SexCock
#	tishaRepaysDebtAction.image = 'tishafinale'
#	tishaRepaysDebtAction.sprites = [['tishanakedhappy', 'pos1']]
#	tishaRepaysDebtAction.add_button("Continue", '4.sexCockEnd')
#	tishaRepaysDebtEvent.add_action('3.sexCock', tishaRepaysDebtAction)
#
#	#Step04, '4.sexCockEnd'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'scene'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_SexCockEnd
#	tishaRepaysDebtAction.image = 'tishafinale'
#	tishaRepaysDebtAction.sprites = [['tishanakedhappy', 'pos1']]
#	tishaRepaysDebtAction.add_button("Offer to take in Tisha", '5.offerStay', {'requirements' : {}, 'result' : {'world' : {'addSlaves' : [{'id' : {'unique' : 'tisha'}}]}}})
#	tishaRepaysDebtAction.add_button("Say nothing", "5.noStay")
#	tishaRepaysDebtEvent.add_action('4.sexCockEnd', tishaRepaysDebtAction)
#
#	#Step05, '5.offerStay'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'dialogue'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_OfferStay	
#	tishaRepaysDebtAction.sprites = [['tishanakedhappy', 'pos1']]
#	tishaRepaysDebtAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'people' : [{'id' : {'unique' : 'tisha'}, 'traits' : {'grateful' : 'add'}, 'meters' : {'obedience' : 90, 'loyal': 15}}, {'id' : {'unique' : 'emily'}, 'consent' : true, 'tags' : {'nosex' : 'erase'}}]}, 'resources' : {'upgradepoints' : 10}, 'sidequests' : {'emily' : {'state' : {'stage' : 16, 'branch' : -1}}}})
#	tishaRepaysDebtEvent.add_action('5.offerStay', tishaRepaysDebtAction)
#
#	#Step05, '5.noStay'
#	tishaRepaysDebtAction = Quest.Event.EventAction.new()
#	tishaRepaysDebtAction.actionType = 'dialogue'
#	tishaRepaysDebtAction.text = sidequestTexts.tishaQuest.RepaysDebt_NoStay
#	tishaRepaysDebtAction.sprites = [['tishaneutral', 'pos1']]
#	tishaRepaysDebtAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'people' : [{'id' : {'unique' : 'emily'}, 'tags' : {'nosex' : 'erase'}}], 'resources' : {'upgradepoints' : 10}, 'sidequests' : {'emily' : {'state' : {'stage' : 16, 'branch' : -1}}}}})
#	tishaRepaysDebtEvent.add_action('5.offerStay', tishaRepaysDebtAction)
#
#	return tishaRepaysDebtEvent
#
#func _quest_maker_tisha_07():
#	#Create tishaPaymentEvent
#	var tishaPaymentEvent = Quest.Event.new()
#	var reqs = {}
#	tishaPaymentEvent.name = 'tishaAppearance'
#	tishaPaymentEvent.startType = 'schedule'
#	tishaPaymentEvent.activateChance = 100
#	tishaPaymentEvent.place = {region = 'any', area = 'mansion', location = 'foyer'}
#	tishaPaymentEvent.requirements = reqs
#
#	#Create start action
#	var tishaPaymentAction = Quest.Event.EventAction.new()
#	tishaPaymentAction.actionType = 'dialogue'
#	tishaPaymentAction.text = sidequestTexts.tishaQuest.TishaPayment
#	tishaPaymentAction.add_button("Close", 'finish', {'requirements' : {}, 'result' : {'resources' : {'gold' : 600}}})
#	tishaPaymentEvent.add_action('start', tishaPaymentAction)
#
#	return tishaPaymentEvent
#
#func _quest_maker_tisha_08():
#	#Create tishaEmilySexEvent
#	var tishaEmilySexEvent = Quest.Event.new()
#	var reqs = {}
#	tishaEmilySexEvent.name = 'tishaEmilySex'
#	tishaEmilySexEvent.startType = 'schedule'
#	tishaEmilySexEvent.activateChance = 100
#	tishaEmilySexEvent.place = {region = 'any', area = 'mansion', location = 'foyer'}
#	tishaEmilySexEvent.requirements = reqs
#
#	#Create start action
#	var tishaEmilySexAction = Quest.Event.EventAction.new()
#	tishaEmilySexAction.actionType = 'scene'
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
