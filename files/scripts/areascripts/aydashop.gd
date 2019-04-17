extends Node

var textnode = globals.questtext


func gornayda():
	var text = ''
	var state = true
	var sprite = [['aydanormal', 'pos1','opac']]
	var buttons = []
	if globals.state.mainquest < 37 || globals.state.sandbox == true:
		globals.main.get_node("outside").setcharacter('aydanormal')
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
			
			buttons.append({name = "See Ayda's assortments", function = 'aydashop'})
			if globals.state.sidequests.ayda == 1:
				buttons.append({name = 'Ask Ayda about herself', function = 'gornaydatalk', args = 1})
			elif globals.state.sidequests.ayda == 2:
				buttons.append({name = 'Ask Ayda about monster races',function = 'gornaydatalk', args = 2})
	
		if globals.state.sidequests.yris == 4:
			buttons.append({name = "Ask about the found ointment", function = "gornaydatalk", args = 3})
		if state == true:
			buttons.append({name = "Leave", function = 'leaveayda'})
		globals.main.maintext = globals.player.dictionary(text)
		globals.main.get_node("outside").buildbuttons(buttons, self)
	elif globals.state.mainquest == 38:
		text = textnode.MainQuestFinaleAydaShop
		sprite = []
		globals.state.sidequests.ayda = 4
		globals.state.mainquest = 39
		globals.main.dialogue(true, self, text, buttons, sprite)
	elif globals.state.sidequests.ayda == 5 || (globals.state.sandbox == true && globals.state.sidequests.yris >= 6):
		aydafinalereturn()
	elif globals.state.sidequests.ayda >= 6:
		text = "The bunny boy greets you as you enter."
		globals.main.maintext = globals.player.dictionary(text)
		buttons.append({name = "See shop's assortments", function = 'aydashop'})
		buttons.append({name = "Leave", function = 'leaveayda'})
		globals.main.get_node("outside").buildbuttons(buttons, self)
		if globals.state.sidequests.ayda in [7,10,13]:
			aydaquest()
			#buttons.append({name = "Ask about Ayda's preferences", function = 'aydaquest'})
		
#	elif globals.state.mainquestcomplete && globals.state.decisions.has("mainquestelves"):
#		globals.main.dialogue(true, self, text, buttons, sprite)
#		buttons.append({name = "See Shop's assortments", function = 'aydashop'})
	else:
		text = "You try to enter Ayda's shop but nobody appears to be around. "
		sprite = []
		globals.main.dialogue(true, self, text, buttons, sprite)

func aydaquest():
	var text = ''
	var ayda
	for i in globals.slaves:
		if i.unique == 'Ayda':
			ayda = i
	if ayda == null:
		globals.state.sidequests.ayda = 100
		return
	match int(globals.state.sidequests.ayda):
		7:
			text = textnode.aydarequest1
			globals.state.sidequests.ayda = 8
		10:
			text = textnode.aydarequest2
			globals.state.sidequests.ayda = 11
		13:
			text = textnode.aydarequest3
			globals.state.sidequests.ayda = 14
		
	gornayda()
	globals.main.maintext = globals.player.dictionary(text)



func leaveayda():
	globals.main.get_node("outside").togorn()
	globals.main.exploration.zoneenter('gorn')

func aydashop():
	if globals.state.sidequests.ayda >= 6:
		globals.main.get_node('outside').shops.aydashop.sprite = null
	globals.main.get_node("outside").shopinitiate("aydashop")

func gornaydatalk(stage = 0):
	var text = ''
	var buttons = []
	globals.main.get_node("outside").setcharacter('aydanormal2')
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
	globals.main.get_node("outside").buildbuttons(buttons, self)

func aydafinalereturn(stage = 0):
	var text = ''
	var buttons = []
	var state = false
	var sprite = []
	
	if stage == 0:
		text = textnode.aydareturn
		sprite = [['aydanormal', 'pos1', 'opac']]
		buttons.append({text = "Agree to Ayda's conditions", function = 'aydafinalereturn', args = 1})
		buttons.append({text = "Refuse and let Ayda leave", function = 'aydafinalereturn', args = 2})
	elif stage == 1:
		text = textnode.aydareturnagree
		globals.state.sidequests.ayda = 6
		globals.state.upcomingevents.append({code = 'aydatimepass', duration = 7})
		sprite = [['aydanormal', 'pos1']]
		state = true
		var person = globals.characters.create("Ayda")
		globals.slaves = person
		globals.main.exploration.zoneenter('gorn')
	elif stage == 2:
		text = textnode.aydareturnrefuse
		globals.state.sidequests.ayda = 101
		sprite = [['aydanormal', 'pos1']]
		globals.main.exploration.zoneenter('gorn')
		state = true
	
	
	globals.main.dialogue(state, self, text, buttons, sprite)

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
		globals.main.get_node("outside").buildbuttons(buttons, self)
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
	globals.main.get_node("outside").buildbuttons(buttons, self)
	#globals.main.dialogue(state, self, text, buttons, sprite)