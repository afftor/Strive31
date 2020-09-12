
extends HBoxContainer

func getPos():
	var pos = 0
	var id = get_meta('id')
	for person in globals.slaves:
		if id == person.id:
			return pos
		pos += 1
	return -1

func slavetabopen():
	var slavetab = get_tree().get_current_scene().get_node("MainScreen/slave_tab")
	get_tree().get_current_scene().hide_everything()
	get_tree().get_current_scene().currentslave = getPos()
	slavetab.slavetabopen()

func _on_cast_spell_pressed():
	slavetabopen()
	if OS.get_name() != "HTML5" && globals.rules.fadinganimation == true:
		yield(get_tree().get_current_scene(), 'animfinished')

func _on_upbutton_pressed():
	var pos = getPos()
	if pos != 0:
		globals.slaves.insert(pos-1, globals.slaves[pos])
		globals.slaves.remove(pos+1)
		get_tree().get_current_scene().rebuild_slave_list()

func _on_downbutton_pressed():
	var pos = getPos()
	if pos < globals.slaves.size()-1:
		globals.slaves.insert(pos+2, globals.slaves[pos])
		globals.slaves.remove(pos)
		get_tree().get_current_scene().rebuild_slave_list()

func _on_topbutton_pressed():
	var pos = getPos()
	if pos != 0:
		globals.slaves.insert(0, globals.slaves[pos])
		globals.slaves.remove(pos+1)
		get_tree().get_current_scene().rebuild_slave_list()

func _on_bottombutton_pressed():
	var pos = getPos()
	if pos < globals.slaves.size()-1:
		globals.slaves.insert(globals.slaves.size(), globals.slaves[pos])
		globals.slaves.remove(pos)
		get_tree().get_current_scene().rebuild_slave_list()


