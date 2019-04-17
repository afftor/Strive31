extends Panel

onready var undress = get_node("undress")
onready var sprite = get_node("TextureFrame")
onready var charlist = get_node("charlist/VBoxContainer")
onready var eventlist = get_node("eventslist/events")

func _on_nextsprite_pressed():
#warning-ignore:unused_variable
	var temp

func show():
	self.visible = true
	undress.hide()
	sprite.set_texture(null)
	get_node("RichTextLabel").set_bbcode('')
	for i in eventlist.get_children():
		if i != eventlist.get_node("Button"):
			i.visible = false
			i.queue_free()
	for i in charlist.get_children():
		if i != charlist.get_node("Button"):
			i.visible = false
			i.queue_free()
	
	var array = []
	for i in globals.charactergallery.values():
		array.append(i)
	array.sort_custom(globals, 'sortbyname')
	
	for i in array:
		var newbutton = charlist.get_node("Button").duplicate()
		if i.unlocked == false:
			newbutton.set_text("???")
			newbutton.set_disabled(true)
		else:
			newbutton.set_text(i.name.capitalize())
		newbutton.show()
		newbutton.set_meta('character', i)
		newbutton.connect('pressed', self, 'selectchar', [newbutton])
		charlist.add_child(newbutton)


func selectchar(button):
	var character = button.get_meta('character')
	var text = '[center]' + character.name + '[/center]\n\n' + character.descript
	get_node("RichTextLabel").set_bbcode(text)
	for i in charlist.get_children():
		if i.is_pressed() && i != button:
			i.set_pressed(false)
	button.set_pressed(true)
	if character.sprite != 'null':
		sprite.set_texture(globals.spritedict[character.sprite])
		get_node("noimage").visible = false
	else:
		sprite.set_texture(null)
		get_node("noimage").visible = true
	undress.visible = true
	undress.set_pressed(false)
	if character.naked == 'null' || character.nakedunlocked == false:
		undress.set_disabled(true)
	else:
		undress.set_disabled(false)
		undress.set_meta('naked', globals.spritedict[character.naked])
		undress.set_meta('clothed', globals.spritedict[character.sprite])
	for i in eventlist.get_children():
		if i != eventlist.get_node("Button"):
			i.visible = false
			i.free()
	for i in character.scenes:
		var newbutton = eventlist.get_node("Button").duplicate()
		newbutton.visible = true
		newbutton.set_tooltip(i.text)
		if i.unlocked == true:
			newbutton.set_text(i.name)
			newbutton.connect("pressed",self, 'sceneselected', [i.code])
		else:
			newbutton.set_text("???")
			newbutton.set_disabled(true)
		eventlist.add_child(newbutton)
	if eventlist.get_children().size() == 1:
		var label = Label.new()
		label.set_text("No scenes found")
		eventlist.add_child(label)

func sceneselected(scene):
	globals.events.sexscene(scene)



func _on_undress_pressed():
	if undress.is_pressed() == true:
		sprite.set_texture(undress.get_meta("naked"))
	else:
		sprite.set_texture(undress.get_meta("clothed"))


func _on_close_pressed():
	self.visible = false
