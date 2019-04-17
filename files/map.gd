extends Control


#warning-ignore:unused_class_variable
var mouse_in = false
#warning-ignore:unused_class_variable
var dragging = false
onready var size = $TextureRect.get_size()
var offset = Vector2()
var status = 'none'
var timer = 0
var currentloc = null


func _ready():
	for i in get_node("TextureRect/roads").get_children() + get_node("TextureRect/towns").get_children():
		i.connect("mouse_entered",self,'showtooltip',[i])
		i.connect("mouse_exited",self,'hidetooltip')

func _input(event):
	if self.is_visible_in_tree() == false:
		return
	if event.is_action_pressed("LMB"):
		var eventpos = event.global_position
		var barpos = $TextureRect.get_global_position()
		size = $TextureRect.get_size()
		var target_rect = Rect2(barpos.x, barpos.y, size.x, size.y)
		if target_rect.has_point(eventpos):
			status = 'clicked'
			offset = barpos - eventpos
	if event.is_action_released("LMB"):
		status = 'none'
	if status == 'clicked' and event.is_class("InputEventMouseMotion"):
		status = 'dragging'
	#centermap('frostford')
	if status == 'dragging':
		$TextureRect.set_global_position(event.global_position+offset)

func _process(delta):
	var rect = $TextureRect.get_global_rect()
	if is_processing_input() == false:
		if timer > 0:
			timer -= delta
		elif timer < 0 && get_parent().get_parent().modulate.a > 0:
			get_parent().get_parent().modulate.a -= delta
	var parentrect = get_parent().get_global_rect()
	if rect.position.x > parentrect.position.x:
		$TextureRect.rect_global_position.x = parentrect.position.x 
	if rect.position.y > parentrect.position.y:
		$TextureRect.rect_global_position.y = parentrect.position.y 
	if rect.end.x < parentrect.end.x:
		$TextureRect.rect_global_position.x += ((parentrect.end.x) - (rect.end.x))
	if rect.end.y < parentrect.end.y:
		$TextureRect.rect_global_position.y += ((parentrect.end.y) - (rect.end.y))


func showtooltip(node):
	if is_processing_input() == false:
		return
	var name = node.get_name()
	var zone = globals.main.get_node('explorationnode').zones[name]
	var text = zone.name
	globals.showtooltip(text)
	for i in zone.exits:
		var sidenode = find_node(i)
		var linesnode = Control.new()
		linesnode.name = 'linesnode'
		get_tree().get_current_scene().add_child(linesnode)
		if sidenode:
			var newnode = Line2D.new()
			get_tree().get_current_scene().get_node('linesnode').add_child(newnode)
			#newnode.width = 3
			#newnode.default_color = Color(1,0.5,0.5,1)
			newnode.texture = load("res://files/buttons/line.png")
			newnode.texture_mode = Line2D.LINE_TEXTURE_TILE
			newnode.add_point(Vector2(node.rect_global_position.x + 8,node.rect_global_position.y + 8))
			newnode.add_point(Vector2(sidenode.rect_global_position.x + 8, sidenode.rect_global_position.y + 8))

func hidetooltip():
	if is_processing_input() == false:
		return
	globals.hidetooltip()
	get_tree().get_current_scene().get_node("linesnode").queue_free()
	

func mapshowup(name):
	var node = find_node(name)
	if node == null || currentloc == name:
		return
	get_parent().get_parent().visible = true
	get_parent().get_parent().modulate.a = 1
	centermap(name)
	timer = 2
	#globals.main.nodefade(self, 1, 2)

func centermap(name):
	var node = find_node(name)
	if node == null:
		return
	var centerscreen = Vector2(get_parent().rect_global_position.x, get_parent().rect_global_position.y) + Vector2(get_parent().rect_size.x/2, get_parent().rect_size.y/2)
	var center = node.rect_global_position
	var nodepos = $TextureRect.rect_global_position
	currentloc = name
	#print(centerscreen-center)
	$TextureRect.set_global_position(nodepos-center+centerscreen)
	$TextureRect/player.set_global_position(Vector2(node.rect_global_position.x+2, node.rect_global_position.y-25))