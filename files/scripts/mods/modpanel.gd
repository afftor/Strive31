extends Panel

#warning-ignore:unused_class_variable
var run_once = false


var file_dictionary = [] #main files data paths
var mods_dictionary = {} #mod folder data

var modfolder = globals.setfolders.mods
var filedir = globals.filedir
var backupdir = globals.backupdir

var temp_mod_scripts = {} #variable to store all original + mod script data before overwrite


var loadorder = []
var activemods = []


func _ready():
#	if globals.developmode == true:
#		return
	var dir = Directory.new()
	var file = File.new()
	var files = globals.dir_contents(filedir)
	for i in files: #collects file_dictionary data and makes a backup
		if (i.find(".gd") != -1):
			dir.open(i.replacen(filedir, backupdir).get_base_dir ())
			if !dir.dir_exists(i.replacen(filedir, backupdir).get_base_dir ()):
				dir.make_dir_recursive(i.replacen(filedir, backupdir).get_base_dir ())
			file_dictionary.append(i)
	for i in scanfolder() : #collects mod_dictionary data
		if !file.file_exists(i +"/info.txt"): #makes info.txt to store mod description
			file.open(i+'/info.txt', File.WRITE)
			file.store_line("There's no information on this mod.")
			file.close()
			var check = false
			print(scanfolder())
			for k in globals.dir_contents(i):
				if k.find('.gd') != -1:
					check = true
			
			if check == false:
				continue
			
			
		
		dir.open(i)
		mods_dictionary[i] = get_mod(i)
	if !dir.dir_exists(backupdir) || globals.dir_contents(backupdir).size() <= 0:
		storebackup()
	
#	order config file management
	
	loadfromconfig()
	
	file.open(backupdir + "/version", File.READ)
	var text = file.get_as_text()
	file.close()
	
	if str(text).strip_edges() != str(globals.gameversion):
		storebackup()


func scanfolder(): #makes an array of all folders in modfolder
	var target = modfolder
	var dir = Directory.new()
	var array = []
	if dir.dir_exists(modfolder) == false:
		dir.make_dir(modfolder)
	if dir.open(target) == OK:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() && !file_name in ['.','..',null]:
				array.append(target + file_name)
			file_name = dir.get_next()
		return array


func _on_Mods_pressed():
	self.visible = !self.visible
	show()



var dir = Directory.new()
var file = File.new()

func loadfromconfig():
	var config = ConfigFile.new()
	var err = config.load(modfolder + "FileOrder.ini")
	if err == OK:
		loadorder = config.get_value("Mods", "LoadOrder", [])
		activemods = config.get_value("Mods", "ActiveMods", []) 
	for i in loadorder:
		if !dir.dir_exists(modfolder + str(i)):
			loadorder.erase(i)
	removeduplicates()

func removeduplicates():
	for i in loadorder:
		var counter = 0
		for k in loadorder:
			if k == i:
				counter += 1
		while counter > 1:
			loadorder.erase(i)
			counter -= 1

func saveconfig():
	var config = ConfigFile.new()
	config.load(modfolder + "FileOrder.ini")
	config.set_value("Mods", "LoadOrder", loadorder)
	config.set_value("Mods", "ActiveMods", activemods)
	config.save(modfolder + "FileOrder.ini")

func storebackup(): #clears and restores backups
	var file = File.new()
	var dir = Directory.new()
	
#	if globals.developmode == true:
#		print("Debug mode: No backup stored.")
#		return
	
	print("Making Backup...")
	for i in globals.dir_contents(backupdir):
		dir.remove(i)
	
	for i in file_dictionary:
		var backup = File.new()
		if !backup.file_exists(i.replacen(filedir, backupdir)):
			file.open(i, File.READ)
			backup.open(i.replacen(filedir, backupdir), File.WRITE)
			backup.store_string(file.get_as_text())
			file.close()
			backup.close()
	file.open(backupdir + "/version", File.WRITE)
	file.store_line(str(globals.gameversion))
	file.close()
	print("Backup finished.")


func loadbackup():
	print("Loading Backup...")
	for i in file_dictionary:
		var backup = File.new()
		backup.open(i.replacen(filedir, backupdir), File.READ)
		var file_string = backup.get_as_text()
		backup.close()
		backup.open(i, File.WRITE)
		backup.store_string(file_string)
		backup.close()
	print("Load Finished")

func show():
	modfolder = globals.setfolders.mods
	$modfolder.text =  modfolder
	$modfolder.hint_tooltip = modfolder
	
	for i in $allmodscontainer/VBoxContainer.get_children():
		if i.name != 'Button':
			i.hide()
			i.queue_free()
	var array = []
	for i in scanfolder():
		array.append(i)
	array.sort_custom(self, 'sortmods')
	for i in array:
		i = i.replace(modfolder,"")
		var modactive = loadorder.has(i)
		var newbutton = $allmodscontainer/VBoxContainer/Button.duplicate()
		$allmodscontainer/VBoxContainer.add_child(newbutton)
		newbutton.visible = true
		newbutton.text = i
		if modactive == true:
			newbutton.pressed = true
			newbutton.get_node("order").text = str(loadorder.find(i))
			newbutton.get_node('up').visible = true
			newbutton.get_node('down').visible = true
			newbutton.get_node("order").visible = true
			newbutton.get_node("up").connect("pressed",self,'modup',[i])
			newbutton.get_node("down").connect("pressed",self,'moddown',[i])
		newbutton.connect("mouse_entered", self, 'moddescript',[i])
		newbutton.connect("pressed",self, 'togglemod', [i])

func sortmods(first,second):
	if loadorder.has(first.replace(modfolder,"")):
		if loadorder.has(second.replace(modfolder,"")):
			if loadorder.find(first.replace(modfolder,"")) < loadorder.find(second.replace(modfolder,"")):
				return true
			else:
				return false
		else:
			return true
		return true
	else:
		return false

func moddescript(mod):
	var text
	file.open(modfolder + mod + '/info.txt', File.READ)
	text = file.get_as_text()
	file.close()
	if text == '':
		text = "There's no information on this mod."
	text = '[center][color=aqua]' + mod + '[/color][/center]\n' + text
	$modinfo.bbcode_text = text

func togglemod(mod):
	if loadorder.has(mod):
		loadorder.erase(mod)
	else:
		loadorder.append(mod)
	show()
	saveconfig()


func modup(mod):
	var order = loadorder.find(mod)
	loadorder.erase(mod)
	if order == 0:
		loadorder.insert(order, mod)
	else:
		loadorder.insert(order-1, mod)
	saveconfig()
	show()

func moddown(mod):
	var order = loadorder.find(mod)
	loadorder.erase(mod)
	if order + 1 > loadorder.size():
		loadorder.append(mod)
	else:
		loadorder.insert(order+1, mod)
	saveconfig()
	show()


func _on_applymods_pressed():
	if !globals.developmode:
		loadbackup()
	for i in loadorder:
		if dir.dir_exists(modfolder + i):
			activemods.append(i)
			apply_mod_to_dictionary(modfolder + i)
	apply_mod_dictionary()
	saveconfig()
	$restartpanel.show()

func apply_mod_dictionary():
	for i in temp_mod_scripts:
		var core_file = File.new()
		core_file.open(i, File.WRITE)
		core_file.store_string(temp_mod_scripts[i])
		core_file.close()

func apply_mod_to_dictionary(mod):
	var dict = get_mod(mod)
	
	for file in dict.keys():
		apply_file_to_dictionary(file, dict[file])

func get_mod(string):
	var mods = globals.dir_contents(string)
	var mod = {}
	string = string.replace(modfolder, '')
	for i in mods:
		if(i.find(".gd") != -1):
			var modfile = File.new()
			modfile.open(i, File.READ)
			mod[i.replace(modfolder, filedir).replace(string, '')] = modfile.get_as_text()
			modfile.close()
	return mod

func apply_file_to_dictionary(file_name, string):
	#print(file_dictionary)
	if file_dictionary.has(file_name):
		file.open(file_name, File.READ)
		temp_mod_scripts[file_name] = file.get_as_text()
		file.close()
		var offset = 0
		while offset != -1 :
			offset = apply_next_element_to_dictionary(file_name, string, offset)

func apply_next_element_to_dictionary(key, string, offset):
	var regex_string_dictionary = {}
	regex_string_dictionary["FUNC"] = "(func\\s+[\\w][\\w\\d]*).*(([\r\n]*[\\t#]+.*)*)"
	#regex_string_dictionary["VAR"] = "(var.*=)\\s([{]([^\\{\\}]*[\r\n]*)*[}])?([^\\{\\}\\s]*)"
	regex_string_dictionary["VAR"] = "(var.*=)\\s+(([\\{\\[][\n\r]+[\\S\\s]*?[\r\n]+[\\}\\]]([\r\n]+|\\Z))|([^\n\r]*))"
	regex_string_dictionary["SIGN"] = "(signal\\s.*)"
	regex_string_dictionary["ONREADY"] = "(onready\\svar.*=).*([\\{]([^\\{\\}]*[\r\n]*)*[\\}])?"
	regex_string_dictionary["CLASS"] = "(class\\s+[\\w][\\w\\d]*).*(([\r\n]*[\\t#]+.*)*)"
	
	var tag_regex = "<(\\w*)(\\s+[0-9\\-]+)?(\\s[0-9\\-]+)?>"
	var add_to = "AddTo"
	var remove_from = "RemoveFrom"
	
	var full_tag = RegEx.new()
	full_tag.compile(tag_regex) 
	
	var has_next = false
	var file_string = temp_mod_scripts[key]
	var which_operation = "NULL"
	var current_match
	var new_offset = 0
	
	for i in regex_string_dictionary.keys():
		var next_func = RegEx.new()
		next_func.compile(regex_string_dictionary[i])
		var next_match = next_func.search(string, offset)
		if next_match != null && (new_offset == 0 || new_offset > next_match.get_start()) && next_match.get_start() > -1:
			new_offset = next_match.get_start()
			current_match = next_match
			which_operation = i
			has_next = true
	
	var next_tag = full_tag.search(string, offset)
	if new_offset != 0 :
		new_offset = new_offset + current_match.get_string().length()
	var file_match
	if has_next && (next_tag == null || new_offset <= next_tag.get_start() || next_tag.get_start() == -1):
		var regex_match = RegEx.new()
		if regex_string_dictionary.has(which_operation):
			regex_match.compile(regex_string_dictionary[which_operation])
			file_match = regex_match.search_all(file_string)
		var found_match = false
		for nested_match in file_match:
			if(current_match.get_string(1) == nested_match.get_string(1)):
				temp_mod_scripts[key] = temp_mod_scripts[key].replacen(nested_match.get_string(), current_match.get_string())
				found_match = true
		if !found_match :
			temp_mod_scripts[key] = temp_mod_scripts[key] + "\r\n" + current_match.get_string()
		pass
	elif has_next :
		var regex_match = RegEx.new()
		if regex_string_dictionary.has(which_operation):
			regex_match.compile(regex_string_dictionary[which_operation])
			file_match = regex_match.search_all(file_string)
		if next_tag.get_string(1) == add_to:
			var param = next_tag.get_string(2).to_int() + 1
			if param == 0:
				param = -1
			
			for nested_match in file_match:
				if(current_match.get_string(1) == nested_match.get_string(1)):
					var pool_string = nested_match.get_string().split("\n")
					if param > pool_string.size() :
						param = -1
#warning-ignore:unused_variable
					var new_string = current_match.get_string()
					if which_operation in ["FUNC",'CLASS']:
						var param_temp = param
						for i in current_match.get_string(2).split("\n"):
							if i != "":
								pool_string.insert(param_temp, i)
								if param_temp > 0:
									param_temp += 1
						temp_mod_scripts[key] = temp_mod_scripts[key].replacen(nested_match.get_string(), pool_string.join("\n"))
					elif which_operation == "VAR":
						var param_temp = param
						for i in current_match.get_string(2).replacen("{", "").replacen("}", "").split("\n"):
							if i != "":
								pool_string.insert(param_temp, i)
								if param_temp > 0:
									param_temp += 1
						temp_mod_scripts[key] = temp_mod_scripts[key].replacen(nested_match.get_string(), pool_string.join("\n"))
					elif which_operation == "SIGN":
						pool_string.insert(param, current_match.get_string(1))
						temp_mod_scripts[key] = temp_mod_scripts[key].replacen(nested_match.get_string(), pool_string.join("\n"))
					elif which_operation == "ONREADY":
						pool_string.insert(param, current_match.get_string(2))
						temp_mod_scripts[key] = temp_mod_scripts[key].replacen(nested_match.get_string(), pool_string.join("\n"))
					else:
						#operation not supported
						pass
					break
		elif next_tag.get_string(1) == remove_from:
			var param = next_tag.get_string(2).to_int()
			var param_2 = next_tag.get_string(3).to_int()
			for nested_match in file_match:
				if(current_match.get_string(1) == nested_match.get_string(1)):
					var new_string = nested_match.get_string().split("\n")
					for i in range(0, param_2 - param + 1):
						if i < new_string.size():
							new_string.remove(param)
					temp_mod_scripts[key] = temp_mod_scripts[key].replacen(nested_match.get_string(), new_string.join("\n"))
					break
			pass
		else:
			# operation not supported
			pass
	offset = new_offset + 1
	if(has_next):
		 return offset
	else:
		 return -1

func _on_disablemods_pressed():
	loadorder.clear()
	activemods.clear()
	saveconfig()
	loadbackup()
	$restartpanel.show()

func _on_closemods_pressed():
	self.visible = false



func _on_FileDialog_dir_selected(dir):
	globals.setfolders.mods = dir
	print(dir)
	show()


func _on_modfolder_pressed():
	$FileDialog.popup()
	$FileDialog.current_dir = modfolder



func _on_helpclose_pressed():
	$Panel.hide()


func _on_modhelp_pressed():
	$Panel.show()


func _on_openmodfolder_pressed():
#warning-ignore:return_value_discarded
	OS.shell_open(modfolder)


func _on_activemods_pressed():
	var text = ''
	for i in activemods:
		text += i + '\n'
	$activemodlist.popup()
	$activemodlist/RichTextLabel.bbcode_text = text


func _on_restartbutton_pressed():
	
	get_tree().quit()
