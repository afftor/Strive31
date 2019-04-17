####Ku-Ku-Ku-Kurapanda!!!
#### EventResult - Processes event results
#### ReturnType - CheckResult = {'pass' : true/false, 'meta' : {'tooltip' = '', ...}}
#### Result Categories - Progress (unlocks, event choices, permanents), World (world variables, new/delete, add/remove), Resources, Items, Quests (Main & Side), People
#
#
#### Public Functions
#### Main Result Process Functions
#static func process_result(result):
#	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
#	#No requirements found
#	if result.empty():
#		return checkResult
#
#	#Process requirements by category
#	for icategory in result:
#		var partCheckResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
#		match icategory:
#			'progress':
#				partCheckResult = _process_progress_result(result[icategory])
#			'world':
#				partCheckResult = _process_world_result(result[icategory])
#			'resources':
#				partCheckResult = _process_resource_result(result[icategory])
#			'items':
#				partCheckResult = _process_item_result(result[icategory])
#			'sidequests':
#				partCheckResult = _process_sidequest_result(result[icategory])
#			'people':
#				partCheckResult = _process_person_result(result[icategory])
#
#		if !partCheckResult.meetsReqs:
#			checkResult.meetsReqs = false
#			if checkResult.meta.tooltip != '':
#				checkResult.meta.tooltip += '\n'
#			checkResult.meta.tooltip += partCheckResult.meta.tooltip
#
#	return checkResult
#
#
#### Private Functions
#static func _process_progress_result(progress):
#	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
#
#	for icategory in progress:
#		match icategory:
#			'gallery':
#				for iperson in progress[icategory]:
#					if progress[icategory][iperson].has('unlock'):
#						globals.charactergallery[iperson].unlocked = true
#						if progress[icategory][iperson].unlock == 'naked':
#							globals.charactergallery[iperson].nakedunlocked = true
#
#					if progress[icategory][iperson].has('scenes'): #ToFix - CharacterGallery scenes should be a dictionary, not array
#						if typeof(progress[icategory][iperson].scenes) == TYPE_ARRAY:
#							for i in progress[icategory][iperson].scenes:
#								globals.charactergallery[iperson]['scenes'][i].unlocked = true
#						else:
#							var i = progress[icategory][iperson].scenes
#							globals.charactergallery[iperson]['scenes'][i].unlocked = true
#			'decisions':
#				for idecision in progress[icategory]:
#					if !globals.state[icategory].has(idecision):
#						globals.state[icategory].append(idecision)
#
#	return checkResult
#
#static func _process_world_result(world):
#	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
#
#	for icategory in world:
#		match icategory:
#			'addSlaves':
#				for iperson in world[icategory]:
#					var idType = iperson.id.keys().front()
#					match idType:
#						'unique':
#							var newSlave = globals.characters.create(iperson.id[idType].capitalize()) #ToFix - Need a check against global 'unique' characters list, so we don't get twins, triplets,...					
#							globals.slaves = newSlave
#			'removeSlaves':
#				for iperson in world[icategory]:
#					var idType = iperson.id.keys().front()
#					match idType:
#						'unique':
#							for islave in globals.slaves:
#								if islave.unique == iperson.id[idType].capitalize():
#									globals.slaves.erase(islave)
#			'scheduleEvent':
#				for ieventcode in world[icategory]:
#					if typeof(world[icategory][ieventcode]) == TYPE_ARRAY:
#						var diceRoll = world[icategory][ieventcode][1] - world[icategory][ieventcode][0] + 1
#						diceRoll = randi() % diceRoll
#						diceRoll += world[icategory][ieventcode][0]
#						globals.state.upcomingevents.append({code = ieventcode, duration = diceRoll}) #ToFix - Hooks into old event scheduler
#					else:
#						globals.state.upcomingevents.append({code = ieventcode, duration = world[icategory][ieventcode]})
#			'reputation':
#				for irep in world[icategory]:
#					globals.state.reputation[irep] += world[icategory][irep]				
#
#	return checkResult
#
#static func _process_resource_result(resources):
#	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
#	var ownedResources = globals.resources	
#
#	for ires in resources:
#		ownedResources[ires] += resources[ires]		
#
#	return checkResult
#
#static func _process_item_result(items):
#	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
#	var ownedItems = globals.itemdict	
#
#	for kitem in items:
#		ownedItems[kitem].amount += items[kitem]
#
#	return checkResult
#
#static func _process_sidequest_result(sidequests):
#	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}
#
#	for iquestname in sidequests:
#		var quests = globals.events.sidequests
#		var questResult = sidequests[iquestname]
#
#		quests[iquestname].state.stage = questResult.state.stage
#		quests[iquestname].state.branch = questResult.state.branch		
#
#		globals.state.sidequests[iquestname] = questResult.state.stage #ToFix - Temporary for compatibility with old code
#
#	return checkResult
#
#static func _process_person_result(people):
#	var checkResult = {'meetsReqs' : true, 'meta' : {tooltip = ''}}	
#
#	for iperson in people:
#		#Find Person		
#		var focusPerson = _find_person(iperson.id, globals.slaves)
#
#		#Find person failed, skip to next person
#		if focusPerson == null:
#			continue
#
#		#Modify traits
#		for icategory in iperson: 
#			match icategory:
#				'consent':
#					focusPerson.consent = iperson[icategory]
#				'tags':
#					for itag in iperson[icategory]:
#						if iperson[icategory][itag] == 'erase':
#							focusPerson.tags.erase(itag)
#						else:
#							if !focusPerson.tags.has(itag):
#								focusPerson.tags.append(itag)
#				'virgin':
#					for ivirgin in iperson[icategory]:
#						match ivirgin:
#							'vagina':
#								focusPerson.vagvirgin = iperson[icategory][ivirgin]
#							'ass':
#								focusPerson.assvirgin = iperson[icategory][ivirgin]
#							'mouth':
#								focusPerson.mouthvirgin = iperson[icategory][ivirgin]
#				'metrics':
#					for imetric in iperson[icategory]:
#						if imetric == 'partners':
#							for ipartner in iperson[icategory][imetric]:
#								if ipartner == 'player' && !focusPerson.metrics.partners.has(globals.player.id):
#									focusPerson.metrics.partners.append(globals.player.id)
#								elif !focusPerson.metrics.partners.has(ipartner):
#									focusPerson.metrics.partners.append(ipartner)
#						else:
#							focusPerson.metrics[imetric] += iperson[icategory][imetric]
#				'meters':
#					for imeter in iperson[icategory]:						
#						match imeter:
#							'stress':
#								focusPerson.stress += iperson[icategory][imeter]
#							'loyal':
#								focusPerson.loyal += iperson[icategory][imeter]
#							'lust':
#								focusPerson.lust += iperson[icategory][imeter]
#							'obedience':
#								focusPerson.obed += iperson[icategory][imeter]
#				'traits' :
#					for itrait in iperson[icategory]:
#						if iperson[icategory][itrait] == 'add':
#							focusPerson.add_trait(itrait.capitalize())
#						else:
#							focusPerson.trait_remove(itrait.capitalize())
#				'effects':
#					for ieffect in iperson[icategory]:
#						var effect = globals.effectdict[ieffect.code].duplicate()
#						if ieffect.has('duration') && ieffect['duration'] < 0:
#							focusPerson.add_effect(effect, true)					
#						else:
#							if ieffect.has('duration') && globals.effectdict[ieffect.code].has('duration'):
#								effect.duration = ieffect.duration
#							focusPerson.add_effect(effect)
#				'away':
#					focusPerson.away.at = iperson[icategory].at
#					focusPerson.away.duration = iperson[icategory].duration
#
#	return checkResult
#
##Helper Functions
#static func _find_person(id, people):
#	var	focusPerson = null		
#	var idType = id.keys().front()
#	match idType:
#		'unique': #ToFix - Should be direct get from a unique character dictionary
#			for iperson in people:
#				if iperson.unique == id[idType].capitalize():
#					focusPerson = iperson
#
#	return focusPerson