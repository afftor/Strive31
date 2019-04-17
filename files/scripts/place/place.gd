###Ku-Ku-Ku-Kurapanda!!!
### Place - Defines one visitable location, {region, area, location}?

#Dictionaries
var placeDict = {
	'nowhere' : {region = 'none', area = 'none', location = 'none'},
	'anywhere': {region = 'any', area = 'none', location = 'any'},
	
	'mansion': {region = 'mansion', area = 'mansion', location = 'any'}, #Mansion region?  It can be outside of any of the 3 starter cities?  Maybe 3 variants?
	'mansionFoyer': {region = 'mansion', area = 'mansion', location = 'foyer'},
	'mansionJail': {region = 'mansion', area = 'mansion', location = 'jail'}, #rename Prison, prison vs dungeon?
	
	'wimbornCity' : {region = 'wimborn', area = 'wimbornCity', location = 'any'},
	'gornCity' : {region = 'gorn', area = 'gornCity', location = 'any'},
	'frostfordTown': {region = 'frostford', area = 'frostfordTown', location = 'any'}
}
