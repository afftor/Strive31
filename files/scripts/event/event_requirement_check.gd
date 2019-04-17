### Ku-Ku-Ku-Kurapanda!!!
### EventRequirementCheck - Handles the requirement checks for all event components
### ReturnType - CheckResult = {'pass' : true/false, 'meta' : {'tooltip' = '', ...}}
### Requirement Categories - Progress (unlocks, event choices, permanents), World (variable states, new/delete, add/remove), Resources, Items, Quests (Main & Side), People

### Constants
const IdType = ['unique']

### Public Functions
### Main Requirement Check Function
static func check_requirements(reqs):
	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	
	#No requirements found
	if reqs.empty():
		return checkResult
		
	#Check requirements by category
	for icategory in reqs:
		var partCheckResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
		match icategory:
			'progress':
				pass
			'world':
				partCheckResult = _check_world_reqs(reqs[icategory])
			'resources':
				partCheckResult = _check_resource_reqs(reqs[icategory])
			'items':
				partCheckResult = _check_item_reqs(reqs[icategory])
			'sidequests':
				partCheckResult = _check_sidequest_reqs(reqs[icategory])
			'people':
				partCheckResult = _check_person_reqs(reqs[icategory])
		
		if !partCheckResult.meetsReqs:
			checkResult.meetsReqs = false
			if checkResult.meta.tooltip != '':
				checkResult.meta.tooltip += '\n'
			checkResult.meta.tooltip += partCheckResult.meta.tooltip
	
	return checkResult

#Place Check Function is exposed as it requires 'place' parameter, ToFix after Place system updated
static func check_place_reqs(placeReq, place):
	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	
	#Check region
	if placeReq.region != 'any' && placeReq.region != place.region:
		checkResult.meetsReqs = false
		checkResult.meta.tooltip = "Wrong region: " + place.region.capitalize()
		return checkResult
	
	#Check area
	if placeReq.area != 'any' && placeReq.area != place.area:
		checkResult.meetsReqs = false
		checkResult.meta.tooltip = "Wrong area: " + place.area.capitalize()
		return checkResult
	
	#Check location
	if placeReq.location != 'any' && placeReq.location != place.location:
		checkResult.meetsReqs = false
		checkResult.meta.tooltip = "Wrong location: " + place.location.capitalize()
	
	return checkResult

	
### Private Functions
#Progress Check Function
static func _check_progress_reqs(progress):
	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	var tooltip = ''
	
	for icategory in progress:
		match icategory:
			'decisions':
				for idecision in progress[icategory]:
					if !globals.state[icategory].has(idecision):
						checkResult.meetsReqs = false
						if tooltip != '':
							tooltip += '\n'
						tooltip += "No decision: " + idecision
	
	if tooltip != '':
		checkResult.meetsReqs = false
		checkResult.meta.tooltip = tooltip

	return checkResult

#World Check Function
static func _check_world_reqs(world):
	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	var tooltip = ''
	
	for icategory in world:
		match icategory:
			'staff': #ToFix - Job & Specs List re-factor, then direct-check staff jobs
				var mansionStaff = globals.main.mansionStaff
				for istaff in world[icategory]:
					var staffJob = istaff.substr(3, istaff.length() - 3)
					staffJob = staffJob.substr(0, 1).to_lower() + staffJob.substr(1, staffJob.length()-1)
					if world[icategory][istaff] == true && mansionStaff[staffJob] == null:						
						if tooltip != '':
							tooltip += '\n'
						tooltip += "No current " + staffJob.capitalize()
					elif world[icategory][istaff] == false && mansionStaff[staffJob] != null:						
						if tooltip != '':
							tooltip += '\n'
						tooltip += "There is a " + staffJob.capitalize()
			'party':
				var party = []
				for partyid in globals.state.playergroup: #ToFix - Not good solution, mixing old and new full slave searches, fix after class Person refactor
					party.append(globals.state.findslave(partyid))
					
				for iperson in world[icategory]:
					var focusPerson = _find_person(iperson.id, party)										
					if focusPerson != null:						
						if tooltip != '':
							tooltip += '\n'
						tooltip += "Missing person in party"
			'spells':
				for ispell in world[icategory]:
					if !globals.spelldict[ispell].learned:						
						if tooltip != '':
							tooltip += '\n'
						tooltip += "Havent learned spell: " + ispell						
	
	if tooltip != '':
		checkResult.meetsReqs = false
		checkResult.meta.tooltip = tooltip
		
	return checkResult

#Resources Check Function
static func _check_resource_reqs(resources):
	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	var ownedResources = globals.resources
	var tooltip = ''
		
	for ires in resources:
		#Set comparison type
		var compareType = '>='
		if typeof(resources[ires]) == TYPE_DICTIONARY:
			if resources[ires].has('compare'):
				compareType = resources[ires].compare
			
			if !_compare(ownedResources[ires], resources[ires].value, compareType):
				if tooltip != '':
					tooltip += '\n'
				tooltip += "Need " + compareType + ires + '[' + str(resources[ires].amount) + ']'
		else:
			if !_compare(ownedResources[ires], resources[ires], compareType):
				if tooltip != '':
					tooltip += '\n'
				tooltip += "Need " + compareType + ires + '[' + str(resources[ires].amount) + ']'			
				
	if tooltip != '':		
		checkResult.meetsReqs = false
		checkResult.meta.tooltip = tooltip
		
	return checkResult
	
#Item Check Function
static func _check_item_reqs(items):
	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	var ownedItems = globals.itemdict	
	var tooltip = ''
	
	for kitem in items:
		#Set comparison type
		var compareType = '>='
		if typeof(items[kitem]) == TYPE_DICTIONARY:
			if items[kitem].has('compare'):
				compareType = items[kitem].compare
				
			if !_compare(ownedItems[kitem].amount, items[kitem].value, compareType):
				if tooltip != '':
					tooltip += "\n"
				tooltip += "Need " + compareType + kitem + '[' + str(items[kitem]) + ']'
		else:
			if !_compare(ownedItems[kitem].amount, items[kitem], compareType):
				if tooltip != '':
					tooltip += "\n"
				tooltip += "Need " + compareType + kitem + '[' + str(items[kitem]) + ']'
	
	if tooltip != '':		
		checkResult.meetsReqs = false
		checkResult.meta.tooltip = tooltip
		
	return checkResult

#Sidequest Check Function
static func _check_sidequest_reqs(sidequests):
	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	var tooltip = ''
	
	for iquestname in sidequests:
		var quests = globals.events.sidequests
		var questReqs = sidequests[iquestname]
		
		#Set comparisonType
		var compareType = '=='
		if questReqs.has('compare'):
			compareType = questReqs.compare
		#Compare quest 'stage' and 'branch'
		quests[iquestname].state.stage = globals.state.sidequests[iquestname]
		if !_compare(str(quests[iquestname].state.stage), str(questReqs.state.stage), compareType):
			if tooltip != '':
				tooltip += '\n'
			tooltip += "Needs quest stage " + compareType + " " + str(questReqs.state.stage)
		elif !_compare(str(quests[iquestname].state.branch), str(questReqs.state.branch), compareType):
			if tooltip != '':
				tooltip += '\n'
			tooltip += "Needs quest branch " + compareType + " " + str(questReqs.state.branch)
		
	if tooltip != '':
		checkResult.meetsReqs = false
		checkResult.meta.tooltip = tooltip
	
	return checkResult
	
#People Check Functions
static func _check_person_reqs(people): 
	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
	
	if people.empty():
		return checkResult
	
	for iperson in people:		
		#Find Person		
		var focusPerson = _find_person(iperson.id, globals.slaves)		
		if focusPerson == null:
			checkResult.meetsReqs = false
			checkResult.meta['tooltip'] = "Missing person"
			return checkResult
		
		#Check Person Reqs		
		for ireq in iperson:
			match ireq:
				'brand':
					_check_person_brand(iperson[ireq], focusPerson, checkResult)
				'meters':
					_check_person_meters(iperson[ireq], focusPerson, checkResult)
				'sexParts':
					_check_person_sex_parts(iperson[ireq], focusPerson, checkResult)
		
	return checkResult

static func _check_person_brand(brandReq, person, checkResult):
	var tooltip = ''
	
	if brandReq == 'any' && person.brand == 'none':
		tooltip = person.name + " has no Brand"
	elif brandReq == 'none' && person.brand != 'none':
		tooltip = person.name + " has a Brand"
	elif !brandReq == 'any' && brandReq != person.brand:
		tooltip = person.name + " needs " + brandReq.capitalize() + " Brand"
	
	if tooltip != '':
		checkResult.meetsReqs = false
		if checkResult.meta.tooltip != '':
			checkResult.meta.tooltip += '\n'
		checkResult.meta.tooltip += tooltip
			
static func _check_person_meters(metersReq, focusPerson, checkResult):
	var tooltip = ''
	
	for imeter in metersReq:
		#Set comparison type
		var compareType = '>='
		if metersReq[imeter].has('compare'):
			compareType = metersReq[imeter].compare
		
		match imeter: #ToFix - After Person refactor, meters = {'meterName' : value}
			'stress':
				if !_compare(focusPerson.stress, metersReq[imeter].value, compareType):
					if tooltip != '':
						tooltip += "\n"
					tooltip = "Needs " + compareType + imeter + '[' + str(metersReq[imeter].value) + ']'
			'loyal':
				if !_compare(focusPerson.loyal, metersReq[imeter].value, compareType):
					if tooltip != '':
						tooltip += "\n"
					tooltip = "Needs " + compareType + imeter + '[' + str(metersReq[imeter].value) + ']'				
			'lust':
				if !_compare(focusPerson.lust, metersReq[imeter].value, compareType):
					if tooltip != '':
						tooltip += "\n"
					tooltip = "Needs " + compareType + imeter + '[' + str(metersReq[imeter].value) + ']'				
			'obedience':
				if !_compare(focusPerson.obed, metersReq[imeter].value, compareType):
					if tooltip != '':
						tooltip += "\n"
					tooltip = "Needs " + compareType + imeter + '[' + str(metersReq[imeter].value) + ']'
	
	if tooltip != '':
		checkResult.meetsReqs = false
		if checkResult.meta.tooltip != '':
			checkResult.meta.tooltip += '\n'
		checkResult.meta.tooltip += tooltip

static func _check_person_sex_parts(partsReq, focusPerson, checkResult):
	var tooltip = ''
	
	for ipart in partsReq:
		match ipart:
			'penis':
				if typeof(partsReq[ipart]) == TYPE_BOOL:
					if partsReq[ipart] == true && focusPerson.penis == 'none':
						if tooltip != '':
							tooltip += "\n"
						tooltip = "Needs " + ipart
					elif partsReq[ipart] == false && focusPerson.penis != 'none':
						if tooltip != '':
							tooltip += "\n"
						tooltip = "Needs no " + ipart
	
	if tooltip != '':
		checkResult.meetsReqs = false
		if checkResult.meta.tooltip != '':
			checkResult.meta.tooltip += '\n'
		checkResult.meta.tooltip += tooltip

#Helper Functions
static func _find_person(id, people):
	var	focusPerson = null		
	var idType = id.keys().front()
	match idType:
		'unique': #ToFix - Should be direct get from a unique character dictionary
			for iperson in people:
				if iperson.unique == id[idType].capitalize():
					focusPerson = iperson
	
	return focusPerson
	
static func _compare(value, compareValue, compareType):
	match compareType:
		'>':
			return value > compareValue
		'>=':
			return value >= compareValue
		'=', '==':
			return value == compareValue
		'<=':
			return value <= compareValue
		'<':
			return value < compareValue
		'inSet':
			return value in compareValue