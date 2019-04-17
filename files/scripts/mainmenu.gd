extends Control


#QMod - Enumerations
enum StageName {
	Inactive = 0,
	GameMode = 1,
	StartType = 2,
	Race = 3,
	Stats = 4,
	Appearance = 5,
	Specialization = 6,
	StartSlave = 7
}

#QMod - Dictionaries
var locationDict = {
	wimborn = {code = 'wimborn', name = 'Wimborn', descript = "Wimborn is the biggest local human city, its rich infrastructure and dense population allows even beginners to make out their living, as long as they are diligent.\n\n[color=aqua][center]Default Start — Recommended.[/center][/color]"},
	gorn = {code = 'gorn', name = 'Gorn', descript = "Gorn is the central Orcish city with hot climate and strict ruleship. There's no Mage's Order, but local slave market is never empty."},
	frostford = {code = 'frostford', name = 'Frostford', descript = "Frostford, located in cold, northern regions, mostly populated by Beastkin. Despite serene attitude of locals, it's covered in snow most of the time and limiting food sources makes it difficult to survive without reasonable preparations and trustworthy people."},
}

var racebonusdict = {
	human = {descript = 'Reputation with Wimborn increased'},
	elf = {descript = 'Start with +1 Magic Affinity'},
	"dark elf" : {descript = 'Start with +1 Agility'},
	orc = {descript = 'Reputation with Gorn increased'},
	demon = {descript = 'Start with +1 unassigned Skillpoint, all starting reputation lowered slightly'},
	beastkin = {descript = 'Reputation with Frostford increased'},
	halfkin = {descript = 'All starting reputation increased slightly'},
	taurus = {descript = 'Start with +1 Endurance'},
}

var skindict = {
	human = [ 'pale', 'fair', 'olive', 'tan', 'brown', 'dark' ],
	drow = ['blue', 'purple', 'pale blue'],
	orc = ['green'],
	goblin = ['green'],
	dryad = ['green'],
	slime = ['jelly'],
	nereid = ['teal', 'blue', 'pale blue']
}
var horndict = {
	human = ['none'],
	demon = ['short', 'long_straight', 'curved'],
	dragonkin = ['short', 'long_straight', 'curved'],
	taurus = ['long_straight'],
}
var wingsdict = {
	human = ['none'],
	"fairy" : ['insect', 'gossamer'], #Added 'gossamer' wing type
	"demon" : ['leather_black', 'leather_red'],
	"dragonkin" : ['leather_black', 'leather_red'],
	"seraph" : ['feathered_black', 'feathered_white', 'feathered_brown'],
}
var furcolordict = {
	"human" : ['none'],
	"beastkin cat" : ['white', 'gray', 'orange_white','black_white','black_gray','black'],
	"beastkin fox" : ['black_white', 'orange'],
	"beastkin wolf" : ['gray', 'black_gray', 'brown'],
	"beastkin bunny" : ['white', 'gray'],
	"beastkin tanuki" : ['black_gray'],
}

var backstorydescription = {
	'$sibling' : 'After the news about your fortune, your $sibling asked to go with you offering $his help. You never quite could refuse $name and so you went with $him. ',
	"Childhood Friend" : "It wasn't easy to keep your good old friend, $name calm when $he heard you are leaving your home town. In the end you found no better solution, than to take $him with you. ",
	"Servant" : "As traveling on your own might be dangerous, you decided to take your trusted servant, $name, who's been around for all your childhood and proven to be very dependable. ",
	"Stranger" : "On your way to the mansion, you've encountered a lone person, who somehow tagged along with you. "
}

var hobbydescription = {
	'Physical' : '[color=aqua]Strength: +1; +Courage[/color]\n\n$name is no stranger to fighting and tends to act boldly in many situations. ',
	'Etiquette' : "[color=aqua]+Confidence, +Charm[/color]\n\n$name has spent $his youth among elder people and high society, learning how to be liked and present $himself while also feeling superior to commonfolk. ",
	'Magic' : "[color=aqua]Magic: +2; +Wit[/color]\n\n$name was a very curious child and spent a lot of $his time reading and studying various things, including magic.",
	'Servitude' : "[color=aqua]Endurance: +1; +Obedience[/color]\n\n$name has spent $his youth in harsh training which lead to $him being more physically fit and respecting to $his superiors."
}

#warning-ignore:unused_class_variable
var backgrounddict = {
	mercenary = {code = 'mercenary', name = "Mercenary", descript = "After spending your early days as a recruit and soldier for the local governor, you eventually left for better opportunities and new experience. After spending few years being a sellsword with limited opportunities, given lack of local conflicts, the news about your inheritance reached your ears and you decided, that at the very least new career option should be less of a hassle. \n\n[color=aqua]Start with 2 Leather Armors and 2 Swords[/color]"},
	farmer = {code = 'farmer', name = "Farmer", descript = "Your childhood has been spent on the family farm. After your father died, there was little option but to take his place and start taking care of it. Upon hearing news of your newfound inheritance, you being fed up with the rural routine and sold your possessions, and moved onto your new life. \n\n[color=aqua]Start with extra 250 gold and 250 food. [/color]"},
	noble = {code = 'noble', name = "Aristocrat", descript = "You were born a member of small and fairly poor aristocrat family. Despite having a relatively reasonable life, your home estate was constantly in danger from your overly ambitious relatives and strong neighbours. After you have found out about your inheritance, you decided to leave everything to your older brother and, with what small possessions you've kept, moved to find out if you can pick up a new opportunity entirely on your own. \n\n[color=aqua]Start with extra 300 gold and 2 Maid Uniforms.[/color] "},
	mage = {code = 'mage', name = "Researcher", descript = "Despite being born in a poor family, you've always shown a profound interest in complex subjects such as alchemy and magic. Thankfully, you've managed to enroll into small local school which gave you a significant opportunities by sharing their resources. After news about your inheritance reached you, it was a chance you couldn't let slip: you quickly packed your most valuable tools and moved out. \n\n[color=aqua]Start with an Alchemy Room and a Heal spell. [/color]"},
}


#NewGame Creator Variables
var stage = 0 setget set_stage #Current stage of newgame creation
var isSandbox = false #Game mode - Sandbox or Story, future game modes?
var startingLocation = 'wimborn'
var makeoverPerson #Used for character appearance customization

#Player Creation Variables
var player
var playerDefaults = {race = 'Human', age = 'teen', sex = 'male', origins = 'poor'}
var playerPortraits = []
var playerBonusStatPoints = variables.playerbonusstatpoint

var malesizes = ['masculine', 'flat']
var femalesizes = ['flat','small','average','big','huge']


#First Slave Variables
var startSlave
var slaveDefaults = {race = 'Human', age = 'adult', sex = 'female', origins = 'poor'}
var slaveBackgrounds = ['$sibling', 'Childhood Friend', 'Servant', 'Stranger']
var slaveHobbies = ['Physical','Etiquette','Magic','Servitude']
var startSlaveHobby = 'Physical'
var slaveTrait = ''


#Story Variables
var introText01 = "The world of Acheron is going through a period of peace. What few local disputes between cities and regions emerge are quickly resolved by the major leading and governing force: The Mage's Order. The brightest, richest and most powerful people all aim to join the most advanced organization out there. Magic, mainly in the form of mind and body manipulations, is of course well-respected by the whole civilization and is controlled very strictly and scientifically.  By utilizing it, The Mage's Order has managed to become what it is now. With its rise to power, recruitment is now open to any who can prove themselves. Naturally, older members still carry the elitist attitude and look down on those who originate from lesser standing.\n\nWhile magic can be eventually learned and executed by anyone, everything comes at a cost. Mana, the source of raw magic, can rarely be obtained directly from nature. The most dominant source for everyone's use is biological life. There are two generally acknowledged options for modern mages to collect mana for their needs: pain and pleasure. Both actions being essential to life, it's theorized to be a part of the existing Great Law of Creation, which eventually made it possible for all living beings to form and connects them to this day. Mages can harness that connection to draw out mana from others during moments of intense pleasure or pain. With this mana, mages can perform great feats like healing the sick or slaying monsters.\n\nOn the other hand, the average person's survival proves to be hard even at these times of relative peace. Constant shortages of food in many regions and high birth rate makes it hard for many to find a reasonable place in society and as a result they end up becoming outlaws. For those who cannot provide for themselves, slavery has become a common practice and is strictly regulated by the government. It serves as a reasonable option for many individuals who seek a better opportunity to their conditions. Slaves make an efficient option for mana gathering. Despite some unrest with the slave system, it is a vital part of commerce."
var introText02 = "Although you have managed to dodge any sort of terrible fate, your life still wasn't anything to be happy about. That changed one day when you received a message, informing you that your old uncle had recently passed away. You barely remembered anything about him, but there were no other close relatives and as such he bequeathed his belongings to you. \n\nWhat surprised you even more; it was a reasonably sized two story mansion near one of the local city centers. While  there's really nothing special about it, a building of this degree is a respectable possession on its own. After making up your mind you leave your old life for this new, better opportunity to make a name for yourself. Access to the local Mage's Order will also allow you to gain access to more power and knowledge, as long as you can be accepted into it... Be it a taste of real political power, rowdy big city life, or magic research, you will figure it out once you get there. Managing your own estate might prove to be difficult, but nothing should be too bad once you get a few personal servants..."





### CONSTRUCTORS, READY, INITIALIZERS

#QMod - Refactored
func _ready():
	var constantsloader = load("res://files/constmodinstal.gd").new()
	constantsloader.run()
	
	#System/OS + global checks and settings	
	_ready_system_check()
	
	#Adult content warning
	_ready_adult_warning()
	
	#Clear global state
	globals.clearstate() #Resets global state when returning to main menu	
	
	#Ready music, credits, changelog, newgame creator
	_ready_music() #Separated from adult_warning to show top-level flow better	
	_ready_credits()
	get_node("TextureFrame/changelog/RichTextLabel").set_selection_enabled(true)
	_ready_newgame_creator()
	
	
	

#QMod - Added system/global check helper
func _ready_system_check():
	$TextureFrame/Label.text = 'ver. ' + globals.gameversion
	globals.mainscreen = 'mainmenu'
	if $TextureFrame/modpanel.activemods.size() > 0:
		$TextureFrame/Label2.visible = true
	if OS.get_name() == "HTML5":
		globals.rules.custommouse = false
		$htmlwarn.popup()
		
	if globals.rules.fullscreen == true:
		OS.set_window_fullscreen(true)
		
func _on_htmlwarnclose_pressed():
	$htmlwarn.hide()
	
#QMod - Added Adult warning helper
func _ready_adult_warning():	
	
	var settings = File.new()
	#Disables Adult warning if settings file exists, for own convenience
#warning-ignore:unused_variable
	var showWarning = !settings.file_exists("user://settings.ini")
	#showWarning = true ### Uncomment this to always show warning as in original
	if true:
		$warning.visible = true
		$TextureFrame.visible = false
	else:
		$warning.visible = false
		$TextureFrame.visible = true

func _on_warningconfirm_pressed():
	get_node("TextureFrame").visible = true
	$warning.visible = false	

func _on_warningcancel_pressed():
	_on_exit_pressed()
	
#QMod - Renamed
func _ready_music():	
	#Guard clause
	if globals.rules.musicvol == 0:
		return
	
	#Set & start main menu/theme music
	var music = get_node("music")
#warning-ignore:unused_variable
	var path = ''
	music.set_autoplay(true)
	music.set_stream(globals.musicdict.maintheme) #Directly call music dictionary's maintheme 
	music.play(0)
	music.set_volume_db(globals.rules.musicvol)
	
#QMod - Added helper for credits/contributors/supporters
func _ready_credits():
	#Designers & game contributors
	var credits = ''
	credits = 'Game design, code and writing: Maverik\nArtist: Warm Tail\nArtist: Demona\n\nSex scenes: NK, Lamoli\n\nWriting and proofreading helpers: Kalderza, Shvan, Xero, Dr. Nobody, Anti-No\n\nPlease contact me if you helped me somewhere and I forgot to mention you.\n\nSpecial notion to all patreons:'
	credits += '\n\n$10+ Supporters: [color=green]'
	
	#Patron '10' list
	var ten = globals.patronlist.ten	
	ten.sort()
	for i in ten:
		credits += i + ', '
	credits.erase(credits.length()-2, 2)
	credits += '[/color]\n\nLegacy Supporters: '
	
	#Patron '5' list
	var five = globals.patronlist.five
	five.sort()
	for i in five:
		credits += i + ', '
	credits.erase(credits.length()-2, 2)
	
	#Closing credit shoutouts
	credits += "\n\nIcons: http://game-icons.net \nOST: The Sixth Gate Music"
	credits += "\n\nSponsored links: \n\nHomura - https://homurascaptions.com"
	
	#Set credits
	get_node("TextureFrame/creditpanel/RichTextLabel").set_bbcode(credits)

#QMod - Renamed, tweaked variable initialization
func _ready_newgame_creator():
	#Connect UI
	#Connect stage selection buttons
	for i in get_node("TextureFrame/newgame/stagespanel/VBoxContainer").get_children():
		if i.get_name() != 'cancel':
			i.connect("pressed", self, '_select_stage', [i])
	
	#Connect text entry boxes	
	for i in get_tree().get_nodes_in_group("lookline"):  
		i.connect("text_changed", self, '_lookline_text', [i])
	
	#Connect list options
	for i in get_tree().get_nodes_in_group("lookoption"):  
		i.connect("item_selected", self, '_option_select', [i])
	
	#Connect stat up/down buttons	
	for i in get_tree().get_nodes_in_group("statup"):  
		i.connect("pressed",self,'statup',[i])		
	for i in get_tree().get_nodes_in_group("statdown"):
		i.connect("pressed",self,'statdown',[i])
	
	#Connect slave customization options
	for i in get_tree().get_nodes_in_group("slaveoption"):  
		i.connect("item_selected",self,'_slave_option', [i])
	
	#Connect game options/settings
	for i in get_tree().get_nodes_in_group("startoption"):  
		i.connect("pressed",self,'_option_toggle',[i])
	
	#Connect virgin option
#warning-ignore:return_value_discarded
	get_node("TextureFrame/newgame/stage6/virgin").connect("pressed", self, '_virgin_press')
	
	#Initialize newgame variables
	player = globals.newslave(playerDefaults.race, playerDefaults.age, playerDefaults.sex, playerDefaults.origins) #Prefer to use a constructor/builder
	player.cleartraits()
	player.hairstyle = 'straight'
	player.beautybase = variables.playerstartbeauty
	globals.player = player #Necessary for descriptions to properly identify player character during newgame creation
	
	startSlave = globals.newslave(slaveDefaults.race, slaveDefaults.age, slaveDefaults.sex, slaveDefaults.origins) #Prefer a constructor/builder
	startSlave.cleartraits()
	startSlave.beautybase = variables.characterstartbeauty
	startSlave.memory = slaveBackgrounds.back()
	
	globals.resources.panel = null #Clear global variables
	globals.showalisegreet = false

	_build_player_portraits() #Build Player portrait list

#QMod - Renamed
func _build_player_portraits():
	#Fill player portrait list from portrait files
	var portraitFiles = globals.dir_contents("res://files/buttons/portraits")
	for i in portraitFiles:
		if i.find('import') >= 0:
			playerPortraits.append(i.replace('.import',''))
	

### SETTERS & GETTERS

#QMod - Renamed to match Godot core 'set_xxx' vs 'xxx_set'
func set_stage(newStage):
	var lastStage = get_node("TextureFrame/newgame/stagespanel/VBoxContainer").get_children().size() - 1
	lastStage -= 1 #Remove 'cancel' button from stage count
	
	stage = clamp(newStage, 0, lastStage) #Clamp stage to valid stage values
	
	if stage < lastStage: #While interesting, this may obfuscate the flow of code
		_advance_stage()
	else:
		_advance_stage(true)	

		
### MAIN MENU	
		
#QMod - New game start
func _on_start_pressed():
	_newgame_creator_reset() #Resets new game variables to default - A fresh start
	get_node("TextureFrame/newgame").visible = true	
	_advance_stage()
	
#QMod - Resets New Game/Character Creator to default settings
func _newgame_creator_reset():
	stage = 0	
	startingLocation = 'wimborn'		
	globals.player = player
	
	startSlave.memory = slaveBackgrounds[0]


var filesname = 'user://saves/autosave'
#QMod - Load game
func _on_load_pressed():
	_on_SavePanel_visibility_changed()

#QMod - Simplified function, didn't see what the extra vars/steps were for? Debug?
func _on_SavePanel_visibility_changed():
	var dir = Directory.new() #Create savegame directory if it doesn't exist
	if dir.dir_exists("user://saves") == false:
		dir.make_dir("user://saves")
		
	for i in get_node("TextureFrame/SavePanel/ScrollContainer/savelist").get_children(): #Clear previous savegame list
		if i != get_node("TextureFrame/SavePanel/ScrollContainer/savelist/Button"):
			i.queue_free()
			i.visible = false
	
	$TextureFrame/SavePanel.visible = true#Display save panel
	
	get_node("TextureFrame/SavePanel/saveline").set_text(filesname.replacen("user://saves/",'')) #Displays name of current selected savefile in textbox	
	
	#var node
	var savefiles = globals.dir_contents()
	for i in globals.savelist:
		if savefiles.find(i) < 0:
			globals.savelist.erase(i)
	
	for i in savefiles:
		var node = get_node("TextureFrame/SavePanel/ScrollContainer/savelist/Button").duplicate() #Create save file button
		get_node("TextureFrame/SavePanel/ScrollContainer/savelist").add_child(node) #Add button to savefile load display list
		node.show()
		if globals.savelist.has(i) == true:
			node.get_node("date").set_text(globals.savelist[i].date)
			node.get_node("name").set_text(i.replacen("user://saves/",''))
		else:
			node.get_node("name").set_text(i.replacen("user://saves/",''))
		node.set_meta('text', i)
		node.connect('pressed', self, '_display_savegame_info', [node]) #Connect button to loadchosen method

#QMod - Renamed as func displays save info and doesn't load savegame.
func _display_savegame_info(node):
	filesname = node.get_meta('text') #Get name of selected savegame
	get_node("TextureFrame/SavePanel/saveline").set_text(filesname.replacen("user://saves/",'')) #Display selected savegame name in textbox
		
	for i in $TextureFrame/SavePanel/ScrollContainer/savelist.get_children(): #Find and 'press' button of selected savegame
		i.pressed = (i == node)
			
	var text
	if globals.savelist.has(filesname): #Load savegame info box - portrait, player name, gold, current day, slave count
		if globals.savelist[filesname].has('portrait') && globals.loadimage(globals.savelist[filesname].portrait):
			$TextureFrame/SavePanel/loadimage.set_texture(globals.loadimage(globals.savelist[filesname].portrait))
		else:
			$TextureFrame/SavePanel/loadimage.set_texture(null)
		text = globals.savelist[filesname].name
	else:
		text = "This save has no info stored."
		$TextureFrame/SavePanel/loadimage.set_texture(null)
	$TextureFrame/SavePanel/RichTextLabel.bbcode_text = text

#Called on 'load button' pressed in save panel for selected savegame
func _on_loadbutton_pressed():
	var dir = Directory.new()
	if dir.file_exists(filesname):
		_load_savegame_file()

#QMod - Renamed, func is a wrapped call to globals load_game function
func _load_savegame_file():
	globals.load_game(filesname)
	_on_SavePanel_visibility_changed()	

#QMod - These delete savegame functions indicate that the savegame filesystem should be refactored out of mainmenu	
#func _on_deletebuttonssave_pressed():
#	var dir = Directory.new()
#	if dir.file_exists(filesname):
#		yesnopopup('Delete this file?', '_delete_savefile', 'cancel')
#	else:
#		popup('No file with such name') 

#QMod - Renamed
#func _delete_savefile():
#	var dir = Directory.new()
#	if dir.dir_exists("user://saves") == false:
#		dir.make_dir("user://saves")
#	dir.remove(filesname)
#	cancel()
#	_on_SavePanel_visibility_changed()

func _on_cancelsaveload_pressed():
	get_node("TextureFrame/SavePanel").visible = false

	
#Main menu options
func _on_Options_pressed():
	get_node("options").visible = true
	

#Main menu display credits
func _on_credits_pressed():
	get_node("TextureFrame/creditpanel").visible = true
	
func _on_creditsclose_pressed():
	get_node("TextureFrame/creditpanel").visible = false
	

#Main menu 'set game constants' panel
func _on_constants_pressed():
	$TextureFrame/constants.visible = true
	for i in $TextureFrame/constants/ScrollContainer/VBoxContainer.get_children():
		if i.name != 'Label':
			i.visible = false
			i.queue_free()
	for i in variables.list:
		var newnode = $TextureFrame/constants/ScrollContainer/VBoxContainer/Label.duplicate()
		$TextureFrame/constants/ScrollContainer/VBoxContainer.add_child(newnode)
		newnode.visible = true
		newnode.set_meta('var', i)
		newnode.set_text(i)
		newnode.hint_tooltip = variables.list[i].descript
		newnode.get_node("LineEdit").text = str(variables[i])
		newnode.get_node("LineEdit").hint_tooltip = "default: " + str(variables.list[i].default) + ", min: " + str(variables.list[i].min) + ", max: " + str(variables.list[i].max)

func _on_closeconstants_pressed():
	$TextureFrame/constants.visible = false

func _on_resetconstants_pressed():
	for i in variables.list:
		variables[i] = variables.list[i].default
	globals.savevars()
	_on_constants_pressed()

func _on_confirmconstants_pressed():
	for i in $TextureFrame/constants/ScrollContainer/VBoxContainer.get_children():
		if i.has_meta('var'):
			var vari = i.get_meta('var')
			variables[vari] = clamp(float(i.get_node("LineEdit").text), variables.list[vari].min, variables.list[vari].max)
	globals.savevars()
	_on_constants_pressed()


#Main menu display game version change log
func _on_Version_pressed():
	get_node("TextureFrame/changelog").popup()

	
#Main menu 'exit' program
func _on_exit_pressed():
	get_tree().quit()


#Patreon, Blogspot, itch.io, and wikia link buttons
func _on_patreonbutton_pressed():
#warning-ignore:return_value_discarded
	OS.shell_open('https://www.patreon.com/maverik')

func _on_blogbutton_pressed():
#warning-ignore:return_value_discarded
	OS.shell_open('https://strivefopower.blogspot.com')

func _on_itchbutton_pressed():
#warning-ignore:return_value_discarded
	OS.shell_open('https://strive4power.itch.io/strive-for-power')

func _on_wikibutton_pressed():
#warning-ignore:return_value_discarded
	OS.shell_open('http://strive4power.wikia.com/wiki/Strive4power_Wiki')
	

### NEWGAME CREATION

#QMod - Adjusted to clear relevant variables when players backtrack during newgame creation
func _select_stage(button):
	#Check character creation - player or first slave
	if stage >= 7 && button.get_position_in_parent() < 7: #Moving from first slave creation back to player creation
		player = globals.player #Restore previously customized player character
		startSlave.cleartraits() #Clear starting slave selected trait(s)
		startSlave.memory = slaveBackgrounds[0]
		startSlaveHobby = slaveHobbies[0]
	
	if stage >= 6: #If backtracking after reaching player specialization stage
		var spec = player.spec
		player.cleartraits()
		player.spec = spec
		
	#Update stage and advance
	self.stage = button.get_position_in_parent()
	
	
#QMod - Refactored to use Match
#Changed 'remember prior choices during creation' to 'forget changes' as default
#warning-ignore:unused_argument
func _advance_stage(confirm = false):		
	#Process newgame creation stage panel visuals
	_process_stage_panels()			
	
	match stage:
		0: #Game Settings, Select Story/Sandbox			
			for i in get_tree().get_nodes_in_group("startoption"):
				i.set_pressed(globals.rules[i.get_name()])
			get_node("TextureFrame/newgame/stage1").visible = true
		1: #Select Quick Start/Customized Start			
			if isSandbox == false:
				_show_intro_text(introText01)
			get_node("TextureFrame/newgame/stage2").visible = true
		2: #Select Starting Location			
			get_node("TextureFrame/newgame/stage3").visible = true
			_stage3()
		3: #Select Player Race			
			if isSandbox == false:
				_show_intro_text(introText02)				
			get_node("TextureFrame/newgame/stage4").visible = true
			_stage4()
		4: #Select Player Basics + Physical Stat Potential			
			playerBonusStatPoints = variables.playerbonusstatpoint
			regenerateplayer()
			get_node("TextureFrame/newgame/stage5").visible = true
			_stage5()
		5: #Select Player Appearance			
			_stage6()
			get_node("TextureFrame/newgame/stage6").visible = true
		6: #Select Player Specialization
			_stage7()
			get_node("TextureFrame/newgame/stage7").visible = true
		7: #Customize Starting Slave									
			_stage8()
			get_node("TextureFrame/newgame/stage8").visible = true

func _process_stage_panels():
	#Process stage panel visuals
	for i in get_tree().get_nodes_in_group('startstage'): #Hide stage main panels
		i.visible = false
	
	#Reset stage buttons to 'unpressed', set selected stage button to 'pressed'
	for i in get_node("TextureFrame/newgame/stagespanel/VBoxContainer").get_children():
		i.set_pressed(false)
	get_node("TextureFrame/newgame/stagespanel/VBoxContainer").get_child(stage).set_pressed(true) #Set selected stage button to 'pressed'
	
	#Set stage buttons to 'enabled/disabled' states, set selected stage button 'text' to 'original text'
	for i in get_node("TextureFrame/newgame/stagespanel/VBoxContainer").get_children():
		if i.get_position_in_parent() > stage && i.get_name() != 'cancel':
			i.set_disabled(true)
			i.set_text(i.get_tooltip())
		else:
			if i.get_position_in_parent() == stage: #Set selected stage button text to original text
				i.set_text(i.get_tooltip())
			i.set_disabled(false)
			i.set_pressed(false)	

			
#Stage01 - Toggles some global game settings
func _option_toggle(button):
	globals.rules[button.get_name()] = button.is_pressed()

func _on_storymode_pressed():
	isSandbox = false
	globals.overwritesettings()
	get_node("TextureFrame/newgame/stagespanel/VBoxContainer/start").set_text("Story")
	self.stage = 1 #Moved to end of function as this calls 'set_stage', which calls 'advance_stage'

func _on_sandboxmode_pressed():
	isSandbox = true
	globals.overwritesettings()	
	get_node("TextureFrame/newgame/stagespanel/VBoxContainer/start").set_text("Sandbox")
	self.stage = 1 #Moved to end of function as this calls 'set_stage', which calls 'advance_stage'

	
#Stage02 - Quick or Custom Start
func _on_customize_pressed():
	get_node("TextureFrame/newgame/stagespanel/VBoxContainer/settings").set_text("Custom Start")
	self.stage = 2
	
#QMod - Incompletely modified, a bit more random now, does not fully implement choice consequences 'properly'
func _on_quickstart_pressed():
	var ageArray = ['teen', 'adult']
	var sexArray = ['male','futanari']
	var playerSpecializationArray = ['Slaver','Hunter'] #Added 'Hunter', 'Alchemist', 'Mage'

	#Select random start location
	var locationArray = locationDict.keys()
	startingLocation = locationArray[rand_range(0, locationArray.size())]
	
	#Generate random Player
	if isSandbox: #Randomize from sandbox full race list
		player.race = globals.allracesarray[rand_range(0, globals.allracesarray.size())]
	else: #Randomize from story starting race list
		player.race = globals.getracebygroup('starting')
		#player.race = globals.starting_pc_races[rand_range(0, globals.starting_pc_races.size())]
	
	if !globals.rules.futa: #If futanari not allowed, remove futa
		sexArray.erase('futanari')
	
	player.sex = sexArray[rand_range(0,sexArray.size())]
	player.age = ageArray[rand_range(0,ageArray.size())]
	player.spec = playerSpecializationArray[rand_range(0, playerSpecializationArray.size())]
	
	#Generate random starting slave
	if globals.rules.children: #If children allowed, add 'child' age
		ageArray.push_front('child')
	
	if isSandbox: #Randomize from sandbox full race list
		slaveDefaults.race = globals.allracesarray[rand_range(0, globals.allracesarray.size())]
	else: #Randomize from story starting race list
		slaveDefaults.race = globals.getracebygroup('starting')
	
	slaveDefaults.age = ageArray[rand_range(0,ageArray.size())]
	slaveDefaults.sex = 'random'
	startSlave = globals.newslave(slaveDefaults.race, slaveDefaults.age, slaveDefaults.sex, 'poor')	
	player.imageportait = playerPortraits[randi()%playerPortraits.size()]
	startSlave.cleartraits()
	_on_slaveconfirm_pressed()

	
#Stage03 - Starting Location
func _stage3():
	var location = locationDict[startingLocation]
	get_node("TextureFrame/newgame/stage3/cityname").set_text(location.name)
	get_node("TextureFrame/newgame/stage3/locationtext").set_bbcode(location.descript)
	get_node("TextureFrame/newgame/stage3/locimage").set_texture(globals.backgrounds[location.code])
	
func _on_next_pressed():
	var counter = locationDict.keys().find(startingLocation)
	if counter + 1 > locationDict.size()-1:
		counter = 0 
	else:
		counter += 1
	var location = locationDict.values()[counter]
	startingLocation = location.code
	_stage3()
	
func _on_locconfirm_pressed():
	self.stage = 3
	globals.state.location = startingLocation
	get_node("TextureFrame/newgame/stagespanel/VBoxContainer/location").set_text(startingLocation.capitalize())	

	
#Stage04 - Select Player Race
#QMod - Initializes player race and portrait to default, reset race selection panel to default
func _stage4():	
	#Reset to defaults
	var defaultText = "Choose starting race for player character.\nDefault race: " + playerDefaults.race
	get_node("TextureFrame/newgame/stage4/racetext").set_bbcode(defaultText) #Resets race select info to default
	player.race = playerDefaults.race #Reset player race to default
	var portraitIndex = playerPortraits.find($TextureFrame/newgame/stage4/portrait.texture.get_path()) #Get current portrait index
	player.imageportait = load(playerPortraits[portraitIndex]) #Set player portrait to default displayed portrait
	
	#Clear race list
	var button = get_node("TextureFrame/newgame/stage4/racecontainer/VBoxContainer/Button")
	for i in get_node("TextureFrame/newgame/stage4/racecontainer/VBoxContainer").get_children():
		if i != button:
			i.visible = false
			i.queue_free()
	
	#Get source race list according to game mode
	var raceArray = []
	if isSandbox == true: #Set available races according to game mode
		raceArray = globals.allracesarray
	else:
		for i in globals.races:
			if globals.races[i].startingrace == true:
				raceArray.append(i)
				if i.find('Beastkin') >= 0:
					raceArray.append(i.replace("Beastkin","Halfkin"))
		#raceArray = globals.starting_pc_races		
	
	#Populate race list and eliminate rule-blocked races
	var newbutton
	for i in raceArray: 
		if i.find('Beastkin') >= 0 && globals.rules.furry == false: #Skip beastkin if no furries allowed
			continue
		newbutton = button.duplicate()
		newbutton.visible = true
		get_node("TextureFrame/newgame/stage4/racecontainer/VBoxContainer").add_child(newbutton)
		newbutton.set_text(i.capitalize())
		newbutton.connect("pressed",self,'_select_race',[i, newbutton])	

func _select_race(racename, button):
	#If button is 'pressed' -> 'unpressed', return to no race selected
	if !button.is_pressed():
		var defaultText = "Choose starting race for player character.\nDefault race: " + playerDefaults.race
		get_node("TextureFrame/newgame/stage4/racetext").set_bbcode(defaultText) #Restore default race text
		player.race = playerDefaults.race		
		return

	#Sets 'race' buttons 'pressed' states
	for i in get_tree().get_nodes_in_group("racebutton"):
		if i != button && i.is_pressed():
			i.set_pressed(false)
		
	#Get description for selected race
	var text = globals.dictionary.getRaceDescription(racename, false)
	
	#Get race bonus identifier for selected race
	var raceBonus
	if racename.find('Beastkin')>=0:
		raceBonus = 'Beastkin'
	elif racename.find('Halfkin')>=0:
		raceBonus = 'Halfkin'
	else:
		raceBonus = racename	
	
	#Set race description to race bonus description + race description for selected race
	if racebonusdict.has(raceBonus.to_lower()):
		text = "[color=aqua]" + racebonusdict[raceBonus.to_lower()].descript + "[/color]\n\n" + text
	get_node("TextureFrame/newgame/stage4/racetext").set_bbcode(text)
	
	#Set player race to selected race
	player.race = racename

#QMod - Tweaked for clarity	
func _on_nextport_pressed():	
	#Get current portrait index
	var portraitIndex = playerPortraits.find($TextureFrame/newgame/stage4/portrait.texture.get_path())
	
	#Find next portrait
	var foundPortrait
	if playerPortraits.size() > portraitIndex+1: #Still more portraits in list
		foundPortrait = load(playerPortraits[portraitIndex + 1]) 
	else: #Cycle back to portrait list start
		foundPortrait = load(playerPortraits[0])
	
	#Set/Display found portrait in UI
	$TextureFrame/newgame/stage4/portrait.texture = foundPortrait
	
	#Set found portrait as player portrait
	player.imageportait = foundPortrait.get_path()

func _on_prevport_pressed():
	#Find previous portrait
	var foundPortrait
	var portraitIndex = playerPortraits.find($TextureFrame/newgame/stage4/portrait.texture.get_path())
	if portraitIndex != 0: #If current portrait not first portrait in list
		foundPortrait = load(playerPortraits[portraitIndex - 1])
	else: #Else cycle to portrait list end
		foundPortrait = load(playerPortraits.back())
		
	#Set/Display found portrait in UI
	$TextureFrame/newgame/stage4/portrait.texture = foundPortrait
		
	#Set found portrait as player portrait
	player.imageportait = foundPortrait.get_path()
	
#QMod - Commit race change through constructor	
func _on_raceconfirm_pressed():
	get_node("TextureFrame/newgame/stagespanel/VBoxContainer/race").set_text(player.race)
	#globals.constructor.changerace(player) #Commit player race change
	regenerateplayer()
	self.stage = 4
	
	
#Stage05 - Select player gender, age, stats
#QMod
func _stage5():
	#Clear age, gender
	get_node("TextureFrame/newgame/stage5/age").clear()
	get_node("TextureFrame/newgame/stage5/sex").clear()
	
	#Build age & gender lists, display currently selected options
	for i in ['male','female','futanari']:
		if i == 'futanari' && globals.rules.futa == false:
			continue
		get_node("TextureFrame/newgame/stage5/sex").add_item(i)
		if player.sex == i:
			get_node("TextureFrame/newgame/stage5/sex").select(get_node("TextureFrame/newgame/stage5/sex").get_item_count()-1)
	for i in ['teen','adult']:
		get_node("TextureFrame/newgame/stage5/age").add_item(i)
		if player.age == i:
			get_node("TextureFrame/newgame/stage5/age").select(get_node("TextureFrame/newgame/stage5/age").get_item_count()-1)

	_update_stage5()
	
#QMod - Refactor
func _update_stage5():
	#Display stat potentials/maximums
	var text = "[center]Strength: [color=yellow]" + str(player.stats.str_max) + "[/color]\nAgility: [color=yellow]" + str(player.stats.agi_max) + "[/color]\nMagic: [color=yellow]" + \
			str(player.stats.maf_max) + "[/color]\nEndurance: [color=yellow]"+ str(player.stats.end_max) + "[/color] \nPoints Left: [color=green]"+str(playerBonusStatPoints) + "[/color][/center]"
	get_node("TextureFrame/newgame/stage5/stattext").set_bbcode(text)
	
func _on_sex_item_selected(id):
	player.sex = get_node("TextureFrame/newgame/stage5/sex").get_item_text(id)
	regenerateplayer()

func _on_age_item_selected(id):
	player.age = get_node("TextureFrame/newgame/stage5/age").get_item_text(id)
	regenerateplayer()

func regenerateplayer():
	var imageportait = player.imageportait
	player = globals.newslave(player.race, player.age, player.sex, 'slave')
	globals.player = player
	player.cleartraits()
	player.unique = 'player'
	player.imageportait = imageportait
	player.beautybase = variables.playerstartbeauty
	playerBonusStatPoints = variables.playerbonusstatpoint
	for i in ['str','agi','maf','end']:
		player.stats[i+'_max'] = 4
	_update_stage5()

func regenerateslave():
	startSlave = globals.newslave(startSlave.race, startSlave.age, startSlave.sex, 'poor')
	startSlave.beautybase = variables.characterstartbeauty

#QMod - Rewrote function
func statup(button):	
	var name = button.get_name().left(3) + "_max" #Get stat being increased
	if playerBonusStatPoints >= 1 && player.stats[name] < 7: #Check bonus points available and stat below maximum limit
		player.stats[name] += 1
		playerBonusStatPoints -= 1
	_update_stage5()
				
#QMod - Rewrote function
func statdown(button):
	var name = button.get_name().left(3) + "_max" #Get stat being decreased
	if player.stats[name] > 2: #Check stat above minimum required
		player.stats[name] -= 1
		playerBonusStatPoints += 1
	_update_stage5()

#QMod - Patch fix for women/futa to have womb == true
func _on_sexconfirm_pressed():
	globals.assets.getsexfeatures(player) #Also modified assets.gd to set has_womb == true for females/futa
	if player.sex != 'male': #Including this here temporarily for compatibility if no other files are modified
		player.preg.has_womb = true
	get_node("TextureFrame/newgame/stagespanel/VBoxContainer/sexage").set_text(player.sex.capitalize() + " " + player.age.capitalize())
	self.stage = 5	
	
	
#Stage06 - Customize makeoverPerson appearance
#Qmod - Refactored, fixed special physical feature options enable/disable
func _stage6(editPerson = player):
	#Set person being edited
	makeoverPerson = editPerson
	
	#Connect and process appearance panel
	_process_stage6() #Process basics
	_process_stage6_sex_options() #Process appearance sex options
	_process_stage6_body_options() #Process physical features - height, skin, ...
	_process_stage6_locked_options() #Process immutable/unchange-able features	

#QMod - Refactor
func _process_stage6():
	#Display selected appearance options
	for i in get_tree().get_nodes_in_group("lookline"): 
		i.set_text(makeoverPerson[i.get_name()])
	
	#Display isVagVirgin, weird option setup
	get_node("TextureFrame/newgame/stage6/virgin").set_text("Virgin")
	get_node("TextureFrame/newgame/stage6/virgin").set_pressed(makeoverPerson.vagvirgin)
	
	#Set makeoverPerson description
	var text = makeoverPerson.description()
	get_node("TextureFrame/newgame/stage6/chardescript").set_bbcode(text)
		
	#Clear appearance options
	for i in get_tree().get_nodes_in_group('lookoption'):
		i.clear()
	
	#get_node("TextureFrame/newgame/stage6/virgin").set_disabled(makeoverPerson.vagina == 'none') #I'm guessing this is the intention?
	
	$TextureFrame/newgame/stage6/virgin.visible = makeoverPerson.vagina != 'none'
	
#QMod - Refactor	
func _process_stage6_sex_options():
	#Add sex size options
	var sexSizes = []
	if makeoverPerson.sex == 'male':
		sexSizes = malesizes
	else:
		sexSizes = femalesizes
		
	for i in sexSizes:
		get_node("TextureFrame/newgame/stage6/asssize").add_item(i)
		if makeoverPerson.asssize == i:
			get_node("TextureFrame/newgame/stage6/asssize").select(get_node("TextureFrame/newgame/stage6/asssize").get_item_count()-1)
		get_node("TextureFrame/newgame/stage6/titssize").add_item(i)
		if makeoverPerson.titssize == i:
			get_node("TextureFrame/newgame/stage6/titssize").select(get_node("TextureFrame/newgame/stage6/titssize").get_item_count()-1)
	
	if makeoverPerson.sex != 'female':
		get_node("TextureFrame/newgame/stage6/penis").set_disabled(false)
		get_node("TextureFrame/newgame/stage6/balls").set_disabled(false)
		for i in ['none','small', 'average', 'big']:
			get_node("TextureFrame/newgame/stage6/penis").add_item(i)
			if makeoverPerson.penis == i:
				get_node("TextureFrame/newgame/stage6/penis").select(get_node("TextureFrame/newgame/stage6/penis").get_item_count()-1)
			get_node("TextureFrame/newgame/stage6/balls").add_item(i)
			if makeoverPerson.balls == i:
				get_node("TextureFrame/newgame/stage6/balls").select(get_node("TextureFrame/newgame/stage6/balls").get_item_count()-1)
	else:
		get_node("TextureFrame/newgame/stage6/penis").set_disabled(true)
		get_node("TextureFrame/newgame/stage6/penis").add_item('none')
		get_node("TextureFrame/newgame/stage6/balls").set_disabled(true)
		get_node("TextureFrame/newgame/stage6/balls").add_item('none')
	
#QMod - Refactor
func _process_stage6_body_options():
	#Process height
	for i in globals.heightarray:
		get_node("TextureFrame/newgame/stage6/height").add_item(i)
		if makeoverPerson.height == i:
			get_node("TextureFrame/newgame/stage6/height").select(get_node("TextureFrame/newgame/stage6/height").get_item_count()-1)
	
	#Process hair
	for i in globals.hairlengtharray:
		get_node("TextureFrame/newgame/stage6/hairlength").add_item(i)
		if makeoverPerson.hairlength == i:
			get_node("TextureFrame/newgame/stage6/hairlength").select(get_node("TextureFrame/newgame/stage6/hairlength").get_item_count()-1)
	
	#Process skin hues
	var skinHues
	if skindict.has(makeoverPerson.race.to_lower()):
		skinHues = skindict[makeoverPerson.race.to_lower()]
	else:
		skinHues = skindict.human
	for i in skinHues:
		get_node("TextureFrame/newgame/stage6/skin").add_item(i)
		if makeoverPerson.skin == i:
			get_node("TextureFrame/newgame/stage6/skin").select(get_node("TextureFrame/newgame/stage6/skin").get_item_count()-1)
	
	#Process horns
	var hornTypes
	if horndict.has(makeoverPerson.race.to_lower()):
		hornTypes = horndict[makeoverPerson.race.to_lower()]
		get_node("TextureFrame/newgame/stage6/horns").set_disabled(false)
	else:
		hornTypes = horndict.human
		get_node("TextureFrame/newgame/stage6/horns").set_disabled(true)
	for i in hornTypes:
		get_node("TextureFrame/newgame/stage6/horns").add_item(i.replace("_", " "))
		if makeoverPerson.horns == i:
			get_node("TextureFrame/newgame/stage6/horns").select(get_node("TextureFrame/newgame/stage6/horns").get_item_count()-1)
	
	#Process wings
	var wingTypes
	if wingsdict.has(makeoverPerson.race.to_lower()):
		wingTypes = wingsdict[makeoverPerson.race.to_lower()]
		get_node("TextureFrame/newgame/stage6/wings").set_disabled(false)
	else:
		wingTypes = wingsdict.human
		get_node("TextureFrame/newgame/stage6/wings").set_disabled(true)
	for i in wingTypes:
		get_node("TextureFrame/newgame/stage6/wings").add_item(i.replace("_", " "))
		
	#Process fur colors
	var furColors
	if furcolordict.has(makeoverPerson.race.to_lower()):
		furColors = furcolordict[makeoverPerson.race.to_lower()]
		get_node("TextureFrame/newgame/stage6/furcolor").set_disabled(false)
	else:
		furColors = furcolordict.human
		get_node("TextureFrame/newgame/stage6/furcolor").set_disabled(true)
	for i in furColors:
		get_node("TextureFrame/newgame/stage6/furcolor").add_item(i.replace("_", " "))
		if makeoverPerson.furcolor == i:
			get_node("TextureFrame/newgame/stage6/furcolor").select(get_node("TextureFrame/newgame/stage6/furcolor").get_item_count()-1)	
	
#QMod - Refactor
func _process_stage6_locked_options():
	#Set & lock immutable features
	get_node("TextureFrame/newgame/stage6/bodyshape").set_disabled(true)
	get_node("TextureFrame/newgame/stage6/bodyshape").add_item(makeoverPerson.bodyshape)
	get_node("TextureFrame/newgame/stage6/ears").set_disabled(true)
	get_node("TextureFrame/newgame/stage6/ears").add_item(makeoverPerson.ears.replace("_", " "))
	get_node("TextureFrame/newgame/stage6/tail").set_disabled(true)
	get_node("TextureFrame/newgame/stage6/tail").add_item(makeoverPerson.tail)
	get_node("TextureFrame/newgame/stage6/penistype").add_item(makeoverPerson.penistype)
	get_node("TextureFrame/newgame/stage6/penistype").set_disabled(true)	
	
func _option_select(item, button):
	if !button.get_name() in ['penis','tits']:
		makeoverPerson[button.get_name()] = button.get_item_text(item).replace(" ", "_")
	elif button.get_name() == 'tits':
		makeoverPerson.titssize = button.get_item_text(item)
	elif button.get_name() == 'penis':
		makeoverPerson.penis = button.get_item_text(item)
	_update_stage6()
	
func _update_stage6():
	var text = makeoverPerson.description()
	get_node("TextureFrame/newgame/stage6/chardescript").set_bbcode(text)

#Update makeoverPerson appearance to selected option
#warning-ignore:unused_argument
func _lookline_text(text, node):
	makeoverPerson[node.get_name()] = node.get_text()
	_update_stage6()

func _virgin_press():
	if makeoverPerson.vagina == 'normal':
		makeoverPerson.vagvirgin = get_node("TextureFrame/newgame/stage6/virgin").is_pressed()
	_update_stage6()

#On confirm in appearance customization panel
func _on_lookconfirm_pressed():
	if stage != 7:		
		self.stage += 1
	else:
		get_node("TextureFrame/newgame/stage6").visible = false
		get_node("TextureFrame/newgame/stage8/slavename").set_text(startSlave.name)
		get_node("TextureFrame/newgame/stage8/slavesurname").set_text(startSlave.surname)
		get_node("TextureFrame/newgame/stage8/backgroundtext").set_bbcode("")
	

#Stage07 - Select specialization
func _stage7():
	#Reset specialization
	player.spec = null
	
	#Set default description
	var text = "Specialization provides a\n" + "considerable bonus to certain way of\n" + "playing."
	get_node("TextureFrame/newgame/stage7/backgroundtext").set_bbcode(text)

	#Clear specializations list
	for i in get_node("TextureFrame/newgame/stage7/backgroundcontainer/VBoxContainer").get_children():
		if i != get_node("TextureFrame/newgame/stage7/backgroundcontainer/VBoxContainer/Button"):
			i.visible = false
			i.queue_free()
			
	#Build specialization list
	for i in globals.playerspecs:
		var newbutton = get_node("TextureFrame/newgame/stage7/backgroundcontainer/VBoxContainer/Button").duplicate()
		get_node("TextureFrame/newgame/stage7/backgroundcontainer/VBoxContainer").add_child(newbutton)
		newbutton.visible = true
		newbutton.set_text(i)
		newbutton.set_meta('spec', i)
		newbutton.connect("pressed",self,'_select_specialization', [newbutton])	
	
	#Disable 'confirm' button
	get_node("TextureFrame/newgame/stage7/backgroundconfirm").set_disabled(true)

#QMod - Renamed, tweaked for 'select' and 'deselect' behavior, added allow 'confirm' only when spec selected
func _select_specialization(button):
	#If button 'unpressed' reset spec panel
	if !button.is_pressed():
		var text = "Specialization provides a\n" + "considerable bonus to certain way of\n" + "playing."
		get_node("TextureFrame/newgame/stage7/backgroundtext").set_bbcode(text)
		get_node("TextureFrame/newgame/stage7/backgroundconfirm").set_disabled(true)
		return

	#Set all non-selected buttons to 'unpressed'
	for i in get_tree().get_nodes_in_group('bgbutton'):
		if i != button:
			i.set_pressed(false)
	
	#Set player specialization to selected spec
	var spec = button.get_meta('spec')
	player.spec = spec
	#Set specialization description
	var text = globals.playerspecs[spec]
	if player.spec in ['Mage', 'Alchemist']:
		text += "\n\n[color=yellow]Not recommended for inexperienced players.[/color]"
	get_node("TextureFrame/newgame/stage7/backgroundtext").set_bbcode(text)
	
	#Enable 'confirm' button
	get_node("TextureFrame/newgame/stage7/backgroundconfirm").set_disabled(false)

func _on_backgroundconfirm_pressed():
	_reset_stage8()
	self.stage += 1

#Handles pre-processing/reset/clear for a stage8 session (doesn't get called again when stage8 is called again within a session)
func _reset_stage8():
	#Reset first slave parameters
	startSlave.memory = slaveBackgrounds.back()
	slaveTrait = ''
	
	#Reset slave customization panel
	$TextureFrame/newgame/stage8/traitpanel/Label.text = "No Trait Selected"
	get_node("TextureFrame/newgame/stage8/backgroundtext").set_bbcode('') #Clear description
	

#Stage08 - Customize starting slave
#QMod - Refactor
func _stage8():
	#Process slave customization options
	_process_stage8() #Process basics	
	_process_stage8_race_options()
	_process_stage8_sex_options() 	
	_process_stage8_age_options()
	_process_stage8_background_list()
	_process_stage8_hobby_list()
	_process_stage8_traits()
	
	_update_stage8()

#QMod - Refactor
func _process_stage8():
	#Clear age, sex, race panel info
	get_node("TextureFrame/newgame/stage8/slaveage").clear()
	get_node("TextureFrame/newgame/stage8/slavesex").clear()
	get_node("TextureFrame/newgame/stage8/slaverace").clear()

#QMod - Refactor
func _process_stage8_race_options():
	#Build race options
	var slaveRaces = []
	if isSandbox:
		slaveRaces = globals.allracesarray
	else:
		for i in globals.races:
			if globals.races[i].startingrace == true:
				slaveRaces.append(i)
				if i.find('Beastkin') >= 0:
					slaveRaces.append(i.replace("Beastkin","Halfkin"))
		#slaveRaces = globals.starting_pc_races
	
	for i in slaveRaces:
		if i.find('Beastkin') >= 0 && globals.rules.furry == false: #Skip beastkin if no furries allowed
			continue
		get_node("TextureFrame/newgame/stage8/slaverace").add_item(i)
		if startSlave.race == i:
			get_node("TextureFrame/newgame/stage8/slaverace").select(get_node("TextureFrame/newgame/stage8/slaverace").get_item_count()-1)
			
#QMod - Refactor
func _process_stage8_sex_options():
	#Build sex options
	for i in ['female','futanari','male']:
		if i == 'futanari' && globals.rules.futa == false:
			continue
		get_node("TextureFrame/newgame/stage8/slavesex").add_item(i)
		if startSlave.sex == i:
			get_node("TextureFrame/newgame/stage8/slavesex").select(get_node("TextureFrame/newgame/stage8/slavesex").get_item_count()-1)
			
#QMod - Refactor	
func _process_stage8_age_options():
	#Build age options
	var slaveAges = ['child', 'teen', 'adult']
	if globals.rules.children == false:
		slaveAges.erase('child')
	for i in slaveAges:
		get_node("TextureFrame/newgame/stage8/slaveage").add_item(i)
		if startSlave.age == i:
			get_node("TextureFrame/newgame/stage8/slaveage").select(get_node("TextureFrame/newgame/stage8/slaveage").get_item_count()-1)
	
#QMod - Refactor
func _process_stage8_background_list():
	#Clear slave background list
	for i in get_node("TextureFrame/newgame/stage8/backgroundcontainer/VBoxContainer").get_children():
		if i != get_node("TextureFrame/newgame/stage8/backgroundcontainer/VBoxContainer/Button"):
			i.visible = false
			i.queue_free()
	
	#Build slave background list
	for i in slaveBackgrounds:
		var newbutton = get_node("TextureFrame/newgame/stage8/backgroundcontainer/VBoxContainer/Button").duplicate()
		newbutton.visible = true
		newbutton.set_meta('bg', i)		
		
		if startSlave.memory == i:
			newbutton.set_pressed(true)
		get_node("TextureFrame/newgame/stage8/backgroundcontainer/VBoxContainer").add_child(newbutton)
		
		if globals.player.race != startSlave.race && i == '$sibling': #Changed player.race to globals.player.race
			newbutton.set_text(startSlave.dictionary("Foster "+i).capitalize())
		else:
			newbutton.set_text(startSlave.dictionary(i).capitalize())
			
		newbutton.connect("pressed",self,'_slave_background', [newbutton])

#QMod - Refactor
func _process_stage8_hobby_list():
	#Clear slave hobby list
	for i in get_node("TextureFrame/newgame/stage8/hobbycontainer/VBoxContainer").get_children():
		if i != get_node("TextureFrame/newgame/stage8/hobbycontainer/VBoxContainer/Button"):
			i.visible = false
			i.queue_free()	
	
	#Build slave hobby list
	for i in slaveHobbies:
		var newbutton = get_node("TextureFrame/newgame/stage8/hobbycontainer/VBoxContainer/Button").duplicate()
		newbutton.visible = true
		newbutton.set_meta('hobby', i)
		if startSlaveHobby == i:
			newbutton.set_pressed(true)
		get_node("TextureFrame/newgame/stage8/hobbycontainer/VBoxContainer").add_child(newbutton)
		newbutton.set_text(i)
		newbutton.connect("pressed",self,'_slave_hobby', [newbutton])

#QMod - Refactor
var forbiddentraits = ['Dominant','Submissive']
func _process_stage8_traits():
	#Clear trait list
	for i in $TextureFrame/newgame/stage8/traitpanel/ScrollContainer/VBoxContainer.get_children():
		if i.name != 'Button':
			i.visible = false
			i.queue_free()
			
	#Build trait list
	for i in globals.origins.traitlist.values():
		if i.tags.has("secondary") || forbiddentraits.has(i):
			continue
		var newbutton = $TextureFrame/newgame/stage8/traitpanel/ScrollContainer/VBoxContainer/Button.duplicate()
		newbutton.visible = true
		$TextureFrame/newgame/stage8/traitpanel/ScrollContainer/VBoxContainer.add_child(newbutton)
		newbutton.text = i.name
		
		if i.name == slaveTrait:
			newbutton.set_pressed(true)
		else:
			newbutton.set_pressed(false)
			
		newbutton.connect("pressed",self,'_trait_toggle',[i, newbutton]) #Connect list buttons to trait toggle method

#Qmod - Added update method
func _update_stage8():
	#Display slave's name + surname
	get_node("TextureFrame/newgame/stage8/slavename").set_text(startSlave.name)
	get_node("TextureFrame/newgame/stage8/slavesurname").set_text(startSlave.surname)
	
	#Display chosen slave trait
	var text = "Trait: "
	if slaveTrait != '':
		text += slaveTrait
	else:
		text += "None"
	$TextureFrame/newgame/stage8/traits.text = text
	
	#Update background
	var bgButton
	for i in get_tree().get_nodes_in_group("slavebg"):
		if i.has_meta('bg') && i.get_meta('bg') == '$sibling': #Appears to short-circuit correctly
			bgButton = i
	
	if globals.player.race != startSlave.race:
		bgButton.set_text(startSlave.dictionary("Foster $sibling").capitalize())
	else:
		bgButton.set_text(startSlave.dictionary('$sibling').capitalize())
	
	
#QMod - Renamed
func _slave_background(button):
	for i in get_tree().get_nodes_in_group("slavebg"):
		if i != button:
			i.set_pressed(false)
		else:
			i.set_pressed(true)
	startSlave.memory = button.get_meta('bg')
	get_node("TextureFrame/newgame/stage8/backgroundtext").set_bbcode(startSlave.dictionary(backstorydescription[startSlave.memory]))
	if startSlave.memory == '$sibling':
		startSlave.surname = globals.player.surname
		get_node("TextureFrame/newgame/stage8/slavesurname").set_text(startSlave.surname)	

#QMod - Renamed
func _slave_hobby(button):
	for i in get_tree().get_nodes_in_group("slavehobby"):
		if i != button:
			i.set_pressed(false)
		else:
			i.set_pressed(true)
	startSlaveHobby = button.get_meta('hobby')
	get_node("TextureFrame/newgame/stage8/backgroundtext").set_bbcode(startSlave.dictionary(hobbydescription[startSlaveHobby]))
		
#QMod - Rewrite using 'match'
func _slave_option(id, button):
	#Set slave race, sex, age on changes in slave panel
	match button.get_name():
		'slaverace':
			startSlave.race = button.get_item_text(id)
			regenerateslave()
			get_node("TextureFrame/newgame/stage8/backgroundtext").set_bbcode(globals.dictionary.getRaceDescription(startSlave.race, true, true))		
		'slavesex':
			startSlave.sex = button.get_item_text(id)
			regenerateslave()
		'slaveage':
			startSlave.age = button.get_item_text(id)
			regenerateslave()
	
	#Refresh slave customization panel
	_update_stage8()

	
#QMod - Refactored - moved once-per-session processing to separate method	
func _on_traits_pressed():
	$TextureFrame/newgame/stage8/traitpanel.popup()

#QMod - Renamed, tweaked button toggling, tweaked 'no trait' selected
func _trait_toggle(trait, button):
	#Set other buttons to 'unpressed'
	for i in $TextureFrame/newgame/stage8/traitpanel/ScrollContainer/VBoxContainer.get_children():
		if i != button:
			i.set_pressed(false)
	
	#Set or clear trait description
	if button.is_pressed():
		slaveTrait = trait.name
		$TextureFrame/newgame/stage8/traitpanel/Label.text = startSlave.dictionary(trait.name)
		$TextureFrame/newgame/stage8/traitpanel/RichTextLabel.bbcode_text = startSlave.dictionary(trait.description)
	else:
		slaveTrait = ''
		$TextureFrame/newgame/stage8/traitpanel/Label.text = "No Trait Selected"
		$TextureFrame/newgame/stage8/traitpanel/RichTextLabel.bbcode_text = ''

func _on_traitclose_pressed():
	$TextureFrame/newgame/stage8/traitpanel.visible = false
	_update_stage8()		
	

func _on_slavefinetune_pressed():
	#Display slave appearance customization panel
	get_node("TextureFrame/newgame/stage6").visible = true
	get_node("TextureFrame/newgame/stage6").set_as_toplevel(true)
	
	#Run character customization back-end
	_stage6(startSlave)
	_update_stage6()

#QMod - Incomplete refactor, removed firecheck
func _on_slaveconfirm_pressed():	
	#Finish processing slave
	startSlave.cleartraits() #Clear traits, reset basics	
	
	#Generate mental stats
	for i in ['conf','cour','wit','charm']:
		startSlave[i] = rand_range(30,35)	
	startSlave.obed = 90
	startSlave.beautybase = variables.characterstartbeauty
	if startSlave.memory.find('$sibling') >= 0:
		globals.connectrelatives(startSlave, player, 'sibling')
	
	#Apply hobby bonus
	if startSlaveHobby == 'Physical':
		startSlave.cour += 25
		startSlave.stats.str_max += 1
	elif startSlaveHobby == 'Etiquette':
		startSlave.conf += 20
		startSlave.charm += 15
	elif startSlaveHobby == 'Magic':
		startSlave.wit += 25
		startSlave.stats.maf_max += 2
	elif startSlaveHobby == 'Servitude':
		startSlave.stats.end_max += 1
		startSlave.loyal += 20
		startSlave.stats.obed_min += 35
	
	#Add traits
	if slaveTrait != '':
		startSlave.add_trait(slaveTrait)
	
	#Assign start slave to global slave list
	startSlave.unique = 'startslave'
	globals.slaves = startSlave	#A bit deceptive as it assigns 'person' to 'array', works because of 'setget'
	
	
	#Apply player racial bonuses
	if player.race == 'Elf':
		player.stats.maf_base += 1
	elif player.race == "Dark Elf":
		player.stats.agi_base += 1
	elif player.race == 'Orc':
		globals.state.reputation.gorn += 30
	elif player.race == 'Demon':
		for i in globals.state.reputation.values():
			i -= 10
		player.skillpoints += 1
	elif player.race == 'Taurus':
		player.stats.end_base += 1
	elif player.race.find("Beastkin") >= 0:
		globals.state.reputation.frostford += 30
	elif player.race.find("Halfkin"):
		for i in globals.state.reputation.values():
			i += 15
	else:
		globals.state.reputation.wimborn += 30
	
	#Add starting player abilities
	player.ability.append('escape')
	player.abilityactive.append('escape')
	player.ability.append("protect")
	player.abilityactive.append("protect")
		
	#Apply external player specialization bonuses
	globals.state.spec = player.spec
	if player.spec == 'Alchemist':
		globals.state.mansionupgrades.mansionalchemy += 1
	var tempitem
	if player.spec == 'Hunter':
		tempitem = globals.items.createunstackable("weapondagger")
		globals.state.unstackables[str(tempitem.id)] = tempitem
	else:
		tempitem = globals.items.createunstackable("weapondaggerrust")
		globals.state.unstackables[str(tempitem.id)] = tempitem
	
	
	#Set globals
	globals.resources.energy = 100
	globals.resources.day = 1
	globals.guildslaves.wimborn = []
	globals.guildslaves.gorn = []
	globals.guildslaves.frostford = []
	
	#Apply Game-mode specific bonuses
	if isSandbox == false:
		globals.resources.upgradepoints = 5
		globals.resources.gold += 250
		globals.resources.food += 200
		globals.resources.mana += 10
	else:
		for i in globals.state.portals.values():
			if i.code != startingLocation:
				i.enabled = true
		globals.resources.upgradepoints = 30
		globals.resources.gold += 5000
		globals.resources.food += 500
		globals.resources.mana += 100
		globals.state.mainquest = 42
		globals.state.rank = 4
		globals.state.sidequests.brothel = 2
		globals.state.branding = 2
		globals.state.farm = 4
		globals.state.portals.amberguard.enabled = true
		globals.itemdict.youthingpot.unlocked = true
		globals.itemdict.maturingpot.unlocked = true
		globals.state.sidequests.sebastianumbra = 2
		globals.state.portals.umbra.enabled = true
		globals.state.sandbox = true #Added this in case it used somewhere in the future?
	
	globals.player = player
	globals.state.upcomingevents.append({code = 'ssinitiate', duration = 1})
	#Change scene to game start 'Mansion'
	globals.ChangeScene("Mansion")
	#self.queue_free()
	#get_tree().change_scene("res://files/Mansion.scn")
	
	
	
	
	

func _on_cancel_pressed():
	get_node("TextureFrame/newgame").visible = false
	stage = 0
	isSandbox = false
	
###NEWGAME START

func _show_intro_text(storyText):
	get_node("TextureFrame/introduction").visible = true
	get_node("TextureFrame/introduction/RichTextLabel").set_bbcode(storyText)
		
func _on_closeintro_pressed(): #Story intro, where to place?
	get_node("TextureFrame/introduction").visible = false
	
	
###Unnecessary Functions

func _on_Button_pressed(): #Should be unnecessary?
	#get_node("TextureFrame/NewGamePanel").visible = true
	pass
	
func _on_warnconf_pressed():
	player = null
	_advance_stage(true)
	get_node("TextureFrame/newgame/warn").visible = false


func _on_warncanc_pressed():
	get_node("TextureFrame/newgame/warn").visible = false
	
func _on_back_pressed(): #Connects to nothing?  Left-over function from prior builds?
	get_node("TextureFrame/NewGamePanel").visible = false
	
func _on_sandbox_pressed(): #Sandbox/story seems to set regardless, unnecessary?
	globals.state.sandbox = get_node("TextureFrame/newgame2/sandbox").is_pressed()

	
