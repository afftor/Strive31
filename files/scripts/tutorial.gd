extends Control


var alisesprites = {
	neutral = {costume1 = load('res://files/images/alise/006.png'), costume2 = load('res://files/images/alise/018.png'), naked = load('res://files/images/alise/025.png'), christmas = load('res://files/images/alise/031.png')},
	happy1 = {costume1 = load('res://files/images/alise/004.png'), costume2 = load('res://files/images/alise/016.png'), naked = load('res://files/images/alise/026.png'), christmas = load('res://files/images/alise/032.png')},
	happy2 = {costume1 = load('res://files/images/alise/008.png'), costume2 = load('res://files/images/alise/020.png'), naked = load('res://files/images/alise/027.png'), christmas = load('res://files/images/alise/033.png')},
	wink1 = {costume1 = load('res://files/images/alise/003.png'), costume2 = load('res://files/images/alise/015.png'), naked = load('res://files/images/alise/028.png'), christmas = load('res://files/images/alise/034.png')},
	wink2 = {costume1 = load('res://files/images/alise/009.png'), costume2 = load('res://files/images/alise/021.png'), naked = load('res://files/images/alise/029.png'), christmas = load('res://files/images/alise/035.png')},
	side = {costume1 = load('res://files/images/alise/005.png'), costume2 = load('res://files/images/alise/017.png'), naked = load('res://files/images/alise/030.png'), christmas = load('res://files/images/alise/036.png')},
}


var textdict = {
	loadgreeting = [
		{sprite = 'happy1', text = "A pleasure to meet you! Although we have not have met before, from now on I'll be around should you need any help.  I hope we'll get along!"},
		{text = "From now on, to call on me, just hit the question mark at the top."},
		{sprite = 'happy2', text = "I'm not going to distract you anymore.  You probably have more important things to address.  "},
		{funct = 'close'}
	],
	introduction = [
		{sprite = 'happy1',text = "It's a pleasure to meet you! You can call me Alise, and starting today I’ll be helping you out with this lengthy adventure! "},
		{text = "I’m here to teach you the basic functions needed to be successful within this realm.",  choice = 'intro'},
	],
	endtutorial = [
		{sprite = 'neutral', text = "I understand... I'm not going to distract you anymore."},
		{sprite = 'wink1', text = "If you have need of me, just hit that question mark at the top."},
		{funct = 'close'},
	],
	basicstext = [
		{sprite = 'happy2', text = "Ahhh, the advantages by owning your own estate, so many possibilities are now available.  It feels amazing doesn't it?"},
		{text = "Please keep in mind that you are responsible for yourself, the estate, and its residents.  Please take care of them.  If you do, they will take care of you. "},
		{text = "Your main goal is survival it its truest form. To do so you need to bring in a steady income and stockpile basic supplies such as food to which you will need on a daily basis. "},
		{sprite = 'wink1',text = "You can find your current Money and Food stock in the panel at the top of the screen. "},
		{text = 'To earn food and income you will need to assign your servants to various occupations, then end the current day by clicking the button at the bottom of the screen or by pressing your "F" key.'},
		{sprite = 'happy1',text = "You can see the current available servants you have on the right hand side of screen. "},
		{text = "Take a note of [color=aqua]Interactions[/color] buttons: that is the place you can set up actions with your slaves!"},
		{text = "Once you are familiar with your new abode and the depth of it, feel free to leave it and explore your surroundings. "},
		{funct = 'closeorcont'},
	],
	slavetext = [
		{sprite = 'happy1', text = "You'd " + ' like to get intimate with your servants? Would you like me to give you the "lowdown" on this subject?',choice = 'person'}
	],
	slavechar = [
		{sprite  = 'wink1',text = "Everyone is different, imagine that!"},
		{text = "Seriously, if you didn't know that... forget it.  Let's continue with the topic."},
		{sprite = 'happy2', text = "There are two attributes, Mental and Physical, which are deciding factors in how servants perform and react to the variety of things you put them through."},
		{text = "The Mental stats consist of [color=aqua]Courage[/color], [color=aqua]Confidence[/color], [color=aqua]Wit[/color], and [color=aqua]Charm[/color].  The higher those are, the better servants will perform their tasks and jobs."},
		{text = "Those stats could also play against you if your servants are not happy or rebelling against you.  In other words, their high aptitude may push them further away from you."},
		{text = "The Physical stats are way more important when regarding combat. They are pretty self-explanatory.  We can talk about them later if you need more explanation.", choice = 'person'}
	],
	slavelevel = [
		{sprite = 'happy1', text = "It seems, your servant has achieved enough experience to advance to next the level. That's great as they will earn new [color=aqua]Attribute Points[/color]."},
		{text = "But first you'll have to figure out what's holding them back from progressing further. For that, talk to them and discover what they require. This might be anything, fights, gifts, love..."},
		{text = "Once you have satisfy that need, they will increase their level and will start to accumulate more experience. "},
		{text = "Higher levels require harder conditions to be met before your servants can advance. However, it's also possible to change the condition to a new random one with some alchemy. ", choice = 'person'},
	],
	slavecond = [
		{sprite = 'wink1', text = "There are four things you need to have knowledge of regarding your servants.  These are: Obedience, Fear, Stress and Loyalty."},
		{text = "All of these are important. Let's start off with Obedience.  You simply can't force a servant to do work unless you cater to their needs or savagely control them.  A disobedient servant is a recipe for disaster as they can refuse to follow orders, publicly cause discord, or escape your control. "},
		{sprite = 'happy2', text = "Obedience can generally be raised by your interactions with the servant and the punishments you hand out to them. However, don't overdo punishments or overpraise your pets as that can cause disobedience."},
		{text = 'Fear is the main thing which can keep obedience high earl on. Punishments cause Fear to grow, which in turn makes them more obedient from some time. However, you might need to keep them scared constantly for regular effect.'},
		{text = "Stress is the gauge which shows a servant's reaction to recent events happening to them. A high stress can cause mental and emotional scarring to a servant and will impede your progress with them."},
		{text = "Lastly, Loyalty is the long-term affection servants hold for you, some call it 'love' and some call it infatuation.  You can call it whatever you wish to. ", choice = 'person'},
	],
	slavegrade = [
		{text = "All servants have specific grade ratings assigned to them. This grade determines what their mental potential is and also adjust the expectations from their master."},
		{sprite = 'wink2',text = "High Grade rated servants are nice to have. They make for better workers, generally. However, be prepared to give them a personal room or special attention as most dislike the community rooms and also have certain requirements to maintain their higher pedigree."},
		{text = "Lower Grade rated servants are more obedient and less demanding of their masters.  This makes them perfect as a starting pet."},
		{sprite = 'happy1',text = "Then again, you can always adjust Grades at the Slavers Guild, for a price, if you should find slaves you want to start upgrade or downgrade.  Between those choices lowering a Grade rating is much cheaper.", choice = 'person'},
	],
	slavework = [
		{text = "It's entirely up to you, how your servants spend their free time! Isn't it great? "},
		{text = "By taking part in various daily occupations they will be able to earn you food, gold and maybe something else. "},
		{text = "However, not every occupation can be picked up by anyone, some have very strict requirements. "},
		{text = "By progressing through the story you will be able to unlock more interesting places and occupations too, so keep your eyes open!"},
		{text = "Location related tasks will affect servant's affiliation to that location and make them also adopt that location's view on you."},
		{text = "I.E. if they work at local town, which hates you, they will also grow to dislike you!", choice = 'person'},
	],
	slavesex = [
		{sprite = 'side',text = "I know that gleam in your eye all too well. You are curious about sex and procreation?"},
		{text = "Sexuality is not only fun; it is a way of life.  Not only that, it also is your main tool to produce mana for your needs. "},
		{text = "Firstly, you'll need to unlock it by propositioning your servant... or you could use force.  However, the latter option might not be as appealing to them and may have a detrimental effect."},
		{text = "The stats that affect this are Obedience, Loyalty, and Lust.  If these stats are high enough, they may accept your proposal. "},
		{text = "This will open up a whole new menu of choices that you can earn over the course of your sexual escapades with your servant. Lust makes them more willing to try new things in this department."},
		{text = "Through sexual activities you gain Affection Points which you can be used to unlock new actions."},
		{text = "These Affection Points can be gained in numerous ways by having frequent intimate interactions being the most effective. "},
		{text = "Please keep in mind though, sexual actions will drain you and your servant's energy.  Unlike you, your servant recovers energy slower. "},
		{text = "Having vaginal intercourse can and will get your ladies pregnant.  Keep this in mind while choosing specific actions! Taking care of your offspring isn't something you should take lightly."},
		{text = "Don't think that because you aren't sexually active with your servant doesn't mean that they aren't sexually active. "},
		{text = "Even if you don't touch them, they still can get into naughty situations and masturbate here and there. ", choice = 'person'},
	],
	interactions = [
		{sprite = 'happy1',text = "Nice find! This panel here allows you to interact with any of your slaves. There are two types of interactions."},
		{text = "Basic interactions, which help you build a relationship with your slaves. Sexual interactions, however, increase loyalty, produce mana and allow the both of you, or maybe more, to have fun at the same time."}, 
		{text = "Be careful, though, you only have a limited number of interactions per day. You can increase this number by increasing your [color=aqua]Endurance[/color], though."},
		{text = "Basic interactions can increase their [color=aqua]Mood[/color] or [color=aqua]Fear[/color]. Improving mood helps raise Loyalty, while increasing Fear helps build discipline."},
		{sprite = 'happy2',text = "Try interacting with your slaves in different locations, you may find they make your actions more impactful Certain items and spells can also boost the effect of your actions."},
		{text = "Once you’ve developed a relationship with your slave, you can unlock consensual sexual actions."},
		{text = "Slaves can have different sexual preferences as they can be modified by certain traits. Even, after intimacy is unlocked, your lover may still refuse to perform certain sexual actions. These actions will require the slave to have a higher level of [color=aqua]Lewdness[/color] before they will consent."},
		{text = "In either case, feel free to experiment and have fun!"},
		{funct = 'closeorcont'},
	],
	slaveend = [
		{sprite = 'happy1', text = "In case you forget anything, don't hesitate to ask!"}, 
		{funct = 'closeorcont'}
	],
	jail = [
		{sprite = 'happy1', text = "It is a bit grim here isn't it? You didn’t expect a resort, did you? "},
		{text = "This is your Jail and it allows you to imprison bad people or those that you wish to become a slave of yours. "},
		{text = "Being locked behind bars and shackled to a wall is not very pleasant for most humanoids, but that's exactly what helps in the creation of a servant out of a hostile captive.  "},
		{text = "Some of these servants may still carry a grudge for their initial incarceration even after you release them to servant duties.  There are other magical means that could allow one to forget the jail time they served.  "},
		{sprite = 'wink2', text = "You can also use this area to punish your unruly servants.  You can perform some forms of bondage in this area in order to make those here more subservient."},
		{text = "In order to take advantage of this place you will have to establish a Jailer.  A Jailer is pretty much a guard that holds the keys to the Jail and makes sure that all prisoners have some form of basic care."},
		{text = "Naturally, anyone within the Jail won't be able to escape or cause any sort of mischief.  Please remember this because it can come in handy from time to time. "},
		{funct = 'closeorcont'},
	],
	alchemy = [
		{sprite = 'happy1', text = "This is a pretty cool place; don't you think?  All the beakers, flasks, vials, and magical ingredients is almost intoxicating! "},
		{text = "Well, to be honest, if you didn't know what alchemy is then I will give you a basic "+ ' "run-down".' + "  You introduce ingredients to other types of ingredients in order to gain a desired effect."},
		{text = "An ingredient is an herb or substance and can be found in stores or while exploring the world."},
		{sprite = 'wink1',text = "In addition, some substances can be gained from performing lewd acts with specific races.  I've also heard, but can't confirm myself, that chances are higher with the magically gifted!"},
		{text = "Many potions are very convenient for your daily tasks, so keep an eye out for the possibilities!"},
		{text = "Lastly, potions are considered wild magic and will build up a magical" +  ' "toxicity" '+", if that is what you want to call it, in those that consume them.  This can produce wild, probably negative effects, that affect the health and well-being of those consumers. "},
		{text = "Please use your discretion and great care should you use them."},
		{funct = 'closeorcont'},
	],
	lab = [
		{sprite = 'happy1', text = "Ah, the sweet smell of science!  Are you about showing your intelligence?  That is quite admirable attribute to have!"},
		{text = "Actually, the Laboratory is more practical than simply research.  A laboratory will allow you to physically modify your servants to your specific tastes or needs!"},
		{text = "All this sounds great, doesn't it?  However, the cost is pricey and an operation will add undesired stress to your servant undergoing the changes."},
		{text = "First off, you'll need a lab assistant who will be maintaining the daily operations. A skilled assistant will help with operation costs significantly, so choose wisely!"},
		{ text = "Ah, the sweet smell of science!"},
		{funct = 'closeorcont'},
	],
	farm = [
		{sprite = 'neutral',text = "A farm, not the kind of place I prefer to stay in.  I guess it's more a 'Dairy', truth be told."},
		{text = "However, it does have a purpose it rightly serves.  This place can net you some serious income provided you follow some basic guidelines.  Let me briefly explain these."},
		{text = "First off, a farm manager is a must and will be in charge of caring for the... *ahem*... cattle. Their individual skill will define the overall income of this operation."},
		{text = "In general, the servants you put here will determine your prosperity, depending on their relating qualities. "},
		{text = "I'm sure you'll be able to figure out the rest on your own, so if you'll excuse me..."},
		{funct = 'closeorcont'},
	],
	outside = [
		{sprite = 'happy1', text = "Starving for some fresh air?  Do you want to explore?  Just wanting to stretch your legs?  Regardless of your reasons, it’s always a good practice to get familiar with your surroundings in any situation."},
		{text = "While you're outside you can visit shops and the guild, find new people, discover and complete quests, or locate new servants.  The choice is purely up to you."},
		{text = "You can return to your mansion any time you desire, just as long as you're not caught up in some event. "},
		{text = "However, keep in mind, once you set your foot out of town, you enter the wilderness where not everyone you encounter is pleasant and wild animals lurk around every corner. "},
		{text = "While encounters may often lead to trouble, they also reward you with items or potential slaves as well as other possible benefits. "},
		{text = "It's quite important to ensure your expeditions are well stocked with additional supplies for healing, capturing and teleportation. "},
		{text = "Captives cannot be brought back to your mansion if you do not possess the means to restrain them first; rope in this case is important. "},
		{text = "Lastly, after exploring a location, you will be able to progress into a  [Deeper Area] of this location. "},
		{text = "Those have harder enemies and better rewards, including the possibility of higher grade characters. They might also feature new encounters or races you may not normally meet in that location. "},
		{funct = 'closeorcont'},
	],
	combatintro = [
		{sprite = 'side', text = "Phew... jeez, running all the way here was really exhausting. "},
	],
	combat = [
		{sprite = 'happy1', text = "A few things will happen here in the wilds. The bulk of it revolves around your party fighting your enemies."},
		{text = "If you are fighting against sentient beings, then you may be able to capture them and force them into servitude!"},
		{sprite = 'wink1',text = "Sometimes the enemy gets the upper-hand on you and get the jump on you.  Generally, servants with a high Agility and Wit will be able to prevent such actions by your enemy. "},
		{text = "Sometimes you run into typical, innocent people.  Starting a fight with these citizens will cause the local controlling faction's reputation, with you, to drop.  This can cause many significant issues in the future. "},
		{text = "When an opposing enemies health drops too low they may and probably will try to run.  You can let them go for an easy victory, or defeat and capture them.  "},
		#{text = "When an opposing enemies health drops too low they may and probably will try to run.  You can manually send your servants after them to try and intercept those that attempt to flee.  "},
		#{text = "The last opponent standing in combat will always stand their ground and do not need a servant to pursue them. This is notable because you could make the most desired enemy, that you would like to capture, the last one standing.  "},
		{sprite = 'side', text = "When you capture enemies you can decide several fates for them.  Some of these choices are violent, some are vile, some are selfless, and some are simply gains for you.  Although, those you make captives won’t be happy."},
		{text = "You also are able to use abilities, that you have learned, during combat.  Keep in mind though that these skills will require energy so it is good practice to keep your energy at a decent level."},
		{sprite = 'happy2',text = "Regardless, always remember that during combat you can die.  If you do depart this realm as a spirit, it's game over! So do yourself and me a favor and don't die."},
		{funct = 'closeorcont'},
	],

	call = [
		{sprite = 'happy1', text = "At your service!"},
		{text = "What can I do for you?", choice = 'menu'},
	],
	gallery = [
		{sprite = 'happy1', text = "With pleasure."},
		{funct = 'galleryshow'}
	],
	redresslingerie = [
		{sprite = 'side', text = "That's... a bold request. Alright, hold on!", funct = ['hide', 'aliselingerie']},
		{sprite = 'side', text = "Do you enjoy what you see?", funct = ['unhide']},
		{text = "Please, try not to stare too hard.  Even I can get embarrassed at times."},
		{sprite = 'happy1',text = "Would you like anything else?", choice = 'menu'}
	],
	redresschristmas = [
		{sprite = 'happy1', text = "It's that time of year already?"},
		{sprite = 'side', text = "I'll be right back.", funct = ['hide', 'alisechristmas']},
		{sprite = 'happy2', text = "I'm feeling merry now!", funct = ['unhide']},
		{sprite = 'happy1',text = "Would you like anything else?", choice = 'menu'}
	],
	redressnaked = [
		{sprite = 'side', text = "You prefer to see everything, huh. Well, saves me time changing at least.", funct = ['hide', 'alisenaked']},
		{sprite = 'side', text = "Coming out!..", funct = ['unhide']},
		{text = "It got breezy here, or it's just me?"},
		{sprite = 'happy1',text = "Would you like anything else?", choice = 'menu'}
	],
	redressnorm = [
		{sprite = 'side', text = "As you wish.", funct = ['hide', 'alisenormal']},
		{sprite = 'happy2', text = "Done!", funct = ['unhide']},
		{text = "Would you like anything else?", choice = 'menu'}
	],
	returntomain = [
		{sprite = 'happy1', text = "Any other questions, hun?", choice = 'gamehelp'},
	],

	bugreport = [
		{sprite = 'neutral',text = "Oh dear!  I'm so sorry that a bug found its way to you.  Strive is still heavily in development, so please forgive us. "},
		{text = "You can make a report at [color=aqua][url=patreon]Patreon[/url][/color] or at [color=aqua][url=itch]itch.io in the bug report thread[/url][/color].  Click on any one of the links to open the site within your browser."},
		{sprite = 'happy1', text = "Thank you for helping us improve the game!", choice = 'help'}
	],
	helpproject = [
		{sprite = 'happy2', text = "That's amazing! I'm truly happy to hear that you enjoyed it. "},
		{text = "You can support us on [color=aqua][url=patreon]Patreon[/url][/color] and become our literal employer.  We provide our supporters with access to earlier version and some additional features.  Make sure to check it out!"},
		{text = 'Alternatively, you can donate to the development via the [color=aqua][url=irch]Itch.io[/url][/color] page.  This platform helps us to easily update and to distribute the latest versions as well.'},
		{sprite = 'wink1', text = "Don't have free funds to aid us?  Everyone has hard times and we fully understand that.  You could support us by recommending Strive to others or promote it in other locations.  We are really appreciative of any help anyone can provide!"},
		{text = "If you have some skills and would like to offer your time and assistance to the game, please visit our [color=aqua][url=blogpost]blogspot[/url][/color] and contact us via striveforpower@gmail.com. ", choice = 'help'},
	],
}

var choices = {
	intro = [
		{text = "— Go on (enable tutorial help)", funct = 'basics'},
		{text = "— No need (skip tutorial)", funct = "endtutorial"}
	],
	close = [
		{text = "End", funct = 'close'}
	],
	menu = [
		{text = "I want to ask about...", funct = 'help'},
		{text = "Show me Character Gallery", funct = 'showgallery'},
		{text = "I want you to change outfit", funct = 'alisewardrobe'},
		{text = "Nothing", funct = 'close'}
	],
	person = [
		{text = 'Characteristics', funct = 'slavechar'},
		{text = 'Leveling', funct = 'slavelevel'},
		{text = 'Conditions', funct = 'slavecond'},
		{text = 'Grade', funct = 'slavegrade'},
		{text = "Jobs", funct = 'slavejobs'},
		{text = 'I know what I need', funct = 'slaveend'},
	],
	help = [
		{text = "Return", funct = "menu"},
		{text = "Gameplay", funct = "gamehelp"},
		{text = "I want to see the game's Wiki", funct = "gamewiki"},
		{text = "I want to report a bug...", funct = "bugreport"},
		{text = "I want to help this project...", funct = "projecthelp"},
	],
	gamehelp = [
		{text = "Return", funct = "help"},
		{text = "Basics", funct = 'basics'},
		{text = "Servants", funct = 'slavechoice', reqs = 'globals.state.tutorial.person == true'},
		{text = "Interactions", funct = 'interactions', reqs = 'globals.state.tutorial.interactions == true'},
		{text = "Jail", funct = "jail", reqs = 'globals.state.tutorial.jail == true'},
		{text = "Alchemy", funct = 'alchemy', reqs = 'globals.state.tutorial.alchemy == true'},
		{text = "Laboratory", funct = 'lab', reqs = 'globals.state.tutorial.lab == true'},
		{text = "Farm", funct = 'farm', reqs = 'globals.state.tutorial.farm == true'},
		{text = "Exploration", funct = 'outside', reqs = 'globals.state.tutorial.outside == true'},
		{text = "Combat", funct = 'combat', reqs = 'globals.state.tutorial.combat == true'},
	],
	alisechange = [
		{text = "Nevermind", funct = "menu"},
		{text = "Default costume", funct = "alisechangenorm"},
		{text = "Lingerie", funct = "alisechangelingerie"},
		{text = "Naked", funct = "alisechangenaked"},
		{text = "Christmas", funct = 'alisechangechristmas'}
	],
}

func bugreport():
	self.currentdict = textdict.bugreport

func projecthelp():
	self.currentdict = textdict.helpproject

var currentdict setget currentdict_set
var counter
var currentline
var lastline
var help = false

signal textshown

func _ready():
	#set_process_input(true)
	#set_process(true)
#warning-ignore:return_value_discarded
	get_node("speech/RichTextLabel").connect("mouse_entered", self, 'stopinput')
#warning-ignore:return_value_discarded
	get_node("speech/RichTextLabel").connect("mouse_exited", self, 'startinput')
	var date = OS.get_date()
	if globals.state.supporter == false && globals.state.alisecloth == 'normal' && ((OS.get_date().month == 12 && date.day > 14) || (OS.get_date().month == 1 && date.day < 12)):
		globals.state.alisecloth = 'christmas'
	elif globals.state.supporter == false && globals.state.alisecloth == 'christmas' && ((!OS.get_date().month in [1,12]) || (OS.get_date().month == 1 && date.day >= 12) || (OS.get_date().month == 12 && date.day <= 14)):
		globals.state.alisecloth = 'normal'
#	starttutorial()

func _input(event):
	if event.is_echo() == true || event.is_pressed() == false :
		return
	if event.is_action("LMB") && event.is_pressed():
		if get_node("speech/RichTextLabel").get_visible_characters() < get_node("speech/RichTextLabel").get_total_character_count():
			get_node("speech/RichTextLabel").set_visible_characters(get_node("speech/RichTextLabel").get_total_character_count())
		else:
			if lastline != true && currentdict != null && (get_node("tutsprite").modulate.a >= 1 || get_node("tutsprite").modulate.a <= 0):
				advance()
	var buttoncontainer = $response/ScrollContainer/VBoxContainer
	if str(event.as_text().replace("Kp ",'')) in str(range(1,9)):
		if buttoncontainer.get_parent().get_parent().visible == false:
			return
		var key = int(event.as_text())
		if buttoncontainer.get_children().size() >= key+1 && buttoncontainer.get_child(key).disabled == false && self.is_visible() == true:
			buttoncontainer.get_child(key).emit_signal("pressed")

#warning-ignore:unused_argument
func _process(delta):
	if get_node("speech/RichTextLabel").get_visible_characters() <= get_node("speech/RichTextLabel").get_total_character_count():
		get_node("speech/RichTextLabel").set_visible_characters(get_node("speech/RichTextLabel").get_visible_characters() + 2)
	if get_node("speech/RichTextLabel").get_visible_characters() >= get_node("speech/RichTextLabel").get_total_character_count():
		emit_signal('textshown')


func stopinput():
	set_process_input(false)

func startinput():
	set_process_input(true)

func advance():
	show_(currentline)
	counter += 1
	if currentdict.size() > counter:
		currentline = currentdict[counter]

func currentdict_set(value):
	lastline = false
	$speech.hide()
	currentdict = value
	counter = 0
	currentline = currentdict[0]
	advance()

func show_(dict):
	set_process_input(true)
	set_process(true)
	if dict.has('sprite'):
		buildbody(get_node("tutsprite"), dict.sprite)
		if is_visible() == false:
			self.visible = true
			aliseshow()
			get_node("response").hide()
			if OS.get_name() != "HTML5":
				set_process_input(false)
				set_process(false)
				yield(get_parent().get_node("Tween"), 'tween_completed')
				set_process_input(true)
				set_process(true)
	if dict.has('text'):
		if is_visible() == false:
			self.visible = true
			aliseshow()
			get_node("response").hide()
			if OS.get_name() != "HTML5":
				set_process_input(false)
				set_process(false)
				yield(get_parent().get_node("Tween"), 'tween_completed')
				set_process_input(true)
				set_process(true)
		get_node("speech").show()
		get_node("speech/RichTextLabel").set_visible_characters(0)
		get_node("speech/RichTextLabel").set_bbcode('[color=yellow]' + globals.player.dictionary(dict.text) + '[/color]')
	else:
		get_node("speech").hide()
	if dict.has('funct'):
		var array = []
		if typeof(dict.funct) == TYPE_STRING:
			array = [dict.funct] 
		else:
			array = dict.funct
		for i in array:
			call(i)
	if dict.has('choice'):
		if dict.has('text') && OS.get_name() != "HTML5":
			yield(self, 'textshown')
		showchoice(dict.choice)
	else:
		nochoice()

func buildbody(node, sprite):
	var dict = {normal = 'costume1', naked = 'naked', lingerie = 'costume2' , christmas = 'christmas'}
	var texture = alisesprites[sprite][dict[globals.state.alisecloth]]
	node.set_texture(texture)

func gamewiki():
#warning-ignore:return_value_discarded
	OS.shell_open('http://strive4power.wikia.com/wiki/Strive4power_Wiki')

func showchoice(arg):
	lastline = true
	var skip = false
	var choice = choices[arg]
	for i in get_node("response/ScrollContainer/VBoxContainer").get_children():
		if i != get_node("response/ScrollContainer/VBoxContainer/Button"):
			i.hide()
			i.queue_free()
	get_node("response").show()
	for i in choice:
		skip = false
		if i.has('reqs'):
			if globals.evaluate(i.reqs) == false:
				skip = true
		if skip == true:
			continue
		var newbutton = get_node("response/ScrollContainer/VBoxContainer/Button").duplicate()
		newbutton.show()
		get_node("response/ScrollContainer/VBoxContainer").add_child(newbutton)
		newbutton.set_text(i.text)
		newbutton.connect("pressed",self,i.funct)

func nochoice():
	get_node("response").hide()

func hide():
	if OS.get_name() != "HTML5":
		yield(self, 'textshown')
		alisehide()
	else:
		alisehide()

func unhide():
	if OS.get_name() != "HTML5":
		yield(self, 'textshown')
		aliseshow()
	else:
		aliseshow()

func basics():
	globals.state.tutorial.basics = true
	self.currentdict = textdict.basicstext

func starttutorial():
	self.currentdict = textdict.introduction

func showgallery():
	self.currentdict = textdict.gallery

func menu():
	showchoice('menu')

func gamehelp():
	showchoice('gamehelp')

func slavechoice():
	showchoice('person')

func help():
	showchoice('help')



func alisegreet():
	for i in globals.state.tutorial:
		globals.state.tutorial[i] = true
	self.currentdict = textdict.loadgreeting

func endtutorial():
	for i in globals.state.tutorial:
		globals.state.tutorial[i] = true
	self.currentdict = textdict.endtutorial

func callalise():
	set_process_input(true)
	set_process(true)
	help = true
	self.currentdict = textdict.call

func alisewardrobe():
	if globals.state.supporter == true:
		showchoice('alisechange')
	else:
		get_parent().popup("This function is available only to supporters. Please, apply to [color=aqua][url=patreon]Patreon[/url][/color] to unlock it, or enter your Supporter code in options if you have it. ")

func alisenaked():
	globals.state.alisecloth = 'naked'

func alisenormal():
	globals.state.alisecloth = 'normal'

func aliselingerie():
	globals.state.alisecloth = 'lingerie'

func alisechristmas():
	globals.state.alisecloth = 'christmas'

func alisechangenorm():
	self.currentdict = textdict.redressnorm

func alisechangelingerie():
	self.currentdict = textdict.redresslingerie


func alisechangechristmas():
	self.currentdict = textdict.redresschristmas

	
func alisechangenaked():
	self.currentdict = textdict.redressnaked
	

func slaveinitiate():
	self.currentdict = textdict.slavetext

func slavechar():
	self.currentdict = textdict.slavechar

func slavelevel():
	self.currentdict = textdict.slavelevel
	
func slavecond():
	self.currentdict = textdict.slavecond

func slavegrade():
	self.currentdict = textdict.slavegrade

func slavejobs():
	self.currentdict = textdict.slavework

func slavesex():
	self.currentdict = textdict.slavesex

func interactions():
	globals.state.tutorial.interactions = true
	self.currentdict = textdict.interactions

func slaveend():
	globals.state.tutorial.person = true
	self.currentdict = textdict.slaveend

func jail():
	globals.state.tutorial.jail = true
	self.currentdict = textdict.jail

func alchemy():
	globals.state.tutorial.alchemy = true
	self.currentdict = textdict.alchemy

func lab():
	globals.state.tutorial.lab = true
	self.currentdict = textdict.lab

func farm():
	globals.state.tutorial.farm = true
	self.currentdict = textdict.farm

func outside():
	globals.state.tutorial.outside = true
	self.currentdict = textdict.outside

func combat():
	globals.state.tutorial.combat = true
	self.currentdict = textdict.combat

func closeorcont():
	if help == true:
		self.currentdict = textdict.returntomain
	else:
		close()

func close():
	help = false
	set_process(false)
	set_process_input(false)
	alisehide()
	get_node("response").hide()
	get_node("speech").hide()
	if OS.get_name() != "HTML5":
		yield(get_parent().get_node("Tween"), 'tween_completed')
	self.visible = false

func _on_RichTextLabel_meta_clicked( meta ):
	if meta == 'patreon':
#warning-ignore:return_value_discarded
		OS.shell_open('https://www.patreon.com/maverik')
	elif meta == 'itch':
#warning-ignore:return_value_discarded
		OS.shell_open('https://itch.io/t/89635/bug-report-thread')
	elif meta == "blogpost":
#warning-ignore:return_value_discarded
		OS.shell_open('http://strivefopower.blogspot.com')

func galleryshow():
	get_parent().get_node("gallery").show()
	close()

func aliseshow():
	var tween = get_parent().tween
	tween.interpolate_property($tutsprite, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func alisehide():
	var tween = get_parent().tween
	tween.interpolate_property($tutsprite, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
