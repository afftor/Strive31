extends Node

var dir = Directory.new()
var file = File.new()
var info = 'This is an inbuilt mod allowing user to access and edit constants from main menu. If your game experiences issues, please delete it to clear settings. \n\nAuthor: Maverik'
var modversion = '0.4.1'


func run(overwrite = false):
	var modsubfolder = globals.modfolder + 'Constants/'
	if dir.dir_exists(modsubfolder):
		if !overwrite:
			#Check and overwrite this mod if updated
			var config = ConfigFile.new()
			config.load(modsubfolder + 'data.ini')
			if config.get_value('main', 'modversion') != modversion:
				overwrite = true
		if overwrite:
			for i in globals.dir_contents(modsubfolder):
				if i.find('storedvariables') == -1:
					dir.remove(i)
		else:
			return
	#making description txt
	dir.make_dir(modsubfolder)
	file.open(modsubfolder + 'info.txt', File.WRITE)
	file.store_line(info)
	file.close()
	
	dir.copy("res://files/scripts/constantsmoddata/constantsmod.gd", modsubfolder + 'constantsmod.gd')
	dir.make_dir(modsubfolder + 'scripts')
	dir.copy('res://files/scripts/constantsmoddata/mainmenu.gd', modsubfolder + 'scripts/mainmenu.gd')
	
	var config = ConfigFile.new()
	config.load(modsubfolder + "data.ini")
	config.set_value("main", "gameversion", globals.gameversion)
	config.set_value("main", "modversion", modversion)
	config.save(modsubfolder + "data.ini")
	
