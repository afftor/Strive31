extends Control

var parser = load("res://files/scripts/sexdescriptions.gd").new()

var participants = []
var givers = []
var takers = []
var turns = 0
var actions = []
var ongoingactions = []
var location
var selectmode = 'normal'
var npcs = []
var aiobserve = false #True - player will not be picked by AI

var takercategories = ['cunnilingus','rimjob','handjob','titjob','tailjob','blowjob']
var analcategories = ['assfingering','rimjob','missionaryanal','doggyanal','lotusanal','revlotusanal','doubledildoass','inerttaila','analvibrator','enemaplug','insertinturnsass']
var punishcategories = globals.punishcategories
var penetratecategories = ['missionary','missionaryanal','doggy','doggyanal','lotus','lotusanal','revlotus','revlotusanal','doubledildo','doubledildoass','inserttailv','inserttaila','tribadism','frottage']


var filter = ['nosehook','relaxinginsense','facesit','afacesit','grovel','enemaplug']

var statuseffects = ['tied', 'subdued', 'drunk', 'resist', 'sexcrazed']


var statsicons = {
	lub1 = load("res://files/buttons/sexicons/lub1.png"),
	lub2 = load("res://files/buttons/sexicons/lub2.png"),
	lub3 = load("res://files/buttons/sexicons/lub3.png"),
	lub4 = load("res://files/buttons/sexicons/lub4.png"),
	lub5 = load("res://files/buttons/sexicons/lub5.png"),
	lust1 = load("res://files/buttons/sexicons/lust1.png"),
	lust2 = load("res://files/buttons/sexicons/lust2.png"),
	lust3 = load("res://files/buttons/sexicons/lust3.png"),
	lust4 = load("res://files/buttons/sexicons/lust4.png"),
	lust5 = load("res://files/buttons/sexicons/lust5.png"),
	sens1 = load("res://files/buttons/sexicons/sens1.png"),
	sens2 = load("res://files/buttons/sexicons/sens2.png"),
	sens3 = load("res://files/buttons/sexicons/sens3.png"),
	sens4 = load("res://files/buttons/sexicons/sens4.png"),
	sens5 = load("res://files/buttons/sexicons/sens5.png"),
	stress1 = load("res://files/buttons/icons/stress/2.png"),
	stress2 = load("res://files/buttons/icons/stress/1.png"),
	stress3 = load("res://files/buttons/icons/stress/3.png"),
}


var selectedcategory = 'caress'
var categories = {caress = [], fucking = [], tools = [], SM = [], humiliation = [], other = []}

var secondactorcounter = {}

class member:
	var name
	var person
	var mood
	var submission
	var loyalty
	var lust = 0 setget lust_set
	var sens = 0 setget sens_set
	var sensmod = 1.0
	var lube = 0
	var pain = 0
	var role
	var sex
	var orgasms = 0
	var lastaction
	var request
	var requestsdone = 0
	
	var number = 0
	var sceneref
	
	var svagina = 0
	var smouth = 0
	var sclit = 0
	var sbreast = 0
	var spenis = 0
	var sanus = 0
	var lewd
	var activeactions = []
	
	var orgasm = false
	var virginitytaken = false
	
	var effects = []
	var isHandCuffed = false
	var subduedby = []
	var subduing
	
	var energy = 100
	
	
	var vagina
	var penis
	var clit
	var breast
	var feet
	var acc1
	var acc2
	var acc3
	var acc4
	var acc5
	var acc6
	var mouth
	var anus
	var tail
	var strapon
	var nipples
	var posh1
	var mode = 'normal'
	var limbs = true
	var consent = true
	var npc = false
	
	var actionshad = {addtraits = [], removetraits = [], samesex = 0, samesexorgasms = 0, oppositesex = 0, oppositesexorgasms = 0, punishments = 0, group = 0}
	
	func _init(source, fileref, isAnimal = false):
		sceneref = fileref
		person = source
		name = source.name_short()

		loyalty = source.loyal
		submission = source.obed
		lust = source.lust*10
		sens = lust/2

		sex = source.sex
		svagina = source.sensvagina
		smouth = source.sensmouth
		spenis = source.senspenis
		sanus = source.sensanal
		lewd = source.lewdness
		consent = source.consent

		if source.traits.has("Sex-crazed"):
			effects.append("sexcrazed")
		if isAnimal:
			limbs = false
		elif source != globals.player:
			if !source.consent:
				consent = false
				effects.append('forced')
				person.metrics.roughsex += 1
			if fileref.calcResistWill(self) > 0:
				effects.append('resist')
			for i in person.gear.values():
				if i == null:
					continue
				var tempitem = globals.state.unstackables.get(i)
				if tempitem != null && tempitem.code == 'acchandcuffs':
					isHandCuffed = true
					break

	func lust_set(value):
		lust = min(value, 1000)
	
	func sens_set(value):
		var change = value - sens
		sens += change*sensmod
		if sens >= 1000:
			if ((lastaction.givers.has(self) && lastaction.scene.givertags.has('noorgasm')) || (lastaction.takers.has(self) && lastaction.scene.takertags.has('noorgasm'))):
				return
			sens = 100
			sensmod -= sensmod*0.2
			orgasm()
	
	func lube():
		if person.vagina != 'none':
			lube = lube + (sens/200)
			lube = min(5+lewd/20,lube)
	
	func orgasm():
		var text = ''
		orgasm = true
		if person.sexexp.orgasms.has(lastaction.scene.code):
			person.sexexp.orgasms[lastaction.scene.code] += 1
		else:
			person.sexexp.orgasms[lastaction.scene.code] = 1
		for k in lastaction.givers + lastaction.takers:
			if self != k:
				if person.sexexp.orgasmpartners.has(k.person.id):
					person.sexexp.orgasmpartners[k.person.id] += 1
				else:
					person.sexexp.orgasmpartners[k.person.id] = 1
		
		var scene
		var temptext = ''
		var penistext = ''
		var vaginatext = ''
		var anustext = ''
		orgasms += 1
		person.metrics.orgasm += 1
		if sceneref.participants.size() == 2 && person != globals.player:
			if person.traits.has("Monogamous") && (sceneref.participants[0].person == globals.player || sceneref.participants[1].person == globals.player):
				person.loyal += rand_range(1.4,5.6)
			else:
				person.loyal += rand_range(1,4)
		elif person != globals.player:
			person.loyal += rand_range(1,2)
		#anus in use, find scene
		if anus != null:
			scene = anus
			for i in scene.givers:
				globals.addrelations(person, i.person, rand_range(30,50))
			#anus in giver slot
			if scene.givers.find(self) >= 0:
				if randf() < 0.4:
					anustext = "[name1] feel[s/1] a {^sudden :intense ::}{^jolt of electricity:warmth:wave of pleasure} inside [him1] and [his1]"
				else:
					anustext = "[names1]"
				if scene.scene.takerpart == 'penis':
					anustext += " [anus1] {^squeezes:writhes around:clamps down on} [names2] [penis2] as [he1] reach[es/1] {^climax:orgasm}."
				else:
					anustext += " [anus1] {^convulses:twitches:quivers} {^in euphoria:in ecstasy:with pleasure} as [he1] reach[es/1] {^climax:orgasm}."
				anustext = sceneref.decoder(anustext, [self], scene.takers)
			#anus is in taker slot
			elif scene.takers.find(self) >= 0:
				if randf() < 0.4:
					anustext = "[name2] feel[s/2] a {^sudden :intense ::}{^jolt of electricity:warmth:wave of pleasure} inside [him2] and [his2]"
				else:
					anustext = "[names2]"
				if scene.scene.giverpart == 'penis':
					anustext += " [anus2] {^squeezes:writhes around:clamps down on} [names1] [penis1] as [he2] reach[es/2] {^climax:orgasm}."
				else:
					anustext += " [anus2] {^convulses:twitches:quivers} {^in euphoria:in ecstasy:with pleasure} as [he2] reach[es/2] {^climax:orgasm}."
				anustext = sceneref.decoder(anustext, scene.givers, [self])
			#no default conditon
		#vagina present
		if person.vagina != 'none':
			lube()
			#vagina in use, find scene
			if vagina != null:
				scene = vagina
				for i in scene.givers:
					globals.addrelations(person, i.person, rand_range(30,50))
				#vagina in giver slot
				if scene.givers.find(self) >= 0:
					if randf() < 0.4:
						vaginatext = "[name1] feel[s/1] a {^sudden :intense ::}{^jolt of electricity:warmth:wave of pleasure} inside [him1] and [his1]"
					else:
						vaginatext = "[names1]"
					if scene.scene.takerpart == 'penis':
						vaginatext += " [pussy1] {^squeezes:writhes around:clamps down on} [names2] [penis2] as [he1] reach[es/1] {^climax:orgasm}."
					else:
						vaginatext += " [pussy1] {^convulses:twitches:quivers} {^in euphoria:in ecstasy:with pleasure} as [he1] reach[es/1] {^climax:orgasm}."
					vaginatext = sceneref.decoder(vaginatext, [self], scene.takers)
				#vagina is in taker slot
				elif scene.takers.find(self) >= 0:
					if randf() < 0.4:
						vaginatext = "[name2] feel[s/2] a {^sudden :intense ::}{^jolt of electricity:warmth:wave of pleasure} inside [him2] and [his2]"
					else:
						vaginatext = "[names2]"
					if scene.scene.giverpart == 'penis':
						vaginatext += " [pussy2] {^squeezes:writhes around:clamps down on} [names1] [penis1] as [he2] reach[es/2] {^climax:orgasm}."
					else:
						vaginatext += " [pussy2] {^convulses:twitches:quivers} {^in euphoria:in ecstasy:with pleasure} as [he2] reach[es/2] {^climax:orgasm}."
					vaginatext = sceneref.decoder(vaginatext, scene.givers, [self])
				#no default conditon
		#penis present
		if person.penis != 'none':
			#penis in use, find scene
			if penis != null:
				scene = penis
				for i in scene.takers:
					globals.addrelations(person, i.person, rand_range(30,50))
				#penis in giver slot
				if scene.givers.find(self) >= 0:
					if randf() < 0.4:
						penistext = "[name1] feel[s/1] {^a wave of:an intense} {^pleasure:euphoria} {^run through:course through:building in} [his1] [penis1] and [his1]"
					else:
						penistext = "[name1] {^thrust:jerk}[s/1] [his1] hips forward and a {^thick :hot :}{^jet:load:batch} of"
					if scene.scene.takerpart == '':
						penistext += " {^semen:seed:cum} {^pours onto:shoots onto:falls to} the {^ground:floor} as [he1] ejaculate[s/1]."
					elif ['anus','vagina','mouth'].has(scene.scene.takerpart):
						if scene.scene.get('takerpart2') && scene.scene.givers.size() == 2 && scene.scene.givers[1] == self:
							temptext = scene.scene.takerpart2.replace('anus', '[anus2]').replace('vagina','[pussy2]')
						else:
							temptext = scene.scene.takerpart.replace('anus', '[anus2]').replace('vagina','[pussy2]')
							if scene.scene.takerpart == 'vagina':
								for i in scene.takers:
									if sceneref.impregnationcheck(i.person, person) == true:
										globals.impregnation(i.person, person)
						penistext += " {^semen:seed:cum} {^pours:shoots:pumps:sprays} into [names2] " + temptext + " as [he1] ejaculate[s/1]."
					elif scene.scene.takerpart == 'nipples':
						penistext += " {^semen:seed:cum} fills [names2] hollow nipples. "
					elif scene.scene.takerpart == 'penis':
						penistext += " {^semen:seed:cum} {^pours:shoots:sprays}, covering [names2] [penis2]. "
					penistext = sceneref.decoder(penistext, [self], scene.takers)
				#penis in taker slot
				elif scene.takers.find(self) >= 0:
					if randf() < 0.4:
						penistext = "[name2] feel[s/2] {^a wave of:an intense} {^pleasure:euphoria} {^run through:course through:building in} [his2] [penis2] and [his2]"
					else:
						penistext = "[name2] {^thrust:jerk}[s/2] [his2] hips forward and a {^thick :hot :}{^jet:load:batch} of"
					if scene.scene.code in ['handjob','titjob']:
						penistext += " {^sticky:white:hot} {^semen:seed:cum} {^sprays onto:shoots all over:covers} [names1] face[/s1] as [he2] ejaculate[s/2]."
					elif scene.scene.code == 'tailjob':
						penistext += " {^sticky:white:hot} {^semen:seed:cum} {^sprays onto:shoots all over:covers} [names1] tail[/s1] as [he2] ejaculate[s/2]."
					elif scene.scene.giverpart == '':
						penistext += " {^semen:seed:cum} {^pours onto:shoots onto:falls to} the {^ground:floor} as [he2] ejaculate[s/2]."
					elif scene.scene.giverpart == 'penis':
						penistext += " {^semen:seed:cum} {^pours:shoots:sprays}, covering [names1] [penis1]. "
					elif ['anus','vagina','mouth'].has(scene.scene.giverpart):
						temptext = scene.scene.giverpart.replace('anus', '[anus1]').replace('vagina','[pussy1]')
						penistext += " {^semen:seed:cum} {^pours:shoots:pumps:sprays} into [names1] " + temptext + " as [he2] ejaculate[s/2]."
						if scene.scene.giverpart == 'vagina':
							for i in scene.givers:
								if sceneref.impregnationcheck(i.person, person) == true:
									globals.impregnation(i.person, person)
					penistext = sceneref.decoder(penistext, scene.givers, [self])
			#orgasm without penis, secondary ejaculation
			else:
				if randf() < 0.4:
					penistext = "[name2] {^twist:quiver:writhe}[s/2] in {^pleasure:euphoria:ecstacy} as"
				else:
					penistext = "[name2] {^can't hold back any longer:reach[es/2] [his2] limit} and"
				penistext += " {^a jet of :a rope of :}{^semen:cum} {^fires:squirts:shoots} from {^the tip of :}[his2] {^neglected :throbbing ::}[penis2]."
				penistext = sceneref.decoder(penistext, [], [self])
		var tempPool = PoolStringArray()
		if !vaginatext.empty():
			tempPool.append(vaginatext)
		if !anustext.empty():
			tempPool.append(anustext)
		if !penistext.empty():
			tempPool.append(penistext)
		if tempPool.size() > 0:
			text += tempPool.join(" ")
		#final default condition
		else:
			if randf() < 0.4:
				temptext = "[name2] feel[s/2] {^a sudden :an intense ::}{^jolt of electricity:heat:wave of pleasure} and [his2]"
			else:
				temptext = "[names2]"
			temptext += " {^entire :whole :}body {^twists:quivers:writhes} in {^pleasure:euphoria:ecstacy} as [he2] reach[es/2] {^climax:orgasm}."
			text += sceneref.decoder(temptext, [], [self])
		
		
		if lastaction.scene.code in sceneref.punishcategories && lastaction.takers.has(self):
			if randf() >= 0.85 || person.effects.has("entranced"):
				actionshad.addtraits.append("Masochist")
	#	if member.lastaction.scene.code in punishcategories && member.lastaction.givers.has(member) && member.person.asser >= 60:
	#		if randf() >= 0.85 || member.person.effects.has("entranced"):
	#			member.actionshad.addtraits.append("Dominant")
		if lastaction.scene.code in sceneref.analcategories && (lastaction.takers.has(self) || lastaction.scene.code == 'doubledildoass'):
			if randf() >= 0.85 || person.effects.has('entranced'):
				actionshad.addtraits.append("Enjoys Anal")
		if sceneref.isencountersamesex(lastaction.givers, lastaction.takers, self) == true:
			actionshad.samesexorgasms += 1
		else:
			actionshad.oppositesexorgasms += 1
		
		
		#return 
		yield(sceneref.get_tree().create_timer(0.1), "timeout")
		sceneref.get_node("Panel/sceneeffects").bbcode_text += "[color=#ff5df8]" + text + "[/color]\n"
	
	
	func actioneffect(acceptance, values, scenedict):
		for key in ['lewd', 'lust', 'sens', 'pain', 'obed', 'stress']:
			values[key] = float(values.get(key, 0))
		lastaction = scenedict
		
		if scenedict.scene.code in globals.punishcategories:
			if scenedict.givers.has(self):
				person.asser += rand_range(1,2)
			else:
				person.asser -= rand_range(1,2)
		
		if acceptance == 'good':
			values.sens *= rand_range(1.1,1.4)
			values.lust *= 2
			
			if lewd < 50 || scenedict.scene.code in ['doublepen','nipplefuck', 'spitroast', 'spitroastass', 'inserttailv', 'inserttaila','doubledildo','doubledildoass','tailjob','footjob','deepthroat']:
				lewd += rand_range(1,3)
			
			for i in scenedict.givers + scenedict.takers:
				if i != self:
					globals.addrelations(person, i.person, rand_range(4,8))
		elif acceptance == 'average':
			values.sens *= 1.1
			#values.lust *= 1
			
			if lewd < 50 || scenedict.scene.code in ['doublepen','nipplefuck', 'spitroast', 'spitroastass', 'inserttailv', 'inserttaila','doubledildo','doubledildoass','tailjob','footjob','deepthroat']:
				lewd += rand_range(1,2)
			
			for i in scenedict.givers + scenedict.takers:
				if i != self:
					globals.addrelations(person, i.person, rand_range(2,4))
			if values.pain > 0.0:
				person.stress += rand_range(0,2)
		else:
			values.sens *= 0.6
			values.lust *= 0.3
			for i in scenedict.givers + scenedict.takers:
				if i != self:
					globals.addrelations(person, i.person, -rand_range(3,5))
			if values.pain > 0.0:
				if effects.has('resist'):
					person.stress += rand_range(5,10)
				else:
					person.stress += rand_range(2,4)
		
		if self in scenedict.takers:
			if scenedict.scene.giverpart == 'mouth':
				for giver in scenedict.givers:
					if giver.person.mods.has("augmenttongue"):
						values.sens *= 1.3
						break
		else:
			if scenedict.scene.takerpart == 'mouth' || (scenedict.scene.get('takerpart2') != null && scenedict.scene.takerpart2 == 'mouth' && scenedict.givers.size == 2 && self == scenedict.givers[1]):
				for taker in scenedict.takers:
					if taker.person.mods.has("augmenttongue"):
						values.sens *= 1.3
						break

		if values.has('tags'):
			if values.tags.has('punish'):
				if (effects.has('resist') || effects.has('forced')) && (!person.traits.has('Masochist') && !person.traits.has('Likes it rough') && !person.traits.has('Sex-crazed') && person.spec != 'nympho'):
					for i in scenedict.givers:
						globals.addrelations(person, i.person, -rand_range(5,10))
					if values.stress == 0.0:
						values.stress = rand_range(3,5)
					if person.effects.has("captured") && rand_range(0,50) <= values.obed + 5:
						person.effects.captured.duration -= 1
					values.lust /= 4
					values.sens /= 4
				else:
					if person.asser < 35 && randf() < 0.1:
						actionshad.addtraits.append('Likes it rough')
					if !person.traits.has('Masochist') && !person.traits.has('Sex-crazed') && person.spec != 'nympho':
						if values.stress == 0.0:
							values.stress = rand_range(2,4)
					else:
						values.stress = 0.0
			if values.tags.has('pervert') && !person.traits.has('Pervert'):
				if person.traits.has('Sex-crazed') || person.spec in ['geisha','nympho']:
					if lust >= 750 && randf() < 0.2:
						actionshad.addtraits.append("Pervert")
				elif acceptance == 'good':
					if lust >= 750 && randf() < 0.2:
						actionshad.addtraits.append("Pervert")
					else:
						values.stress += rand_range(2,4)
				else:
					values.sens /= 1.75
					values.stress += rand_range(2,4)
			if values.tags.has('group'):
				actionshad.group += 1
		
		self.lewd += values.lewd
		self.lust += values.lust
		self.sens += values.sens
		person.obed += values.obed
		person.stress += values.stress
		
		if values.get('obed', 0) > 0 && effects.has('resist') && sceneref.calcResistWill(self) < 0 && person != globals.player:
			var text = ''
			text += "\n[color=green]Afterward, {^[name2] seems to have:it looks as though [name2] [has2]} {^learned [his2] lesson:reformed [his2] rebellious ways:surrendered} and shows {^complete:total} {^submission:obedience:compliance}"
			if person.traits.find("Masochist") >= 0:
				text += ", but there is also {^an unusual:a strange} {^flash:hint:look} of desire in [his2] eyes"
			text += '. [/color]'
			#yield(sceneref.get_tree().create_timer(0.1), "timeout")
			effects.erase('resist')
			sceneref.get_node("Panel/sceneeffects").bbcode_text += sceneref.decoder(text, scenedict.givers, scenedict.takers) + '\n'
		

func dog():
	var person = globals.newslave( globals.randomfromarray(globals.allracesarray), 'adult', 'male')
	person.obed = 90
	person.lewdness = 70
	person.penistype = 'canine'
	person.name = "Dog " + str(secondactorcounter.dog)
	person.penis = globals.weightedrandom([['average',1],['big',1]])
	person.asser = rand_range(65, 100)
	person.unique = 'dog'
	person.imageportait = null
	person.imagefull = null
	for i in categories.fucking:
		person.sexexp.actions[i.code] = 15
	participants.append( member.new(person, self, true) )

func horse():
	var person = globals.newslave( globals.randomfromarray(globals.allracesarray), 'adult', 'male')
	person.obed = 90
	person.lewdness = 70
	person.penistype = 'equine'
	person.asser = rand_range(65, 100)
	person.name = "Horse " + str(secondactorcounter.horse)
	person.height = 'tall'
	person.penis = 'big'
	person.unique = 'horse'
	person.imageportait = null
	person.imagefull = null
	for i in categories.fucking:
		person.sexexp.actions[i.code] = 15
	participants.append( member.new(person, self, true) )


func _ready():
	for i in globals.dir_contents('res://files/scripts/actions'):
		if i.find('.remap') >= 0:
			continue
		var newaction = load(i).new()
		categories[newaction.category].append(newaction)
	for i in get_node("Panel/HBoxContainer").get_children():
		i.connect("pressed",self,'changecategory',[i.get_name()])
	
	filter = globals.state.actionblacklist
	
	var i = 4
	if globals.player.name == '':
		globals.itemdict.supply.amount = 10
		globals.itemdict.rope.amount = 10
		while i > 0:
			i -= 1
			createtestdummy()

		turns = variables.timeforinteraction
		createtestdummy('resist')
		changecategory('caress')
		clearstate()
		#$Panel/sceneeffects.bbcode_text = '1' + '[img]' + add_portrait_to_text(participants[0]) + '[/img]' 
		rebuildparticipantslist()

func add_portrait_to_text(member):
	var newimage = Image.new()
	if !File.new().file_exists(member.person.imageportait):
		return
	newimage.load(member.person.imageportait)
	var subimage = ImageTexture.new()
	subimage.create_from_image(newimage)
	subimage.set_size_override(Vector2(24,24))
	$Panel/sceneeffects.add_image(subimage)

func _input(event):
	if !event is InputEventKey || is_visible_in_tree() == false:
		return
	var dict = {49 : 1, 50 : 2, 51 : 3, 52 : 4,53 : 5,54 : 6,55 : 7,56 : 8, 16777351 :1, 16777352 : 2, 16777353 : 3, 16777354 : 4, 16777355 : 5, 16777356: 6, 16777357: 7, 16777358: 8}
	if event.scancode in dict:
		var key = dict[event.scancode]
		if event.is_action_pressed(str(key)) == true && participants.size() >= key:
			if !givers.has(participants[key-1]) && !takers.has(participants[key-1]):
				$Panel/givetakepanel/ScrollContainer/VList.get_child(key).get_node("ButtonGiver").emit_signal("pressed")
			else:
				$Panel/givetakepanel/ScrollContainer/VList.get_child(key).get_node("ButtonReceiver").emit_signal("pressed")
	if event.is_action_pressed("F") && $Panel/passbutton.disabled == false:
		_on_passbutton_pressed()

var dummycounter = 0

func createtestdummy(type = 'normal'):
	var person = globals.newslave( globals.randomfromarray(globals.allracesarray), 'random', 'random')
	person.lewdness = 70
	person.mods['hollownipples'] = 'hollownipples'
	#person.sex = 'male'
	if type == 'resist':
		person.obed = 0
		person.consent = false
	else:
		person.obed = 90
		person.consent = true
#	if participants.size() > 0:
#		person.sex = 'female'
#		globals.connectrelatives(participants[0].person, person, 'father')
	
	var newmember = member.new(person, self)
	newmember.number = dummycounter
	dummycounter += 1
	participants.append(newmember)


func startsequence(actors, mode = null, secondactors = [], otheractors = []):
	participants.clear()
	secondactorcounter.clear()
	$Panel/sceneeffects.clear()
	get_node("Control").hide()
	for person in actors:
		for i in actors + secondactors:
			if person != i:
				person.sexexp.watchers[i.id] = person.sexexp.watchers.get(i.id, 0) + 1
		person.recordInteraction()
		person.metrics.sex += 1
		participants.append( member.new(person, self) )

	$Panel/aiallow.pressed = aiobserve
	get_node("Panel/sceneeffects").set_bbcode("You bring selected participants into your bedroom. ")
	for i in otheractors:
		while otheractors[i] > 0:
			if self.has_method(i):
				secondactorcounter[i] = secondactorcounter.get(i, 0) + 1
				call(i)
				participants[participants.size()-1].npc = true
			otheractors[i] -= 1
	
	var counter = 0
	for i in participants:
		i.person.attention = 0
		i.number = counter
		counter += 1
	turns = variables.timeforinteraction
	if actors.size() > 4:
		turns += variables.bonustimeperslavefororgy * actors.size()
		for person in actors:
			person.metrics.orgy += 1
	changecategory('caress')
	clearstate()
	rebuildparticipantslist()


func clearstate():
	givers.clear()
	takers.clear()
	if givers.size() >= 1:
		givers.append(participants[0])

func changecategory(name):
	selectedcategory = name
	for i in get_node("Panel/HBoxContainer").get_children():
		i.set_pressed( i.get_name() == name )
	rebuildparticipantslist()

func rebuildparticipantslist():
	var newnode
	var effects
	if selectmode == 'ai':
		clearstate()
	for i in get_node("Panel/ScrollContainer/VBoxContainer").get_children() + get_node("Panel/GridContainer/GridContainer").get_children() + get_node("Panel/givetakepanel/ScrollContainer/VList").get_children() + $Panel/GridContainer2/GridContainer.get_children():
		if !i.get_name() in ['Panel', 'Button', 'ControlLine']:
			i.hide()
			i.queue_free()
	for i in participants:
		newnode = get_node("Panel/ScrollContainer/VBoxContainer/Panel").duplicate()
		newnode.visible = true
		get_node("Panel/ScrollContainer/VBoxContainer").add_child(newnode)
		newnode.get_node("name").set_text(i.person.dictionary('$name'))
		newnode.get_node("name").connect("pressed",self,"slavedescription",[i])
		newnode.set_meta("person", i)
		newnode.get_node("sex").set_texture(globals.sexicon[i.person.sex])
		newnode.get_node("sex").set_tooltip(i.person.sex)
		newnode.get_node('arousal').value = i.sens
		newnode.get_node("portrait").texture = globals.loadimage(i.person.imageportait)
		newnode.get_node("portrait").connect("mouse_entered",self,'showbody',[i])
		newnode.get_node("portrait").connect("mouse_exited",self,'hidebody')
		
		if i.request != null:
			newnode.get_node('desire').show()
			newnode.get_node('desire').hint_tooltip = i.person.dictionary(requests[i.request])
		
		for k in i.effects:
			newnode.get_node(k).visible = true
		
#		if ai.has(i):
#			newnode.get_node('name').set('custom_colors/font_color', Color(1,0.2,0.8))
#			newnode.get_node('name').hint_tooltip = 'Leads'
		
		newnode = get_node("Panel/givetakepanel/ScrollContainer/VList/ControlLine").duplicate()
		var giveNode = newnode.get_node("ButtonGiver")
		var takeNode = newnode.get_node("ButtonReceiver")
		giveNode.set_pressed(givers.has(i))
		takeNode.set_pressed(takers.has(i))
		giveNode.text = i.person.name_short()
		takeNode.text = i.person.name_short()
		giveNode.connect("pressed",self,'switchsides',[i, 'give'])
		takeNode.connect("pressed",self,'switchsides',[i, 'take'])
		newnode.visible = true
		get_node("Panel/givetakepanel/ScrollContainer/VList").add_child(newnode)

	
	#check for double dildo scenes between participants
	var actionarray = []
	for i in categories:
		for k in categories[i]:
			actionarray.append(k)
	actionarray.sort_custom(self, 'sortactions')
	
	var actionreplacetext = ''
	
	for i in givers:
		if i.effects.has('tied'):
			actionreplacetext = i.person.dictionary("$name is tied and can't act.")
		elif !i.subduedby.empty():
			actionreplacetext = i.person.dictionary("$name is struggling and can't act.")
		elif i.effects.has('resist'):
			actionreplacetext = i.person.dictionary("$name resists and won't follow any orders.")
		elif i.subduing != null && ((takers.size() == 1 && takers[0] != i.subduing) || takers.size() > 1 ):
			actionreplacetext = i.person.dictionary("$name is busy holding down ") + i.subduing.person.dictionary("$name \nand can only act on $him. ")
	
	var array = []
	var bottomrow =  ['rope', 'subdue', 'strapon']

	if actionreplacetext.empty():
		for i in actionarray:
			var result = checkaction(i)
			if result[0] == 'false' || i.code in ['wait'] || (selectedcategory != i.category && !i.code in bottomrow ):
				continue
			if i.code in bottomrow :
				newnode = get_node("Panel/GridContainer2/GridContainer/Button").duplicate()
				get_node("Panel/GridContainer2/GridContainer").add_child(newnode)
			else:
				newnode = get_node("Panel/GridContainer/GridContainer/Button").duplicate()
				get_node("Panel/GridContainer/GridContainer").add_child(newnode)
			newnode.visible = true
			newnode.set_text(i.getname())
			var tooltip = i.getname()
			if result.size() == 2 && !result[1].empty():
				tooltip += ' - ' + result[1]
			if i.code == 'rope':
				tooltip += '\nFree Ropes left: ' + str(globals.state.getCountStackableItem('rope'))
			if result[0] == 'disabled':
				newnode.disabled = true
			else:
				var conflicts = getConflictsWithOngoing(i)
				if !conflicts.empty():
					tooltip += '\nConflicts:'
					for idx in range(conflicts.size()):
						if idx % 3 == 0:
							tooltip += '\n     '
						tooltip += conflicts[idx].action.scene.getname() + ', '
					tooltip = tooltip.substr(0, tooltip.length() - 2)
			newnode.hint_tooltip = tooltip
			
			newnode.connect("pressed",self,'startscene',[i])
			if i.canlast == true && newnode.disabled == false:
				newnode.get_node("continue").visible = true
				newnode.get_node("continue").connect("pressed",self,'startscenecontinue',[i])
			for j in ongoingactions:
				if j.scene.code != i.code:
					continue
				if j.givers.size() != i.givers.size() || j.takers.size() != i.takers.size():
					continue
				if getIntersection(j.givers, i.givers).size() != j.givers.size():
					continue
				if getIntersection(j.takers, i.takers).size() == j.takers.size():
					newnode.get_node("continue").pressed = true
		if selectmode != 'ai':
			var noPlayerFound = true
			for member in givers:
				if member.person == globals.player:
					noPlayerFound = false
					break
			if !givers.empty() && noPlayerFound:
				newnode = get_node("Panel/GridContainer2/GridContainer/Button").duplicate()
				get_node("Panel/GridContainer2/GridContainer").add_child(newnode)
				newnode.visible = true
				if givers.size() == 1:
					newnode.set_text(givers[0].person.dictionary("Let $name Lead"))
				else:
					newnode.set_text("Let Actors Lead")
				newnode.connect("pressed",self,'activateai')
				for i in givers:
					if i.effects.has('resist') || i.effects.has('forced'):
						newnode.hint_tooltip = i.person.dictionary('$name refuses to participate. ')
						newnode.disabled = true
						break
					if i.effects.has('tied') || !i.subduedby.empty():
						newnode.hint_tooltip = i.person.dictionary("$name is immobile and can't do anything. ")
						newnode.disabled = true
						break
		else:
			newnode = get_node("Panel/GridContainer/GridContainer/Button").duplicate()
			get_node("Panel/GridContainer/GridContainer").add_child(newnode)
			newnode.visible = true
			newnode.set_text("Stop")
			newnode.connect("pressed",self,'activateai')
	else:
		newnode = Label.new()
		get_node("Panel/GridContainer/GridContainer").add_child(newnode)
		newnode.visible = true
		#newnode.disabled = true
		newnode.set_text(actionreplacetext)
	$Panel/GridContainer/GridContainer.move_child($Panel/GridContainer/GridContainer/Button, $Panel/GridContainer/GridContainer.get_child_count()-1)
	$Panel/GridContainer2/GridContainer.move_child($Panel/GridContainer2/GridContainer/Button, $Panel/GridContainer2/GridContainer.get_child_count()-1)

	var text = ''
	if givers.empty():
		text += '[...] '
	else:
		for i in givers:
			text += '[color=yellow]' + i.name + '[/color], '
	text += 'will do it ... to '

	if takers.empty():
		text += "[...]"
	else:
		for i in takers:
			text += '[color=aqua]' + i.name + '[/color], '
		text = text.substr(0, text.length() -2)+ '. '

	text += "\n\n"
	for i in ongoingactions:
		text += decoder(i.scene.getongoingname(i.givers,i.takers), i.givers, i.takers) + ' [url='+str(ongoingactions.find(i))+'][Interrupt][/url]\n'
	
	get_node("Panel/passbutton").set_disabled( givers.empty() && selectmode != 'ai' )
	
	if selectmode == 'ai':
		$Panel/passbutton.set_text("Observe")
	else:
		$Panel/passbutton.set_text("Pass")
	
	get_node("TextureFrame/Label").set_text(str(turns))
	
	get_node("Panel/sceneeffects1").set_bbcode(text)
	
	globals.state.actionblacklist = filter
	
	if turns == 0:
		endencounter()

var categoriesorder = ['caress', 'fucking', 'tools', 'SM', 'humiliation']

func sortactions(first, second):
	var cmpCat = categoriesorder.find(first.category) - categoriesorder.find(second.category)
	if cmpCat == 0:
		if first.get('order') == null:
			return false
		if second.get('order') == null:
			return true
		return first.order < second.order
	return cmpCat < 0

var requests = {
	pet = "$name wishes to be touched.",
	petgive = '$name wishes to touch.',
	fuck = '$name wishes to be penetrated.',
	fuckgive = '$name wishes to penetrate.',
	pussy = "$name wishes to have $his pussy used.",
	penis = '$name wishes to use $his penis.',
	anal = '$name wishes to have $his ass used.',
	punish = '$name wishes to be punished.',
	humiliate = '$name wishes to be humiliated.',
	group = '$name wishes to have multiple partners.'
}

func generaterequest(member):
	var rval = requests.keys()
	
	if member.person.vagvirgin == true:
		rval.erase('fuck')
	if member.person.penis == 'none':
		rval.erase('penis')
	if member.person.penis == 'none' && member.strapon == null:
		rval.erase('fuckgive')
	if member.person.vagina == 'none':
		rval.erase('pussy')
	if member.person.traits.has('Dominant'):
		rval.erase('humiliate')
	if !member.person.traits.has('Likes it rough') && !member.person.traits.has('Masochist'):
		rval.erase('punish')
	if member.person.traits.has('Monogamous') || participants.size() == 2 || (!member.person.traits.has('Fickle') && member.lewd < 50):
		rval.erase('group')
	
	
	rval = rval[randi()%rval.size()]
	
	$Panel/sceneeffects.bbcode_text += ("[color=#f4adf4]Desire: " + member.person.dictionary(requests[rval]) + '[/color]\n')
	
	member.request = rval

func checkrequest(member):
	
	if member.request == null:
		return false
	
	var conditionsatisfied = false
	
	var lastaction = member.lastaction
	
	match member.request:
		'pet':
			if lastaction.takers.has(member) && lastaction.scene.get('takertags') != null && lastaction.scene.takertags.has('pet'):
				conditionsatisfied = true
		'petgive':
			if lastaction.givers.has(member) && lastaction.scene.get('givertags') != null && lastaction.scene.givertags.has('pet'):
				conditionsatisfied = true
		'fuck':
			if lastaction.takers.has(member) && lastaction.scene.get('takertags') != null && lastaction.scene.takertags.has('penetration'):
				conditionsatisfied = true
		'fuckgive':
			if lastaction.givers.has(member) && lastaction.scene.get('takertags') != null && lastaction.scene.takertags.has('penetration'):
				conditionsatisfied = true
		'pussy':
			if lastaction.scene.get('givertags') != null && (lastaction.scene.givertags.has('vagina') || lastaction.scene.takertags.has('vagina')) :
				conditionsatisfied = true
		'penis':
			if lastaction.scene.get('givertags') != null && (lastaction.scene.givertags.has('penis') || lastaction.scene.takertags.has('penis')) :
				conditionsatisfied = true
		'anal':
			if lastaction.scene.get('givertags') != null && (lastaction.scene.givertags.has('anal') || lastaction.scene.takertags.has('anal')) :
				conditionsatisfied = true
		'punish':
			if lastaction.takers.has(member) && lastaction.scene.get('takertags') != null && lastaction.scene.takertags.has('punish'):
				conditionsatisfied = true
		'humiliate':
			if lastaction.takers.has(member) && lastaction.scene.get('takertags') != null && lastaction.scene.takertags.has('shame'):
				conditionsatisfied = true
		'group':
			if (lastaction.givers.has(member) && lastaction.takers.size() > 1) || (lastaction.takers.has(member) && lastaction.givers.size() > 1):
				conditionsatisfied = true
	
	
	if conditionsatisfied == true:
		member.request = null
		member.requestsdone += 1
		#$Panel/sceneeffects.bbcode_text += '[color=green]Wish satisfied.[/color]\n'
		#globals.resources.mana += 10
		if member.person.traits.has("Monogamous") && lastaction.takers.size() == 1 && lastaction.givers.size() == 1 && (lastaction.givers[0].person == globals.player || lastaction.takers[0].person == globals.player):
			member.person.loyal += rand_range(7,14)
		else:
			member.person.loyal += rand_range(5,10)
		member.lewd += rand_range(3,6)
		member.sensmod += 0.2
	return conditionsatisfied

var ai = []

func activateai():
	ai.clear()
	for member in participants:
		member.role = 'none'
	if selectmode != 'ai':
		selectmode = 'ai'
		for i in givers:
			ai.append(i)
	else:
		selectmode = 'normal'
	rebuildparticipantslist()


func doubledildocheck():
	var givercheck = false
	for scene in ongoingactions:
		if !scene.scene.code in ['doubledildo','doubledildoass','tribadism','frottage']:
			continue
		for i in givers:
			if scene.givers.has(i) || scene.takers.has(i):
				givercheck = true
		if !givercheck:
			continue
		for i in takers:
			if scene.givers.has(i) || scene.takers.has(i):
				return true
		givercheck = false
	return false

func checkaction(action):
	action.givers = givers
	action.takers = takers
	if action.requirements() == false || filter.has(action.code):
		return ['false']
#	elif doubledildocheck() && action.category in ['caress','fucking'] && !action.code in ['doubledildo','doubledildoass','tribadism','frottage']:
#		return ['false']
	if action.category in ['SM','tools','humiliation']:
		for k in givers+takers:
			if k.limbs == false:
				return ['false']
	var disabled = false
	var hint_tooltip = ''
	for k in givers:
		if k.person == globals.player:
			continue
		if action.giverconsent != 'any' && k.effects.has('resist'):
			disabled = true
			hint_tooltip = k.person.dictionary("$name refuses to perform this action (high resistance: low obedience, loyalty, or lust)")
		elif action.giverconsent == 'advanced' && k.lewd < 50:
			disabled = true
			hint_tooltip = k.person.dictionary("$name refuses to perform this action (low lewdness)")
	for k in takers:
		if k.person == globals.player:
			continue
		if action.takerconsent == 'any' && k.effects.has('resist') && action.code != 'subdue':
			if k.subduedby.empty() && !k.effects.has('tied') || (action.code == 'deepthroat' && k.acc1 == null):
				hint_tooltip = k.person.dictionary("$name refuses to perform this action (high resistance: low obedience, loyalty, or lust)")
				disabled = true
			else:
				hint_tooltip = k.person.dictionary("$name refuses to perform this action, but is being restrained")
		elif action.takerconsent != 'any' && k.effects.has('resist'):
			disabled = true
			hint_tooltip = k.person.dictionary("$name refuses to perform this action (high resistance: low obedience, loyalty, or lust)")
		elif action.takerconsent == 'advanced' && k.lewd < 50:
			disabled = true
			hint_tooltip = k.person.dictionary("$name refuses to perform this action (low lewdness)")
	if disabled:
		return ['disabled',hint_tooltip]
	else:
		return ['allowed',hint_tooltip]


func slavedescription(member):
	if !member.person.unique in ['dog','horse']:
		get_parent().popup(member.person.descriptionsmall())

var nakedspritesdict = globals.gallery.nakedsprites

func showbody(i):
	if globals.loadimage(i.person.imagefull) != null:
		$Panel/bodyimage.visible = true
		$Panel/bodyimage.texture = globals.loadimage(i.person.imagefull)
	elif nakedspritesdict.has(i.person.unique):
		if i.effects.has('resist'):
			$Panel/bodyimage.texture = globals.spritedict[nakedspritesdict[i.person.unique].rape]
		else:
			$Panel/bodyimage.texture = globals.spritedict[nakedspritesdict[i.person.unique].cons]
		$Panel/bodyimage.visible = true

func hidebody():
	$Panel/bodyimage.visible = false


func switchsides(member, side):
	givers.erase(member)
	takers.erase(member)
	if member.role == side:
		member.role = 'none'
	else:
		member.role = side
	if member.role == 'give':
		givers.append(member)
	elif member.role == 'take':
		takers.append(member)
	rebuildparticipantslist()

func getIntersection(array1, array2):
	var intersection = []
	for i in array1:
		if array2.has(i):
			intersection.append(i)
	return intersection

func getConflictsWithOngoing(scenescript):
	var conflicts = []
	var set1
	var set2

	if !scenescript.giverpart.empty():
		for i in givers:
			if i[scenescript.giverpart] != null:
				conflicts.append({'action': i[scenescript.giverpart], 'givers': [i], 'takers': []})
	if !scenescript.takerpart.empty():
		for i in takers:
			if i[scenescript.takerpart] != null:
				conflicts.append({'action': i[scenescript.takerpart], 'givers': [], 'takers': [i]})
	if scenescript.get('takerpart2') != null && !scenescript.takerpart2.empty():
		for i in takers:
			if i[scenescript.takerpart2] != null:
				conflicts.append({'action': i[scenescript.takerpart2], 'givers': [], 'takers': [i]})

	#handle action conflict not covered by part overlaps
	if scenescript.giverpart.empty() && scenescript.takerpart.empty():
		for i in ongoingactions:
			if scenescript.code == i.scene.code:
				set1 = getIntersection(i.givers, givers)
				set2 = getIntersection(i.takers, takers)
				if !set1.empty() && !set2.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': set2})

	if scenescript.code in ['cunnilingus','rimjob']:
		for i in ongoingactions:
			if i.scene.category == 'fucking' && i.scene.code != 'strapon':
				set1 = getIntersection(i.givers, takers)
				if !set1.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': []})

	elif scenescript.code in ['massagefoot','lickfeet']:
		for i in ongoingactions:
			if i.scene.category == 'fucking' && i.scene.code != 'strapon':
				set1 = getIntersection(i.givers, givers)
				if !set1.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': []})

	elif scenescript.code in ['doubledildo', 'doubledildoass', 'tribadism']:
		for i in ongoingactions:
			if i.scene.category in ['caress', 'fucking'] && i.scene.code != 'strapon':
				set1 = getIntersection(i.givers, givers + takers)
				if !set1.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': []})

	elif scenescript.code == 'grovel':
		for i in ongoingactions:
			if i.scene.code in ['facesit','afacesit']:
				set2 = getIntersection(i.takers, takers)
				if !set2.empty():
					conflicts.append({'action': i, 'givers': [], 'takers': set2})
			elif i.scene.category == 'fucking' && i.scene.code != 'strapon':
				set1 = getIntersection(i.givers, takers)
				if !set1.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': []})

	elif scenescript.code in ['facesit','afacesit']:
		for i in ongoingactions:
			if i.scene.code == 'grovel':
				set2 = getIntersection(i.takers, takers)
				if !set2.empty():
					conflicts.append({'action': i, 'givers': [], 'takers': set2})
			elif i.scene.category == 'fucking' && i.scene.code != 'strapon':
				set1 = getIntersection(i.givers, givers + takers)
				set2 = getIntersection(i.takers, givers)
				if !set1.empty() || !set2.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': set2})

	elif scenescript.code == 'rope':
		for i in takers:
			for k in i.activeactions:
				if k.scene.code == 'subdue':
					conflicts.append({'action': k, 'givers': [], 'takers': [i]})

	elif scenescript.category == 'caress':
		for i in ongoingactions:
			if i.scene.code in ['doubledildo', 'doubledildoass', 'tribadism']:
				set1 = getIntersection(i.givers, givers)
				set2 = getIntersection(i.takers, givers)
				if !set1.empty() || !set2.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': set2})

	elif scenescript.category == 'fucking' && scenescript.code != 'strapon':
		for i in ongoingactions:
			if i.scene.code in ['cunnilingus','rimjob']:
				set2 = getIntersection(i.takers, givers)
				if !set2.empty():
					conflicts.append({'action': i, 'givers': [], 'takers': set2})
			elif i.scene.code in ['massagefoot','lickfeet']:
				set1 = getIntersection(i.givers, givers)
				if !set1.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': []})
			elif i.scene.code in ['doubledildo', 'doubledildoass', 'tribadism']:
				set1 = getIntersection(i.givers, givers)
				set2 = getIntersection(i.takers, givers)
				if !set1.empty() || !set2.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': set2})
			elif i.scene.code == 'grovel':
				set2 = getIntersection(i.takers, givers)
				if !set2.empty():
					conflicts.append({'action': i, 'givers': [], 'takers': set2})
			elif i.scene.code in ['facesit','afacesit']:
				set1 = getIntersection(i.givers, givers + takers)
				set2 = getIntersection(i.takers, givers)
				if !set1.empty() || !set2.empty():
					conflicts.append({'action': i, 'givers': set1, 'takers': set2})
	#reduce redundancy by not conflicting with same action twice, though it will still list multiple actions with same name
	var idx1 = conflicts.size() - 1
	var idx2
	while idx1 > 0:
		idx2 = idx1 - 1
		while idx2 >= 0:
			if conflicts[idx1].action == conflicts[idx2].action:
				conflicts[idx2].givers += conflicts[idx1].givers
				conflicts[idx2].takers += conflicts[idx1].takers
				conflicts.remove(idx1)
				break
			idx2 -= 1
		idx1 -= 1

	return conflicts


func startscene(scenescript, cont = false, pretext = ''):
	var textdict = {mainevent = pretext, repeats = '', orgasms = '', speech = ''}
	var pain = 0
	var effects
	scenescript.givers = givers
	scenescript.takers = takers
	turns -= 1
	
	for i in givers + takers:
		if i.effects.has('resist') && scenescript.code != 'subdue':
			var result = resistattempt(i)
			textdict.mainevent += result.text
			if result.consent == false:
				get_node("Panel/sceneeffects").bbcode_text += (textdict.mainevent + "\n" + textdict.repeats)
				rebuildparticipantslist()
				return
	
	for i in givers + takers:
		if isencountersamesex(givers,takers,i) == true:
			i.actionshad.samesex += 1
		else:
			i.actionshad.oppositesex += 1
		if i.person.sexexp.actions.has(scenescript.code):
			i.person.sexexp.actions[scenescript.code] += 1
		else:
			i.person.sexexp.actions[scenescript.code] = 1
		for k in givers + takers:
			if k != i:
				if i.person.sexexp.partners.has(k.person.id):
					i.person.sexexp.partners[k.person.id] += 1
				else:
					i.person.sexexp.partners[k.person.id] = 1
	
	for i in participants:
		i.orgasm = false
		if !givers.has(i) && !takers.has(i):
			if i.person.sexexp.seenactions.has(scenescript.code):
				i.person.sexexp.seenactions[scenescript.code] += 1
			else:
				i.person.sexexp.seenactions[scenescript.code] = 1
	
	
	#temporary support for scenes converted to centralized output and those not
	#should be unified in the future
	var centralized = false
	if scenescript.has_method('initiate'):
		textdict.mainevent += decoder(scenescript.initiate(), givers, takers)
	else:
		centralized = true
		textdict.mainevent += output(scenescript, scenescript.initiate, givers, takers) + output(scenescript, scenescript.ongoing, givers, takers)
		
	
	if centralized == false:
		if scenescript.has_method('reaction'):
			for i in takers:
				textdict.mainevent += '\n' + decoder(scenescript.reaction(i), givers, [i])
	elif scenescript.reaction != null:
			for i in takers:
				textdict.mainevent += '\n' + output(scenescript, scenescript.reaction, givers, [i])
	
	#remove virginity if relevant
	if scenescript.virginloss == true:
		for i in givers:
			if scenescript.giverpart == 'vagina':
				i.person.vagvirgin = false
			elif scenescript.giverpart == 'anus':
				i.person.assvirgin = false
		for i in takers:
			if scenescript.takerpart == 'vagina':
				i.person.vagvirgin = false
			elif scenescript.takerpart == 'anus':
				i.person.assvirgin = false
	
	
	var dict = {'scene' : scenescript, 'takers' : takers.duplicate(), 'givers' : givers.duplicate()}
	
	if scenescript.code in ['strapon', 'nippleclap', 'clitclap', 'ringgag', 'blindfold', 'nosehook', 'vibrator', 'analvibrator', 'rope', 'milker', 'subdue', 'relaxinginsense']:
		cont = true

	var conflicts = getConflictsWithOngoing(scenescript)
	for c in conflicts:
		stopongoingaction(c.action)

	if scenescript.giverpart != '':
		for i in givers:
			#print(i.name + " " + str(i[scenescript.giverpart]) + str(scenescript.giverpart))
			i[scenescript.giverpart] = dict
	
	if scenescript.takerpart != '':
		for i in takers:
			i[scenescript.takerpart] = dict
	
	if scenescript.get('takerpart2'):
		for i in takers:
			i[scenescript.takerpart2] = dict
	
	for i in givers: 
		if scenescript.has_method('givereffect'):
			effects = scenescript.givereffect(i)
			i.actioneffect(effects[0], effects[1], dict)
		i.lube()
		
	for i in takers:
		if scenescript.has_method('takereffect'):
			effects = scenescript.takereffect(i)
			i.actioneffect(effects[0], effects[1], dict)
		i.lube()
	
	var sceneexists = false
	var temptext = ''
	for i in ongoingactions:
		temptext = ''
		if i.givers == givers && i.takers == takers && i.scene == scenescript:
			sceneexists = true
		elif i.scene.has_method('getongoingdescription'):
			temptext = decoder(i.scene.getongoingdescription(i.givers, i.takers), i.givers, i.takers)
		else:
			temptext = output(i.scene, i.scene.ongoing, i.givers, i.takers)
		if temptext != '':
			textdict.repeats += '\n' + temptext
	textdict.repeats = textdict.repeats.replace("[color=yellow]", '').replace('[color=aqua]', '').replace('[/color]','')
	
	
	for i in ongoingactions:
		for k in i.givers + i.takers:
			k.person.sexexp.actions[i.scene.code] += 1
			for j in i.givers + i.takers:
				if j != k:
					if k.person.sexexp.partners.has(j.person.id):
						k.person.sexexp.partners[j.person.id] += 1
					else:
						k.person.sexexp.partners[j.person.id] = 1
		for k in participants:
			if !i.givers.has(k) && !i.takers.has(k):
				if k.person.sexexp.seenactions.has(i.scene.code):
					k.person.sexexp.seenactions[i.scene.code] += 1
				else:
					k.person.sexexp.seenactions[i.scene.code] = 1
		if i.scene.has_method("givereffect"):
			for member in i.givers:
				effects = i.scene.givereffect(member)
				member.actioneffect(effects[0], effects[1], i)
		if i.scene.has_method("takereffect"):
			for member in i.takers:
				effects = i.scene.takereffect(member)
				member.actioneffect(effects[0], effects[1], i)
	
	
	var request
	
	for i in participants:
		if i in givers+takers:
			i.lastaction = dict
			request = checkrequest(i)
			if request == true:
				textdict.orgasms += decoder("[color=aqua]Desire fullfiled! [name1] grows lewder and more sensitive. [/color]\n", [i], [i])
#			if i.sens >= 1000:
#				textdict.orgasms += triggerorgasm(i)
#				i.orgasm = true
#			else:
#				i.orgasm = false
		else:
			for j in ongoingactions:
				if i in j.givers + j.takers:
					i.lastaction = j
#					if i.sens >= 1000:
#						textdict.orgasms += triggerorgasm(i)
#						i.orgasm = true
#					else:
#						i.orgasm = false
		if not i.lastaction in ongoingactions:
			i.lastaction = null
		
	
	if cont == true && sceneexists == false: 
		ongoingactions.append(dict)
		for i in givers + takers:
			i.activeactions.append(dict)
	else:
		for i in givers:
			if scenescript.giverpart != '':
				i[scenescript.giverpart] = null
		for i in takers:
			if scenescript.takerpart != '':
				i[scenescript.takerpart] = null
	
	var x = (givers.size()+takers.size())/2
	
	while x > 0:
		if randf() < 0.3: #0.3
			var charspeech = characterspeech(dict)
			if charspeech.text != '':
				textdict.speech += charspeech.character.name + ': ' + decoder(charspeech.text, [charspeech.character], [charspeech.partner]) + '\n'
		x -= 1
	
	
	var text = textdict.mainevent + "\n" + textdict.repeats + '\n' + textdict.speech + textdict.orgasms
#	temptext = ''
#	while text.length() > 0:
#		if !text.begins_with('%'):
#			if text.find('%') >= 0:
#				temptext = text.substr(0,text.find('%'))
#			else:
#				temptext = text
#			text = text.replace(temptext, '')
#			$Panel/sceneeffects.append_bbcode(temptext)
#		else:
#			var string = text.substr(text.find("%"), 2)
#			add_portrait_to_text(participants[int(string.substr(1,1))])
#			text.erase(0,2)
		#print($Panel/sceneeffects.text)
		#get_node("Panel/sceneeffects").add_text()
	#$Panel/sceneeffects.bbcode_enabled = true
	get_node("Panel/sceneeffects").bbcode_text += '\n' + text
	
	
	
	var temparray = []
	
	for i in participants:
		if i.person == globals.player || i.person.unique in ['dog','horse'] || i.effects.has('forced') || i.effects.has('resist'):
			continue
		temparray.append(i)
	
	
	if randf() < 0.15 && temparray.size() > 0:
		generaterequest(temparray[randi()%temparray.size()])
	
	rebuildparticipantslist()

var prevailing_lines = ['mute', 'silence', 'orgasm', 'resistorgasm', 'pain', 'painlike', 'resist', 'blowjob']

func characterspeech(scene, details = []):
	var partner
	var partnerside
	var array = [] #serves as RNG pool for partners and speech

	for i in scene.takers+scene.givers:
		if i.person != globals.player:
			array.append(i)
	var character = array[randi()%array.size()] #who speaks
	
	if character in scene.takers:
		partnerside = 'givers'
	else:
		partnerside = 'takers'
	
	if !scene[partnerside].empty():
		partner = scene[partnerside][randi()%scene[partnerside].size()]
	
	var dict = {}
	var cp = character.person
	if cp.traits.has('Mute'):
		dict.mute = [speechdict.mute, 1]
	if cp.traits.has('Sex-crazed'):
		dict.sexcrazed = [speechdict.sexcrazed, 1]
	if cp.traits.has('Enjoys Anal'):
		dict.enjoysanal = [speechdict.enjoysanal, 1]
	if cp.traits.has('Likes it rough'):
		dict.rough = [speechdict.rough, 1]
	if cp.rules.silence == true:
		dict.silence = [speechdict.silence, 1]
	if character.effects.has('resist'):
		dict.resist = [speechdict.resist, 1]
		if scene.scene.code in ['missionaryanal', 'doggyanal', 'lotusanal','revlotusanal', 'inserttaila', 'insertinturnsass']  && partnerside == 'givers':
			dict.analrape = [speechdict.analrape, 1]
	if character.orgasm == true:
		if character.effects.has('resist'):
			dict.resistorgasm = [speechdict.resistorgasm, 1]
		else:
			dict.orgasm = [speechdict.orgasm, 1]
	if scene.scene.code in ['blowjob'] && partnerside == 'takers':
		dict.mouth = [speechdict.blowjob, 1]
	if scene.scene.code in ['blowjob','spitroast'] && partnerside == 'givers':
		dict.mouth = [speechdict.blowjobtake, 1]
	if scene.scene.code in ['missionary', 'doggy', 'lotus', 'revlotus', 'inserttailv', 'insertinturns'] && partnerside == 'givers':
		dict.vagina = [speechdict.vagina, 1]
	if scene.scene.code in ['missionaryanal', 'doggyanal', 'lotusanal','revlotusanal', 'inserttaila', 'insertinturnsass'] && partnerside == 'givers':
		dict.anal = [speechdict.anal, 1]
	if partner != null && (!cp.traits.has('Homosexual') && !cp.traits.has("Bisexual")) && character.sex != 'male' && partner.sex != 'male' && partnerside == 'givers':
		dict.nonlesbian = [speechdict.nonlesbian, 1]
	if scene.scene.get("takertags") && scene.scene.takertags.has("pain") && partnerside == 'givers' && !cp.traits.has('Likes it rough') && !cp.traits.has("Masochist"):
		if character.effects.has('resist'):
			dict.pain = [speechdict.pain, 2.5]
		else:
			dict.painlike = [speechdict.painlike, 2.5]
	dict.moans = [speechdict.moans, 0.25]

	for i in prevailing_lines:
		if dict.has(i):
			array = [dict[i]]
			dict.clear() 
			break
	if !dict.empty():
		array = dict.values()
	var text = globals.weightedrandom(array)
	if text != null:
		text = text[randi()%text.size()]
	
	if text != null && partner != null:
		if partner.person == globals.player || cp.traits.has("Monogamous"):
			text = text.replace('[name2]', cp.getMasterNoun())
		else:
			text = text.replace('[name2]', partner.name)
		text = '[color=lime]' + text + '[/color]'
	else:
		text = ''

	return {'text' : text, 'character' : character, 'partner' : partner}


var speechdict = {
	resist = ["Stop it!", "No... I don't want to!", "Why are you doing this...", "You, bastard...", "Let me go!"],
	resistorgasm = ["Ahh-hh... No...", "*Sob* why... this feels so good...", "No, Please stop, before I... Ahh... No *sob*"],
	mute = ['...', '...!', '......', '*gasp*'],
	blowjob = ["Does it feel good? *slurp*", "Mh-m... this smell...", "Does this feel good, [name2]?", "You like my mouth, [name2]?"],
	blowjobtake = ["Like my cock, [name2]?" , "Yes, suck it, dear...", "Mmmm, suck it like that."],
	inexperienced = ["I've never done this...", "What's this?", "Not so fast, [name2], I'm new to this..."],
	#virgin = ["Aaah! My first time...", "My first time...", "My first time... you took it..."],
	vagina = ["Ah! Yes! Fuck my pussy!", "Yes, fill me up, [name2]!", "More, give me more, [name2]!", "Ah, this is so good, [name2]..."],
	anal = ["My {^ass:butt}... feels good...", "Ah... My {^ass:butt}...", "Keep {^fucking:ravaging:grinding} my {^ass:butt}, [name2]..."],
	orgasm = ["Cumming, I'm cumming!..", "Ah, Ahh, AAAHH!","[name2], please hold me, I'm cumming!"],
	analrape = ["Stop! Where are you putting it!?", "No, please, not there!", "No, not my {^ass:butt}... I beg you..."],
	sexcrazed = ["Your {^dick:cock:penis}... Yes...", "Give me your {^dick:cock:penis}, [name2]... I need it", "Fuck me, [name2], I begging you!.."],
	nonlesbian = ["No, we shouldn't...", "No, we are both girls...","[name2], Ah, stop, I'm not into girls..."],
	enjoysanal = ["Please, put my {^butt:ass} into a good use, [name2]...", "I want it in my {^butt:ass}..."],
	rough = ["[name2], do me harder...", "Yes... Please, abuse me!"],
	pain = ["Ouch! It hurts...", "Please, no more...", "*sob*", 'It hurts...', '[name2], please, stop...'],
	painlike = ["Umh... Yes, hit me harder...", "Yes, [name2], punish me...", "Ah... this strings... nicely..."],
	silence = ['Mmhmm...', '*gasp*', 'Mhm!!'],
	moans = ["Ah...", "Oh...", "Mmmh...", "[name2]..."]
}


#func triggerorgasm(i):
#	var text = ''
#	if i.person.sexexp.orgasms.has(i.lastaction.scene.code):
#		i.person.sexexp.orgasms[i.lastaction.scene.code] += 1
#	else:
#		i.person.sexexp.orgasms[i.lastaction.scene.code] = 1
#	for k in i.lastaction.givers + i.lastaction.takers:
#		if i != k:
#			if i.person.sexexp.orgasmpartners.has(k.person.id):
#				i.person.sexexp.orgasmpartners[k.person.id] += 1
#			else:
#				i.person.sexexp.orgasmpartners[k.person.id] = 1
#	text += '\n' + orgasm(i)
#	return text

#Effects: pleasure, excitement, pain, deviancy, obedience 

func startscenecontinue(scenescript):
	startscene(scenescript, true)


var sexdict = load("res://files/scripts/newsexdictionary.gd").new()

#centralized output processing
#category currently assumed to be 'fucking', will expland with further conversions
func output(scenescript, valid_lines, givers, takers):
	var shared_lines = sexdict.shared_lines
	var giverpart = scenescript.giverpart
	var takerpart = scenescript.takerpart
	var act_lines = scenescript.act_lines
	var links = sexdict.linksets[scenescript.linkset]
	#internal
	var linearray = []
	var output = ''
	var virginpart = null
	var virginsource = null
	var link = null
	#checks
	var checks = {
		code = scenescript.code,
		link = null,
		orifice = 'insert',
		consent = true,
		virgin = true,
		parallel = true if scenescript.rotation1.x == scenescript.rotation2.x else false,
		facing = true if scenescript.rotation1.w == 0.0 && scenescript.rotation2.w == 0.0 else false,
		arousal = 1,
		lube = 1,
		lust = 1,
	}
	
	#link with ongoingactions
	if givers[0][giverpart] != null:
		if givers[0][giverpart].scene.code in links:
			link = givers[0][giverpart].scene
			for i in givers:
				if i[giverpart] != givers[0][giverpart]:
					link = null
					break
			for i in takers:
				if i[takerpart] != givers[0][giverpart]:
					link = null
					break
	#link with lastaction if ongoing fails
	if link == null && givers[0].lastaction != null:
		if givers[0].lastaction.scene.code in links:
			link = givers[0].lastaction.scene
			for i in givers+takers:
				if i.lastaction != givers[0].lastaction:
					link = null
					break
	#gather orifice info from link
	if link != null:
		checks.link = link.code
		if scenescript.virginloss == true && link.virginloss == true:
			if checks.code == link.code:
				checks.orifice = 'same'
			elif 'vagina' in [scenescript.giverpart] + [scenescript.takerpart] && 'vagina' in [link.giverpart] + [link.takerpart]:
				checks.orifice = 'shift'
			elif 'anus' in [scenescript.giverpart] + [scenescript.takerpart] && 'anus' in [link.giverpart] + [link.takerpart]:
				checks.orifice = 'shift'
			else:
				checks.orifice = 'swap'
	#virginity assignments
	if giverpart == 'penis':
		if takerpart == 'vagina':
			virginpart = 'vagvirgin'
			virginsource = takers
		elif takerpart == 'anus':
			virginpart = 'assvirgin'
			virginsource = takers
	elif takerpart == 'penis':
		if giverpart == 'vagina':
			virginpart = 'vagvirgin'
			virginsource = givers
		elif giverpart == 'anus':
			virginpart = 'assvirgin'
			virginsource = givers
	#assign virginity check
	for i in virginsource:
		if i.person[virginpart] == false:
			checks.virgin = false
	#assign consent
	for i in takers:
		if i.effects.has('forced') || i.effects.has('resist'):
			checks.consent = false
	#based on screen values, subject to adjustment
	if takers.size() == 1:
		checks.arousal = int(clamp(ceil(takers[0].sens/200), 1, 5))
		checks.lube = int(clamp(ceil(takers[0].lube/2), 1, 5))
		checks.lust = int(clamp(ceil(takers[0].lust/200), 1, 5))
	
	#build the output
	var drop = false
	for i in valid_lines:
		linearray = []
		if i in act_lines:
			for j in act_lines[i]:
				drop = false
				for k in act_lines[i][j].conditions:
					if checks.has(k) && !act_lines[i][j].conditions[k].has(checks[k]):
						drop = true
						break
				if drop == false:
					linearray += act_lines[i][j].lines
		if i in shared_lines:
			for j in shared_lines[i]:
				drop = false
				for k in shared_lines[i][j].conditions:
					if checks.has(k) && !shared_lines[i][j].conditions[k].has(checks[k]):
						drop = true
						break
				if drop == false:
					linearray += shared_lines[i][j].lines
		if linearray.size() > 0:
			output += linearray[randi()%linearray.size()]
	
	
	
	return decoder(output, givers, takers)

#func orgasm(member):
#	member.sens = member.sens/5
#	#member.lust -= max(300, member.lust/2)
#	var scene
#	var text
#	var temptext = ''
#	var penistext = ''
#	var vaginatext = ''
#	var anustext = ''
#	member.orgasms += 1
#	member.person.metrics.orgasm += 1
#	if participants.size() == 2 && member.person != globals.player:
#		member.person.loyal += rand_range(1,4)
#	elif member.person != globals.player:
#		member.person.loyal += rand_range(1,2)
#	#anus in use, find scene
#	if member.anus != null:
#		scene = member.anus
#		for i in scene.givers:
#			globals.addrelations(member.person, i.person, rand_range(30,50))
#		#anus in giver slot
#		if scene.givers.find(member) >= 0:
#			if randf() < 0.4:
#				anustext = "[name1] feel[s/1] a {^sudden :intense ::}{^jolt of electricity:warmth:wave of pleasure} inside [him1] and [his1]"
#			else:
#				anustext = "[names1]"
#			if scene.scene.takerpart == 'penis':
#				anustext += " [anus1] {^squeezes:writhes around:clamps down on} [names2] [penis2] as [he1] reach[es/1] {^climax:orgasm}."
#			else:
#				anustext += " [anus1] {^convulses:twitches:quivers} {^in euphoria:in ecstasy:with pleasure} as [he1] reach[es/1] {^climax:orgasm}."
#			anustext = decoder(anustext, [member], scene.takers)
#		#anus is in taker slot
#		elif scene.takers.find(member) >= 0:
#			if randf() < 0.4:
#				anustext = "[name2] feel[s/2] a {^sudden :intense ::}{^jolt of electricity:warmth:wave of pleasure} inside [him2] and [his2]"
#			else:
#				anustext = "[names2]"
#			if scene.scene.giverpart == 'penis':
#				anustext += " [anus2] {^squeezes:writhes around:clamps down on} [names1] [penis1] as [he2] reach[es/2] {^climax:orgasm}."
#			else:
#				anustext += " [anus2] {^convulses:twitches:quivers} {^in euphoria:in ecstasy:with pleasure} as [he2] reach[es/2] {^climax:orgasm}."
#			anustext = decoder(anustext, scene.givers, [member])
#		#no default conditon
#	#vagina present
#	if member.person.vagina != 'none':
#		member.lube()
#		#vagina in use, find scene
#		if member.vagina != null:
#			scene = member.vagina
#			for i in scene.givers:
#				globals.addrelations(member.person, i.person, rand_range(30,50))
#			#vagina in giver slot
#			if scene.givers.find(member) >= 0:
#				if randf() < 0.4:
#					vaginatext = "[name1] feel[s/1] a {^sudden :intense ::}{^jolt of electricity:warmth:wave of pleasure} inside [him1] and [his1]"
#				else:
#					vaginatext = "[names1]"
#				if scene.scene.takerpart == 'penis':
#					vaginatext += " [pussy1] {^squeezes:writhes around:clamps down on} [names2] [penis2] as [he1] reach[es/1] {^climax:orgasm}."
#				else:
#					vaginatext += " [pussy1] {^convulses:twitches:quivers} {^in euphoria:in ecstasy:with pleasure} as [he1] reach[es/1] {^climax:orgasm}."
#				vaginatext = decoder(vaginatext, [member], scene.takers)
#			#vagina is in taker slot
#			elif scene.takers.find(member) >= 0:
#				if randf() < 0.4:
#					vaginatext = "[name2] feel[s/2] a {^sudden :intense ::}{^jolt of electricity:warmth:wave of pleasure} inside [him2] and [his2]"
#				else:
#					vaginatext = "[names2]"
#				if scene.scene.giverpart == 'penis':
#					vaginatext += " [pussy2] {^squeezes:writhes around:clamps down on} [names1] [penis1] as [he2] reach[es/2] {^climax:orgasm}."
#				else:
#					vaginatext += " [pussy2] {^convulses:twitches:quivers} {^in euphoria:in ecstasy:with pleasure} as [he2] reach[es/2] {^climax:orgasm}."
#				vaginatext = decoder(vaginatext, scene.givers, [member])
#			#no default conditon
#	#penis present
#	if member.person.penis != 'none':
#		#penis in use, find scene
#		if member.penis != null:
#			scene = member.penis
#			for i in scene.takers:
#				globals.addrelations(member.person, i.person, rand_range(30,50))
#			#penis in giver slot
#			if scene.givers.find(member) >= 0:
#				if randf() < 0.4:
#					penistext = "[name1] feel[s/1] {^a wave of:an intense} {^pleasure:euphoria} {^run through:course through:building in} [his1] [penis1] and [his1]"
#				else:
#					penistext = "[name1] {^thrust:jerk}[s/1] [his1] hips forward and a {^thick :hot :}{^jet:load:batch} of"
#				if scene.scene.takerpart == '':
#					penistext += " {^semen:seed:cum} {^pours onto:shoots onto:falls to} the {^ground:floor} as [he1] ejaculate[s/1]."
#				elif ['anus','vagina','mouth'].has(scene.scene.takerpart):
#					if scene.scene.get('takerpart2') && scene.scene.givers[1] == member:
#						temptext = scene.scene.takerpart2.replace('anus', '[anus2]').replace('vagina','[pussy2]')
#					else:
#						temptext = scene.scene.takerpart.replace('anus', '[anus2]').replace('vagina','[pussy2]')
#						if scene.scene.takerpart == 'vagina':
#							for i in scene.takers:
#								if impregnationcheck(i.person, member.person) == true:
#									globals.impregnation(i.person, member.person)
#					penistext += " {^semen:seed:cum} {^pours:shoots:pumps:sprays} into [names2] " + temptext + " as [he1] ejaculate[s/1]."
#				elif scene.scene.takerpart == 'nipples':
#					penistext += " {^semen:seed:cum} fills [names2] hollow nipples. "
#				elif scene.scene.takerpart == 'penis':
#					penistext += " {^semen:seed:cum} {^pours:shoots:sprays}, covering [names2] [penis2]. "
#				penistext = decoder(penistext, [member], scene.takers)
#			#penis in taker slot
#			elif scene.takers.find(member) >= 0:
#				if randf() < 0.4:
#					penistext = "[name2] feel[s/2] {^a wave of:an intense} {^pleasure:euphoria} {^run through:course through:building in} [his2] [penis2] and [his2]"
#				else:
#					penistext = "[name2] {^thrust:jerk}[s/2] [his2] hips forward and a {^thick :hot :}{^jet:load:batch} of"
#				if scene.scene.code in ['handjob','titjob']:
#					penistext += " {^sticky:white:hot} {^semen:seed:cum} {^sprays onto:shoots all over:covers} [names1] face[/s1] as [he2] ejaculate[s/2]."
#				elif scene.scene.code == 'tailjob':
#					penistext += " {^sticky:white:hot} {^semen:seed:cum} {^sprays onto:shoots all over:covers} [names1] tail[/s1] as [he2] ejaculate[s/2]."
#				elif scene.scene.giverpart == '':
#					penistext += " {^semen:seed:cum} {^pours onto:shoots onto:falls to} the {^ground:floor} as [he2] ejaculate[s/2]."
#				elif scene.scene.giverpart == 'penis':
#					penistext += " {^semen:seed:cum} {^pours:shoots:sprays}, covering [names1] [penis1]. "
#				elif ['anus','vagina','mouth'].has(scene.scene.giverpart):
#					temptext = scene.scene.giverpart.replace('anus', '[anus1]').replace('vagina','[pussy1]')
#					penistext += " {^semen:seed:cum} {^pours:shoots:pumps:sprays} into [names1] " + temptext + " as [he2] ejaculate[s/2]."
#					if scene.scene.giverpart == 'vagina':
#						for i in scene.givers:
#							if impregnationcheck(i.person, member.person) == true:
#								globals.impregnation(i.person, member.person)
#				penistext = decoder(penistext, scene.givers, [member])
#		#orgasm without penis, secondary ejaculation
#		else:
#			if randf() < 0.4:
#				penistext = "[name2] {^twist:quiver:writhe}[s/2] in {^pleasure:euphoria:ecstacy} as"
#			else:
#				penistext = "[name2] {^can't hold back any longer:reach[es/2] [his2] limit} and"
#			penistext += " {^a jet of :a rope of :}{^semen:cum} {^fires:squirts:shoots} from {^the tip of :}[his2] {^neglected :throbbing ::}[penis2]."
#			penistext = decoder(penistext, null, [member])
#	if vaginatext != '' || anustext != '' || penistext != '':
#		text = vaginatext + " " + anustext + " " + penistext
#	#final default condition
#	else:
#		if randf() < 0.4:
#			temptext = "[name2] feel[s/2] {^a sudden :an intense ::}{^jolt of electricity:heat:wave of pleasure} and [his2]"
#		else:
#			temptext = "[names2]"
#		temptext += " {^entire :whole :}body {^twists:quivers:writhes} in {^pleasure:euphoria:ecstacy} as [he2] reach[es/2] {^climax:orgasm}."
#		text = decoder(temptext, null, [member])
#	
#	
#	if member.lastaction.scene.code in punishcategories && member.lastaction.takers.has(member):
#		if randf() >= 0.85 || member.person.effects.has("entranced"):
#			member.actionshad.addtraits.append("Masochist")
#	if member.lastaction.scene.code in punishcategories && member.lastaction.givers.has(member) && member.person.asser >= 60:
#		if randf() >= 0.85 || member.person.effects.has("entranced"):
#			member.actionshad.addtraits.append("Dominant")
#	if member.lastaction.scene.code in analcategories && (member.lastaction.takers.has(member) || member.lastaction.scene.code == 'doubledildoass'):
#		if randf() >= 0.85 || member.person.effects.has('entranced'):
#			member.actionshad.addtraits.append("Enjoys Anal")
#	if isencountersamesex(member.lastaction.givers, member.lastaction.takers, member) == true:
#		member.actionshad.samesexorgasms += 1
#	else:
#		member.actionshad.oppositesexorgasms += 1
#		
#	return "[color=#ff5df8]" + text + "[/color]"

func impregnationcheck(person1, person2):
	var valid = true
	if person1.unique in ['dog','horse'] || person2.unique in ['dog','horse']:
		valid = false
	return valid
	

func isencountersamesex(givers, takers, actor = null):
	if givers.empty() || takers.empty():
		return false
	var giverssex = givers[0].sex
	var takerssex = takers[0].sex
	if givers.has(actor):
		return actor.sex == takerssex || (actor.sex in ['female','futanari'] && takerssex in ['female','futanari'])
	elif takers.has(actor):
		return actor.sex == giverssex || (actor.sex in ['female','futanari'] && giverssex in ['female','futanari'])
	return false


func decoder(text, tempgivers, temptakers):
	return parser.decoder(text, tempgivers, temptakers)

func _on_sceneeffects1_meta_clicked( meta ):
	stopongoingaction(meta, true)

func stopongoingaction(meta, rebuild = false):
	var action
	if typeof(meta) == TYPE_STRING:
		action = ongoingactions[int(meta)]
	elif typeof(meta) == TYPE_DICTIONARY:
		action = meta
	if !action.scene.giverpart.empty():
		for i in action.givers:
			i[action.scene.giverpart] = null
	if !action.scene.takerpart.empty():
		for i in action.takers:
			i[action.scene.takerpart] = null
	if action.scene.get("takerpart2") != null && !action.scene.get("takerpart2").empty():
		for i in action.takers:
			i[action.scene.takerpart2] = null
	if action.scene.code == 'strapon' && action.givers[0].penis != null:
		stopongoingaction(action.givers[0].penis)
	elif action.scene.code == 'ringgag':
		var isResist = false
		for t in action.takers:
			if !t.effects.has('resist'):
				continue
			for a in t.activeactions:
				if a.scene.code == 'deepthroat':
					stopongoingaction(a)
					break
	elif action.scene.code == 'rope':
		for i in action.takers:
			i.effects.erase('tied')
		globals.itemdict['rope'].amount += globals.state.calcRecoverRope(action.takers.size(), 'sex')
	elif action.scene.code == 'subdue':
		for taker in action.takers:
			for giver in action.givers:
				giver.subduing = null
				taker.subduedby.erase(giver)
	for i in action.givers + action.takers:
		i.activeactions.erase(action)
	ongoingactions.erase(action)
	if rebuild == true:
		rebuildparticipantslist()


func _on_passbutton_pressed():
	if selectmode == 'normal':
		startscene(categories.other[0])
	else:
		askslaveforaction(globals.randomfromarray(ai))

func _on_stopbutton_pressed():
	endencounter()

func endencounter():
	var mana = 0
	var totalmana = 0
	var manaDict = {}
	var text = ''
	for i in participants:
		i.person.lewdness = i.lewd
		if i.orgasms > 0:
			i.person.lust = 0
		else:
			i.person.lust = i.sens/10
		i.person.lastsexday = globals.resources.day
		text += i.person.dictionary("$name: Orgasms - ") + str(i.orgasms) 
		
		for trait in i.actionshad.addtraits:
			i.person.add_trait(trait)
		
		if i.actionshad.samesex > i.actionshad.oppositesex && i.actionshad.samesexorgasms > 0:
			if !i.person.traits.has("Bisexual") && !i.person.traits.has("Homosexual") && (randf() >= 0.5 || i.person.effects.has('entranced')):
				i.person.add_trait("Bisexual")
			elif i.person.traits.has("Bisexual") && (randf() >= 0.5 || i.person.effects.has('entranced')) && max(0.2,i.actionshad.samesex)/max(0.2, i.actionshad.oppositesex) > 4 :
				i.person.trait_remove("Bisexual")
				i.person.add_trait('Homosexual')
		if i.actionshad.samesex < i.actionshad.oppositesex && i.actionshad.oppositesexorgasms > 0:
			if (i.person.traits.has("Bisexual") || i.person.traits.has("Homosexual")) && (randf() >= 0.5 || i.person.effects.has('entranced')):
				if i.person.traits.has("Bisexual") && (randf() >= 0.5 || i.person.effects.has('entranced')) && max(0.2,i.actionshad.oppositesex)/max(0.2, i.actionshad.samesex) > 4:
					i.person.trait_remove("Bisexual")
				else:
					i.person.trait_remove("Homosexual")
					i.person.add_trait("Bisexual")
		if i.actionshad.group*0.01 > randf():
			i.person.trait_remove("Monogamous")
			i.person.add_trait("Fickle")
		
		if i.orgasms >= 1:
			var essence = i.person.getessence()
			if essence != null && i.person.smaf*20 > rand_range(0,100):
				text += ", Ingredient gained: [color=yellow]" + globals.itemdict[essence].name + "[/color]"
				globals.itemdict[essence].amount += 1
			mana += i.orgasms*3 + rand_range(1,2)
		else:
			mana += i.sens/500
		if i.person.race == 'Dark Elf':
			mana *= 1.2
		if i.person.spec == 'nympho':
			mana += i.actionshad.samesex + i.actionshad.oppositesex
		if i.person == globals.player:
			mana /= 2
		if i.requestsdone > 0:
			mana += i.requestsdone*10
			text += ", [color=aqua]Desires fullfiled: " + str(i.requestsdone) + '[/color]'
		mana = round(mana)
		manaDict[i.person] = mana
		totalmana += mana
		text += "\n"
	
	var manaScaling = 1.0 - 0.9 * totalmana / (500.0 + totalmana)
	totalmana = 0
	for person in manaDict:
		mana = round(manaScaling * manaDict[person])
		totalmana += mana
		person.metrics.manaearn += mana
	
	text += "\nEarned mana: " + str(totalmana)
	globals.resources.mana += totalmana 
	
	ongoingactions.clear()
	
	get_node("Control").show()
	get_node("Control/Panel/RichTextLabel").set_bbcode(text)


func askslaveforaction(chosen):
	#choosing target
	var targets = []
	clearstate()
	var chosensex = chosen.person.sex
	var debug = ""
	var group = false
	var target
	
	if chosen.person.race == 'Elf':
		chosen.person.obed += rand_range(3,6)
	
	debug += 'Chosing targets... \n'
	
	for i in participants:
		if i != chosen:
			if i.person == globals.player && aiobserve == true:
				continue
			debug += i.name
			var value = 10
			if chosen.person.traits.has("Monogamous") && i.person != globals.player:
				value = 0
			elif chosen.person.traits.has("Fickle") || chosen.person.traits.has('Slutty'):
				value = 25
			if chosen.person.traits.has('Devoted') && i.person == globals.player:
				value += 50
			
			if i.npc == true && chosen.npc == true:
				value -= 50
			
			if chosen.person.sexexp.orgasms.has(i.person.id):
				value += chosen.person.sexexp.orgasms[i.person.id]*4
			if chosen.person.sexexp.watchers.has(i.person.id):
				value += (chosen.person.sexexp.watchers[i.person.id]-1)*2
			if chosen.person.sexexp.partners.has(i.person.id):
				value += chosen.person.sexexp.partners[i.person.id]/0.2
			if isencountersamesex([chosen], [i], chosen) && chosen.person.traits.has('Bisexual') == false && chosen.person.traits.has('Homosexual') == false:
				value = max(value/5,1)
			elif isencountersamesex([chosen], [i], chosen) == false && chosen.person.traits.has('Homosexual'):
				value = max(value/5,1)
			debug += " - " + str(value) + '\n'
			value = min(value, 120)
			if value > 0:
				targets.append([i, value])
	target = globals.weightedrandom(targets)
	debug += 'final target - ' + target.name
	
	
	debug += '\nChosing dom: \n'
	var dom = [['giver',40],['taker', 10]]
	
	if target.person.sex != chosen.person.sex && chosen.person.sex == 'female' && (chosen.person.asser < 75 || !chosen.person.traits.has("Dominant")):
		dom[0][1] = 0
	
	if chosen.person.asser >= 75:
		dom[1][1] = 0
	elif chosen.person.asser <= 25:
		dom[0][1] = 0
	debug += str(dom) + "\n"
	dom = globals.weightedrandom(dom)
	
	debug += 'final dom: ' + dom + '\n'
	
	var groupchosen = [chosen] 
	var grouptarget = [target]
	
	if participants.size() >= 3:
		if randf() >= 0.5 && chosen.person.traits.has("Monogamous") == false:
			group = true
	var freeparticipants = []
	
	if group == true:
		debug += "Group action attempt:\n"
		for i in participants:
			if i.person == globals.player && aiobserve == true:
				continue
			if i != chosen && i != target && randf() >= 0.5:
				freeparticipants.append(i)
		
		while freeparticipants.size() > 0:
			var targetgroup
			var newparticipant = freeparticipants[randi()%freeparticipants.size()]
			var samesex = isencountersamesex([newparticipant], [chosen], chosen)
			if chosen.person.traits.has("Bisexual"):
				targetgroup = 'any'
			elif (chosen.person.traits.has("Homosexual") && samesex) || !samesex:
				targetgroup = 'target'
			elif chosen.person.traits.has("Homosexual"):
				targetgroup = 'any'
			else:
				targetgroup = 'chosen'
			if (targetgroup == 'any' && randf() >= 0.5) || targetgroup == 'chosen':
				groupchosen.append(newparticipant)
			else: 
				grouptarget.append(newparticipant)
			
			freeparticipants.erase(newparticipant)
	
	#choosing action
	var chosenpos = ''
	var actions = []
	var chosenaction = null
	debug += 'chosing action: \n' 
	for i in categories:
		for j in categories[i]:
			clearstate()
			debug += j.code + ": "
			if j.code == 'wait':
				continue
			if (j.code in takercategories) == (dom == 'taker'):
				givers = groupchosen.duplicate()
				takers = grouptarget.duplicate()
			else:
				takers = groupchosen.duplicate()
				givers = grouptarget.duplicate()
			var result = checkaction(j)
			if result[0] == 'allowed':
				var value = 0
				if chosen.person.sexexp.actions.has(j.code):
					value += chosen.person.sexexp.actions[j.code]/2
				if chosen.person.sexexp.orgasms.has(j.code):
					value += chosen.person.sexexp.orgasms[j.code]*4
				if chosen.person.sexexp.seenactions.has(j.code):
					value += chosen.person.sexexp.seenactions[j.code]/10
				
				if i in ['caress','fucking']:
					value += 10
				
				if !chosen.person.traits.has("Enjoys Anal") && j.code in analcategories:
					if chosenpos == 'giver' && !takercategories.has(j.code):
						value -= 5
					elif chosenpos == 'taker' && takercategories.has(j.code):
						value -= 5
				
				
				if chosen.person.traits.has('Masochist') && j.code in punishcategories && chosenpos == 'taker':
					value *= 2.5
				if chosen.person.traits.has('Dominant') && j.code in punishcategories && chosenpos == 'giver':
					value *= 2.5
				if target.person.obed < 80  && j.code in punishcategories && chosenpos == 'giver':
					value *= 3
				if chosen.person.penis == 'none' && dom == 'giver' && j.code == 'strapon':
					value *= 10
				if chosen.person.traits.has("Pervert") && ((givers.has(chosen) && j.giverconsent == 'advanced') || (takers.has(chosen) && j.takerconsent == 'advanced')):
					value += 15
				
				if chosen.person.vagvirgin == true && j.category == 'fucking' && !j.code in analcategories:
					value -= 25
				if chosen.person.assvirgin == true && j.category == 'fucking' && j.code in analcategories:
					value -= 25
				
				if j.category == 'fucking':
					value += max(15 - turns, 0)
					if chosen.lube < 5:
						value -= (5 - chosen.lube)*2
				
				debug += str(value) + '\n'
				if value > 0:
					actions.append([j, value])
	if actions.empty():
		actions.append([categories.other[0], 1])
	chosenaction = globals.weightedrandom(actions)
	clearstate()
	if (chosenaction.code in takercategories) == (dom == 'taker'):
		givers = groupchosen.duplicate()
		takers = grouptarget.duplicate()
	else:
		takers = groupchosen.duplicate()
		givers = grouptarget.duplicate()
	var cont = false
	chosenaction.givers = givers
	chosenaction.takers = takers
	var text = '[color=green][name1] initiates ' + chosenaction.getname() + ' with [name2].[/color]\n\n'
	if chosenaction.canlast == true && randf() >= 0.2:
		cont = true
	$PopupPanel/RichTextLabel.bbcode_text = debug
	#$PopupPanel.popup()
	startscene(chosenaction, cont, decoder(text, groupchosen, grouptarget))

func _on_finishbutton_pressed():
	ai.clear()
	for i in participants:
		if i.npc == false:
			for k in participants:
				if k.npc == true:
					i.person.sexexp.watchers.erase(k.person.id)
					i.person.sexexp.partners.erase(k.person.id)
					i.person.sexexp.orgasms.erase(k.person.id)
	selectmode = 'normal'
	get_parent().animationfade()
	if OS.get_name() != 'HTML5':
		yield(get_parent(), 'animfinished')
	hide()
	get_parent()._on_mansion_pressed()


func _on_blacklist_pressed():
	$blacklist.visible = true
	for i in $blacklist/ScrollContainer/VBoxContainer.get_children():
		if i.get_name() != 'CheckBox':
			i.visible = false
			i.queue_free()
	for i in categories.values():
		for j in i:
			if j.code == 'wait':
				continue
			var node = $blacklist/ScrollContainer/VBoxContainer/CheckBox.duplicate()
			j.givers = [participants[0]]
			$blacklist/ScrollContainer/VBoxContainer.add_child(node)
			node.visible = true
			node.text = j.getname(1)
			node.set_pressed(!filter.has(j.code))
			node.set_meta("action", j)
			node.connect("toggled", self, 'toggleaction', [node])

func toggleaction(button, node):
	var action = node.get_meta('action')
	if filter.has(action.code):
		filter.erase(action.code)
	else:
		filter.append(action.code)
	node.set_pressed(!filter.has(action.code))

func _on_closeblacklist_pressed():
	$blacklist.visible = false
	rebuildparticipantslist()

func _on_debug_pressed():
	$PopupPanel.popup()


func _on_aiallow_pressed():
	aiobserve = $Panel/aiallow.pressed

func calcResistWill(member):
	if member.person.traits.has('Sex-crazed'):
		return 0
	var resistwill = 200
	if !member.consent:
		resistwill += 200
	if member.person.effects.has('captured'):
		resistwill += 100

	if member.person.effects.has('drunk'):
		resistwill /= 2

	resistwill -= member.person.obed*3 + member.person.loyal*2 + member.lust/10 - member.lewd/3
	if member.person.traits.has("Likes it rough"):
		resistwill -= 60
	
	return resistwill

func resistattempt(member):
	var result = {text = '', consent = true}
	if calcResistWill(member) > 0:
		var resiststrength = member.person.sstr + 1
		var subdue = 0
		if member.effects.has('tied'):
			resiststrength = 0
			result.text += '[name1] is powerless to resist, as [his1] limbs are restricted by rope.\n'
		elif member.isHandCuffed:
			resiststrength = ceil(resiststrength * 2.0 / 3.0) - 1
			result.text += '[name1] has some difficulty resisting, as [his1] arms are restricted by handcuffs.\n'
		
		for i in member.subduedby:
			subdue += i.person.sstr + 1

		if resiststrength >= subdue && resiststrength != 0:
			result.consent = false
			result.text += '[name1] resists the attempt with brute force.\n'
			member.person.obed -= rand_range(4,8)
		else:
			if !member.person.traits.has("Likes it rough") && !member.person.traits.has("Sex-crazed") && !(member.person.traits.has("Submissive") && member.person.loyal >= 40) && member.person.spec != 'nympho':
				member.person.conf -= rand_range(2,4)
				member.person.cour -= rand_range(2,4)
			
			if member.subduedby.size() == 0:
				result.text += '[name1] tries to struggle, but [his1] strength is not enough to fight back...\n'
			else:
				result.text += "[name1]'s attempts to resist are stopped by being held by [name2]. \n"	
	else:
		member.effects.erase('resist')
		result.text += '[name1] no longer fights back.\n'
	
	result.text = decoder(result.text, [member], member.subduedby)
	return result
