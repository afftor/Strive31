extends Node

var dir = Directory.new()
var file = File.new()
var info = 'This is an inbuilt mod allowing user to access and edit constants from main menu. If your game experiences issues, please delete it to clear settings. \n\nAuthor: Maverik'
var modversion = '0.2'


func run(overwrite = false):
	var modfolder = globals.modfolder
	if dir.dir_exists(modfolder + 'Constants/') && overwrite == false: #check if folder exists
		return
	var modsubfolder = modfolder + 'Constants/'
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
	