extends Panel

var person
#warning-ignore:unused_class_variable
onready var sstr = get_node("sstr/Label")
#warning-ignore:unused_class_variable
onready var sagi = get_node("sagi/Label")
#warning-ignore:unused_class_variable
onready var smaf = get_node("smaf/Label")
#warning-ignore:unused_class_variable
onready var send = get_node("send/Label")
#warning-ignore:unused_class_variable
onready var cour = get_node("cour/Label")
#warning-ignore:unused_class_variable
onready var conf = get_node("conf/Label")
#warning-ignore:unused_class_variable
onready var wit = get_node("wit/Label")
#warning-ignore:unused_class_variable
onready var charm = get_node("charm/Label")
var mode = 'slavebase'

func _ready():
	for i in ['send','smaf','sstr','sagi']:
#warning-ignore:return_value_discarded
		get_node(i+'/Button').connect("pressed", self, 'statup', [i])
	for i in globals.statsdict:
		get(i).get_parent().get_node("Control").connect("mouse_entered", self, 'showtooltip', [i])
		get(i).get_parent().get_node("Control").connect("mouse_exited", globals, 'hidetooltip')
	

func showtooltip(value):
	var text = globals.statsdescript[value]
	globals.showtooltip(text)

func statup(stat):
	person[stat] += 1
	person.skillpoints -= 1
	show()

func show():
	var text = ''
	var mentals = [cour, conf, wit, charm]
	for i in globals.statsdict:
		text = ''
		if i in ['sstr','sagi','smaf','send']:
			if person.stats[globals.maxstatdict[i].replace("_max",'_mod')] >= 1:
				text = "[color=green]"
			elif person.stats[globals.maxstatdict[i].replace("_max",'_mod')] < 0:
				text = "[color=red]"
		text += str(person[i]) 
		if mode in ['full','slaveadv']:
			if text.find('color') >= 0:
				text += "[/color]"
			text += "/" +str(min(person.stats[globals.maxstatdict[i]], person.originvalue[person.origins]))
		get(i).set_bbcode(text)
	for i in mentals:
		if mode == 'slavebase':
			i.get_parent().visible = false
		else:
			i.get_parent().visible = true
	if !person.traits.empty():
		text = "$name has trait(s): "
		var text2 = ''
		for i in person.get_traits():
			text2 = '[url=' + i.name + ']' + i.name + "[/url]"
			if i.tags.find('sexual') >= 0:
				text2 = "[color=#ff5ace]" + text2 + '[/color]'
			elif i.tags.find('detrimental') >= 0:
				text2 = "[color=#ff4949]" + text2 + '[/color]'
			text += text2 + ', '
		text = text.substr(0, text.length() - 2) + '.'
	if person.spec != null:
		text += "\n\nSpecialization: [color=aqua]" + globals.jobs.specs[person.spec].name + "[/color]."
	get_node("traittext").set_bbcode(person.dictionary(text))
	if mode == 'full':
		text = "[url=race][color=aqua]"+ person.race + "[/color][/url]\nHealth : " + str(round(person.health)) + '/' + str(round(person.stats.health_max)) + '\nEnergy : ' + str(round(person.energy)) + '/' + str(round(person.stats.energy_max)) + '\nLevel : '+str(person.level) + '\nAttribute Points : '+str(person.skillpoints)
		if person == globals.player:
			text = person.dictionary('$name $surname\nRace: ') + person.dictionary(' $race\n').capitalize() + text
	else:
		text =  'Level : '+str(person.level) + '\nAvailable Attribute Points : '+str(person.skillpoints)
	get_node("leveltext").set_bbcode(person.dictionary(text))
	get_node("levelprogress/Label").set_text("Experience: " + str(person.xp) + '%')
	get_node("levelprogress").set_value(person.xp)
	for i in ['send','smaf','sstr','sagi']:
		#print( person.stats[globals.maxstatdict[i].replace('_max','_base')], "  ", person.stats[globals.maxstatdict[i]])
		if person.skillpoints >= 1 && (globals.slaves.find(person) >= 0||globals.player == person) && person.stats[globals.maxstatdict[i].replace('_max','_base')] < person.stats[globals.maxstatdict[i]]:
			get_node(i+'/Button').visible = true
		else:
			get_node(i+'/Button').visible = false
	if person.levelupreqs.empty() && person.xp < 100:
		get_node("levelreqs").set_bbcode("")
	elif person.xp >= 100 && person.levelupreqs.empty():
		get_node("levelreqs").set_bbcode(person.dictionary("You don't know what might unlock $name's potential further, yet. "))
	else:
		get_node("levelreqs").set_bbcode(person.levelupreqs.descript)
	




#warning-ignore:unused_argument
func _on_traittext_meta_hover_ended(meta):
	globals.hidetooltip()


func _on_traittext_meta_hover_started(meta):
	var text = globals.origins.trait(meta).description
	globals.showtooltip(person.dictionary(text))


func _on_traittext_mouse_exited():
	globals.hidetooltip()
