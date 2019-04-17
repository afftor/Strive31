extends WindowDialog

var mode = 'portrait' setget mode_set
var person

var portaitsbuilt = false
#warning-ignore:unused_class_variable
var bodybuilt = false
var portraitspath = globals.setfolders.portraits
var bodypath = globals.setfolders.fullbody
var thumbnailpath = "user://thumbnails/"

func _ready():
#warning-ignore:return_value_discarded
	get_node("ScrollContainer/_v_scroll").connect("value_changed", self, "_on_scroll")

func mode_set(value):
	if mode != value:
		mode = value
		portaitsbuilt = false

func chooseimage():
	if get_node("racelock").is_pressed() == false:
		get_node("search").visible = true
		get_node("search").set_text("")
	else:
		get_node("search").visible = false
	popup()
	if portaitsbuilt == false:
		portaitsbuilt = true
		buildimagelist(mode)
	resort()


func _on_reloadlist_pressed():
	buildimagelist(mode)

var currentpath 

func buildimagelist(type = mode):
	var dir = Directory.new()
#warning-ignore:unused_variable
	var array = []
	var filecheck = File.new()
	if type == 'portrait':
		currentpath = portraitspath
	else:
		currentpath = bodypath
	for i in get_node("ScrollContainer/GridContainer").get_children():
		if i.get_name() != "Button":
			i.visible = false
			i.free()
	if dir.dir_exists(currentpath) == false:
		dir.make_dir(currentpath)
	if dir.dir_exists(thumbnailpath) == false:
		dir.make_dir(thumbnailpath)
	if dir.dir_exists(thumbnailpath + type) == false:
		dir.make_dir(thumbnailpath + type)
	for i in globals.dir_contents(currentpath):
		if filecheck.file_exists(i) && (i.find('.png') >= 0 || i.find('.jpg') >= 0):
			var node = get_node("ScrollContainer/GridContainer/Button").duplicate()
			var iconpath = i.replace(currentpath, thumbnailpath + type)
			node.set_meta('thumbnail', iconpath)
			if !filecheck.file_exists(iconpath) && globals.rules.thumbnails == true:
				createimagethumbnail(i, iconpath)
			get_node("ScrollContainer/GridContainer").add_child(node)
			#node.get_node("pic").set_texture(globals.loadimage(iconpath))
			node.connect('pressed', self, 'setslaveimage', [i])
			node.get_node("Label").set_text(i.replacen(currentpath + '/','').replacen('.jpg','').replacen('.png',''))
			node.set_meta("type", i)
			node.set_meta("loaded", false)
	$ScrollContainer/GridContainer.move_child($ScrollContainer/GridContainer/Button, $ScrollContainer/GridContainer.get_children().size())
	resort()

func createimagethumbnail(originpath, newpath):
	var image = Image.new()
	image.load(originpath)
	image.resize(100, 100)
	var filepath = originpath.replace(bodypath, '').replace(portraitspath, '')
	filepath = Array(filepath.split('/'))
	for i in filepath:
		if i.findn('.jpg') != -1 || i.findn('.png') != -1:
			filepath.erase(i)
	var workingpath = thumbnailpath + mode
	for i in filepath:
		if !workingpath.ends_with('/'):
			workingpath += '/'
		workingpath += i
		var dir = Directory.new()
		if dir.dir_exists(workingpath) == false:
			dir.make_dir(workingpath)
		
	image.save_png(newpath)

func resort():
	var strictsearch = get_node("racelock").is_pressed()
	var gender = person.sex
	var race = person.race
	var counter = 0
	if gender == 'futanari':
		gender = 'female'
	race = race.replace("Beastkin ", "").replace("Halfkin ", "")

	
	
	
	for i in get_node("ScrollContainer/GridContainer").get_children():
		i.hide()
		if i == get_node("ScrollContainer/GridContainer/Button"):
			continue
		if strictsearch == true:
			if i.get_meta('type').findn(race) < 0:
				continue 
		if strictsearch == false && get_node("search").get_text() != '' && i.get_node("Label").get_text().findn(get_node("search").get_text()) < 0:
			continue
		i.show()
		counter += 1
	if counter < 1:
		get_node("noimagestext").visible = true
	else:
		get_node("noimagestext").visible = false

func setslaveimage(path):
	if mode == 'portrait':
		person.imageportait = path
		if $assignboth.pressed && globals.loadimage(path.replace("portraits", 'bodies')) != null:
			person.imagefull = path.replace("portraits",'bodies')
	elif mode == 'body':
		person.imagefull = path
		if $assignboth.pressed && globals.loadimage(path.replace("bodies","portraits")) != null:
			person.imageportait = path.replace('bodies',"portraits")
	self.visible = false
	updatepage()



func _on_cancelportait_pressed():
	self.visible = false


func _on_racelock_pressed():
	chooseimage()
	resort()


#warning-ignore:unused_argument
func _on_search_text_changed( text ):
	resort()

func _on_removeportrait_pressed():
	if mode == 'portrait':
		person.imageportait = null
	elif mode == 'body':
		person.imagefull = null
	self.visible = false
	updatepage()

func _on_reverseportrait_pressed():
	if person.unique != null:
		if person.unique == 'Cali':
			person.imageportait = globals.characters.characters.Cali.imageportait
		elif person.unique == 'Emily':
			person.imageportait = globals.characters.characters.Emily.imageportait
		elif person.unique == 'Tisha':
			person.imageportait = globals.characters.characters.Tisha.imageportait
		elif person.unique == 'Chloe':
			person.imageportait = globals.characters.characters.Chloe.imageportait
		elif person.unique == 'Yris':
			person.imageportait = globals.characters.characters.Yris.imageportait
		elif person.unique == 'Maple':
			person.imageportait = globals.characters.characters.Maple.imageportait
		elif person.unique == 'Ayneris':
			person.imageportait = globals.characters.characters.Ayneris.imageportait
		elif person.unique == 'Melissa':
			person.imageportait = globals.characters.characters.Melissa.imageportait
		elif person.unique == 'Ayda':
			person.imageportait = globals.characters.characters.Ayda.imageportait
		self.visible = false
		person.imagefull = null
		updatepage()



func _on_addcustom_pressed():
	get_node("FileDialog").popup()

func _on_FileDialog_file_selected( path ):
	var dir = Directory.new()
	var path2 = path.substr(path.find_last('/'), path.length()-path.find_last('/'))
	dir.copy(path, portraitspath + path2)
	buildimagelist()

func _on_openfolder_pressed():
#warning-ignore:return_value_discarded
	OS.shell_open(OS.get_user_data_dir())

func updatepage():
	if person == globals.player:
		get_tree().get_current_scene()._on_selfbutton_pressed()
	else:
		get_tree().get_current_scene().get_node("MainScreen/slave_tab").slavetabopen()
		get_tree().get_current_scene().rebuild_slave_list()


func _on_selectfolder_pressed():
	get_node("selectfolders").popup()
	get_node("selectfolders/chooseportraitolder").set_text(globals.setfolders.portraits)
	get_node("selectfolders/choosebodyfolder").set_text(globals.setfolders.fullbody)


func _on_chooseportraitolder_pressed():
	get_node("folderdialogue").set_meta('meta', "portrait")
	get_node("folderdialogue").popup()
	if portraitspath.find('user://') >= 0:
		get_node("folderdialogue").set_current_path(OS.get_data_dir() + '/' +portraitspath.replace("user://", ''))
	else:
		get_node("folderdialogue").set_current_path(portraitspath)
	

func _on_choosebodyfolder_pressed():
	get_node("folderdialogue").set_meta('meta', "body")
	get_node("folderdialogue").popup()
	if bodypath.find('user://') >= 0:
		get_node("folderdialogue").set_current_path(OS.get_data_dir() + '/' +bodypath.replace("user://", ''))
	else:
		get_node("folderdialogue").set_current_path(bodypath)

func _on_folderdialogue_dir_selected( dir ):
	if get_node("folderdialogue").get_meta("meta") == 'portrait':
		globals.setfolders.portraits = dir
		portraitspath = dir
		buildimagelist()
		_on_selectfolder_pressed()
	elif get_node("folderdialogue").get_meta("meta") == 'body':
		globals.setfolders.fullbody = dir
		bodypath = dir
		buildimagelist()
		_on_selectfolder_pressed()


func _on_closefolderselect_pressed():
	get_node("selectfolders").visible = false

func _on_scroll(value):
	var scrolled_top = value
	var scrolled_bottom = scrolled_top + get_node("ScrollContainer").get_size().y
	for node in get_node("ScrollContainer/GridContainer").get_children():
		if node.is_visible_in_tree() && !node.get_meta("loaded"):
			var node_rect = node.get_rect()
			var node_top = node_rect.position.y
			var node_bottom = node_rect.end.y
			if (node_top >= scrolled_top && node_top < scrolled_bottom) || (node_bottom >= scrolled_top && node_bottom < scrolled_bottom):
				if globals.rules.thumbnails == true:
					node.get_node("pic").set_texture(globals.loadimage(node.get_meta("thumbnail")))
				else:
					node.get_node("pic").set_texture(globals.loadimage(node.get_meta("type")))
				node.set_meta("loaded", true)
