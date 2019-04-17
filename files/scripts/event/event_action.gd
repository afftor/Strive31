### Ku-Ku-Ku-Kurapanda!!!
### EventAction - One action within an Event

### Resources
const ReqCheck = preload("res://files/scripts/event/event_requirement_check.gd")

### Member Variables
var event = null
var actionType = 'dialogue' #Types - 'dialogue', 'scene', 'decision', 'combat'
var pov = ''
var text = ''
var image = ''
var sprites = []
var nodes = []

	
###Public Functions
#'Node' accessors
func add_node(node): #node = {eventState = eventStateVal, meta = {requirements = {}, result = {}}}
	if !node.has('meta'):
		node['meta'] = {'requirements' : {}, 'result' : {}}
	nodes.append(node)

func get_node():
	var decisionNode
	var defaultNodes = []
	var availableNodes = []
	
	#Fill in defaultNodes & availableNodes
	for inode in nodes:
		if inode.meta.requirements.empty():
			defaultNodes.append(inode)
			continue
		var checkResult = ReqCheck.check_requirements(inode.meta.requirements)
		if checkResult.meetsReqs:
			availableNodes.append(inode)
	
	#Select decisionNode
	if !availableNodes.empty():
		var diceRoll = randi() % availableNodes.size()
		decisionNode = availableNodes[diceRoll]		
	elif !defaultNodes.empty():
		var diceRoll = randi() % defaultNodes.size()
		decisionNode = defaultNodes[diceRoll]
	else:
		decisionNode = {'eventState' : 'finish', 'meta' : {'requirements' : {}, 'result' : {}}} #This case shouldn't occur, it's a fallback for broken events
		
	return decisionNode
	
#'Button' accessors
func add_button(buttonName, newEventState, buttonMeta = {requirements = {}, result = {}}):
	nodes.append({name = buttonName, eventState = newEventState, meta = buttonMeta})
		
func get_buttons():
	var checkResult
	var finalButtons = []		
	
	for ibutton in nodes:
		var result = ibutton.meta.result
		checkResult = ReqCheck.check_requirements(ibutton.meta.requirements)
		
		if checkResult.meetsReqs: #No missing reqs			
			finalButtons.append({name = ibutton.name, text = ibutton.name, function = '_process_event', args = [ibutton.eventState, event, result]})  #ToFix - name, text are redundant, because outside.buildbuttons() and mansion.dialogue() are inconsistent
		else:
			finalButtons.append({name = ibutton.name, text = ibutton.name, function = '_process_event', args = [ibutton.eventState, event, result], disabled = true, tooltip = checkResult.meta.tooltip})				
		
	return finalButtons

#'Combat' accessors
func add_combat(combat, combatFinish): # combat = {'combat' = {combatData}}, combatFinish = {'win' = {'eventState' : {}, 'results' : {}}}
	nodes.append(combat)
	
	for ifinish in combatFinish:
		nodes.append(ifinish)

func get_combat():
	var combatNodes = {'combat' : null, 'win' : null}
		
	for inode in nodes:
		if inode.has('combat'):
			combatNodes.combat = inode.combat
		elif inode.has('win'):
			combatNodes.win = inode.win
		
	return combatNodes
	
#Utiliy Functions	
func clear():
	event = null
	actionType = 'dialogue'
	text = ''
	image = ''
	sprites.clear()
	nodes.clear()
	
#File system functions
func to_dict():
	var actionDict = {'actionType' : actionType, 'pov' : pov, 'text' : text, 'image' : image, 'sprites': sprites, 'nodes' : nodes}
	return actionDict
	
func from_dict(actionDict):
	clear()
	actionType = actionDict.actionType
	pov = actionDict.actionType
	text = actionDict.text
	image = actionDict.image
	sprites = actionDict.sprites
	nodes = actionDict.nodes