
extends Control

var period = 'base'
#warning-ignore:unused_class_variable
var phase = ''
var currentenemies
#warning-ignore:unused_class_variable
var enemygear = {}
var playergroup = []
var enemygroup = []
var selectedcharacter
var targetskill
var nocaptures = false
#warning-ignore:unused_class_variable
var area
var trapper = false
#warning-ignore:unused_class_variable
var trappername
var turns = 0
var combatantnodes = []
var enemyturn = false
var animationskip = false

var combatlog = '' setget combatlog_set, combatlog_get

var instantanimation = globals.rules.instantcombatanimation

func combatlog_set(value):
	$TextureRect2/combatlog.bbcode_text = value
	$TextureRect2/combatlog.scroll_to_line($TextureRect2/combatlog.get_line_count()-1)

func combatlog_get():
	return $TextureRect2/combatlog.bbcode_text

var debug = false


var enemypaneltextures = {
	normal = load("res://files/buttons/combat/6.png"),
	target = load("res://files/buttons/combat/7.png"),
}
var playerpaneltextures = {
	normal = load("res://files/buttons/combat/8.png"),
	target = load("res://files/buttons/combat/9.png"),
	disabled = load("res://files/buttons/combat/8.1.png"),
}


func _ready():
	$grouppanel/skilline/skill.set_meta('skill', {})
	if debug == true:
		var scene = load("res://files/scripts/exploration.gd")
		globals.main = self
		$TextureRect.set_script(scene)
		globals.player = globals.newslave('randomany', 'random', 'random')
		var x = 2
		while x > 0:
			var newslave = globals.newslave('randomany', 'random', 'random')
			x -= 1
			globals.slaves = newslave
			globals.state.playergroup.append(newslave.id)
		for i in globals.slaves + [globals.player]:
			var newcombatant = combatant.new()
			var newbutton = $grouppanel/groupline/character.duplicate()
			$grouppanel/groupline.add_child(newbutton)
			newcombatant.node = newbutton
			newcombatant.scene = self
			newcombatant.createfromslave(i)
			newcombatant.energy = 50
			newcombatant.person.lust = 0
			newbutton.connect('pressed', newcombatant, 'selectcombatant')
			newbutton.connect('mouse_entered', newcombatant, 'combatanttooltip')
			newbutton.connect("mouse_exited", globals, 'hidetooltip')
			newbutton.visible = true
			playergroup.append(newcombatant)
			newbutton.set_meta('combatant', newcombatant)
			if OS.get_name() != 'HTML5' || true:
				yield(get_tree(), 'idle_frame')
			combatantnodes.append(newbutton)
			newcombatant.hp = 10
		yield(get_tree(), 'idle_frame')
		
		$TextureRect.buildenemies("banditseasy")
		currentenemies = $TextureRect.enemygroup
		for i in currentenemies.units:
			var newcombatant = combatant.new()
			var newbutton = $enemypanel/enemyline/character.duplicate()
			$enemypanel/enemyline.add_child(newbutton)
			newcombatant.node = newbutton
			newbutton.set_meta('combatant', newcombatant)
			newbutton.connect('mouse_entered', newcombatant, 'combatanttooltip')
			newcombatant.scene = self
			newbutton.connect('pressed', newcombatant, 'selectcombatant')
			newbutton.visible = true
			if nocaptures == false && i.capture != null:
				newcombatant.createfromslave(i.capture, i)
			else:
				newcombatant.createfromdata(i)
			newcombatant.name = i.name
			enemygroup.append(newcombatant)
			combatantnodes.append(newbutton)
			#newcombatant.draw()


func resetpanels():
	for i in $grouppanel/groupline.get_children() + $enemypanel/enemyline.get_children():
		if i.name != 'character':
			i.hide()
			i.free()




func start_battle(nosound = false):
	get_parent().animationfade(0.4)
	instantanimation = globals.rules.instantcombatanimation
	resetpanels()
	yield(get_parent(),'animfinished')
	get_node("autowin").visible = get_parent().get_node("new slave button").visible
	var _slave
#warning-ignore:unused_variable
	var combatant
	trapper = false
	enemyturn = false
	globals.main.get_node("outside").hide()
	globals.main.get_node("ResourcePanel").hide()
	turns = 1
	self.combatlog = ''
	playergroup.clear()
	enemygroup.clear()
	combatantnodes.clear()
	for i in $enemypanel.get_children() + $grouppanel.get_children():
		if i.get_class() == 'TextureButton':
			i.hide()
			i.free()
			#i.queue_free()
	
	if nosound == false:
		globals.main.music_set('combat')
	self.visible = true
	combatlog = ''
	var slavearray = []
	for i in globals.state.playergroup:
		slavearray.append(globals.state.findslave(i))
	for i in [globals.player] + slavearray:
		var newcombatant = self.combatant.new()
		var newbutton = $grouppanel/groupline/character.duplicate()
		$grouppanel/groupline.add_child(newbutton)
		newcombatant.node = newbutton
		newcombatant.scene = self
		newcombatant.createfromslave(i)
		newbutton.connect('pressed', newcombatant, 'selectcombatant')
		newbutton.connect('mouse_entered', newcombatant, 'combatanttooltip')
		newbutton.connect("mouse_exited", newcombatant, 'hidecombatanttooltip')
		newbutton.get_node("info").connect("pressed",self,'showinfochar',[newcombatant])
		newbutton.visible = true
		playergroup.append(newcombatant)
		newbutton.set_meta('combatant', newcombatant)
		checkforinheritdebuffs(newcombatant)
		combatantnodes.append(newbutton)
	
	for i in currentenemies:
		var newcombatant = self.combatant.new()
		var newbutton = $enemypanel/enemyline/character.duplicate()
		$enemypanel/enemyline.add_child(newbutton)
		newcombatant.node = newbutton
		newbutton.set_meta('combatant', newcombatant)
		newcombatant.scene = self
		newbutton.connect('pressed', newcombatant, 'selectcombatant')
		newbutton.connect('mouse_entered', newcombatant, 'combatanttooltip')
		newbutton.connect("mouse_exited", newcombatant, 'hidecombatanttooltip')
		newbutton.visible = true
		if nocaptures == false && i.capture != null:
			newcombatant.createfromslave(i.capture, i)
		else:
			newcombatant.createfromdata(i)
		newcombatant.name = i.name
		enemygroup.append(newcombatant)
		combatantnodes.append(newbutton)
	
	$grouppanel/skilline/skill.set_meta('skill', {})
	nocaptures = false
	#if OS.get_name() != 'HTML5':
	yield(get_tree(),'idle_frame')
	for i in $grouppanel/groupline.get_children():
			if i.name != 'character':
				var pos = i.rect_global_position
				$grouppanel/groupline.remove_child(i)
				$grouppanel.add_child(i)
				i.rect_global_position = pos
	for i in $enemypanel/enemyline.get_children():
			if i.name != 'character':
				var pos = i.rect_global_position
				$enemypanel/enemyline.remove_child(i)
				$enemypanel.add_child(i)
				i.rect_global_position = pos
	period = 'base'
	
	if globals.state.tutorial.combat == false:
		globals.main.get_node("tutorialnode").combat()


#warning-ignore:unused_argument
func _process(delta):
	if self.visible == false:
		return
	$resources/mana/Label.text = str(globals.resources.mana)
	$resources/turns/Label.text = str(turns)
	$period.text = period
	
	if animationskip == true:
		animationskip = false
		tweenfinished()
	
	if period == 'nextturn' && ongoinganimation == false:
		turns += 1
		period = 'base'
		self.combatlog += "\n[center]Turn " + str(turns) + "[/center]"
	
	for i in combatantnodes:
		var combatant = i.get_meta('combatant')
		
		if ongoinganimation:
			break
		if combatant.state in ['defeated','escaped'] && combatant.animationplaying == false:
			combatant.effects.clear()
			i.hide()
			#i.queue_free()
			combatantnodes.erase(i)
			return
		
		i.get_node("portrait").texture = globals.loadimage(combatant.portrait)
		i.get_node("name").text = combatant.name
		if i.get_node("hp").value != (combatant.hp/combatant.hpmax)*100:
			$Tween.interpolate_property(i.get_node("hp"), "value", i.get_node('hp').value, (combatant.hp/combatant.hpmax)*100, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			#i.get_node("hp").value = (combatant.hp/combatant.hpmax)*100
		i.get_node("hp/Label").text = str(ceil(combatant.hp)) + "/" + str(combatant.hpmax)
		if combatant.group == 'enemy' && playergroup[0].effects.has('mindreadeffect'):
			i.get_node("hp/Label").visible = true
		elif combatant.group == 'enemy':
			i.get_node('hp/Label').visible = false
		if i.has_node("en"):
			i.get_node("en").value = float(combatant.energy)/combatant.energymax*100
			i.get_node("en/Label").text = str(ceil(combatant.energy)) + "/" + str(combatant.energymax)
		if i.has_node('stress') && combatant.person != globals.player:
			i.get_node('stress').visible = true
			i.get_node('stress/Label').text = str(combatant.stress)
			i.get_node('stress').value = round(float(combatant.stress)/combatant.stressmax*100)
		
	
	#Reset panel textures
	if period == 'base':
		for i in $enemypanel.get_children():
			if i.get_class() == 'TextureButton':
				if period == 'skilltarget' && targetskill.targetgroup == 'enemy':
					i.set_normal_texture(enemypaneltextures.target)
				else:
					i.set_normal_texture(enemypaneltextures.normal)
		for i in $grouppanel.get_children():
			if i.get_class() == 'TextureButton':
				if period == 'skilltarget' && targetskill.targetgroup == 'ally':
					i.set_normal_texture(playerpaneltextures.target)
				elif i.get_meta('combatant').actionpoints <= 0:
					i.set_normal_texture(playerpaneltextures.disabled)
				else:
					i.set_normal_texture(playerpaneltextures.normal)
				if selectedcharacter == null && i.get_meta('combatant').actionpoints > 0:
					i.emit_signal('pressed')
	
	#Set cursor and skill pressed
	if period == 'skilltarget':
		Input.set_custom_mouse_cursor(load("res://files/buttons/kursor_act.png"))
		for i in $grouppanel/skilline.get_children():
			i.pressed = i.get_meta("skill") == targetskill
	else:
		Input.set_custom_mouse_cursor(load("res://files/buttons/kursor.png"))
		for i in $grouppanel/skilline.get_children():
			i.pressed = false

func rebuildbuffs(combatant):
	var node = combatant.node
	for i in node.get_node("buffscontainer").get_children():
			if i.name != 'TextureRect':
				i.hide()
				i.free()
	for i in combatant.effects.values():
		var newnode = node.get_node("buffscontainer/TextureRect").duplicate()
		node.get_node("buffscontainer").add_child(newnode)
		newnode.visible = true
		newnode.texture = i.icon
		newnode.connect("mouse_entered", self, 'bufftooltip', [i])
		newnode.connect("mouse_exited", globals, 'hidetooltip')

func _input(event):
	if event.is_echo() == true || event.is_pressed() == false || get_node("abilitites/Panel").visible == true || is_visible_in_tree() == false:
		return
	#Cancel skill by rightclick
	if event.is_action_pressed("RMB") && period == 'skilltarget':
		period = 'base'
		selectedcharacter.selectcombatant()
	#Select ability by 1-8 nums
	if str(event.as_text()) in str(range(1,9)):
		if self.visible == true && $win.visible == false && $grouppanel/skilline.get_children().size() > int(event.as_text()) && $grouppanel/skilline.get_child(int(event.as_text())).disabled == false:
			get_node("grouppanel/skilline").get_child(int(event.as_text())).emit_signal('pressed')
	#select characters
	if event.as_text() in ['F1','F2','F3','F4'] && $win.visible == false && get_node("grouppanel/groupline").get_children().size() > int(event.as_text().replace("F","")):
		$grouppanel/groupline.get_child(int(event.as_text().replace("F",""))).emit_signal('pressed')
	#End turn
	if event.is_action_pressed("F") == true && $confirm.disabled == false && $win.visible == false:
		_on_confirm_pressed()



class combatant:
	var person
	var group
	var state = 'normal'
#warning-ignore:unused_class_variable
	var panel
	var name
	var hp setget health_set, health_get
	var hpmax
	var energy
	var energymax
	var stress = 0
	var stressmax = 0
	var lust
	var lustmax
	var passives = {}
	var attack = 0
	var magic = 0
	var armor = 0
#warning-ignore:unused_class_variable
	var protection = 0
	var speed = 0
	var portrait
#warning-ignore:unused_class_variable
	var target
	var geareffects = []
	var abilities
	var activeabilities
	var node
	var scene
	var cooldowns = {}
	var actionpoints = 1
#warning-ignore:unused_class_variable
	var effects = {}
	var faction
	
	var animationplaying = false
	
	var ai = ''
#warning-ignore:unused_class_variable
	var aimemory = ''
	
	
	func createfromdata(data):
		name = data.name
		portrait = data.icon
		if person == globals.player || (globals.slaves.has(person) && globals.state.playergroup.has(person.id)):
			group = 'player'
		else:
			group = 'enemy'
		abilities = data.stats.abilities
		#Filling values
		
		if data.has('faction'):
			faction = data.faction
		
		hp = data.stats.health
		hpmax = data.stats.health
		energy = data.stats.energy
		
		attack = data.stats.power
		armor = data.stats.armor
		speed = data.stats.speed
		magic = data.stats.magic
		
		if data.stats.has("passives"):
			for i in data.stats.passives:
				var passive = globals.abilities.passivesdict[i]
				self.passives[passive.effect] = passive
		
		ai = 'attack'
		if scene.get_parent().get_node("explorationnode").deeperregion:
			attack = ceil(attack * 1.25)
			hpmax = ceil(hpmax * 1.5)
			hp = hpmax
			speed = ceil(speed + 5)
		
	
	func createfromslave(person, data = null):
		name = person.name_short()
		self.person = person
		if person == globals.player || (globals.slaves.has(person) && globals.state.playergroup.has(person.id)):
			group = 'player'
			portrait = person.imageportait
		else:
			group = 'enemy'
			portrait = data.icon
			if person.sex in ['female','futa'] && data.has('iconalt'):
				portrait = data.iconalt
		abilities = person.ability
		activeabilities = person.abilityactive
		if data != null:
			for i in data.stats.abilities:
				abilities.append(i)
		
		#Filling values
		
		hp = person.health
		hpmax = person.stats.health_max
		energy = person.energy
		energymax = person.stats.energy_max
		stress = person.stress
		stressmax = person.stats.stress_max
		lust = person.lust
		lustmax = person.stats.lust_max
		
		attack = variables.baseattack + round(person.sstr * variables.damageperstr) + floor(person.level/2)
		magic = person.smaf
		armor = person.stats.armor_cur
		speed = variables.speedbase + (person.sagi * variables.speedperagi)
		ai = 'attack'
		
		if data != null && data.stats.has("passives"):
			for i in data.stats.passives:
				var passive = globals.abilities.passivesdict[i]
				self.passives[passive.effect] = passive
		
		if person.race == 'Seraph':
			speed += 4
		elif person.race.find('Wolf') >= 0:
			attack += 3
		if person.spec == 'assassin':
			speed += 5
			attack += 5
		
		if person.preg.duration > variables.pregduration/3:
			speed = round(speed - speed*0.25)
			scene.getbuff(scene.makebuff('pregnancy', self, self), self)
		#Gear
		
		
		for i in person.gear.values():
			var tempitem
			if i != null:
				if group == 'player':
					tempitem = globals.state.unstackables[i]
				else:
					tempitem = scene.enemygear[i]
				for k in tempitem.effects:
					if k.type == 'incombat' && globals.abilities.has_method(k.effect):
						globals.abilities.call(k.effect, self, k.effectvalue)
					if k.type in ['incombatphyattack', 'incombatturn', 'incombatspecial']:
						self.geareffects.append(k)
					if k.type == 'passive':
						self.passives[k.effect] = k
		scene.rebuildbuffs(self)
	
	func selectcombatant():
		if state == 'defeated':
			return
		if actionpoints <= 0 && scene.period == 'base':
			node.pressed = false
			scene.floattext(node.rect_global_position,'This character has already acted this turn')
			return
		if scene.period == 'base':
			if group == 'enemy':
				return
			scene.selectedcharacter = self
			for i in scene.playergroup:
				if i.state == 'defeated':
					continue
				i.node.pressed = i == scene.selectedcharacter
			buildabilities()
		elif scene.period == 'skilltarget':
			if scene.targetskill.targetgroup == 'enemy' && scene.selectedcharacter.group == self.group:
				scene.floattext(node.rect_global_position,'Wrong Target')
				return
			elif scene.targetskill.targetgroup == 'ally' && scene.selectedcharacter.group != self.group:
				scene.floattext(node.rect_global_position,'Wrong Target')
				return
			scene.period = 'skilluse'
			scene.useskills(scene.targetskill, scene.selectedcharacter, self)
	
	func combatanttooltip():
		if group == 'player':
			node.get_node('Panel').visible = true
			for i in ['attack','speed','protection','armor']:
				node.get_node('Panel/' + i + '/Label').text = str(get(i))
			if actionpoints <= 0:
				node.hint_tooltip = 'No action points left'
			else:
				node.hint_tooltip = ''
		elif group == 'enemy':
			if scene.playergroup[0].effects.has('mindreadeffect'):
				node.get_node('Panel').visible = true
				node.get_parent().move_child(node, node.get_parent().get_children().size())
				for i in ['attack','speed','protection','armor']:
					node.get_node('Panel/' + i + '/Label').text = str(get(i))
	
	func hidecombatanttooltip():
		node.get_node("Panel").hide()
	
	func buildabilities():
		for i in scene.get_node("grouppanel/skilline").get_children():
			if i.name != 'skill':
				i.hide()
				i.free()
		for i in activeabilities:
			var skill = globals.abilities.abilitydict[i]
			var newbutton = scene.get_node("grouppanel/skilline/skill").duplicate()
			scene.get_node("grouppanel/skilline").add_child(newbutton)
			newbutton.set_disabled(cooldowns.has(skill.code))
			newbutton.show()
			
			newbutton.get_node("number").set_text(str(scene.get_node("grouppanel/skilline").get_children().size()-1))
			if skill.cooldown > 0 && cooldowns.has(skill.code):
				newbutton.get_node('cooldown').visible = true
				newbutton.get_node('cooldown').text = str(cooldowns[skill.code])
			newbutton.set_meta("skill", skill)
			newbutton.connect("mouse_entered",scene,'showskilltooltip',[skill])
			newbutton.connect("mouse_exited",scene,'hideskilltooltip')
			newbutton.connect("pressed",scene,'pressskill', [skill])
			if skill.has('iconnorm'):
				newbutton.set_normal_texture(skill.iconnorm)
				newbutton.set_pressed_texture(skill.iconpressed)
				newbutton.set_disabled_texture(skill.icondisabled)
#			if action != null:
#				if action.name == skill.name:
#					newbutton.set_pressed(true)
			if newbutton.is_disabled():
				newbutton.get_node("number").set('custom_colors/font_color', Color(1,0,0,1))
			elif newbutton.is_pressed():
				newbutton.get_node("number").set('custom_colors/font_color', Color(0,1,1,1))
	
	func dodge():
		scene.floattext(node.rect_global_position, 'Miss!', '#ffff00')
	
	func health_set(value):
#warning-ignore:unused_variable
		var effect = ''
		var color = 'white'
		var difference = ceil(value - hp)
		if difference > 0:
			effect = 'increase'
			color = '#00ff5e'
			scene.healdamage(self)
		elif difference < 0:
			effect = 'decrease'
			color = '#f05337'
			scene.takedamage(self)
		hp = clamp(ceil(value), 0, hpmax)
		
		if group == 'enemy' && person != null && ai == 'attack' && hp <= hpmax/2 && randf() >= 0.6:
			ai = 'escape'
		
		#draw()
		scene.floattext(node.rect_global_position, str(difference), color)
		if hp <= 0:
			defeat()
	
	func health_get():
		return hp
	
	func defeat():
		state = 'defeated'
		scene.defeatanimation(self)
		yield(scene, 'defeatfinished')
		node.hide()
		animationplaying = false
		scene.combatlog += scene.combatantdictionary(self, self, "\n[color=aqua][name1] has been defeated.[/color]")
		if group == 'enemy':
			for i in scene.enemygroup:
				if i.passives.has("cultleaderpassive") && i != self:
					i.hpmax += 150
					i.hp += 300
					i.attack += 50
					scene.combatlog += "\n[color=red]Cult leader absorbs the power of defeated ally and grows stronger![/color]"
		if group == 'player':
			scene.playergroup.remove(scene.playergroup.find(person.id))
			if person == globals.player:
				globals.main.animationfade(1)
				if OS.get_name() != 'HTML5':
					yield(globals.main, 'animfinished')
				globals.main.get_node("gameover").show()
				globals.main.get_node("gameover/Panel/text").set_bbcode("[center]You have died.[/center]")
				scene.period = 'end'
				return
			else:
				var _slave = person
				if globals.rules.permadeath == false:
					_slave.stats.health_cur = 15
					_slave.away.duration = 3
					_slave.away.at = 'rest'
					_slave.work = 'rest'
					globals.state.playergroup.erase(person.id)
				else:
					globals.state.playergroup.erase(person.id)
					for i in globals.state.playergroup:
						globals.state.findslave(i).stress += rand_range(25,40)
					_slave.death()
		else:
			scene.repositionanimation()
		scene.endcombatcheck()
	

func checkforresults():
	if playergroup[0].state == 'defeated':
		lose()
		return
	var counter = 0
#warning-ignore:unused_variable
	var text = ''
	
	for i in playergroup:
		if i.state == 'defated':
			text += '\n[color=#ff4949]' + i.name + ' has fallen. [/color]'
			playergroup.remove(playergroup.find(i))
	for i in enemygroup:
		if i.state == 'defeated':
			counter += 1
	if counter >= enemygroup.size():
		win()

func lose():
	globals.main.animationfade(1)
	$confirm.disabled = true
	if OS.get_name() != 'HTML5':
		yield(globals.main, 'animfinished')
	globals.main.get_node("gameover").show()
	globals.main.get_node("gameover/Panel/text").set_bbcode("[center]You have died. \nGame over.[/center]")

func win():
	get_node("win").show()
	globals.main.music_set('stop')
	globals.main.sound('win')




func showinfochar(combatant):
		get_parent().get_node('outside').opencharacter(combatant.person, true, combatant)




func showskilltooltip(skill):
	var text = ''
	text += '[center]' + skill.name + '[/center]\n\n' + skill.description 
	if skill.costenergy > 0:
		text += "\n[color=yellow]Energy: " + str(skill.costenergy) + "[/color]"
	if skill.costmana > 0:
		var cost = skill.costmana
		if globals.state.spec == 'Mage':
			cost = round(cost/2)
		text += "\n[color=aqua]Mana: " + str(cost) + "[/color]"
	text += '\nBasic cooldown: ' + str(skill.cooldown)
	if selectedcharacter.cooldowns.has(skill.code):
		text += '\n\nCooldown: ' + str(selectedcharacter.cooldowns[skill.code])
	globals.showtooltip(text)

func hideskilltooltip():
	globals.hidetooltip()

func enemytooltip(enemy):
	var text = ''
	text += '[center]' + enemy.name + '[/center]\n'
	if enemy.person != null:
		text += enemy.person.race + ' ' + enemy.person.age + ' ' + enemy.person.sex + '.\n'
	if playergroup[0].effects.has('mindreadeffect') || globals.developmode == true:
		text += "Power: " + str(enemy.power) + " Speed: " + str(enemy.speed) + " Protection: " + str(enemy.protection) + " Armor: " + str(enemy.armor)
		if enemy.person != null:
			text += "\nGrade: " + enemy.person.origins
#	if enemy.person != null:
#		text += enemygear[enemy.person.gear.armor].name + "\n" + enemygear[enemy.person.gear.weapon].name
	globals.showtooltip(text)

func bufftooltip(buff):
	var text = '[center][color=yellow]' + buff.name + "[/color][/center]"
	if buff.description != null:
		text += '\n'+buff.description
	if str(buff.stats).replace('(','').replace(')','') != '':
		text += "\n" + str(buff.stats).replace('(','').replace(')','')
	if buff.duration >= 0:
		text += '\nDuration: ' + str(buff.duration)+ ' turns'
	globals.showtooltip(text)

func physdamage(caster, target, skill):
	var damage = 0
	var power = (caster.attack * skill.power)
	var protection = float(float(100-target.protection)/100)
	var armor = target.armor
	if skill.attributes.has('physpen'):
		protection = 1
		armor = 0
	for i in caster.geareffects:
		if i.type == 'incombatphyattack':
			if i.effect == 'protpenetration':
				protection = 1
			if i.effect == 'fullpenetration':
				armor = 0
				protection = 1
	if target.passives.has('defenseless'):
		armor = 0
		protection = 1
	if target.passives.has("armorbreaker"):
		armor = max(0, armor-8)
	if caster.passives.has('exhaust'):
		power = power * 0.66
	
	damage = power * protection - armor
	if target.person != null && target.person.traits.has("Sturdy"):
		damage = damage*0.85
	damage = max(damage, 1)
	
	if skill.attributes.has('lifesteal'):
		caster.hp = caster.hp + damage/4
	
	return ceil(damage)

func spelldamage(caster, target, skill):
	var damage = 0
	damage = max(1,(caster.magic * 4)) * skill.power
	if skill.code == 'mindblast':
		if target.faction == 'boss':
			damage += target.hpmax/15
		else:
			damage += target.hpmax/5
	if globals.state.spec == 'Mage' && caster.group == 'player':
		damage *= 1.2
	if target.person != null && target.person.traits.has("Sturdy"):
		damage = damage*0.85
	return ceil(damage)

func calculatehit(caster,target,skill):
	var hitchance = 80
	if caster.speed >= target.speed:
		hitchance += (caster.speed - target.speed)*2.5
	else:
		hitchance -= (target.speed - caster.speed)*4
	if caster.person != null && caster.person.traits.has("Nimble"):
		hitchance *= 1.25
	if skill.has('accuracy'):
		hitchance = hitchance*skill.accuracy
	if target.person != null && target.person.race.findn("cat") >= 0:
		hitchance = hitchance*0.9
	if rand_range(0,100) > hitchance:
		return 'miss'
	else:
		return 'hit'

func floattext(pos, value, color = 'white'):
	var newnode = $floattext.duplicate()
	self.add_child(newnode)
	newnode.visible = true
	newnode.text = str(value)
	if color != 'white':
		newnode.set('custom_colors/font_color', Color(color))
	var tween = $Tween
	var change = 100
	tween.interpolate_property(newnode, "rect_position", pos, Vector2(pos.x, pos.y-change), 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(newnode, "modulate", Color(1,1,1,1), Color(1,1,1,0),  1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 1)
	tween.interpolate_callback(self, 2, 'floattextdelete', newnode)
	tween.start()

func floattextdelete(node):
	node.queue_free()

func pressskill(skill):
	if (skill.costmana > 0 && globals.resources.mana < skill.costmana) || (skill.costenergy > 0 && selectedcharacter.energy < skill.costenergy):
		return
	if skill.target in ['one']:
		period = 'skilltarget'
		targetskill = skill
		if skill.targetgroup == 'enemy':
			var counter = 0
			var tempenemy
			for i in enemygroup:
				if i.state in ['escaped','captured','defeated']:
					counter += 1
				else:
					tempenemy = i
			if enemygroup.size() - counter <= 1:
				period = 'skilluse'
				useskills(skill, selectedcharacter, tempenemy)
	else:
		period = 'skilluse'
		useskills(skill, selectedcharacter, selectedcharacter)
	
func useskills(skill, caster = null, target = null, retarget = false):
	if caster == null || target == null:
		return
	else:
		deselectall()
	var text = ''
	var damage = 0
	var group
	var hit = 'hit'
#warning-ignore:unused_variable
	var targetparty
	var targetarray
	globals.hidetooltip()
	if caster.group != target.group && target.effects.has('protecteffect') && retarget == false:
		if target.effects.protecteffect.caster.state == 'normal' && target.effects.protecteffect.caster.hp > 0:
			self.combatlog += combatantdictionary(target.effects.protecteffect.caster, target, "[name1] covers [targetname1] from attack.")
			useskills(skill, caster, target.effects.protecteffect.caster, true)
			return
	caster.actionpoints -= 1
	if skill.cooldown > 0:
		caster.cooldowns[skill.code] = skill.cooldown
	if playergroup.has(caster):
		if skill.costmana > 0:
			var cost = skill.costmana
			if globals.state.spec == 'Mage':
				cost = round(cost/2)
			globals.resources.mana -= cost
		caster.energy -= skill.costenergy
	else:
		group = 'enemy'
	var skillcounter = 1
	if caster.passives.has('doubleattack') && rand_range(0,100) < caster.passives.doubleattack.effectvalue && skill.type == 'physical':
		skillcounter += 1
		text += "[color=yellow]Double attack![/color] "
	while skillcounter > 0:
		skillcounter -= 1
		if skill.has('castersfx'):
			call(skill.castersfx, caster)
			yield(self, "damagetrigger")
		else:
			animationskip = true
		
		if skill.has('targetsfx'):
			call(skill.targetsfx, target)
		#target skills
		if skill.target == 'one':
			if skill.code == 'attack':
				text += '[color=lime][name1][/color] tries to attack [color=#ec636a][targetname1][/color]. '
			else:
				text += '[name1] uses [color=aqua]' + skill.name + "[/color] on [targetname1]. "
			if skill.attributes.has('damage'):
				if skill.can_miss == true:
					hit = calculatehit(caster, target, skill)
				if skill.type == 'physical' && hit != 'miss':
					damage = physdamage(caster, target, skill)
					text += '[targetname1] takes [color=#f05337]' + str(damage) + '[/color] damage.' 
				elif skill.type == 'spell':
					damage = spelldamage(caster, target, skill)
					text += '[targetname1] takes [color=#f05337]' + str(damage) + '[/color] spell damage.' 
				
				
				
				if skill.type == 'physical' && hit == 'miss':
					target.dodge()
					text += '[targetname1] [color=yellow]dodges[/color] it. '
				else:
					target.hp -= damage
		#aoe skills
		elif skill.target == 'all':
			if group == 'player':
				targetarray = enemygroup
			else:
				targetarray = playergroup
			
			text += '[name1] uses [color=aqua]' + skill.name + '[/color]. '
			var counter = 0
			for i in targetarray:
				if i.state != 'normal':
					continue
				if skill.attributes.has('damage'):
					if skill.can_miss == true:
						hit = calculatehit(caster, target, skill)
					if skill.type == 'physical' && hit != 'miss':
						damage = physdamage(caster, target, skill)
					elif skill.type == 'spell':
						damage = spelldamage(caster, target, skill)
					if !i.effects.has("protecteffect"):
						if hit == 'hit':
							i.hp -= damage
							text += "[targetname" + str(counter) + "] takes [color=#f05337]" + str(damage) + '[/color] damage. '
						else:
							i.dodge()
							text += "[targetname" + str(counter) + "] [color=yellow]dodges[/color]. "
					if hit == 'hit' && skill.effect != null:
						sendbuff(caster, i, skill.effect)
					counter += 1
			
			
			
			
		elif skill.target == 'self':
			if skill.code == 'escape' && globals.main.get_node("explorationnode").launchonwin != null && caster.group == 'player':
				globals.main.popup("You can't escape from this fight")
				caster.energy += skill.costenergy
				caster.actionpoints += 1
				period = 'base'
				caster.cooldowns.erase('escape')
				return
		#buffs and effects
		if skill.attributes.has('noescape') && target.effects.has('escapeeffect'):
			self.combatlog += "[targetname1] being held in place! "
			removebuff("escapeeffect",target)
		
		if skill.effect != null && hit == 'hit' && skill.target != 'all':
			sendbuff(caster, target, skill.effect)
		if skill.has('script') && hit == 'hit':
			scripteffect(caster,target,skill.script)
		if skill.has('effectself') && skill.effectself != null:
			sendbuff(caster, caster, skill.effectself)
		
		
		yield(self, 'tweenfinished')
	
	if skill.code == 'heal':
		globals.abilities.restorehealth(caster,target)
	elif skill.code == "masshealcouncil":
		for i in targetarray:
				if i != caster:
					globals.abilities.restorehealth(caster,i)
	elif skill.code == 'escape':
		text += "[name1] prepares to escape! "
	
	
	
	if skill.target == 'all':
		target = targetarray
	
	self.combatlog += '\n' + combatantdictionary(caster, target, text)
	endcombatcheck()
	if period == 'win':
		playerwin() 
	if period == 'skilluse':
		period = 'base'
		
	emit_signal("skillplayed")

func scripteffect(caster,target,script):
	globals.abilities.call(script, caster, target)
	

func sendbuff(caster, target, effect):
	getbuff(makebuff(effect, target, caster), target)

func makebuff(code, target, caster):
	var effect = globals.abilities.effects[code].duplicate()
	var buff = {duration = effect.duration, name = effect.name, code = effect.code, type = effect.type, stats = {}, icon = effect.icon, description = null, caster = caster}
	if effect.has('description'):
		buff.description = effect.description
	if effect.has('script'):
		buff.script = effect.script
	for i in effect.stats:
		var temp = i[1].split(',')
		temp = Array(temp)
		for ii in range(0, temp.size()):
			if temp[ii].find('caster') >= 0:
				var temp2 = temp[ii].split('.')
				temp[ii] = caster[temp2[1]]
			elif temp[ii].find('target') >= 0:
				var temp2 = temp[ii].split('.')
				temp[ii] = target[temp2[1]]
		var temp2 = ''
		for i in temp:
			temp2 += str(i)
		buff.stats[i[0]] = globals.evaluate(temp2)
	return buff


func getbuff(buff, target):
	var buffexists = false
	if target.faction == 'boss' && buff.type == 'debuff':
		if buff.duration > 1:
			buff.duration = 1
		for i in buff.stats:
			buff.stats[i] = buff.stats[i]/2
	if target.effects.has(buff.code):
		buffexists = true
	if buffexists == true:
		target.effects[buff.code].duration = buff.duration
	else:
		target.effects[buff.code] = buff
		for i in buff.stats:
			target[i] = target[i] + buff.stats[i]
	if buff.type == 'script':
		globals.abilities.call(buff.script, target)
	rebuildbuffs(target)

func removebuff(buffcode, target):
	if target.effects.has(buffcode):
		for i in target.effects[buffcode].stats:
			target[i] = target[i] - target.effects[buffcode].stats[i]
		target.effects.erase(buffcode)
	rebuildbuffs(target)


func combatantdictionary(combatant, combatant2, text):
	text = text.replace('[name1]', combatant.name)
	if typeof(combatant2) == TYPE_ARRAY:
		for i in range(0,combatant2.size()):
			text = text.replace('[targetname'+str(i) + ']', combatant2[i].name)
	else:
		text = text.replace('[targetname1]', combatant2.name)
	return text


func deselectall():
	selectedcharacter = null
	for i in get_node("grouppanel/skilline").get_children():
		if i.name != 'skill':
			i.hide()
			i.queue_free()
	for i in $grouppanel.get_children():
		if i.get_class() == 'TextureButton':
			i.pressed = false

#warning-ignore:function_conflicts_variable
func enemyturn():
	if $autoattack.pressed == true:
		for i in playergroup:
			if i.state == 'normal' && i.actionpoints > 0:
				for j in enemygroup:
					if j.node != null && j.state == 'normal':
						useskills(globals.abilities.abilitydict.attack, i, j)
						break
				yield(self, 'skillplayed')
	
	for i in enemygroup + playergroup:
		if i.state != 'normal':
			continue
		
		for effect in i.effects.values():
			if effect.caster.group == 'enemy':
				if effect.code == 'escapeeffect':
					if i.effects.has('stun'):
						continue
					if trapper == true && randf() > 0.5:
						i.state = 'defeated'
						self.combatlog += combatantdictionary(i, i,'[name1] has tried to escape but was caught in one of the traps... ')
						continue
					escapeanimation(i)
					i.state = 'escaped'
				if effect.type == 'onendturn':
					self.combatlog += "\n" + combatantdictionary(i, i, globals.abilities.call(globals.abilities.effects[effect.code].script, i))
				if effect.duration > 0:
					effect.duration -= 1
				if effect.duration == 0:
					removebuff(effect.code, i)
	enemyturn = true
	var target
	for combatant in enemygroup:
		if combatant.state != 'normal' || combatant.effects.has('stun'):
			continue
		for effect in combatant.effects.values():
			if effect.code == 'escapeeffect':
				escapeanimation(combatant)
				combatant.state = 'escaped'
		var skill = []
		for k in combatant.abilities:
			var i = globals.abilities.abilitydict[k]
			
			if combatant.ai == 'escape':
				if !combatant.effects.has('shackleeffect'):
					skill = 'escape'
				else:
					combatant.ai = 'attack'
			if combatant.ai == 'attack':
				if combatant.cooldowns.has(i.code):
					continue
				if i.aipatterns.has('attack'):
					skill.append({value = i, weight = i.aipriority})
		
		
		
		
		if playergroup.size() == 0:
			lose()
			return
		
		if typeof(skill) == TYPE_ARRAY:
			skill = globals.weightedrandom(skill)
			combatant.aimemory = skill.code
		if skill == null:
			skill = globals.abilities.abilitydict[combatant.abilities[0]]
		elif typeof(skill) == TYPE_STRING:
			skill = globals.abilities.abilitydict[skill]
		var targetarray = []
		if skill.targetgroup == 'enemy':
			for i in playergroup:
				if i.state == 'normal':
					targetarray.append(i)
		elif skill.target == 'self':
			targetarray = [combatant]
		else:
			for i in enemygroup:
				if i.state == 'normal':
					targetarray.append(i)
		if targetarray.size() <= 0:
			return
		target = targetarray[randi()%targetarray.size()]
		if combatant.state in ['normal']:
			useskills(skill, combatant, target)
			yield(self, 'skillplayed')
	
	
	for i in enemygroup:
		i.stress += 3
		i.actionpoints = 1
		if i.effects.has('stun'):
			i.actionpoints = 0
		var cooldownstoerase = []
		for k in i.cooldowns:
			i.cooldowns[k] -= 1
			if i.cooldowns[k] <= 0:
				cooldownstoerase.append(k)
		for k in cooldownstoerase:
			i.cooldowns.erase(k)
		for effect in i.effects.values():
			if effect.caster.group == 'player':
				if effect.duration > 0:
					effect.duration -= 1
				if effect.duration == 0:
					removebuff(effect.code, i)
	for i in playergroup:
		checkforinheritdebuffs(i)
		i.stress += 3
		if i.person.traits.has("Coward"):
			i.stress += 3
		i.actionpoints = 1
		if i.effects.has("stun"):
			i.actionpoints = 0
		for k in i.cooldowns:
			i.cooldowns[k] -= 1
			if i.cooldowns[k] <= 0:
				i.cooldowns.erase(k)
		for effect in i.effects.values():
			if effect.caster.group == 'player':
				if effect.duration > 0:
					effect.duration -= 1
				if effect.duration == 0:
					if effect.code == 'escapeeffect':
						i.state = 'escaped'
					removebuff(effect.code, i)
	
	if endcombatcheck() == 'continue':
		enemyturn = false
		
		period = 'nextturn'
	else:
		if period == 'escape':
			playerescape()
		elif period == 'win':
			playerwin()

func endcombatcheck():
	var counter = 0
	for i in enemygroup:
		if i.state in ['escaped','defeated','captured']:
			counter += 1
	if counter >= enemygroup.size():
		period = 'win'
		return
	
	if playergroup[0].state == 'escaped':
		period = 'escape'
		return
	
	return 'continue'

func checkforinheritdebuffs(combatant):
	if combatant.person == globals.player:
		return
	if combatant.energy > 0 && combatant.passives.has('exhausted'):
		removebuff('exhaust', combatant)
		combatant.passives.erase("exhaust")
	elif combatant.energy <= 0:
		getbuff(makebuff('exhaust', combatant, combatant), combatant)
		combatant.passives.exhaust = {code = 'exhaust'}
	if combatant.person != null && combatant.person != globals.player:
		if combatant.person.lust >= 80:
			getbuff(makebuff('luststrong', combatant, combatant), combatant)
			removebuff('lustweak', combatant)
		elif combatant.person.lust >= 50:
			getbuff(makebuff('lustweak', combatant, combatant), combatant)
			removebuff('luststrong', combatant)
		else:
			removebuff('luststrong',combatant)
			removebuff('lustweak',combatant)

func playerescape():
	for i in playergroup:
		if i.state in ['normal', 'escaped']:
			escapeanimation(i)
	yield(self, 'tweenfinished')
	get_parent().animationfade(0.4)
	if OS.get_name() != 'HTML5':
		yield(get_parent(),'animfinished')
	hide()
	for i in playergroup:
		i.person.stats.energy_cur = i.energy
		i.person.stats.health_cur = i.hp
	globals.main.get_node("explorationnode").enemyleave()
	globals.main.popup('You hastily escape from the fight. ')
	globals.main.get_node("outside").show()
	globals.main.get_node("ResourcePanel").show()

func playerwin():
	get_node("win").show()
	globals.main.music_set('stop')
	globals.main.sound('win')

func _on_confirm_pressed():
	if period != 'base':
		return
	period = 'enemyturn'
	deselectall()
	enemyturn()


func damage(combatant, value):
	combatant.attack += value

func armor(combatant, value):
	combatant.armor += value

func speed(combatant, value):
	combatant.speed += value

#func passive(combatant, value):
#	combatant.passives.append(value)

func protection(combatant, value):
	combatant.protection += value

#warning-ignore:unused_argument
func lust(combatant, value):
	combatant.person.lust += 2

func victory():
#warning-ignore:unused_variable
	var deads = []
	
	get_parent().animationfade(0.4)
	if OS.get_name() != 'HTML5':
		yield(get_parent(),'animfinished')
	get_node("win").hide()
	for i in range(0, enemygroup.size()):
		if enemygroup[i].state == 'escaped':
			currentenemies[i].state = 'escaped'
		else:
			currentenemies[i].state = 'defeated'
	globals.main.get_node("explorationnode").enemygroup.units = currentenemies
	hide()
	globals.main.get_node("outside").show()
	globals.main.get_node("ResourcePanel").show()
	globals.main.get_node("explorationnode").enemydefeated()


func _on_winconfirm_pressed():
	get_node("win").hide()
	for i in playergroup:
		i.person.metrics.win += 1
		i.person.stats.energy_cur = i.energy
		i.person.stats.health_cur = i.hp
		i.person.stress = i.stress
	victory()

func _on_autowin_pressed():
	period = 'base'
	victory()

signal damagetrigger
signal tweenfinished
signal skillplayed
signal defeatfinished
var ongoinganimation = false

func damagein():
	yield(get_tree(), 'idle_frame')
	ongoinganimation = false
	emit_signal("damagetrigger")

func tweenfinished():
	yield(get_tree(), 'idle_frame')
	ongoinganimation = false
	emit_signal("tweenfinished")


func defeatfinished():
	emit_signal("defeatfinished")

func attackanimation(combatant):
	var node = combatant.node
	var tween = $Tween
	var pos = node.rect_position
	var change = 30
	
	var timings = {speed1 = 0.5,speed2 = 0.5,delay2 = 0.6,delaydamage = 0.5,delayfinish = 1.1}
	
	if instantanimation == true:
		for i in timings:
			timings[i] = 0.05
		timings.delay2 = 0
	
	globals.main.sound('attack')
	
	
	ongoinganimation = true
	if combatant.group == 'enemy':
		change = -change
	tween.interpolate_property(node, "rect_position", pos, Vector2(pos.x, pos.y-change), timings.speed1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	tween.interpolate_deferred_callback(self, timings.delaydamage, 'damagein')
	tween.interpolate_property(node, "rect_position", Vector2(pos.x, pos.y-change), pos,  timings.speed2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, timings.delay2)
	tween.interpolate_deferred_callback(self, timings.delayfinish, 'tweenfinished')
	tween.start()

func firebreathanimationcaster(combatant):
	var node = combatant.node
	var tween = $Tween
	var pos = node.rect_position
	var change = 30
	
	var timings = {speed1 = 0.5,speed2 = 0.5,delay2 = 0.6,delaydamage = 0.5,delayfinish = 1.1}
	
	if instantanimation == true:
		for i in timings:
			timings[i] = 0.05
		timings.delay2 = 0
	
	globals.main.sound('attack')
	
	
	ongoinganimation = true
	if combatant.group == 'enemy':
		change = -change
	tween.interpolate_property(node, "rect_position", pos, Vector2(pos.x, pos.y-change), timings.speed1, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	tween.interpolate_deferred_callback(self, timings.delaydamage, 'damagein')
	tween.interpolate_property(node, "rect_position", Vector2(pos.x, pos.y-change), pos,  timings.speed2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, timings.delay2)
	tween.interpolate_deferred_callback(self, timings.delayfinish, 'tweenfinished')
	tween.start()


func firebreathanimationtarget(combatant):
	var node = combatant.node
	var tween = $Tween
	
	tween.interpolate_property(node, "modulate", Color(1,0.25,0.25,1), Color(1,1,1,1), 0.6, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

#warning-ignore:unused_argument
func slamanimation(combatant):
	var tween = $Tween
	
	ongoinganimation = true
	
	get_parent().shake(0.5)
	tween.interpolate_callback(self, 0.5, 'tweenfinished')
	

func escapeanimation(combatant):
	var node = combatant.node
	var tween = $Tween
	var pos = node.rect_position
	var change = -40
	ongoinganimation = true
	if combatant.group == 'enemy':
		change = -change
	tween.interpolate_property(node, "rect_position", pos, Vector2(pos.x, pos.y-change), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(node, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	tween.interpolate_callback(self, 1.2, 'tweenfinished')
	tween.start()

func defeatanimation(combatant):
	var node = combatant.node
	var tween = $Tween
	var pos = node.rect_position
	var change = -25
	combatant.animationplaying = true
	ongoinganimation = true
	tween.interpolate_property(node, "rect_position", pos, Vector2(pos.x, pos.y-change), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(node, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	tween.interpolate_callback(self, 1.5, 'defeatfinished')
	tween.start()

func repositionanimation():
	var previousposition
	var tempposition
	if enemygroup.size() < 10:
		return
	
	var counter = 0
	for i in enemygroup:
		if i.state != 'defeated' && i.node.visible == true:
			counter += 1
	
	if counter < 8:
		return
	
	var replacedead = false
	
	for i in enemygroup:
		if i.node.visible == false:
			previousposition = i.node.get_position()
			replacedead = true
			continue
		if previousposition != null:
			tempposition = i.node.get_position()
			if replacedead == true:
				i.node.set_position(Vector2(previousposition.x, previousposition.y - 25))
				replacedead = false
			else:
				i.node.set_position(Vector2(previousposition.x, previousposition.y))
			previousposition = tempposition

func takedamage(combatant):
	var node = combatant.node
	var tween = $Tween
	
	tween.interpolate_property(node, "modulate", Color(1,0.25,0.25,1), Color(1,1,1,1), 0.6, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func healdamage(combatant):
	var node = combatant.node
	var tween = $Tween
	
	tween.interpolate_property(node, "modulate", Color(0.25,1,0.25,1), Color(1,1,1,1), 0.6, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func barrieranimation(combatant):
	var node = combatant.node
	var tween = $Tween
	
	tween.interpolate_property(node, "modulate", Color(0.25,0.25,1,1), Color(1,1,1,1), 1.3, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()

func findcombatantfromslave(person):
	for i in playergroup:
		if i.person == person:
			return i