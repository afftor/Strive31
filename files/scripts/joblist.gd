extends Popup

var currentslave 
var jobdict = globals.jobs.jobdict
#QMod - Variables
const StaffJobs = ['cooking', 'maid', 'nurse', 'headgirl', 'jailer', 'farmmanager']
var mansionStaff = {'headslave' : null, 'jailer' : null, 'alchemyAssistant' : null, 'librarian' : null, 'labAssistant' : null, 'farmManager' : null, 'cook' : null, 'nurse' : null, 'maid' : []}
var takenjobs = {}
func sortjobs(first,second):
	if first.order < second.order:
		return true
	else:
		return false


func joblist():
	currentslave = globals.currentslave
	var array = []
	var basic = get_node("jobs/VBoxContainer")
	for i in basic.get_children():
		if i != get_node("jobs/VBoxContainer/Button"):
			i.visible = false
			i.queue_free()
	get_node("tooltiptext").set_bbcode("")
	show()
	takenjobs.clear()
	for i in jobdict.values():
		array.append(i)
	array.sort_custom(self, 'sortjobs')
	for i in array:
		if globals.evaluate(i.unlockreqs) == true:
			var newbutton = get_node("jobs/VBoxContainer/Button").duplicate()
			var locked
			for k in globals.state.portals.values():
				if i.tags.find(k.code) >= 0 && k.enabled == false && globals.state.location != k.code:
					locked = true
			if locked == true:
				continue
			newbutton.visible = true
			newbutton.set_text(i.name)
			basic.add_child(newbutton)
			if currentslave.work == i.code:
				basic.move_child(newbutton,0)
			#dict[i.type].add_child(newbutton)
			if currentslave.work == i.code:
				newbutton.set('custom_colors/font_color', Color(0,1,0,1))
			if globals.evaluate(i.reqs) == false:
				newbutton.set_disabled(true)
				newbutton.set_tooltip(currentslave.dictionary("$name is not suited for this work"))
			if i.tags.find('sex') >= 0 && i.code != 'fucktoy':
				if !globals.currentslave.bodyshape in ['humanoid', 'bestial', 'shortstack']:
					newbutton.set_disabled(true)
					newbutton.set_tooltip(currentslave.dictionary("This occupation only allows humanoid currentslaves. "))
				elif currentslave.tags.find('nosex') >= 0:
					newbutton.set_disabled(true)
					newbutton.set_tooltip(currentslave.dictionary("$name refuses to participate in sexual activities at this moment. "))
				elif currentslave.traits.has("Monogamous") || currentslave.traits.has("Prude"):
					newbutton.set_disabled(true)
					newbutton.set_tooltip(currentslave.dictionary("$name refuses to whore $himself."))
			if i.tags.find('social') >= 0:
				if currentslave.traits.has('Uncivilized') || currentslave.traits.has('Regressed'):
					newbutton.set_disabled(true)
					newbutton.set_tooltip(currentslave.dictionary("$name is not suited to work in social circles. "))
			if i.tags.find("management") >= 0:
				if currentslave.traits.has("Passive"):
					newbutton.set_disabled(true)
					newbutton.set_tooltip(currentslave.dictionary("$name is not suited for leading roles. "))
					
		
			if i.maxnumber >= 1:
				var counter = 0
				for tempslave in globals.slaves:
					if tempslave.work == i.code:
						takenjobs[i] = tempslave
						counter += 1
				if counter >= i.maxnumber:
					#newbutton.set_disabled(true)
					
					newbutton.set_tooltip("This occupation is already taken")
			newbutton.set_meta("job", i)
			newbutton.connect('pressed', self, 'choosejob', [newbutton])
			newbutton.connect("mouse_entered",self,'jobtooltipshow',[newbutton])
			#newbutton.connect("mouse_exit",self,'jobtooltiphide')

var chosenbutton

func choosejob(button):
	var oldJob = currentslave.work
	chosenbutton = button
	var curjob = button.get_meta('job')
	if takenjobs.has(curjob):
		get_parent().yesnopopup(takenjobs[curjob].name_short() + takenjobs[curjob].dictionary(" currently assigned to this occupation. Replace $him?"), 'confirmjob', self)
		return
	currentslave.work = curjob.code
	
	#QMod - Staff Jobs
	if oldJob in StaffJobs: #Clear old job
		match oldJob:
			'cooking':
				mansionStaff.cook = null
			'nurse':
				mansionStaff.nurse = null
			'headgirl':
				mansionStaff.headslave = null
			'jailer':
				mansionStaff.jailer = null
			'farmmanager':
				mansionStaff.farmManager = null
			'maid':
				mansionStaff.maid.erase(currentslave)
	if currentslave.work in StaffJobs: #Assign new job
		match currentslave.work:
			'cooking':
				mansionStaff.cook = currentslave
			'nurse':
				mansionStaff.nurse = currentslave
			'headgirl':
				mansionStaff.headslave = currentslave
			'jailer':
				mansionStaff.jailer = currentslave
			'farmmanager':
				mansionStaff.farmManager = currentslave
			'maid':
				mansionStaff.maid.append(currentslave)
	_on_jobcancel_pressed()
	get_tree().get_current_scene().slavepanel.slavetabopen()
	if get_tree().get_current_scene().get_node("slavelist").is_visible():
		get_tree().get_current_scene().slavelist()

func jobtooltipshow(button):
	var job = button.get_meta('job')
	var text = '[center]' + job.name + '[/center]\n' + job.description
	if job.location in ['wimborn','gorn','frostford']:
		text += "\n\nWork town: " + job.location.capitalize()
		for i in globals.state.reputation:
			if i == job.location:
				text += "\nAffiliation: " + get_parent().reputationword(globals.state.reputation[i])
	get_node("tooltiptext").set_bbcode(currentslave.dictionary(text))

func confirmjob():
	var job = chosenbutton.get_meta('job')
	takenjobs[job].work = 'rest'
	takenjobs.erase(job)
	choosejob(chosenbutton)

func _on_jobcancel_pressed():
	self.visible = false
