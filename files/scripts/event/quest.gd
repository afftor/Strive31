#### Ku-Ku-Ku-Kurapanda!!!
#### Quest - A collection of linked or related Events
#
#### Resources
#const ReqCheck = preload("res://files/scripts/event/event_requirement_check.gd")
#const Event = preload("res://files/scripts/event/event.gd")
#
#### Member Variables
#var uid = ''
#var state = {stage = -1, branch = -1} #stage = major progress, branch = variations/minor progress, value {-1 = 'inactive_start', -2 = 'self_suspend', -3 = 'external_suspend', -10 = 'finish', 0 = 'active_start', [1, x] = 'quest_progression'
#var events = {} #Dictionary of 'place.region' : {eventName : event}
#
#
#### Public Functions
##Event accessors
#func add_event(event):
#	if !events.has(event.place.region):
#		events[event.place.region] = {}
#	events[event.place.region][event.name] = event
#
#func remove_event(event):
#	if !events.has(event.region):
#		return
#
#	events[event.region].erase(event)
#
#	#If no events at region, remove 'region' from keys
#	if events[event.region].empty(): 
#		events.erase(event.region)
#
#func get_events(place):
#	var availableEvents = []
#
#	#Get list of available events at place.region
#	if events.has(place.region):
#		for ievent in events[place.region].values():
#			if ievent.is_available(place).meetsReqs:
#				availableEvents.append(ievent)
#
#	#Get list of available events that are not region-specific
#	if place.region != 'any' && events.has('any'):
#		for ievent in events['any'].values():
#			if ievent.is_available(place).meetsReqs:
#				availableEvents.append(ievent)
#
#	return availableEvents
#
##Utility Functions
#func clear():
#	uid = ''
#	state = {stage = 0, branch = -1}
#	events = {}
#
##File system functions
#func to_dict():
#	var questDict = {'uid' : uid, 'state' : state}	
#	questDict['events'] = _to_dict_events()
#
#	return questDict
#
#func _to_dict_events():
#	var eventsDict = {}
#	for iregion in events:
#		eventsDict[iregion] = {}		
#		for ievent in events[iregion]:
#			eventsDict[iregion][ievent] = events[iregion][ievent].to_dict()
#	return eventsDict
#
#func from_dict(questDict):
#	clear()
#	uid = questDict.uid
#	state = questDict.state
#	events = _from_dict_events(questDict)
#
#func _from_dict_events(questDict):
#	var eventsDict = {}
#	for iregion in questDict.events:
#		eventsDict[iregion] = {}
#		for ievent in questDict.events[iregion]:
#			var newEvent = Event.new()
#			newEvent.from_dict(questDict.events[iregion][ievent])
#			eventsDict[iregion][ievent] = newEvent
#
#	return eventsDict		
