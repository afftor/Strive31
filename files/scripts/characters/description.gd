extends Node

var person
var showmode = 'default'

func getslavedescription(tempperson, mode = 'default'):
	showmode = mode
	person = tempperson
	var text = basics() + features() + genitals() + mods() + tattoo() + piercing()
	if person.customdesc != '':
		text += '\n\n' + person.customdesc
	if person == globals.player:
		text = person.dictionaryplayerplus(person.dictionaryplayer(text))
	else:
		text = person.dictionary(text)
	
	if text.find('[furcolor]'):
		text = text.replace('[furcolor]', getdescription('furcolor'))
	
	
	return text

func basics():
	var text = ''
	if showmode == 'default':
		text += "[url=basic][color=#d1b970]Basics:[/color][/url] "
	if globals.state.descriptsettings.basic == true || showmode != 'default':
		text += entry() + race() + getdescription('bodyshape') + getdescription('age') + getbeauty()
	else:
		text += "[color=yellow]$name, [url=race]" + person.race + "[/url], " + person.age.capitalize() +'[/color]. '
	return text

func features():
	var text = '\n'
	if showmode == 'default':
		text += '[url=appearance][color=#d1b970]Appearance:[/color][/url] '
	if globals.state.descriptsettings.appearance == true || showmode != 'default':
		text = "\n" + text
		text += getdescription('hairlength') + getdescription('hairstyle') + getdescription("eyecolor") + getdescription("eyeshape") + getdescription('horns') + getdescription('ears') + getdescription('skin') + getdescription("skincov") + getdescription("wings") + getdescription("tail") + getdescription("height")
	else:
		text += "Omitted. "
	return text

func genitals():
	var text = '\n'
	if showmode == 'default':
		text += '[url=genitals][color=#d1b970]Privates:[/color][/url] '
	if globals.state.descriptsettings.genitals == true || showmode != 'default':
		text = "\n" + text + getdescription("titssize") + gettitsextra() + getdescription("asssize") + lowergenitals()
		if person.preg.duration > variables.pregduration/1.5:
			text += "\n\n$His unborn child forces $his belly to protrude massively; $he will give birth soon."
		elif person.preg.duration > variables.pregduration/2:
			text += "\n\n$His advanced pregnancy is clearly evident by the prominent bulge in $his belly."
		elif person.preg.duration > variables.pregduration/4:
			text += "\n\n$His unborn fetus causes $his belly to bulge slightly."
		if person.preg.has_womb == false && person.sex != 'male':
			text += "\n\n[color=yellow]$name's womb is sterile.[/color]"
	else:
		text += "Omitted. "
	
	return text

func lowergenitals():
	var text = ''
	if person.vagina == 'normal':
		if person.vagvirgin == true:
			text = '$He has a tight, [color=yellow]virgin pussy[/color]. '
		else:
			text = '$He has a [color=yellow]normal pussy[/color] below $his waist. '
	if person.penis != 'none':
		var temp = person.penistype + '_' + person.penis
		if penisdescription.has(temp):
			text += penisdescription[temp]
	if person.balls != 'none':
		text += getdescription('balls')
	if person.vagina == 'none' && person.penis == 'none' && person.balls == 'none':
		text += "For some reason, $his crotch has no visible genitals. "
	return text

func piercing():
	var text = ""
	if person.piercing.earlobes == 'earrings':
		text += '$His ears are decorated with a pair of [color=aqua]fancy earrings[/color]. '
	elif person.piercing.earlobes == 'stud':
		text += '$His ears have a pair of [color=aqua]small studs[/color] in them. '
	if person.piercing.eyebrow == 'stud':
		text += '$His eyebrow is decorated with a [color=aqua]small stud[/color]. '
	if person.piercing.nose == 'ring':
		text += '$His nose bears a [color=aqua]large nose ring[/color] in it. '
	elif person.piercing.nose == 'stud':
		text += '$His nose has a [color=aqua]small stud[/color] in it. '
	if person.piercing.lips == 'ring':
		text += '$His lip is pierced with a [color=aqua]small ring[/color]. '
	elif person.piercing.lips == 'stud':
		text += '$His lip has a [color=aqua]small stud[/color] in it. '
	if person.piercing.tongue == 'stud':
		text += '$His tongue has a shiny [color=aqua]stud[/color], visible when $he talks. '
	if person.piercing.navel == 'stud':
		text += "$His navel is pierced with a [color=aqua]small stud[/color]."
	
	if person.piercing.nipples == 'stud':
		text += '$His pierced nipples are decorated with [color=aqua]a pair of small studs[/color]. '
	elif person.piercing.nipples == 'ring':
		text += '$His pierced nipples contain a [color=aqua]pair of rings[/color]. '
	elif person.piercing.nipples == 'chain':
		text += 'Her pierced nipples are connected by a [color=aqua]small chain[/color]. '
	if person.piercing.clit == 'ring':
		text += '$His clit is pierced with a [color=aqua]ring[/color]. '
	elif person.piercing.clit == 'stud':
		text += '$His clit has a [color=aqua]small stud[/color] in it. '
	if person.piercing.labia == 'ring':
		text += '$His pierced labia is decorated with [color=aqua]a pair of rings[/color]. '
	elif person.piercing.labia == 'stud':
		text += '$His pierced labia is decorated with a [color=aqua]small stud[/color]. '
	if person.piercing.penis == 'ring':
		text += '$His cock has a considerable [color=aqua]ring[/color] on the tip. '
	elif person.piercing.penis == 'stud':
		text += '$His cock has a [color=aqua]stud[/color] in it. '
	
	if text != '':
		if globals.state.descriptsettings.piercing == true || showmode != 'default':
			text = "\n\n[url=piercing][color=#d1b970]Piercing:[/color][/url] " + text
		else:
			text = "\n[url=piercing][color=#d1b970]Piercing:[/color][/url] Omitted."
	return text

func tattoo():
	var text = ''
	var sametattoo = true
	for i in person.tattoo.values():
		if person.tattoo.face != i || person.tattoo.face == 'none':
			sametattoo = false
			break
	if sametattoo == true:
		text += "$name's entire body is tattooed with [color=yellow]" + tattoooptions[person.tattoo.face].name + '[/color] pattern, featuring complex ' + tattoooptions[person.tattoo.face].descript + '. '
	else:
		if person.tattoo.face != 'none' && person.tattooshow.face == true:
			text += tattoosdescript.face.start + '[color=yellow]' + tattoooptions[person.tattoo.face].name + '[/color]' + tattoosdescript.face.end + tattoooptions[person.tattoo.face].descript + '. '
		if person.tattoo.chest != 'none' && person.tattooshow.chest == true:
			text += tattoosdescript.chest.start + '[color=yellow]' + tattoooptions[person.tattoo.chest].name + '[/color]' + tattoosdescript.chest.end + tattoooptions[person.tattoo.chest].descript + '. '
		if person.tattoo.arms != 'none' && person.tattooshow.arms == true:
			text += tattoosdescript.arms.start + '[color=yellow]' + tattoooptions[person.tattoo.arms].name + '[/color]' + tattoosdescript.arms.end + tattoooptions[person.tattoo.arms].descript + '. '
		if person.tattoo.waist != 'none' && person.tattooshow.waist == true:
			text += tattoosdescript.waist.start + '[color=yellow]' + tattoooptions[person.tattoo.waist].name + '[/color]' + tattoosdescript.waist.end + tattoooptions[person.tattoo.waist].descript + '. '
		if person.tattoo.legs != 'none' && person.tattooshow.legs == true:
			text += tattoosdescript.legs.start + '[color=yellow]' + tattoooptions[person.tattoo.legs].name + '[/color]' + tattoosdescript.legs.end + tattoooptions[person.tattoo.legs].descript + '. '
		if person.tattoo.ass != 'none' && person.tattooshow.ass == true:
			text += tattoosdescript.ass.start + '[color=yellow]' + tattoooptions[person.tattoo.ass].name + '[/color]' + tattoosdescript.ass.end + tattoooptions[person.tattoo.ass].descript + '. '
	if text != '':
		if globals.state.descriptsettings.tattoo == true || showmode != 'default': 
			text = "\n\n[url=tattoo][color=#d1b970]Tattoos:[/color][/url] " + text
		else:
			text = "\n[url=tattoo][color=#d1b970]Tattoos:[/color][/url] Omitted."
	return text

func mods():
	var text = ''
	
	if person.mods.has('hollownipples') == true:
		text += '[color=#B05DB0]$His nipples are magically modified, allowing them to stretch and be penetrated. [/color]'
	if person.mods.has('augmentfur'):
		text += "[color=#B05DB0]$His fur is magically augmented to provide extra protection against harmful effects.[/color]\n"
	if person.mods.has('augmenttongue'):
		text += "[color=#B05DB0]$His tongue is unusually long, increasing performance during oral sex [/color]\n"
	if person.mods.has('augmentscales'):
		text += "[color=#B05DB0]$His scales are magically modified to be thicker than normal and provide extra protection.[/color]\n"
	if person.mods.has('augmenthearing'):
		text += "[color=#B05DB0]$His hearing is magically augmented, increasing $his awareness of $his surroundings.[/color]\n"
	if person.mods.has('augmentstr'):
		text += "[color=#B05DB0]Through magical modification, the potential of $his muscles has increased.[/color]\n"
	if person.mods.has('augmentagi'):
		text += "[color=#B05DB0]Through magical modification, $his pre-existing limitations on $his reflexes and flexibility no longer hold $him back.[/color]\n"
	
	if text != '':
		text = "\n[url=mods]Mods: [/url]" + text
	return text


func race():
	var text = "$He is "
	if person.race[0] in ['E','A','O','U']:
		text += 'an '
	else:
		text += 'a '
	text += "[color=yellow][url=race]" + person.race + '[/url][/color]: '
	return text

func entry():
	var text = ''
	if globals.slaves.find(person) >= 0 || globals.player == person || person.fromguild == true || globals.get_tree().get_current_scene().get("makeoverPerson") != null:
		if person.sleep == 'jail':
			text = 'Behind the iron bars you see '
		elif globals.player == person:
			text = 'In the mirror you see '
		else:
			text = 'You see '
		if person.nickname == '':
			text += person.name + ' ' + person.surname + '. '
		else:
			text += person.name + ' "'+person.nickname+'" ' + person.surname + '. '
	else:
		
		text = 'A tied and bound [color=yellow]$sex[/color] looks at you with fear and hatred. '
	text = text.replace(" .", ".")
	return text

func getdescription(value):
	var text
	if descriptions.has(value) && descriptions[value].has(person[value]):
		text = descriptions[value][person[value]]
		text = text.split('|',true)
		text = text[rand_range(0,text.size())]
	elif descriptions.has(value) && descriptions[value].has('default'):
		text = descriptions[value].default
	else:
		text = "[color=red]Error at getting description for " + value + ": " + person[value] + '[/color]. '
	return text

func getbeauty(justtext = false):
	var calculate 
	var text = ''
	var appeal = person.beauty
	var tempappeal = person.beautytemp
	
	if appeal <= 15:
		calculate = 'ugly'
	elif appeal <= 30:
		calculate = 'boring'
	elif appeal <= 50:
		calculate = 'normal'
	elif appeal <= 70:
		calculate = 'cute'
	elif appeal <= 85:
		calculate = 'pretty'
	else:
		calculate = 'beautiful'
	
	text = descriptions['beauty'][calculate]
	if justtext == false:
		text += "(" 
		if tempappeal != 0:
			text += '[color=aqua]'+str(floor(appeal))+'[/color]'
		else:
			text += str(floor(appeal)) 
		text += ")"
	if justtext == false:
		return text
	else:
		return calculate

func gettitsextra():
	var text
	if person.titsextra >= 1:
		if person.titsextradeveloped == false:
			text = 'Below $his chest you can spot [color=yellow]' + str(person.titsextra) + ' additional '+ globals.fastif(person.titsextra == 1, 'pair', 'pairs') +'[/color] of [color=yellow]rudimentary nipples[/color]. '
		else:
			text = 'Below $his chest $he possesses [color=yellow]' + str(person.titsextra) + globals.fastif(person.titsextra == 1, ' row', ' rows')+ '[/color] of slightly smaller [color=yellow]ripe tits[/color]. '
	else:
		text = ''
	return text

static func getstatus(person):
	var text = ''
	text += 'Fear: '
	if person.fear <= 20:
		text += '[color=yellow]$name is not really afraid of you. [/color]'
	elif person.fear <= 40:
		text += '[color=#adff2f]$name has some concerns about your anger. [/color]'
	elif person.fear <= 60:
		text += "[color=green]$name knows well you can punish $him swiftly. [/color]"
	elif person.fear <= 80:
		text += '[color=#adff2f]$name shows heavy signs of fear with you around. [/color]' 
	else:
		text += '[color=#FFA500]$name trembles with fear whenever you are mentioned. [/color]'
	text += '\n'
	text += "Obedience: "
	
	if person.obed <= 20:
		text += '[color=#ff4949]$name barely pays any attention to you, as if demonstrating $his independence. [/color]'
	elif person.obed <= 40:
		text += '[color=#FFA500]$name avoids looking at you, reacting poorly to any command. [/color]'
	elif person.obed <= 60:
		text += "[color=yellow]$name shows some respect, but it is clear that it is forced. [/color]"
	elif person.obed <= 80:
		text += '[color=#adff2f]$name tries to appeal to you, showing that your opinion is important to $him. [/color]' 
	else:
		text += '[color=green]$name holds your word as law and gives you all of the attention that $he can muster. [/color]'
	
	text += '\n'
	text += "Stress: "
	if person.stress < 33:
		text += '[color=green]Overall $name acts content and lively[/color]. ' 
	elif person.stress < 66:
		text += '[color=yellow]$name looks somewhat depressed.[/color] '
	elif person.stress < 99:
		text += '[color=#FFA500]$name looks heavily stressed.[/color] '
	else:
		text += '[color=#ff4949]$name looks terrible, as if $he could break apart at any moment.[/color] '
#	elif person.stress <= 60:
#	
	
	text += '\n'
	
	text += "Loyalty: "
	if person.loyal <= 20:
		text += '[color=#ff4949]$name’s face is cold, showing no sign of attachment. [/color]' 
	elif person.loyal <= 40:
		text += "[color=#FFA500]$name's attitude gives away some of the affection $he holds for you. [/color]"
	elif person.loyal <= 60:
		text += '[color=yellow]$name shows considerable loyalty to you as $his master.[/color] '
	elif person.loyal <= 80:
		text += '[color=#adff2f]$name’s face shows a strong bond and deep feelings for you.[/color] '
	else:
		text += "[color=green]To $name, nothing is more important than you and your will.[/color] "
	
	
	if person.effects.has('captured') == true:
		text += '\n[color=#ff4949]Due to recent events $name rebels against your control.[/color]'
	text = person.dictionary(text)
	
	return text

func getBabyDescription(person):
	var text = '$He has ' + person.haircolor + ' hair and ' + person.eyecolor + ' eyes. $His skin is ' + person.skin + '. '
	var dict = {}
	dict = {
	none = '',
	plants = "It is covered in some leaves and green plant matter. ",
	scales = "It is covered in a few scales. ",
	feathers = "It has bird feathers in some places. ",
	full_body_fur = "It shows the beginnings of fur. ",
	}
	text += dict[person.skincov]
	if person.tail != 'none':
		text += '$He appears to have a small tail, inherited from one of the parents. '
	if person.horns != 'none':
		text += '$He has pair of tiny horns on $his head. '
	dict = {
	human = 'normal',
	short_furry = 'short and furry',
	long_pointy_furry = 'long and furry',
	pointy = 'pointy',
	long_round_furry = 'of a bunny',
	long_droopy_furry = 'of a bunny',
	feathery = "feathery",
	fins = 'fin-like',
	}
	text += '$His ears are ' + dict[person.ears] + '. '
	
	text = person.dictionary(text)
	return text





var penisdescription = {
	human_small = 'Below $his waist dangles a [color=yellow]tiny humanish dick[/color], small enough that it could be called cute. ',
	human_average ='$He has an [color=yellow]ordinary humanish penis[/color] below $his waist, more than enough to make most men proud. ',
	human_big = 'A [color=yellow]huge humanish cock[/color] swings heavily from $his groin, big enough to give even the most veteran whore pause. ',
	canine_small = 'A slender, pointed [color=yellow]canine dick[/color] hangs below $his waist, so small that its knot is barely noticeable. ',
	canine_average = '$He has a knobby, red, [color=yellow]canine cock[/color] of respectable size below $his waist, which wouldn’t look out of place on a large dog. ', 
	canine_big = 'Growing from $his crotch is a [color=yellow]massive canine dick[/color], red-skinned and sporting a thick knot near the base. ',
	feline_small = 'A [color=yellow]tiny feline penis[/color] dangles below $his waist, so small you can barely see the barbs. ',
	feline_average = '$He has a barbed [color=yellow]cat dick[/color] growing from $his crotch, big enough to rival an average human. ',
	feline_big = 'There is a frighteningly [color=yellow]large feline cock[/color] hanging between $his thighs, its sizable barbs making it somewhat intimidating. ', 
	equine_small = 'Below $his waist hangs a [color=yellow]smallish equine cock[/color], which is still respectable compared to the average man. ',
	equine_average= 'A [color=yellow]sizable equine cock[/color] grows from $his nethers, which, while small on a horse, is still thicker and heavier than the average human tool. ',
	equine_big = 'A [color=yellow]massive equine cock[/color] hangs heavily below $his waist, its mottled texture not quite matching the rest of $his skin. ',
}

var tattoosdescript = { #this goes like : start + tattoo theme + end + tattoo description: I.e On $his face you see a notable nature themed tattoo, depicting flowers and vines
	face = {start = "On $his cheek you see a notable ", end = " themed tattoo, depicting"},
	chest = {start = "$His chest is decorated with a ", end = " tattoo, portraying"},
	waist = {start = "On the lower part of $his back, you spot a ", end = " tattooed image of"},
	arms = {start = "$His arm has a skillfully created ", end = " image of"},
	legs = {start = "$His ankle holds a piece of ", end = " art, representing"},
	ass = {start = "$His butt has a large ", end = " themed image showing "},
	}
	
var tattoooptions = {
	none = {name = 'none', descript = "", applydescript = "Select a tattoo theme."},
	nature = {name = 'nature', descript = " flowers and vines", function = "naturetattoo", applydescript = "A nature themed tattoo will increase $name's beauty. "},
	tribal = {name = 'tribal',descript = " totemic markings and symbols", function = "tribaltattoo", applydescript = "A tribal themed tattoo will increase $name's scouting performance. "},
	degrading = {name = 'derogatory', descript = " rude words and lewd drawings", function = "degradingtattoo", applydescript = "A derogatory themed tattoo will enhance $name's lust and enforce obedience. "},
	animalistic = {name = 'beastly', descript = " realistic beasts and insects", function = "animaltattoo", applydescript = "An animalistic themed tattoo will boost $name's energy regeneration. "},
	magic = {name = "energy", descript = " empowering patterns and runes", function = "manatattoo", applydescript = "A tattoo consisting of magic runes will increase $name's Magic Affinity. "},
	}


var descriptions = { #Store descriptions for various body parts. Separate alternative with | sign to make description pick one at random
bodyshape = {
	humanoid = '$His body is quite [color=yellow]normal[/color]. ', 
	bestial = "$His body resembles a human's, except for some [color=yellow]bestial features[/color] in $his face and body structure. ",
	shortstack = '$His body is rather [color=yellow]petite[/color], about half the size of the average person. ',
	jelly = '$His body is [color=yellow]jelly-like[/color] and partly transparent. ',
	halfbird = '$His body has [color=yellow]wings for arms and avian legs[/color] making everyday tasks difficult. ',
	halfsnake = 'The lower portion of $his body consists of a long-winding [color=yellow]snake’s tail[/color]. ', 
	halffish = '$His body is [color=yellow]scaly and sleek[/color], possessing fins and webbed digits. ',
	halfspider = "The lower portion of $his body consists of a [color=yellow]spider's legs and abdomen[/color]. ",
	halfhorse = 'While $his upper body is human, $his lower body is [color=yellow]equine[/color] in nature. ',
	halfsquid = 'The lower portion of $his body consists of a [color=yellow]number of tentacular appendages[/color], similar to those of an octopus. ', 
},age = { 
	child = '$He looks like a [color=aqua]child[/color] that has barely hit puberty. ',
	teen = "$He's a young-looking [color=aqua]teen[/color]. ",
	adult = "$He's a fully-grown [color=aqua]adult[/color] $sex. ",
},beauty = {
	ugly = '$He is rather [color=yellow]unsavory[/color] to look at. ',
	boring = '$His looks are [color=yellow]bland and unimpressive[/color]. ',
	normal = '$He appears to be pretty [color=yellow]average[/color] looking. ',
	cute = '$His looks are quite [color=yellow]cute[/color] and appealing. ',
	pretty = '$He looks unusually [color=yellow]pretty[/color] and attracts some attention. ',
	beautiful = '$He looks exceptionally [color=yellow]beautiful[/color], having no visible flaws and easily evoking envy. ', 
},
hairlength = {
	ear = '$His [color=aqua][haircolor][/color] hair is cut [color=aqua]short[/color]. ',
	neck = '$His [color=aqua][haircolor][/color] hair falls down to just [color=aqua]below $his neck[/color]. ',
	shoulder = '$His wavy [color=aqua][haircolor][/color] hair is [color=aqua]shoulder length[/color]. ',
	waist = '$His gorgeous [color=aqua][haircolor][/color] hair [color=aqua]sways down to $his waist[/color]. ',
	hips = '$His [color=aqua][haircolor][/color] hair cascades down, [color=aqua]reaching $his hips[/color]. ',
},
hairstyle = {
	straight = 'It [color=aqua]hangs freely[/color] from $his head. ',
	ponytail = 'It is tied in a [color=aqua]high ponytail[/color]. ',
	twintails = 'It is managed in girly [color=aqua]twin-tails[/color]. ',
	braid = 'It is combed into a single [color=aqua]braid[/color]. ',
	'two braids' : 'It is combed into [color=aqua]two braids[/color]. ',
	bun = "It is tied into a neat [color=aqua]bun[/color]. ",
},
eyecolor = {
	default = '$His eyes are [color=aqua][eyecolor][/color]. ',
},
eyeshape = {
	normal = "",
	slit = "$He has [color=aqua]vertical, animalistic pupils[/color]. "
},
horns = {
	none = '',
	short = 'There is a pair of [color=aqua]tiny, pointed horns[/color] on top of $his head. ',
	'long_straight' : '$He has a pair of [color=aqua]long, bull-like horns[/color]. ',
	curved = 'There are [color=aqua]curved horns[/color] coiling around $his head. ',
	},
ears = {
	human = '',
	short_furry = '$He has a pair of fluffy, [color=aqua]medium-sized animal-like ears[/color]. ',
	long_pointy_furry = '$He has a pair of fluffy, [color=aqua]lengthy, animal-like ears[/color]. ',
	pointy = '$He has quite long, [color=aqua]pointed[/color] ears. ',
	long_round_furry = '$He has a pair of [color=aqua]standing bunny ears[/color] rising above $his head. ',
	long_droopy_furry = '$He has a pair of [color=aqua]droopy, bunny ears[/color] on $his head. ',
	feathery = "There's a pair of clutched [color=aqua]feathery ears[/color] on the sides of " + '$His head. ',
	fins = '$His ears look like a pair of [color=aqua]fins[/color]. ',
},
skin = {
	pale = '$His skin is a [color=aqua]pale[/color] white. ',
	fair = '$His skin is healthy and [color=aqua]fair[/color] color. ',
	olive = '$His skin is of an unusual [color=aqua]olive[/color] tone. ', 
	'tan' : '$His skin is a [color=aqua]tanned[/color] bronze color. ',
	brown = '$His skin is a mixed [color=aqua]brown[/color] color. ',
	dark = '$His skin is deep [color=aqua]dark[/color]. ',
	jelly = '$His skin is [color=aqua]semi-transparent and jelly-like[/color]. ', 
	blue = '$His skin is dark [color=aqua]blue[/color]. ',
	"pale blue" : '$His skin is [color=aqua]light pale blue[/color]. ',
	green = '$His skin is [color=aqua]green[/color]. ',
	red = '$His skin is bright [color=aqua]red[/color]. ',
	purple = '$His skin is [color=aqua]purple[/color]. ',
	teal = '$His skin is [color=aqua]teal[/color]. ',
},
skincov = {
	none = '',
	plants = 'Various leaves and bits of [color=aqua]plant matter[/color] cover parts of $his body. ',
	scales = '$His skin is partly covered with [color=aqua]scales[/color]. ',
	feathers = '$His body is covered in [color=aqua]bird-like feathers[/color] in many places. ',
	full_body_fur = '$His body is covered in thick, soft [color=aqua]fur of [furcolor]',
},
furcolor ={ # fur color
	none = '',
	white = 'marble color[/color]. ',
	gray = 'gray color[/color]. ',
	orange_white = 'orange-white pattern[/color]. ',
	black_white = 'black-white pattern[/color]. ',
	black_gray = 'black-gray pattern[/color]. ',
	black = 'jet-black color[/color]. ',
	orange = 'common fox pattern[/color]. ',
	brown = 'light-brown tone[/color]. ',
},
#arms = {
#	scales = '$His' + globals.fastif(person['legs'] == 'scales', ' arms and legs', ' arms') + ' are covered in [color=aqua]scales[/color]. ',
#	winged = "$His arms closely resemblance a [color=aqua]bird's wings[/color]. ",
#	webbed = '$His' + globals.fastif(person['legs'] == 'webbed', ' hands and feet', ' hands') + ' have [color=aqua]webbed digits[/color]. ', 
#	fur_covered = '$His' + globals.fastif(person['legs'] == 'fur_covered', ' arms and legs', ' arms') + ' are covered in [color=aqua]fur[/color]. ',
#},
wings = {
	none = '',
	feathered_black = 'On $his back, $he has folded, [color=aqua]black, feathery wings[/color]. ',
	feathered_white = 'On $his back, $he has folded, [color=aqua]white, feathery wings[/color]. ',
	feathered_brown = 'On $his back, $he has folded, [color=aqua]brown, feathery wings[/color]. ',
	insect = 'On $his back rests translucent [color=aqua]fairy wings[/color]. ',
	leather_black = 'Hidden on $his back is a pair of bat-like, [color=aqua]black leather wings[/color]. ',
	leather_red = 'Hidden on $his back is a pair of bat-like, [color=aqua]red leather wings[/color]. ',
},
tail = {
	none = '',
	cat = 'Below $his waist, you spot a slim [color=aqua]cat tail[/color] covered with fur. ',
	fox = '$He has a large, fluffy [color=aqua]fox tail[/color]. ',
	wolf = "Below $his waist there's a short, fluffy, [color=aqua]wolf tail[/color]. ",
	bunny = '$He has a [color=aqua]small ball of fluff[/color] behind $his rear. ',
	racoon = '$He has a plump, fluffy [color=aqua]raccoon tail[/color]. ',
	scruffy = 'Behind $his back you notice a long tail covered in a thin layer of fur which ends in a [color=aqua]scruffy brush[/color]. ',
	demon = '$He has a long, thin, [color=aqua]demonic tail[/color] ending in a pointed tip. ',
	dragon = 'Trailing somewhat behind $his back is a [color=aqua]scaled tail[/color]. ',
	bird = '$He has a [color=aqua]feathery bird tail[/color] on $his rear. ', 
	fish = '$His rear ends in long, sleek [color=aqua]fish tail[/color]. ', 
	"snake tail" : '',
	tentacles = '',
	horse = '',
	"spider abdomen" : ''
},
height = {
	tiny = '$His stature is [color=aqua]extremely small[/color], barely half the size of a normal person. ',
	petite = '$His stature is quite [color=aqua]petite[/color]. ',
	short = '$His height is quite [color=aqua]short[/color]. ',
	average = '$He is of [color=aqua]average[/color] height. ',
	tall = '$He is quite [color=aqua]tall[/color] compared to the average person. ',
	towering = '$He is unusually tall, [color=aqua]towering[/color] over others. ',
},
titssize = {
	flat = '$His chest is barely visible and nearly [color=yellow]flat[/color]. ',
	small = '$He has [color=yellow]small[/color], round boobs. ',
	average= '$His nice, [color=yellow]perky[/color] breasts are firm and inviting. ',
	big = '$His [color=yellow]big[/color] tits are pleasantly soft, but still have a nice spring to them. ',
	huge = '$His [color=yellow]giant[/color] tits are mind-blowingly big. ',
	masculine = '$His chest is of definitive [color=yellow]masculine[/color] shape. ',
},
asssize = {#ass strings
	flat = '$His butt is skinny and [color=yellow]flat[/color]. ',
	small = '$He has a [color=yellow]small[/color], firm butt. ',
	average= '$He has a nice, [color=yellow]pert[/color] ass you could bounce a coin off. ',
	big = '$He has a pleasantly [color=yellow]plump[/color], heart-shaped ass that jiggles enticingly with each step. ',
	huge = '$He has a [color=yellow]huge[/color], attention-grabbing ass. ',
	masculine = '$His ass definitively has a [color=yellow]masculine[/color] shape. ',
},
balls = {
	small = '$He has a pair of [color=yellow]tiny[/color] balls. ',
	average = '$He has an [color=yellow]average-sized[/color] ballsack. ',
	big = '$He has a [color=yellow]huge[/color] pair of balls weighing down $his scrotum. ',
},
}

