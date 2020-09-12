extends Node

const category = 'tools'
const code = 'relaxinginsense'
const order = 12
var givers
var takers
const canlast = true
const giverpart = ''
const takerpart = ''
const virginloss = false
const giverconsent = 'basic'
const takerconsent = 'any'
const givertags = ['noorgasm']
const takertags = ['noorgasm']

func getname(state = null):
	return "Arousing Incense"

func getongoingname(givers, takers):
	return "[name1] use[s/1] arousing incense on [name2]."

func getongoingdescription(givers, takers):
	return ""
	
func requirements():
	var valid = true
	if takers.size() < 1 || givers.size() < 1:
		valid = false
	elif givers.size() > 2:
		valid = false
	return valid

func givereffect(member):
	var result
	var effects = {lust = 25, sens = 10}
	if member.consent == true || (member.person.traits.find("Likes it rough") >= 0 && member.lewd >= 10):
		result = 'good'
	elif member.person.traits.find("Likes it rough") >= 0:
		result = 'average'
	else:
		result = 'bad'
	return [result, effects]

func takereffect(member):
	var result
	var effects = {lust = 75, sens = 20}
	if member.consent == true || (member.person.traits.find("Likes it rough") >= 0 && member.lewd >= 10):
		result = 'good'
	elif member.person.traits.find("Likes it rough") >= 0:
		result = 'average'
	else:
		result = 'bad'
	return [result, effects]

func initiate():
	var text = ''
	var temparray = []
	temparray += ["[name1] {^take:place:shove:stick:hold}[s/1] [names2] face[/s2] {^close to:near} the incense"]
	temparray += ["[name1] activate[s/1] the incense under [names2] nose[/s2]"]
	text += temparray[randi()%temparray.size()]
	temparray.clear()
	temparray += [", {^whispering to:teasing} [him2] about the effects."]
	temparray += [", {^moving:waving} it beneath [his2] nose[/s2]."]
	temparray += [", so that [he2] {^sniff:inhale}[s/2] the {^aroma:scent:odor:perfume.}"]
	text += temparray[randi()%temparray.size()]
	return text

func reaction(member):
	var text = ''
	if member.energy == 0:
		text = "[name2] lie[s/2] unconscious, {^trembling:twitching} {^slightly:weakly} as [his2] {^nose[/s2]:nostrils} [is2] {^flooded:consumed:invaded} with the {^scent:incense:smell}."
	#elif member.consent == false:
		#TBD
	elif member.sens < 100:
		text = "[name2] {^show:give}[s/2] little {^response:reaction} to the {^incense:aroma:perfume}."
	elif member.sens < 400:
		text = "[name2] {^begin:start}[s/2] to {^respond:react} as the {^scent:smell:fragrance} is breathed in."
	elif member.sens < 800:
		text = "[name2] {^shiver[s/2]:shudder[s/2]:relax[es/2]} in {^pleasure:arousal:extacy} as the incense {^fills:invades:spreads through} [his2] sinuses."
	else:
		text = "[names2] bod[y/ies2] {^tremble:quiver}[s/2] {^as the incense permeates [his2] senses:in response to [names2] inhaling}{^ as [he2] rapidly near[s/2] orgasm: as [he2] approach[es/2] orgasm: as [he2] edge[s/2] toward orgasm:}."
	return text
