extends Control

func _ready():
	pass



func _on_Button_pressed():
	$edittree.show_("races")


func _on_BodypartsButton_pressed():
	$edittree.show_('bodyparts')


func _on_racetree_item_rmb_edited():
	pass # replace with function body

func editarray(array):
	$EditArray.show_(array)