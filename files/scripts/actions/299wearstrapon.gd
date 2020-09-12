extends Node

const category = 'fucking'
const code = 'strapon'
var givers
var takers
const canlast = false
const giverpart = 'strapon'
const takerpart = ''
const virginloss = false
const giverconsent = 'basic'
const takerconsent = 'any'
const givertags = []
const takertags = []

func getname(state = null):
	return "Wear Strap-on"

func getongoingname(givers, takers):
	return "[name1] [is1] wearing a strap-on."

func getongoingdescription(givers, takers):
	return ""

func requirements():
	var valid = true
	if givers.size() < 1:
		valid = false
	for i in givers:
		if i.person.penis != 'none' || i.strapon != null:
			valid = false
	return valid


func initiate():
	return "[name1] put[s/1] on [a /1]strap-on dildo[/s1]."
