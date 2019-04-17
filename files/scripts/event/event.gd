### Ku-Ku-Ku-Kurapanda!!!
### Event - A single game encounter composed of EventActions

### Resources
const ReqCheck = preload("res://files/scripts/event/event_requirement_check.gd")
const EventAction = preload("res://files/scripts/event/event_action.gd")


### Member Variables
var name = ''
var startType = 'none' #'none' - direct-call only, 'hook' - activated by player action/choice, 'trigger' - automatically activated if event requirements are met, 'schedule' - called by event scheduler
var activateChance = 100
var place = {region = 'none', area = 'none', location = 'none'}
var state = 'start' #values = 'start', ['anyName01', 'anyName02', ...], 'finish', 'reset' - back to 'start'
var callback = null

var requirements = {} 
var actions = {} #Dictionary of actions {'Event.state' : EventAction}


### Public Functions
#'Availability' functions, checks if event requirements are met
func is_available(currentPlace = globals.places.anywhere):
	var checkResult	= {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	
	#Check event state
	if state != 'start':
		checkResult.meetsReqs = false
		return checkResult
		
	#Check for correct place
	checkResult = ReqCheck.check_place_reqs(place, currentPlace)	
	if checkResult.meetsReqs == false:
		return checkResult
	
	#Check event requirements
	checkResult = ReqCheck.check_requirements(requirements)
	if checkResult.meetsReqs == false:
		return checkResult
		
	#Roll for activation chance
	var diceRoll = randi() % 100
	if diceRoll >= activateChance:
		checkResult.meetsReqs = false			
		
	return checkResult

#Event action accessors	
func add_action(eventState, action):		
	action.event = self
	actions[eventState] = action		
	
func get_start_action():	
	return actions['start']

#Utiliy Functions
func clear():
	name = ''
	startType = 'none'
	activateChance = 100
	place = {region = 'none', area = 'none', location = 'none'}
	state = 'start'
	callback = null
	requirements = {}
	actions = {}
	
#File system functions
func to_dict():
	var eventDict = {'name' : name, 'startType' : startType, 'activateChance' : activateChance, 'place' : place, 'state' : state, 'requirements' : requirements}
	eventDict['actions'] = _to_dict_actions()
	
	return eventDict
	
func _to_dict_actions():
	var actionsDict = {}
	for iaction in actions:
		actionsDict[iaction] = actions[iaction].to_dict()
	
	return actionsDict
	
func from_dict(eventDict):
	clear()
	name = eventDict.name
	startType = eventDict.startType
	activateChance = eventDict.activateChance
	place = eventDict.place
	state = eventDict.state
	requirements = eventDict.requirements
	actions = _from_dict_actions(eventDict)

func _from_dict_actions(eventDict):
	var actionsDict = {}
	for iaction in eventDict.actions:
		var newAction = EventAction.new()
		newAction.from_dict(eventDict.actions[iaction])
		newAction.event = self
		actionsDict[iaction] = newAction
	
	return actionsDict