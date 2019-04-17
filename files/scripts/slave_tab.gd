
extends Control

var person
var tab
var jobdict = globals.jobs.jobdict
var showfullbody = true

func _ready():
	for i in $stats/customization/tattoopanel/VBoxContainer.get_children():
		i.connect('pressed',self,'choosetattooarea',[i])
	set_process_input(true)
	relativesdata = globals.state.relativesdata
	$stats/trainingabilspanel/learncost.text = "Learning points per attribute: " + str(variables.learnpointsperstat)
	for i in get_tree().get_nodes_in_group('slaverules'):
		i.connect("pressed", self, 'rulecheck', [i])
	for i in [sstr,sagi, smaf, send]:
		i.get_node('Button').connect("pressed",self,'statup', [i.get_name()])
	for i in globals.statsdict:
		get(i).get_node('Control').connect('mouse_entered', self, 'stattooltip',[i])
		get(i).get_node('Control').connect('mouse_exited', globals, 'hidetooltip') 
	
#warning-ignore:return_value_discarded
	$stats/customization/relativespanel/relativestext.connect("meta_hover_started",self,'relativeshover')
#warning-ignore:return_value_discarded
	$stats/customization/relativespanel/relativestext.connect("meta_hover_ended",globals, 'slavetooltiphide')
#warning-ignore:return_value_discarded
	$stats/customization/relativespanel/relativestext.connect("meta_clicked",self, "relativesselected")
	
#warning-ignore:return_value_discarded
	$stats/trainingabilspanel/upgradepointsbuy.connect("pressed", self, "buyattributepoint")
	
	for i in ['cour','conf','wit','charm']:
#warning-ignore:return_value_discarded
		get_node("stats/trainingabilspanel/" +i + '/Button').connect("pressed", self, 'mentalup',[i])
#warning-ignore:return_value_discarded
		get_node("stats/trainingabilspanel/" +i + '/Button2').connect("pressed", self, 'mentalup5',[i])

func _input(event):
	if globals.main.get_node("screenchange").visible || $stats/customization/nicknamepanel.is_visible() :
		return
	if event == InputEventKey:
		var dict = {49 : 1, 50 : 2, 51 : 3, 52 : 4,53 : 5,54 : 6,55 : 7,56 : 8,}
		if event.scancode in [KEY_1,KEY_2,KEY_3,KEY_4]:
			var key = dict[event.scancode]
			if event.is_action_pressed(str(key)) == true && self.is_visible() == true && get_tree().get_current_scene().get_node("dialogue").is_hidden() == true:
				#set_current_tab(key-1)
				pass

func mentalup(mental):
	person[mental] += 1
	person.learningpoints -= variables.learnpointsperstat
	$stats._on_trainingabils_pressed()

func mentalup5(mental):
	person[mental] += 5
	person.learningpoints -= variables.learnpointsperstat*5
	$stats._on_trainingabils_pressed()

var nakedspritesdict = globals.gallery.nakedsprites

func upgradecostupdate():
	var text = 'Atr. Points per Upgrade point: ' + str(variables.attributepointsperupgradepoint) + '\nAvailable Atr. Points: ' + str(person.skillpoints)
	$stats/trainingabilspanel/upgradecost.text = text

func buyattributepoint():
	if person.skillpoints >= variables.attributepointsperupgradepoint:
		person.skillpoints -= variables.attributepointsperupgradepoint
		globals.resources.upgradepoints += 1
	else:
		get_tree().get_root().get_node("Mansion").infotext("[color=red]Not enough attribute points[/color]")
	upgradecostupdate()

func slavetabopen():
	var label
	var text = ""
	get_parent().get_node("mansion/mansioninfo").set_bbcode('')
	person = globals.slaves[get_tree().get_current_scene().currentslave]
	$stats.person = person
	sleeprooms()
	if person.sleep == 'jail':
		tab = 'prison'
		get_tree().get_current_scene().background_set('jail')
	else:
		tab = null
		get_tree().get_current_scene().background_set('mansion')
	if OS.get_name() != "HTML5" && globals.rules.fadinganimation == true:
		yield(get_tree().get_current_scene(), 'animfinished')
	globals.currentslave = person
	self.visible = true
#warning-ignore:unused_variable
	var file = File.new()
	text = person.description()
	$stats/basics/slavedescript.set_bbcode(text)
	text = person.status()
	$stats/statustext.set_bbcode(text)
	if showfullbody == true:
		$stats/basics/bodypanel/fullbody.set_texture(null)
		if person.imagefull != null && globals.loadimage(person.imagefull) != null:
			$stats/basics/bodypanel/fullbody.set_texture(globals.loadimage(person.imagefull))
		elif nakedspritesdict.has(person.unique):
			if person.obed <= 50 || person.stress > 50:
				$stats/basics/bodypanel/fullbody.set_texture(globals.spritedict[nakedspritesdict[person.unique].clothrape])
			else:
				$stats/basics/bodypanel/fullbody.set_texture(globals.spritedict[nakedspritesdict[person.unique].clothcons])
		$stats/basics/bodypanel.visible = ($stats/basics/bodypanel/fullbody.get_texture() != null)
	else:
		$stats/basics/bodypanel.visible = false
	for i in $stats/basics/traits/traitlist.get_children() + $stats/basics/sextraits/traitlist.get_children() :
		if i.get_name() != 'Label':
			i.visible = false
			i.free()
	for i in person.get_traits():
		label = $stats/basics/traits/traitlist/Label.duplicate()
		if i.tags.has("sexual"):
			$stats/basics/sextraits/traitlist.add_child(label)
		else:
			$stats/basics/traits/traitlist.add_child(label)
		label.visible = true
		label.set_text(i.name)
		label.connect("mouse_entered", self, 'traittooltip', [i])
		label.connect("mouse_exited", self, 'traittooltiphide')
	for i in $stats/customization/rules.get_children():
		if i.is_in_group('advrules'):
			if person.brand == 'advanced':
				i.visible = true
			else:
				i.visible = false
	#regulationdescription()
	for i in get_tree().get_nodes_in_group("slaverules"):
		if person.rules.has(i.get_name()):
			i.set_pressed(person.rules[i.get_name()])
	get_node("stats/workbutton").set_text(jobdict[person.work].name)
	$stats/customization/brandbutton.set_text(person.brand.capitalize())
	if globals.state.branding == 0:
		find_node('brandbutton').set_disabled(true)
	else:
		find_node('brandbutton').set_disabled(false)
#	text = "Health : " + str(round(person.health)) + '/' + str(round(person.stats.health_max)) + '\nEnergy : ' + str(round(person.energy)) + '/' + str(round(person.stats.energy_max)) + '\nLevel : '+str(person.level) + '\nExp : '+str(round(person.xp))+'\nSkillpoints : '+str(person.skillpoints)
#	get_node("stats/levelinfo").set_bbcode(text)
	for i in get_tree().get_nodes_in_group('prisondisable'):
		if tab == 'prison':
			i.visible = false
		else:
			i.visible = true
	$stats/customization/hairstyle.set_text(person.hairstyle)
	updatestats()
	if globals.state.mansionupgrades.mansionparlor >= 1:
		$stats/customization/tattoo.set_disabled(false)
		$stats/customization/piercing.set_disabled(false)
		$stats/customization/tattoo.set_tooltip("")
		$stats/customization/piercing.set_tooltip("")
	else:
		$stats/customization/tattoo.set_disabled(true)
		$stats/customization/piercing.set_disabled(true)
		$stats/customization/tattoo.set_tooltip("Unlock Beauty Parlor to access Tattoo options. ")
		$stats/customization/piercing.set_tooltip("Unlock Beauty Parlor to access Piercing options. ")
	if globals.state.tutorial.has('person') && globals.state.tutorial.person == false:
		globals.state.tutorial.person = true
		get_tree().get_current_scene().get_node("tutorialnode").slaveinitiate()
	
	$stats/basics/fullbodycheck.pressed = showfullbody
	
	if person.work == 'jailer':
		get_node("stats/workbutton").set_text('Jailer')
	elif person.work == 'headgirl':
		get_node("stats/workbutton").set_text('Headgirl')
	elif person.work == 'farmmanager':
		get_node("stats/workbutton").set_text('Farm Manager')
	elif person.work == 'labassist':
		get_node("stats/workbutton").set_text('Lab Assistant')



func _on_workbutton_pressed():
	get_tree().get_current_scene().get_node("joblist").joblist()

func _on_statistics_pressed():
	buildmetrics()

func _on_statsclose_pressed():
	$stats/statisticpanel.visible = false

func buildmetrics():
	var text = ""
	$stats/statisticpanel.visible = true
	text += "[center]Personal achievments[/center]\n"
	text += "In your possession: " + str(person.metrics.ownership) + " day"+globals.fastif(person.metrics.ownership == 1, '','s')+";\n"
	text += "Spent in jail: " + str(person.metrics.jail) + " day"+globals.fastif(person.metrics.jail == 1, '','s')+";\n"
	text += "Worked in brothel: " + str(person.metrics.brothel) + " day"+globals.fastif(person.metrics.brothel == 1, '','s')+";\n"
	text += "Won battles: " + str(person.metrics.win) + " time"+globals.fastif(person.metrics.win == 1, '','s')+";\n"
	text += "Captured enemies: " + str(person.metrics.capture) + " enem"+globals.fastif(person.metrics.capture == 1, 'y','ies')+";\n"
	text += "Earned gold: " + str(person.metrics.goldearn) + " piece"+globals.fastif(person.metrics.goldearn == 1, '','s')+";\n"
	text += "Earned food: " + str(person.metrics.foodearn) + " unit"+globals.fastif(person.metrics.foodearn == 1, '','s')+";\n"
	text += "Produced mana: " + str(person.metrics.manaearn) + " mana;\n"
	text += "Used items: " + str(person.metrics.item) + " time"+globals.fastif(person.metrics.item == 1, '','s')+";\n"
	text += "Affected by spells: " + str(person.metrics.spell) + " time"+globals.fastif(person.metrics.spell == 1, '','s')+";\n"
	text += "Modified in lab: " + str(person.metrics.mods) + " time"+globals.fastif(person.metrics.mods == 1, '','s')+";\n"
	$stats/statisticpanel/statstext.set_bbcode(text)
	text = "[center]Sexual achievments[/center]\n"
	text += "Had intimacy: " + str(person.metrics.sex) + " time"+globals.fastif(person.metrics.sex == 1, '','s')+";\n"
	text += "Orgasms: " + str(person.metrics.orgasm) + " time"+globals.fastif(person.metrics.orgasm == 1, '','s')+";\n"
	if person.vagina != 'none':
		text += "Vaginal penetrations: " + str(person.metrics.vag)+";\n"
	text += "Anal penetrations: " + str(person.metrics.anal)+";\n"
	text += "Gave oral: " + str(person.metrics.oral) + " time"+globals.fastif(person.metrics.oral == 1, '','s')+";\n"
	text += "Was forced: " + str(person.metrics.roughsex) + " time"+globals.fastif(person.metrics.roughsex == 1, '','s')+";\n"
	#text += person.dictionary("Of those $he liked: ") + str(person.metrics.roughsexlike) + " time"+globals.fastif(person.metrics.roughsexlike == 1, '','s')+";\n"
	text += "Had partners: " + str(person.sexexp.partners.size()) + " partner"+globals.fastif(person.sexexp.partners.size() == 1, '','s')+";\n"
	if person.preg.has_womb == true:
		text += "Was pregnant: " + str(person.metrics.preg) + " time"+globals.fastif(person.metrics.preg == 1, '','s')+";\n"
		text += "Gave birth: " + str(person.metrics.birth) + " time"+globals.fastif(person.metrics.birth == 1, '','s')+";\n"
	#text += "Participated in threesomes: " + str(person.metrics.threesome) + " time"+globals.fastif(person.metrics.threesome == 1, '','s')+";\n"
	#text += "Participated in orgies: " + str(person.metrics.orgy) + " time"+globals.fastif(person.metrics.orgy == 1, '','s')+";\n"
	$stats/statisticpanel/statssextext.set_bbcode(text)
	text = ''
	for i in person.relations:
		var tempslave = globals.state.findslave(i)
		if tempslave == null:
			continue
		text += tempslave.name_short() + ": " + relationword(person.relations[i]) + '\n'
		
	$stats/statisticpanel/relations/RichTextLabel.bbcode_text = text
		

func relationword(value):
	var text = 'neutral'
	if value >= 900:
		text = '[color=green]love[/color]'
	elif value >= 500:
		text = '[color=green]affectionate[/color]'
	elif value >= 200:
		text = 'friendly'
	elif value <= -900:
		text = '[color=red]hostile[/color]'
	elif value <= -500:
		text = '[color=red]bitter[/color]'
	elif value <= -200:
		text = 'aloof'
	return text


func rulecheck(button):
	person.rules[button.get_name()] = button.is_pressed()








func _on_grade_mouse_entered():
	var person = globals.slaves[get_tree().get_current_scene().currentslave]
	var text = ''
	for i in globals.originsarray:
		if i == person.origins:
			text += '[color=green] ' + i.capitalize() + '[/color]'
		else:
			text += i.capitalize()
		if i != 'noble':
			text += ' - '
	text += '\n\n' + globals.dictionary.getOriginDescription(person)
	globals.showtooltip(text)

func traittooltip(trait):
	globals.showtooltip(person.dictionary(trait.description))

func traittooltiphide():
	globals.hidetooltip()

func _on_grade_mouse_exited():
	globals.hidetooltip()


func _on_courfield_mouse_enter():
	find_node('courval').visible = true
	globals.showtooltip(globals.statsdescript.cour)

func _on_courfield_mouse_exit():
	find_node('courval').visible = false
	globals.hidetooltip()

func _on_conffield_mouse_enter():
	find_node('confval').visible = true
	globals.showtooltip(globals.statsdescript.conf)


func _on_conffield_mouse_exit():
	find_node('confval').visible = false
	globals.hidetooltip()

func _on_witfield_mouse_enter():
	find_node('witval').visible = true
	globals.showtooltip(globals.statsdescript.wit)

func _on_witfield_mouse_exit():
	find_node('witval').visible = false
	globals.hidetooltip()

func _on_charmfield_mouse_enter():
	find_node('charmval').visible = true
	globals.showtooltip(globals.statsdescript.charm)

func _on_charmfield_mouse_exit():
	find_node('charmval').visible = false
	globals.hidetooltip()




##############Regulation screen



func regulationdescription():
	#var cloth = globals.clothes
	#var underwear = globals.underwear
	var text
	if !jobdict.has(person.work):
		person.work = 'rest'
	text = person.dictionary(jobdict[person.work].workline + '\n')
	if person.brand == 'none':
		text = text + '[color=#ff4949]Currently, $he is not branded. [/color]\n'
	elif person.brand == 'basic':
		text = text + 'On $his neck you can recognize the magic [color=green]brand[/color] you left on $him.\n'
	elif person.brand == 'advanced':
		text = text + 'On $his neck you can spot the complex symbol of your [color=green]refined brand[/color].\n'
	if person.gear.costume != null:
		text += "$He wears [color=green]" + globals.state.unstackables[person.gear.costume].name + '[/color]'
		if person.gear.armor != null:
			text += " with [color=green]" + globals.state.unstackables[person.gear.armor].name + "[/color] on top of it.\n"
		else:
			text += ".\n"
	elif person.gear.costume == null && person.gear.armor != null:
		text += "$He wears only suit of [color=green]" + globals.state.unstackables[person.gear.armor].name + "[/color] without any additional clothing under it. \n"
	elif person.gear.costume == null:
		text += "$He [color=yellow]does not wear any upper clothing[/color] while at mansion.\n"
	if person.gear.underwear != null && person.gear.underwear != 'underwearplain':
		text += " " 
	#text = text + "$He wears [color=green]" + person.gear.costume + '[/color] and [color=green]' + person.gear.underwear + '[/color] on beneath.\n'
	if person.sleep == 'communal':
		text = text + 'At the night $he will be sleeping with others at [color=yellow]communal room[/color].\n'
	elif person.sleep == 'personal':
		text = text + 'At the night $he will be resting at [color=green]personal room[/color].\n'
	elif person.sleep == 'your':
		text = text + 'At the night $he will be warming [color=purple]your bed[/color].\n'
	return find_node('regulationdescript').set_bbcode(person.dictionary(text))




func _on_SelectButtonClothes_button_selected( value ):
	person.gear.clothes = globals.clothes[value]
	regulationdescription()


func _on_SelectButtonUnderwear_button_selected( value ):
	person.gear.underwear = globals.underwear[value]
	regulationdescription()




###########Brand popup window

func _on_brandbutton_pressed():
	var confirm = $stats/customization/brandpopup/confirm
	confirm.visible = false
	find_node('brandingtext').visible = false
	find_node('enhbrandingtext').visible = false
	find_node('brandremovetext').visible = false
	find_node('remove').visible = false
	$stats/customization/brandpopup.popup()
	if person.brand == 'basic' || person.brand == 'advanced':
		find_node('brandremovetext').visible = true
		if globals.resources.mana >= 5:
			find_node('remove').visible = true
	if person.brand == 'none' && globals.state.branding >= 1:
		find_node('brandingtext').visible = true
		if globals.resources.mana >= 10 && globals.player.energy >= 20:
			confirm.visible = true
			confirm.set_meta('value', 1)
		else:
			confirm.visible = false
	elif person.brand == 'basic' && globals.state.branding == 2:
		find_node('enhbrandingtext').visible = true
		if globals.resources.mana >= 15:
			confirm.visible = true
			confirm.set_meta('value', 2)

func _on_cancel_pressed():
	$stats/customization/brandpopup.visible = false


func _on_confirm_pressed():
	var confirm = find_node('confirm')
	var popup = find_node('brandpopup')
	popup.visible = false
	if confirm.get_meta('value') == 1:
		person.brand = 'basic'
		person.stress = 15 + person.conf/5 - person.loyal/10
		get_tree().get_current_scene().popup(person.dictionary('You perform a Ritual of Branding on $name. As symbols are engraved onto $his neck, $he yelps in pain. \n\nWith this you put serious claim on $his future life: $He will be unable to raise a hand against you and will be far less tempted to escape. '))
		globals.resources.mana -= 10
		globals.player.energy -= 20
	elif confirm.get_meta('value') == 2:
		person.brand = 'advanced'
		globals.player.energy -= 20
		globals.resources.mana -= 15
	slavetabopen()


func _on_remove_pressed():
	find_node('brandpopup').visible = false
	person.brand = 'none'
	globals.resources.mana -= 5
	slavetabopen()


##############Sleep

var sleepdict = {
'communal': 0,
'personal': 1,
'your': 2,
'jail': 3,
}

func _on_sleep_item_selected( ID ):
	for i in sleepdict:
		if sleepdict[i] == ID:
			person.sleep = i
	get_parent().get_parent().rebuild_slave_list()
	slavetabopen()

func sleeprooms():
	$stats/sleep.selected = sleepdict[person.sleep]
	var beds = globals.count_sleepers()
	$stats/sleep.set_item_disabled(1, beds.personal >= globals.state.mansionupgrades.mansionpersonal)
	$stats/sleep.set_item_disabled(2, beds.your_bed == globals.state.mansionupgrades.mansionbed)
	$stats/sleep.set_item_disabled(3, beds.jail >= globals.state.mansionupgrades.jailcapacity)







func _on_impregnate_pressed():
	globals.impregnation(person)

func _on_slavedescript_meta_clicked( meta ):
	if meta == 'race':
		get_tree().get_current_scene().showracedescript(person)
	elif globals.state.descriptsettings.has(meta):
		globals.state.descriptsettings[meta] = !globals.state.descriptsettings[meta]
	slavetabopen()

var relativesdata

var counter = 0
var slavearray = []

func _on_relativesbutton_pressed():
	var text = ''
	$stats/customization/relativespanel.popup()
	if relativesdata.has(person.id) == false:
		text = person.dictionary("You don't know anything about $name's relatives. ")
		$stats/customization/relativespanel/relativestext.bbcode_text = text
		return
	var entry = relativesdata[person.id]
	var entry2
	counter = 0
	slavearray.clear()
	text += '[center]Parents[/center]\n'
	for i in ['father','mother']:
		if int(entry[i]) <= 0:
			text += i.capitalize() + ": Unknown\n"
		else:
			if relativesdata.has(entry[i]):
				entry2 = relativesdata[entry[i]]
				text += i.capitalize() + ": " + getentrytext(entry2) + "\n"
			else:
				text += i.capitalize() + ": Unknown\n"
	
	if entry.siblings.size() > 0:
		text += '\n[center]Siblings[/center]\n'
		for i in entry.siblings:
			entry2 = relativesdata[i]
			if entry2.state == 'fetus':
				continue
			if entry2.sex == 'male':
				text += "Brother: " 
			else:
				text += "Sister: "
			text += getentrytext(entry2) + "\n"
	
	if entry.children.size() > 0:
		text += '\n[center]Children[/center]\n'
		for i in entry.children:
			entry2 = relativesdata[i]
			if entry2.state == 'fetus':
				continue
			if entry2.sex == 'male':
				text += "Son: " 
			else:
				text += "Daughter: "
			text += getentrytext(entry2) + "\n"
	$stats/customization/relativespanel/relativestext.set_meta("slaves", slavearray)
	$stats/customization/relativespanel/relativestext.bbcode_text = text

func getentrytext(entry):
	var text = ''
	if globals.state.findslave(entry.id) != null:
		text += '[url=person' + str(counter) + '][color=yellow]' + entry.name + '[/color][/url]'
		slavearray.append(globals.state.findslave(entry.id))
		counter += 1
	else:
		text += entry.name
	if entry.state == 'dead':
		text += " - Deceased"
	elif entry.state == 'left':
		text += " - Status Unknown"
	text += ", " + entry.race
	return text

func relativeshover(meta):
	var tempslave = slavearray[int(meta.replace('person',''))]
	globals.slavetooltip(tempslave)

func relativesselected(meta):
	var tempslave = slavearray[int(meta.replace('person',''))]
	$stats/customization/relativespanel.visible = false
	globals.slavetooltiphide()
	globals.openslave(tempslave)
	if tempslave != globals.player:
		globals.main.get_node('MainScreen/slave_tab')._on_relativesbutton_pressed()
	else:
		globals.main._on_selfrelatives_pressed()

func _on_relativesclose_pressed():
	$stats/customization/relativespanel.visible = false


func _on_nickname_pressed():
	$stats/customization/nicknamepanel.popup()

func _on_nickaccept_pressed():
	$stats/customization/nicknamepanel.visible = false
	person.nickname = $stats/customization/nicknamepanel/nickline.get_text()
	get_tree().get_current_scene().rebuild_slave_list()
	slavetabopen()


func _on_description_pressed():
	$stats/customization/descriptpopup.popup()
	$stats/customization/descriptpopup/TextEdit.set_text(person.customdesc)


func _on_confirmdescript_pressed():
	person.customdesc = $stats/customization/descriptpopup/TextEdit.get_text()
	$stats/customization/descriptpopup.visible = false
	slavetabopen()


func _on_gear_pressed():
	globals.main._on_inventory_pressed()
	globals.main.get_node('inventory').selectcategory(globals.main.get_node('inventory/everything'))
	globals.main.get_node('inventory/gear').pressed = true
	globals.main.get_node('inventory').selectcategory(globals.main.get_node('inventory/gear'))
	globals.main.get_node('inventory').selectbuttonslave(person)


func _on_items_pressed():
	globals.main._on_inventory_pressed()
	globals.main.get_node('inventory').selectcategory(globals.main.get_node('inventory/everything'))
	globals.main.get_node('inventory/potion').pressed = true
	globals.main.get_node('inventory').selectcategory(globals.main.get_node('inventory/potion'))
	globals.main.get_node('inventory').selectbuttonslave(person)




#Tattoos

#warning-ignore:unused_class_variable
var tattoosdescript = { #this goes like : start + tattoo theme + end + tattoo description: I.e On $his face you see a notable nature themed tattoo, depicting flowers and vines
face = {start = "On $his cheek you see a notable ", end = " themed tattoo, depicting"},
chest = {start = "$His chest is decorated with a", end = " tattoo, portraying"},
waist = {start = "On lower part of $his back, you spot a ", end = " tattooed image of "},
arms = {start = "$His arm has a skillfully created ", end = " image of "},
legs = {start = "$His ankle holds a piece of ", end = " art, representing"},
ass = {start = "$His butt has a large ", end = " themed image showing "},
}

var tattoooptions = {
none = {name = 'none', descript = "", applydescript = "Select a theme for future tattoo"},
nature = {name = 'nature', descript = " flowers and vines", function = "naturetattoo", applydescript = "Nature thematic tattoo will increase $name's beauty. "},
tribal = {name = 'tribal',descript = " totemic markings and symbols", function = "tribaltattoo", applydescript = "Tribal thematic tattoo will increase $name's scouting performance. "},
degrading = {name = 'derogatory', descript = " rude words and lewd drawings", function = "degradingtattoo",  applydescript = "Derogatory tattoo will promote $name's lust and enforce obedience. "},
animalistic = {name = 'beastly', descript = " realistic beasts and insects", function = "animaltattoo", applydescript = "Animalistic tattoo will boost $name's energy regeneration. "},
magic = {name = "energy", descript = " empowering patterns and runes", function = "manatattoo", applydescript = "Magic tattoo will increase $name's Magic Affinity. "},
}

var tattoolevels = {
nature = {
1 : {bonusdescript = "+5 Beauty", effect = 'nature1'},
2 : {bonusdescript = "+10 Beauty", effect = 'nature2'},
3 : {bonusdescript = "+15 Beauty", effect = 'nature3'},
highest = "+15 Beauty",
},
tribal = {
1 : {bonusdescript = "+3 Awareness", effect = 'tribal1'},
2 : {bonusdescript = "+6 Awareness", effect = 'tribal2'},
3 : {bonusdescript = "+9 Awareness", effect = 'tribal3'},
highest = "+9 Awareness",
},
degrading = {
1 : {bonusdescript = "+5 Lust and Obedience per day", effect = 'degrading1'},
2 : {bonusdescript = "+10 Lust and Obedience per day", effect = 'degrading2'},
3 : {bonusdescript = "+15 Lust and Obedience per day", effect = 'degrading3'},
4 : {bonusdescript = "+20 Lust and Obedience per day", effect = 'degrading4'},
highest = "+20 Lust and Obedience per day",
},
animalistic = {
1 : {bonusdescript = "+8 Energy per day", effect = 'animalistic1'},
2 : {bonusdescript = "+16 Energy per day", effect = 'animalistic2'},
3 : {bonusdescript = "+24 Energy per day", effect = 'animalistic3'},
highest = "+24 Energy per day",
},
magic = {
1 : {bonusdescript = "+0 Magic Affinity", effect = 'magic1'},
2 : {bonusdescript = "+1 Magic Affinity", effect = 'magic2'},
3 : {bonusdescript = "+1 Magic Affinity", effect = 'magic3'},
4 : {bonusdescript = "+1 Magic Affinity", effect = 'magic4'},
5 : {bonusdescript = "+2 Magic Affinity", effect = 'magic5'},
highest = '+2 Magic Affinity',
},
}

var tattoodict = {
none = {value = 0, code = 'none'},
nature = {value = 1, code = 'nature'},
tribal = {value = 2, code = 'tribal'},
degrading = {value = 3, code = 'degrading'},
animalistic = {value = 4, code = 'animalistic'},
magic = {value = 5, code = 'magic'},
}

var selectedpart = ''
var slavetattoos = {}
var tattootheme = 'none'

func _on_applybutton_pressed():
	person.tattooshow[selectedpart] = !get_node("stats/customization/tattoopanel/invisible").is_pressed()
	if get_node("stats/customization/tattoopanel/tattoooptions").is_disabled():
		return
	elif tattootheme == 'none':
		return
	elif globals.itemdict.magicessenceing.amount < 1 || globals.itemdict.supply.amount < 1:
		get_tree().get_current_scene().infotext("Not enough resources",'red')
		return
	else:
		globals.itemdict.magicessenceing.amount -= 1
		globals.itemdict.supply.amount -= 1
	
	person.tattoo[selectedpart] = tattootheme
	counttattoos()
	var tattooDict = {currentlevel = slavetattoos[person.tattoo[selectedpart]]}
	if tattoolevels[tattootheme].has(tattooDict.currentlevel-1) && tattoolevels[tattootheme].has(tattooDict.currentlevel):
		person.add_effect(globals.effectdict[tattoolevels[tattootheme][tattooDict.currentlevel-1].effect],true)
	if tattoolevels[tattootheme].has(tattooDict.currentlevel):
		person.add_effect(globals.effectdict[tattoolevels[tattootheme][tattooDict.currentlevel].effect])
	for i in get_node("stats/customization/tattoopanel/VBoxContainer").get_children():
		if i.get_name() == selectedpart:
			choosetattooarea(i)
	if person != globals.player:
		slavetabopen()

func _on_tattoo_pressed():
	$stats/customization/tattoopanel.popup()
	tattootheme = 'none'
	selectedpart = ''
	counttattoos()
	$stats/customization/tattoopanel/tattoooptions.visible = false
	$stats/customization/tattoopanel/RichTextLabel.set_bbcode("Select body part to work on")
	for i in $stats/customization/tattoopanel/VBoxContainer.get_children():
		i.set_pressed(false)
		if i.get_name() in ['legs','arms']:
			if i.get_name() == 'legs' && person.legs in ['webbed','fur_covered','normal','scales']:
				i.set_disabled(false)
			elif i.get_name() == 'arms' && person.arms in ['webbed','fur_covered','normal','scales']:
				i.set_disabled(false)
			else:
				i.set_disabled(true)

func counttattoos():
	slavetattoos = {none = 0,nature = 0, tribal = 0, degrading = 0, animalistic = 0, magic = 0}
	for i in person.tattoo:
		slavetattoos[person.tattoo[i]] += 1

func choosetattooarea(button):
	var area = button.get_name()
	var text = ''
	selectedpart = str(area)
	for i in $stats/customization/tattoopanel/VBoxContainer.get_children():
		if i == button:
			i.set_pressed(true)
		else:
			i.set_pressed(false)
	$stats/customization/tattoopanel/tattoooptions.visible = true
	$stats/customization/tattoopanel/tattoooptions.select(tattoodict[person.tattoo[area]].value)
	if $stats/customization/tattoopanel/tattoooptions.get_selected() == 0:
		text += "$name currently has no tattoos on $his " + area + ". "
		$stats/customization/tattoopanel/tattoooptions.set_disabled(false)
	else:
		$stats/customization/tattoopanel/tattoooptions.set_disabled(true)
		text += "$name has a [color=aqua]" + tattoooptions[person.tattoo[area]].name + '[/color] tattoo on $his ' + area + '. '
		text += "\n[color=aqua]Apply to change visibility[/color]"
	$stats/customization/tattoopanel/RichTextLabel.set_bbcode(person.dictionary(text))

func _on_tattooclose_pressed():
	get_node("stats/customization/tattoopanel").visible = false


#warning-ignore:unused_argument
func _on_tattoooptions_item_selected( ID ):
	for i in tattoodict.values():
		if i.value == get_node("stats/customization/tattoopanel/tattoooptions").get_selected():
			tattootheme = i.code
	var text = person.dictionary(tattoooptions[tattootheme].applydescript)
	if tattootheme != 'none':
		text += "\n\n"
		if slavetattoos[tattootheme] > 0:
			text += "Current Level: " + str(slavetattoos[tattootheme])
			if tattoolevels[tattootheme].has(slavetattoos[tattootheme]):
				text += "\nCurrent Bonus: " + tattoolevels[tattootheme][slavetattoos[tattootheme]].bonusdescript
			else:
				text += "\nCurrent Bonus: " + tattoolevels[tattootheme].highest
		if tattoolevels[tattootheme].has(slavetattoos[tattootheme]+1):
			text += "\nNext Bonus: " + tattoolevels[tattootheme][slavetattoos[tattootheme]+1].bonusdescript
		else:
			text += "\n[color=yellow]No additional effects. [/color]"
	get_node("stats/customization/tattoopanel/RichTextLabel").set_bbcode(text)
	

#Piercing


var piercingdict = {
earlobes = {name = 'earlobes', options = ['earrings', 'stud'], requirement = null, id = 1},
eyebrow = {name = 'eyebrow', options = ['stud'], requirement = null, id = 2},
nose = {name = 'nose', options = ['stud', 'ring'], requirement = null, id = 3},
lips = {name = 'lips', options = ['stud', 'ring'], requirement = null, id = 4},
tongue = {name = 'tongue', options = ['stud'], requirement = null, id = 5},
navel = {name = 'navel', options = ['stud'], requirement = null, id = 6},
nipples = {name = 'nipples', options = ['ring', 'stud', 'chain'], requirement = 'lewdness', id = 7},
clit = {name = 'clit', options = ['ring', 'stud'], requirement = 'lewdness, pussy', id = 8},
labia = {name = 'labia', options = ['ring', 'stud'], requirement = 'lewdness, pussy', id = 9},
penis = {name = 'penis', options = ['ring', 'stud'], requirement = 'lewdness, penis', id = 10},
}

func _on_piercing_pressed():
	$stats/customization/piercingpanel.popup()
	for i in $stats/customization/piercingpanel/ScrollContainer/VBoxContainer.get_children():
		if i.get_name() != 'piercingline' :
			i.visible = false
			i.queue_free()
	if person.consent == true || person == globals.player:
		$stats/customization/piercingpanel/piercestate.set_text(person.dictionary('$name does not seems to mind you pierce $his private places.'))
	else:
		$stats/customization/piercingpanel/piercestate.set_text(person.dictionary('$name refuses to let you pierice $his private places'))
	$stats/customization/piercingpanel/piercestate.visible = person != globals.player
	for i in piercingdict:
		if person.piercing.has(i) == false:
			person.piercing[i] = null
	
	var array = []
	for i in piercingdict.values():
		array.append(i)
	array.sort_custom(self, 'idsort')
	
	for ii in array:
		if ii.requirement == null || ( person.consent == true && ii.requirement == 'lewdness') || (person.penis != 'none' && person.consent == true && ii.id == 10) || (person.vagina == 'normal' && person.consent == true && (ii.id == 8 || ii.id == 9)):
			var newline = $stats/customization/piercingpanel/ScrollContainer/VBoxContainer/piercingline.duplicate()
			newline.visible = true
			$stats/customization/piercingpanel/ScrollContainer/VBoxContainer/.add_child(newline)
			newline.get_node("placename").set_text(ii.name.capitalize())
			for i in ii.options:
				newline.get_node("pierceoptions").add_item(i)
				if person.piercing[ii.name] == i:
					newline.get_node("pierceoptions").select(newline.get_node("pierceoptions").get_item_count()-1)
			newline.get_node('pierceoptions').set_meta('pierce', ii.name)
			newline.get_node("pierceoptions").connect("item_selected", self, 'pierceselect', [newline.get_node("pierceoptions").get_meta('pierce')])

func idsort(first, second):
	if first.id < second.id:
		return true
	else:
		return false

func pierceselect(ID, node):
	if ID == 0:
		person.piercing[node] = 'pierced'
	else:
		person.piercing[node] = piercingdict[node].options[ID-1]
	_on_piercing_pressed()
	if person != globals.player:
		slavetabopen()

func _on_closebutton_pressed():
	$stats/customization/piercingpanel.visible = false


func _on_hairstyle_item_selected( ID ):
	person = globals.currentslave
	var hairstyles = ['straight','ponytail', 'twintails', 'braid', 'two braids', 'bun']
	person.hairstyle = hairstyles[ID]
	slavetabopen()


func _on_image_pressed():
	get_tree().get_current_scene().imageselect("body", person)


func _on_portrait_pressed():
	get_tree().get_current_scene().imageselect("portrait", person)




func _on_bodybutton_pressed():
	if get_node("inspect/Panel 2/fullbody").get_texture() != null:
		get_node("inspect/Panel 2").set_hidden(!get_node("inspect/Panel 2").is_hidden())






func stattooltip(value):
	var text = globals.statsdescript[value]
	globals.showtooltip(text)

func statup(stat):
	person.stats[globals.maxstatdict[stat].replace('_max','_base')] += 1
	person[stat] += 0
	person.skillpoints -= 1
	updatestats()

#warning-ignore:unused_class_variable
onready var sstr = get_node("stats/statspanel/sstr")
#warning-ignore:unused_class_variable
onready var sagi = get_node("stats/statspanel/sagi")
#warning-ignore:unused_class_variable
onready var smaf = get_node("stats/statspanel/smaf")
#warning-ignore:unused_class_variable
onready var send = get_node("stats/statspanel/send")
#warning-ignore:unused_class_variable
onready var cour = get_node("stats/statspanel/cour")
#warning-ignore:unused_class_variable
onready var conf = get_node("stats/statspanel/conf")
#warning-ignore:unused_class_variable
onready var wit = get_node("stats/statspanel/wit")
#warning-ignore:unused_class_variable
onready var charm = get_node("stats/statspanel/charm")

func updatestats():
	var text = ''
	var mentals = [$stats/statspanel/cour, $stats/statspanel/conf, $stats/statspanel/wit, $stats/statspanel/charm]
	for i in globals.statsdict:
		text = str(person[i]) 
		get(i).get_node('cur').set_text(text)
		if i in ['sstr','sagi','smaf','send']:
			if person.stats[globals.maxstatdict[i].replace("_max",'_mod')] >= 1:
				get(i).get_node('cur').set('custom_colors/font_color', Color(0,1,0))
			elif person.stats[globals.maxstatdict[i].replace("_max",'_mod')] < 0:
				get(i).get_node('cur').set('custom_colors/font_color', Color(1,0.29,0.29))
			else:
				get(i).get_node('cur').set('custom_colors/font_color', Color(1,1,1))
		get(i).get_node('max').set_text(str(min(person.stats[globals.maxstatdict[i]], person.originvalue[person.origins])))
		#get(i).set_bbcode(text)
	for i in mentals:
		if person == globals.player:
			i.get_parent().visible = false
		else:
			i.get_parent().visible = true
	if !person.traits.empty():
		text = "$name has trait(s): "
		var text2 = ''
		for i in person.get_traits():
			text2 += '[url=' + i.name + ']' + i.name + "[/url]"
			if i.tags.find('sexual') >= 0:
				text2 = "[color=#ff5ace]" + text2 + '[/color]'
			elif i.tags.find('detrimental') >= 0:
				text2 = "[color=#ff4949]" + text2 + '[/color]'
			text2 += ', '
			text += text2
		text = text.substr(0, text.length() - 2) + '.'
	text = person.name_long() + '\n[color=aqua][url=race]' +person.dictionary('$race[/url][/color]').capitalize() +  '\nLevel : '+str(person.level)
	get_node("stats/statspanel/info").set_bbcode(person.dictionary(text))
	get_node("stats/statspanel/attribute").set_text("Free Attribute Points : "+str(person.skillpoints))
	
	for i in ['send','smaf','sstr','sagi']:
		if person.skillpoints >= 1 && (globals.slaves.find(person) >= 0||globals.player == person) && person.stats[globals.maxstatdict[i].replace('_max','_base')] < person.stats[globals.maxstatdict[i]]:
			get_node("stats/statspanel/" + i +'/Button').visible = true
		else:
			get_node("stats/statspanel/" + i+'/Button').visible = false
	if person.levelupreqs.empty() && person.xp < 100:
		$stats/basics/levelupreqs.set_bbcode("")
	get_node("stats/statspanel/hp").set_value((person.stats.health_cur/float(person.stats.health_max))*100)
	get_node("stats/statspanel/en").set_value((person.stats.energy_cur/float(person.stats.energy_max))*100)
	get_node("stats/statspanel/xp").set_value(person.xp)
	text = "Health: " + str(person.stats.health_cur) + "/" + str(person.stats.health_max) + "\nEnergy: " + str(person.stats.energy_cur) + "/" + str(person.stats.energy_max) + "\nExperience: " + str(person.xp) 
	get_node("stats/statspanel/hptooltip").set_tooltip(text)
	get_node("stats/statspanel/grade").set_texture(gradeimages[person.origins])
	if person.imageportait != null && globals.loadimage(person.imageportait):
		$stats/statspanel/TextureRect/portrait.set_texture(globals.loadimage(person.imageportait))
	else:
		person.imageportait = null
		$stats/statspanel/TextureRect/portrait.set_texture(null)
	$stats/statspanel/spec.set_texture(specimages[str(person.spec)])
	if person.xp >= 100 && person.levelupreqs.empty():
		$stats/basics/levelupreqs.set_bbcode(person.dictionary("You don't know what might unlock $name's potential further, yet. "))
	elif person.xp >= 100:
		$stats/basics/levelupreqs.set_bbcode(person.levelupreqs.descript)
	else:
		$stats/basics/levelupreqs.set_bbcode('')

var gradeimages = globals.gradeimages

var specimages = globals.specimages


func _on_traittext_meta_clicked( meta ):
	var text = globals.origins.trait(meta).description
	globals.showtooltip(person.dictionary(text))


func _on_traittext_mouse_exit():
	globals.hidetooltip()


#warning-ignore:unused_argument
func _on_info_meta_clicked( meta ):
	get_tree().get_current_scene().showracedescript(person)

func _on_spec_mouse_entered():
	var text 
	if person.spec == null:
		text = "Specialization can provide special abilities and effects and can be trained at Slavers' Guild. "
	else:
		var spec = globals.jobs.specs[person.spec]
		text = "[center]" + spec.name + '[/center]\n'+ spec.descript + "\n[color=aqua]" +  spec.descriptbonus + '[/color]'
	globals.showtooltip(text)


func _on_spec_mouse_exited():
	globals.hidetooltip()


func _on_inspect_pressed():
	$stats/inspect.pressed = true
	$stats/customize.pressed = false
	$stats/basics.visible = true
	$stats/customization.visible = false

func _on_customize_pressed():
	$stats/inspect.pressed = false
	$stats/customize.pressed = true
	$stats/basics.visible = false
	$stats/customization.visible = true




func _on_fullbodycheck_pressed():
	showfullbody = $stats/basics/fullbodycheck.pressed
	slavetabopen()

