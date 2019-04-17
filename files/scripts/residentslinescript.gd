
extends HBoxContainer

func slavetabopen():
	var slavetab = get_tree().get_current_scene().get_node("MainScreen/slave_tab")
	get_tree().get_current_scene().hide_everything()
	get_tree().get_current_scene().currentslave = int(get_meta('pos'))
	slavetab.slavetabopen()



func _on_cast_spell_pressed():
	slavetabopen()
	if OS.get_name() != "HTML5" && globals.rules.fadinganimation == true:
		yield(get_tree().get_current_scene(), 'animfinished')



func _on_upbutton_pressed():
	var pos = get_meta('pos')
	if pos != 0:
		globals.slaves.insert(pos-1, globals.slaves[pos])
		globals.slaves.remove(pos+1)
		get_tree().get_current_scene().rebuild_slave_list()


func _on_downbutton_pressed():
	var pos = get_meta('pos')
	if pos < globals.slaves.size()-1:
		globals.slaves.insert(pos+2, globals.slaves[pos])
		globals.slaves.remove(pos)
		get_tree().get_current_scene().rebuild_slave_list()

func _on_topbutton_pressed():
	var pos = get_meta('pos')
	if pos != 0:
		globals.slaves.insert(0, globals.slaves[pos])
		globals.slaves.remove(pos+1)
		get_tree().get_current_scene().rebuild_slave_list()

func _on_bottombutton_pressed():
	var pos = get_meta('pos')
	if pos < globals.slaves.size()-1:
		globals.slaves.insert(globals.slaves.size(), globals.slaves[pos])
		globals.slaves.remove(pos)
		get_tree().get_current_scene().rebuild_slave_list()


