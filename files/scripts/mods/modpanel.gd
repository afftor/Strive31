extends Panel


var gameDir = globals.gameDir
var modfolder = globals.setfolders.mods
var filedir = globals.fileDir
var backupdir = globals.backupDir
var detailsFile = gameDir + "details.ini"
var saveID = ''

var backupExtensions = ['gd','tscn','scn']

var op_regex_dict = {}
var tag_regex
var file_tag_regex
var tag_add_to = "AddTo"
var tag_remove_from = "RemoveFrom"
var tag_file_new = "CustomFile"
var tag_file_mod = "ModFile"

var temp_mod_scripts = {} #variable to store all original + mod script data before overwrite

var curMod = ''
var scriptEdits = {}  # {'file' : {'header' : [ [startLine, endLine, change, 'mod'] ]} } #zero change is replace 
var logOverlaps = PoolStringArray()
var logErrors = PoolStringArray()
var logUnmatched = PoolStringArray()
var logPatches = {} # {'file' : 'firstMod'}
var retCode #lazy def to avoid many def


var loadorder = []
var activemods = []
var newFiles = PoolStringArray()
var backupVersion = ''

var dir = Directory.new()

func _ready():
#	if globals.developmode == true:
#		return
	var file = File.new()
	for mod in scanfolder():
		if !file.file_exists(mod +"/info.txt"): #makes info.txt to store mod description
			retCode = file.open(mod +'/info.txt', File.WRITE)
			if retCode == OK:
				file.store_line("There's no information on this mod.")
				file.close()
			else:
				handleError("Creating default info.txt for " + mod, retCode)

	loadfromconfig()
	if !dir.dir_exists(backupdir) || str(globals.gameversion) != backupVersion || globals.dir_contents(backupdir).size() <= 0:
		storebackup()
	initRegexs()

func initRegexs():
	var regex_string_dictionary = {
		"FUNC" : "(#.*\\R)*(?<header>(?<!\\V)(static\\h+)?func\\h+\\w+).*\\R(?<body>((\\t.*|#.*)?\\R)*(\\t+\\S.*(\\R|\\Z)))?",
		"VAR" : "(#.*\\R)*(?<header>(?<!\\V)(const|enum|onready\\h+var|var)\\h*\\w+)(?<body>(\\h*:?=\\h*[\\{\\[](.*?[\\}\\]]\\h*(#.*)?|(?<inner>.*(\\R.*)+?)?\\R[\\}\\]](?!\\h*[,\\}\\]]).*)|.*)(\\R|\\Z))",
		"SIGN" : "(#.*\\R)*(?<header>(?<!\\V)signal\\h.*(\\R|\\Z))",
		"CLASS" : "(#.*\\R)*(?<header>(?<!\\V)class\\h+\\w+).*\\R(?<body>((\\t.*|#.*)?\\R)*(\\t+\\S.*(\\R|\\Z)))?",
	}
	var tag_regex_string = "(?<!\\V)<(\\w+)(\\h+\\-?\\d+)?(\\h+\\-?\\d+)?>"
	var file_tag_regex_string = "(?<!\\V)###\\h*<(\\w+)>\\h*###(\\R|\\Z)"

	for key in regex_string_dictionary:
		var newRegex = RegEx.new()
		retCode = newRegex.compile(regex_string_dictionary[key]) 
		if retCode == OK:
			op_regex_dict[key] = newRegex
		else:
			handleError("Compiling '"+key+"' regex", retCode)

	tag_regex = RegEx.new()
	retCode = tag_regex.compile(tag_regex_string)
	handleError("Compiling tag regex", retCode)
	file_tag_regex = RegEx.new()
	retCode = file_tag_regex.compile(file_tag_regex_string)
	handleError("Compiling file tag regex", retCode)


func scanfolder(): #makes an array of all folders in modfolder
	var array = []
	if dir.dir_exists(modfolder) == false:
		retCode = dir.make_dir(modfolder)
		handleError("Making mod directory " + str(modfolder), retCode)
	retCode = dir.open(modfolder)
	if retCode == OK:
		retCode = dir.list_dir_begin(true)
		if retCode == OK:
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir() && !file_name in ['.','..',null]:
					array.append(modfolder + file_name)
				file_name = dir.get_next()
		else:
			handleError("Scanning mod directory " + str(modfolder), retCode)
	else:
		handleError("Opening mod directory " + str(modfolder), retCode)
	return array



func loadfromconfig():
	if !dir.file_exists(detailsFile):
		return
	var config = ConfigFile.new()
	retCode = config.load(detailsFile)
	if retCode == OK:
		loadorder = config.get_value("Mods", "LoadOrder", [])
		activemods = config.get_value("Mods", "ActiveMods", [])
		newFiles = config.get_value("Backup", "NewFiles", PoolStringArray())
		backupVersion = config.get_value("Backup", "Version", '')
		saveID = config.get_value("Saves", "ID", '')
		if saveID.empty():
			globals.saveDir = globals.saveDirDefault
		else:
			globals.saveDir = globals.saveDirDefault.insert(globals.saveDirDefault.length() - 1, "_" + saveID) 
	else:
		handleError("Opening config file " + str(detailsFile), retCode)
	var record = [] #record of unique entries
	for i in loadorder.duplicate():
		if !dir.dir_exists(modfolder + str(i)):
			loadorder.erase(i)
		if i in record:
			loadorder.erase(i)
		else:
			record.append(i)

func saveconfig():
	var config = ConfigFile.new()
	config.set_value("Mods", "LoadOrder", loadorder)
	config.set_value("Mods", "ActiveMods", activemods)
	config.set_value("Backup", "Version", str(globals.gameversion))
	config.set_value("Backup", "NewFiles", newFiles)
	config.set_value("Saves", "ID", saveID)
	retCode = config.save(detailsFile)
	handleError("Saving config file " + detailsFile, retCode)

func storebackup(): #clears and creates backups
	print("Making Backup...")
	if dir.dir_exists(backupdir):
		for path in globals.dir_contents(backupdir):
			retCode = dir.remove(path)
			handleError("Deleting file " + str(path), retCode)
	for path in globals.dir_contents(filedir):
		if !path.get_extension() in backupExtensions:
			continue
		var destPath = path.replacen(gameDir, backupdir)
		if !dir.dir_exists( destPath.get_base_dir()):
			dir.make_dir_recursive( destPath.get_base_dir())
		retCode = dir.copy(path, destPath)
		handleError("Copying backup file " + str(path), retCode)
	newFiles = PoolStringArray()
	saveconfig()
	print("Backup finished.")


func loadbackup():
	if !dir.dir_exists(backupdir):
		return true
	print("Removing New Files...")
	for path in newFiles:
		retCode = dir.remove(path)
		handleError("Deleting new file " + path, retCode)
	activemods.clear()
	newFiles = PoolStringArray()
	saveconfig()

	print("Remove Finished\nLoading Backup...")
	var errorFree = true
	for path in globals.dir_contents(backupdir):
		var destPath = path.replacen(backupdir, gameDir)
		retCode = dir.copy(path, destPath)
		if retCode != OK:
			handleError("Resetting file " + destPath, retCode)
			errorFree = false	
	print("Load Finished")
	return errorFree

func handleError(msg, code):
	if code != OK:
		if curMod.empty():
			logErrors.append("ERROR: " + msg + " (" + globals.errorText[code] + ")")
		else:
			logErrors.append("ERROR("+ curMod +"): " + msg + " (" + globals.errorText[code] + ")")
		globals.printErrorCode(msg, code)

func displayReport(afterMod = true):
	var text 
	if afterMod:
		text = "Mod list has been changed. Game must close for changes to take effect."
	else:
		text = "Errors in the mod system have been detected."
	if logErrors.size() == 0:
		text += "\n\n[color=green]No errors recorded.[/color]"
	else:
		text += "\n\n[color=red]The following errors were recorded:[/color]\n" + logErrors.join('\n')
		logErrors = PoolStringArray()

	var textAdd = ''
	if logUnmatched.size() > 0:
		textAdd += "\nScript files unique to mod (these scripts have a new relative path compared to game files):\n" + logUnmatched.join('\n')
		logUnmatched = PoolStringArray()
	if logOverlaps.size() > 0:
		textAdd += "\n\n[color=orange]The following overlaps were recorded:[/color]\n" + logOverlaps.join('\n')
		logOverlaps = PoolStringArray()
	if newFiles.size() > 0:
		textAdd += "\n\n[color=orange]The following new files were added by patches:[/color]\n" + newFiles.join('\n')

	if !textAdd.empty():
		text += "\n\n[color=#6680ff]Additional Mod Installation Information:\nThese are not errors, but may indicate the source of install problems.[/color]" + textAdd
	$restartpanel/RichTextLabel.bbcode_text = text
	$restartpanel.show()

func _on_applymods_pressed():
	if !globals.developmode:
		if !loadbackup():
			saveconfig()
			displayReport(false)
			return
	for mod in loadorder:
		var modPath = modfolder + mod + "/"
		if dir.dir_exists(modPath):
			activemods.append(mod)
			curMod = mod
			apply_mod_to_dictionary(modPath)
	scriptEdits = {}
	curMod = ''
	apply_mod_dictionary()
	saveconfig()
	displayReport()

func apply_mod_dictionary():
	for i in temp_mod_scripts:
		var core_file = File.new()
		retCode = core_file.open(i, File.WRITE)
		if retCode == OK:
			core_file.store_string(temp_mod_scripts[i])
			core_file.close()
		else:
			handleError("Modding file " + str(i), retCode)
	temp_mod_scripts.clear()

func patchFile(sourcePath, destPath):
	if destPath == detailsFile:
		handleError("Patching '" + destPath + "' has been blocked for safety.", ERR_FILE_NO_PERMISSION)
		return
	if logPatches.has(destPath):
		logOverlaps.append("Patches: " + destPath + "\n     " + logPatches[destPath] + ", " + curMod)
	else:
		logPatches[destPath] = curMod
	if dir.file_exists(destPath):
		if destPath.ends_with(".gd"):
			temp_mod_scripts.erase(destPath)
			if scriptEdits.has(destPath):
				scriptEdits.erase(destPath)
				logOverlaps.append("Patched over changes: " + destPath + ", " + curMod)
		if !destPath.get_extension() in backupExtensions && !destPath in newFiles:
			retCode = dir.copy(destPath, destPath.replacen(gameDir, backupdir))
			handleError("Copying backup file " + str(destPath), retCode)
	else:
		newFiles.append(destPath)
	retCode = dir.copy(sourcePath, destPath)
	handleError("Patching file " + destPath, retCode)

func apply_mod_to_dictionary(modPath):
	var file = File.new()
	var patchSource = modPath + "patch/"
	if dir.dir_exists(patchSource):
		for path in globals.dir_contents(patchSource):
			patchFile(path, path.replacen(patchSource, gameDir))
	for path in globals.dir_contents(modPath):
		if path.begins_with(patchSource):
			continue
		if path.ends_with(".gd"):
			var curFileTag = null
			var modText = ''
			retCode = file.open(path, File.READ)
			if retCode == OK:
				modText = file.get_as_text()
				file.close()
			else:
				handleError("Reading mod script " + str(path), retCode)

			var tag = file_tag_regex.search(modText)
			if tag != null:
				if tag.get_string(1) == tag_file_new || tag.get_string(1) == tag_file_mod:
					curFileTag = tag.get_string(1)
				else:
					handleError("ERROR: '" + str(tag.get_string(1)) + "' file tag not supported.", ERR_BUG)

			var destPath = path.replacen(modPath, filedir)
			if !modText.empty() && file.file_exists(destPath):
				apply_file_to_dictionary(destPath, modText)
				if curFileTag == tag_file_new:
					handleError("Relative path for file '" +str(path)+ "' tagged as '"+tag_file_new+"' matches a game file", ERR_FILE_BAD_PATH)
			else:
				if curFileTag == tag_file_mod:
					handleError("Relative path for file '" +str(path)+ "' tagged as '"+tag_file_mod+"' does not match a game file", ERR_FILE_BAD_PATH)
				elif curFileTag == null:
					logUnmatched.append(str(path))

# returns [lineNumber, column] for the given offset of given string, the start point can be altered through lineNum and startOffset
func getLinePos(string, endOffset, lineNum = 1, startOffset = -1):
	while true:
		var temp = string.find('\n', startOffset + 1)
		if temp == -1 || temp > endOffset:
			return [lineNum, endOffset - startOffset]
		else:
			startOffset = temp
			lineNum += 1

func apply_file_to_dictionary(file_name, string):
	if !temp_mod_scripts.has(file_name):
		var file = File.new()
		retCode = file.open(file_name, File.READ)
		if retCode == OK:
			temp_mod_scripts[file_name] = file.get_as_text()
			file.close()
		else:
			handleError("Reading file " + str(file_name), retCode)
	var offset = 0
	while offset != -1 :
		var newOffset = apply_next_element_to_dictionary(file_name, string, offset)
		if newOffset == null:
			var pos = getLinePos(string, offset)
			handleError("WARNING: error occurred while modding file " + str(file_name) + ", skipped rest of file. Ended on line: " + str(pos[0]) + ", Column: " + str(pos[1]), ERR_BUG)
			return
		else:
			offset = newOffset

func replaceOnce(strFile, matchTarget, newText):
	strFile.erase(matchTarget.get_start(), matchTarget.get_string().length())
	return strFile.insert(matchTarget.get_start(), newText)

func changeToText(modName, startLine, change):
	var text = "\n     " + curMod + ": "
	if change == 0:
		return text + "Replace all"
	text += "line " + str(startLine - 1) + ", "
	if change > 0:
		return text + "Add " + str(change)
	else:
		return text + "Remove " + str(-change)

#var scriptEdits = {}  # {'file' : {'header' : [ [startLine, endLine, change, 'mod'] ]} } #zero change is replace
func addEditRecord(file, header, startLine, endLine, change):
	if !scriptEdits.has(file):
		scriptEdits[file] = {header : []}
	elif !scriptEdits[file].has(header):
		scriptEdits[file][header] = []
	var ref = scriptEdits[file][header]
	for entry in ref:
		if endLine >= entry[0] && startLine <= entry[1] && curMod != entry[3]:
			logOverlaps.append(file + ": " + header + changeToText(entry[3], entry[0], entry[2]) + changeToText(curMod, startLine, change))
	if change == 0:
		ref.clear()
	ref.append([startLine, endLine, change, curMod])

func adjustForEdit(file, header, startLine):
	var ref = scriptEdits.get(file, {}).get(header)
	if ref == null:
		return startLine
	for entry in ref:
		if startLine >= entry[0] && entry[2] != 0: #overlap is undefined, after is simple add
			if startLine > entry[1] || entry[2] > 0:
				startLine += entry[2]
			else: # startLine has been removed, move back to first line still present
				startLine = entry[0]
	return startLine

#fixes the gain of an extra line from normal split + join of string for add or remove tags
#second arg determines whether the front or the back is checked for extra line
func customSplit(string, front = false):
	var pool_string = string.split('\n')
	var idx = 0 if front else pool_string.size() - 1
	if pool_string[idx].empty():
		pool_string.remove(idx)
	return pool_string

func apply_next_element_to_dictionary(path, modText, offset):
	var has_next = false
	var which_operation = "NULL"
	var current_match
	var new_offset = 0
	
	for op in op_regex_dict:
		var next_match = op_regex_dict[op].search(modText, offset)
		if next_match != null && (new_offset == 0 || new_offset > next_match.get_start()) && next_match.get_start() > -1:
			new_offset = next_match.get_start()
			current_match = next_match
			which_operation = op
			has_next = true
	
	var next_tag = tag_regex.search(modText, offset)
	if has_next && (next_tag == null || new_offset <= next_tag.get_start() || next_tag.get_start() == -1):
		var found_match = false
		for nested_match in op_regex_dict[which_operation].search_all(temp_mod_scripts[path]):
			if(current_match.get_string("header") == nested_match.get_string("header")):
				addEditRecord(path, nested_match.get_string("header"), 0, getLinePos(current_match.get_string(), current_match.get_string().length())[0], 0)
				temp_mod_scripts[path] = replaceOnce(temp_mod_scripts[path], nested_match, current_match.get_string())
				found_match = true
		if !found_match:
			temp_mod_scripts[path] = temp_mod_scripts[path] + "\n\n" + current_match.get_string()
	elif has_next:
		if next_tag.get_string(1) == tag_add_to:
			var param = max(0, next_tag.get_string(2).to_int() + 1)
			if param == 0:
				param = -1
			
			for nested_match in op_regex_dict[which_operation].search_all(temp_mod_scripts[path]):
				if current_match.get_string("header") != nested_match.get_string("header"):
					continue
				var pool_string = nested_match.get_string().split('\n')
				var startSize = pool_string.size()
				var startLine = param
				var match_stripped = current_match.get_string("body")
				var endIdx = startSize

				if which_operation in ["FUNC",'CLASS']:
					match_stripped = customSplit(match_stripped)
				elif which_operation == "VAR":
					var pos = match_stripped.find('\n')
					if pos != -1 && pos < match_stripped.length() - 1:
						match_stripped = current_match.get_string("inner")
					match_stripped = customSplit(match_stripped, true)
					endIdx -= 2 if (startSize > 2) else 1
				else: # operation not supported
					break

				if param > 0:
					param = adjustForEdit(path, nested_match.get_string("header"), param)
					if param >= endIdx:
						param = endIdx
						startLine = param
				else:
					param = endIdx
					startLine = param
				for i in match_stripped:
					pool_string.insert(param, i)
					param += 1
				addEditRecord(path, nested_match.get_string("header"), startLine, startLine, pool_string.size() - startSize)
				temp_mod_scripts[path] = replaceOnce(temp_mod_scripts[path], nested_match, pool_string.join("\n"))
				break
		elif next_tag.get_string(1) == tag_remove_from:
			var param = max(1, next_tag.get_string(2).to_int() + 1)
			var param_2 = max(1, next_tag.get_string(3).to_int() + 1)
			var startLine = param
			for nested_match in op_regex_dict[which_operation].search_all(temp_mod_scripts[path]):
				if current_match.get_string("header") != nested_match.get_string("header"):
					continue
				param = adjustForEdit(path, nested_match.get_string("header"), param)
				param_2 = adjustForEdit(path, nested_match.get_string("header"), param_2)
				var new_string = nested_match.get_string().split('\n')
				var startSize = new_string.size()
				for i in range(0, param_2 - param + 1):
					if param < new_string.size():
						new_string.remove(param)
				addEditRecord(path, nested_match.get_string("header"), startLine, startLine + startSize - new_string.size() - 1, new_string.size() - startSize)
				temp_mod_scripts[path] = replaceOnce(temp_mod_scripts[path], nested_match, new_string.join("\n"))
				break
		elif next_tag.get_string(1) == tag_file_new || next_tag.get_string(1) == tag_file_mod:
			handleError("ERROR: '" + str(next_tag.get_string(1)) + "' is a file tag, not a mod operation tag", ERR_BUG)
			return next_tag.get_end()
		else:
			# operation not supported
			handleError("ERROR: '" + str(next_tag.get_string(1)) + "' tag not supported.", ERR_BUG)
			return next_tag.get_end()
	if has_next:
		 return current_match.get_end()
	else:
		 return -1

func _on_disablemods_pressed():
	loadorder.clear()
	var result = loadbackup()
	saveconfig()
	displayReport(result)


func _on_Mods_pressed():
	self.visible = !self.visible
	show()

func show():
	modfolder = globals.setfolders.mods
	$modfolder.text = modfolder
	$modfolder.hint_tooltip = "Select new location for mod folder. Current location:\n" + ProjectSettings.globalize_path(modfolder)

	$saveFolderID.text = saveID
	$saveFolderID.hint_tooltip = "Current save folder:\n" + ProjectSettings.globalize_path(globals.saveDir)
	
	for i in $allmodscontainer/VBoxContainer.get_children():
		if i.name != 'Button':
			i.hide()
			i.queue_free()
	var array = []
	for i in scanfolder():
		array.append(i.replacen(modfolder,""))
	array.sort_custom(self, 'sortmods')
	for i in array:
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
	if logErrors.size() > 0:
		displayReport(false)

func sortmods(first,second):
	var index1 = loadorder.find(first)
	var index2 = loadorder.find(second)
	if index1 == index2:
		return first < second
	if index1 < index2:
		return index1 != -1
	return index2 == -1

func moddescript(mod):
	var text = ''
	var file = File.new()
	retCode = file.open(modfolder + mod + '/info.txt', File.READ)
	if retCode == OK:
		text = file.get_as_text()
		file.close()
	else:
		handleError("Reading file " + str(modfolder + mod + '/info.txt'), retCode)
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

func modup(mod):
	var order = loadorder.find(mod)
	loadorder.erase(mod)
	if order == 0:
		loadorder.insert(order, mod)
	else:
		loadorder.insert(order-1, mod)
	show()

func moddown(mod):
	var order = loadorder.find(mod)
	loadorder.erase(mod)
	if order + 1 > loadorder.size():
		loadorder.append(mod)
	else:
		loadorder.insert(order+1, mod)
	show()

func _on_closemods_pressed():
	self.visible = false
	saveconfig()

func _on_FileDialog_dir_selected(path):
	path = path.replace(OS.get_user_data_dir(), "user:/")
	if !path.ends_with("/"):
		path += "/"
	globals.modfolder = path
	globals.setfolders.mods = path
	show()

func _on_saveFolderID_text_changed(textID):
	var pos = $saveFolderID.caret_position
	var length = textID.length()
	for symbol in ['/', '\\', '<', '>', ':', '"', '|', '?', '*']:
		textID = textID.replace(symbol, "")
	saveID = textID
	if length != textID.length():
		$saveFolderID.text = textID
		$saveFolderID.caret_position = pos - (length - textID.length())
	if saveID.empty():
		globals.saveDir = globals.saveDirDefault
	else:
		globals.saveDir = globals.saveDirDefault.insert(globals.saveDirDefault.length() - 1, "_" + saveID) 
	$saveFolderID.hint_tooltip = "Current save folder:\n" + ProjectSettings.globalize_path(globals.saveDir)

func _on_modfolder_pressed():
	$FileDialog.current_dir = ProjectSettings.globalize_path(modfolder)
	$FileDialog.popup()

func _on_helpclose_pressed():
	$Panel.hide()

func _on_modhelp_pressed():
	$Panel.show()

func _on_openmodfolder_pressed():
	globals.shellOpenFolder(modfolder)

func _on_activemods_pressed():
	var text = '\n'
	for i in activemods:
		text += i + '\n'
	$activemodlist/RichTextLabel.bbcode_text = text
	$activemodlist.popup()

func _on_restartbutton_pressed():
	get_tree().quit()

func _on_continuebutton_pressed():
	$restartpanel.hide()
	show()
