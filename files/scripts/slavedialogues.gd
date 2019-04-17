extends Node

# familiar relations, e.g. is the person a child or a sibling of the player
var relation = 'unrelated'

var shy = false
var bold = false
var rude = false
var scared = false
var horny = false
# affectionate: can the person use less formal, more affectionate nicknames &c, e.g. dad or Master John instead of Father or Master.
var affectionate = false

# this could probably go to globals as a static function, similar to fastif(), if you end up using this sort of randomization more
func randomitemfromarray(source):
	# there should be a try-catch that checks that source is an array and its size is >0, but I don't know how to do that in gdscript
	if source.size() > 0:
		return source[rand_range(0, source.size())]


func gettalkreply(person):
	var answerOptions = []
	var text = ""

	relation = getrelation(person, globals.player)
	
	checkspeechpatterns(person)
	text += getgreeting(person)

	answerOptions += gettraitreplies(person)
	answerOptions += getdirtyreplies(person) 
	answerOptions += getobediencereplies(person) 
	answerOptions += geteffectreplies(person)
	
	if relation != 'unrelated':
		answerOptions += getfamilyplies(person)
	
	#choose one of the comments in the answer-array
	if answerOptions.size() > 0:
		text += randomitemfromarray(answerOptions)
	else:
		text += ("— I don't know what to say. \n")

	# get additional comments (about mood etc) after the random reply
	if rand_range(0,1) >= 0.666:
		text += getadditionalcomment(person)
	
	return text

func getgreeting(person):
	var answer = []
	if rude == true:
		answer.append("— It's you, " +getplayercallname(person) +'.\n')
		answer.append("— What do you want, " +getplayercallname(person) +'?\n')
		answer.append("— Stop looking at me, " +getplayercallname(person) +'.\n')
		answer.append("— I wish we'd never met, " +getplayercallname(person) +'.\n')
		answer.append("— Can't you just leave me be, " +getplayercallname(person) +'?\n')
		answer.append("— Just leave me alone, " +getplayercallname(person) +'!\n')
	else:
		answer.append("— Hello, " + getplayercallname(person) +'.\n')
		answer.append("— Nice to see you, " + getplayercallname(person) +'.\n')
		answer.append("— Hi again, " + getplayercallname(person) +'.\n')
		answer.append("— How are you, " + getplayercallname(person) +'?\n')
		answer.append("— I hope you're doing well, " + getplayercallname(person) +'.\n')
		answer.append("— Greetings, " + getplayercallname(person) +'.\n')

	var text = randomitemfromarray(answer)
	text = globals.player.dictionaryplayer('\n' +text)
	return text

# Check the family relationship between two characters & returns one of: 'unrelated', 'child', 'sibling', 'parent'
func getrelation(char1, char2):
	# check if char1 is char's child
	if char1.relatives.father == char2.id || char1.relatives.mother == char2.id:
		return 'child'

	# check if char1 is char2's sibling
	if char1.relatives.father == char2.relatives.father || char1.relatives.mother == char2.relatives.mother:
		return 'sibling'

	# check if char1 is char2's parent
	if char1.id == char2.relatives.father || char1.id == char2.relatives.mother:
		return 'parent'
	
	return 'unrelated'	
	
# check speech patterns, e.g. shy, bold, scared
func checkspeechpatterns(person):
	shy = false
	bold = false
	scared = false
	rude = false
	horny = false
	affectionate = false

	if (person.conf < 35 && person.dom < 40 && person.traits.has('Dominant') != true ) || ( person.traits.has('Submissive') && person.conf < 60 ):
		shy = true
	if (person.conf > 55 && person.dom > 60 && person.traits.has('Submissive') != true ) || ( person.traits.has('Dominant') && person.conf > 35 ):		
		bold = true
	if person.punish.expect == true && person.stress > 35:
		scared = true
	if person.obed<35 && person.loyal < 35 :
		rude = true
	if person.lust > 50 && person.traits.has('Prude') != true && shy != true && person.sexuals.unlocked:
		horny = true
	if person.loyal > 70 && person.obed > 50 && person.effects.has('captured') == false:
		affectionate = true

func getplayercallname(person):
	var callname = []
	
	if rude:
		callname.append(globals.fastif( globals.player.sex == 'male', 'mister', 'lady'))
		callname.append('$name')
	elif affectionate: 
		callname.append("$name dear")
		if person.punish.expect == false && person.stress < 30:
			callname.append("kind $master")
		callname.append('$master $name')
		callname.append('dear $master')
		if person.sexuals.unlocked:
			callname.append('darling')
	else:
		callname.append('$master')
		callname.append('$sir $name')
		
	if relation == 'parent':
		if globals.player.sex == 'male':
			callname.append('Father')
			callname.append('Dad')
			if affectionate:
				callname.append('father')
				callname.append('dad')
				callname.append('papa')
				callname.append('daddy')
		else:
			callname.append('Mother')
			callname.append('Mom')
			if affectionate:
				callname.append('mother')
				callname.append('mum')
				callname.append('mama')
				callname.append('mommy')
	elif relation == 'sibling':
		callname.append('$sibling')
	
	# This should be run through globals.player.dictionaryplayer, because $sir depends on the person's gender.
	# Now it's only called from getgreeting(), where that's done.
	return randomitemfromarray(callname)

func gettraitreplies(person):
	var answer = []
	if person.traits.has('Sex-crazed') == true && person.obed > 40:
		answer.append("— I don't care about my life, or anything, can we just fuck here, $master?")
		answer.append("— I don't care about that, $master, but maybe you could fuck me right now?")
		answer.append("— I'm so hot! Can we fuck now, $master?")

	return answer

func getdirtyreplies(person):
	var answer = []
	var text = ""
	# dirty comments
	if person.sexuals.unlocked:
		if person.obed < 35:
			if rude:
				answer.append("— Pervert! Maniac!\n" )
			if person.loyal < 40:
				answer.append("— I don't like it when you touch me.\n" )

		if person.age == 'child':
			answer.append("— I thought kids were too young for that sex stuff!\n")
			if person.preg.duration > 8:
				answer.append("— I'm a child, I'm not supposed to be pregnant!\n")
				answer.append("— How will the baby come out? \n— ... Won't that hurt? \n")
		elif person.age == 'teenager':
			if person['face']['beauty'] > 50:
				answer.append("— I'm young AND pretty! Nothing better, right, $master?\n")
			if person.preg.duration > 8:
				answer.append("— I didn't really plan on getting pregnant this young. \n")
				if horny:
					answer.append("— I still have needs even though I'm pregnant, $master. \n$name winks at you. \n")
		else:
			if person['face']['beauty'] > 50:
				answer.append("— Just look at this body, $master! Full of mature charm. \n")
			if person.preg.duration > 8:
				answer.append("— There's a baby in this belly, $master. \n")
				answer.append("— I'm going to be a $parent, huh? \n")
				
		if relation == 'child':
			if globals.player.sex == 'male':
				answer.append("— Father, do you ever think we've gone too far?\n")
				answer.append("— Is it really all right for you to do those things with me, dad?\n")
				answer.append("— Is it really all right for us to do all these things, dad?\n")
			else:
				answer.append("— Mother, do you ever think we've gone too far?\n")
				answer.append("— Is it really all right for you to do those things with me, mom?\n")
				answer.append("— Is it really all right for us to do all these things, mom?\n")
		if relation == 'sibling':
				answer.append( globals.player.dictionaryplayer( "— Hey $sibling, do you ever think we've gone too far?\n" ) )
				answer.append("— Is it really all right for you to do those things with me, $sibling?\n")
				answer.append("— Is it really all right for us to do all these things, $sibling?\n")

		if person.preg.duration > 8:
			answer.append("— What will you do once the baby is born?\n")
		elif person.preg.duration > 20:
			answer.append("— The baby is so big in my belly! \n")
			answer.append("— I'm going to be a mother! \n")

	return answer


func getobediencereplies(person):
	var answer = []
	#person with very low obedience
	if person.obed < 35:
		answer.append("— Do you want me to do something? \n")
		# low obed & low loyalty
		if person.loyal < 25:
			answer.append("— I don't wanna talk with you after all you've done!\n")	
			if bold && rude:
				answer.append("— I hate you, *hate* you! \n")
				answer.append("— Leave me alone! Don't come near me!\n")
				answer.append( "$name ignores you.\n")
			if bold:
				answer.append( "— I'm not talking with you!\n")
				answer.append("— Just leave me alone!\n")
				answer.append("— Don't you come near me!\n")
				answer.append("— Oh just let me be!\n")
			if scared:
				answer.append("— No, $master, please spare me, I haven't done anything! \n$name gets scared as $he realizes you're trying to start a conversation.\n")
				answer.append("\n— I don't want this... I don't want this...\n$name didn't seem to hear your question.")
			if shy:
				answer.append("— ...\n$name clearly doesn't like you, but doesn't dare to say anything.")
				answer.append("— ...\n$name seems to be uncomfortable in your presence, but doesn't dare to say anything.")
				answer.append("— I... I have work to do, $master. \n$name excuses $himself.")
		#low obed & meagre loyalty
		elif person.loyal < 40:
			answer.append( "— I'm not talking with you!\n")
			if rude:
				answer.append( "$name pretends not to hear you.\n")
			if bold:
				answer.append( "— I'm really angry with you, $master! You do all these... It's just not right! \n")
				answer.append("— I don't wanna talk with you right now! Not after all you've done...\n$name seems to feel conflicted about you.")
			if shy:
				answer.append("— ...yes, $master?\n $name seems to be upset with you, but doesn't dare to say anything.\n")
				answer.append("— *sigh* \n $name seems to be in a melancholical mood, but won't tell you what's bothering her.\n")
				answer.append("— ...\n$name clearly doesn't like you, but doesn't dare to say anything.")
		# low obed & medium-high loyalty
		elif person.loyal < 60:
			answer.append("— I like you, $master, but sometimes you're not very nice! \n")
			if bold:
				answer.append("— I like you, $master, but sometimes you're just horrible! \n")
			if shy:
				answer.append("— ...yes, $master?\n $name seems to be upset with you, but doesn't dare to say anything.\n")
				answer.append("— *sigh* \n $name seems to be in a melancholical mood, but won't tell you what's bothering her.\n")
				answer.append("— $name smiles at you, but isn't giving you $his whole attention.")
		# low obed & high loyalty
		elif person.loyal < 80:
			answer.append("— You're so great, $master! But... sometimes it's hard to do as you say. \n")
			answer.append("— I really do love you, $master, but sometimes you're not very nice! \n")
			if bold:
				answer.append("— I really do love you, $master, but sometimes you're just horrible! \n")
			if shy:
				answer.append("— ...yes, $master?\n$name seems to be upset with you, but is still happy at your attention.\n")
				answer.append("— *sigh* \n$name seems to be in a melancholical mood, but won't tell you what's bothering her.\n")
		# low obed & very high loyalty
		else:
			answer.append("— I love you, $master, but I don't know how long I can go on like this... \n")

	#moderately obedient person
	elif person.obed < 60:
		answer.append("— What are your orders, $master? \n")
		answer.append("— Do you have any orders, $master? \n")
		# moderate obed & low loyalty
		if person.loyal < 25:
			answer.append(globals.player.dictionaryplayer('— I will try to obey your orders, $master. \n'))
			if bold:
				answer.append( "— I don't wanna talk with you after all you've done!\n")			
			if shy:
				answer.append(globals.player.dictionaryplayer("— ...$master?\n$name waits for your orders.\n"))
		# moderate obed & meagre loyalty
		elif person.loyal < 40:
			answer.append("— What are your orders, $master?\n")
			answer.append("— With respect, $master, I'd prefer not to talk with you right now!\n")
			if person.conf < 30:
				answer.append("— ...yes, Master?\n $name seems to be upset with you, but doesn't dare to say anything.\n")
				answer.append("— *sigh* \n $name seems to be in a melancholical mood, but starts smiling as you spend time together.\n")
		# moderate obed & medium-high loyalty
		elif person.loyal < 60:
			if bold:
				answer.append(globals.player.dictionaryplayer("— I like you, $master! \n"))
			answer.append( "— I do rather like you, $master. \n$There's a gentle smile on $his lips." )
		# moderate obed & high loyalty
		elif person.loyal < 80:
			answer.append("— I really do love you, $master, but sometimes you're just horrible! \n")
			answer.append("— You're so great, $master! But... sometimes it's hard to do as you say. \n")
		# moderate obed & very high loyalty
		else:
			answer.append("— I love you, $master, but I don't know how long I can go on like this... \n")

	#very obedient person
	else:
		if person.loyal <= 60:
			answer.append('— Your will be done, $master. \n')
			answer.append('— As you wish, $master. \n')
			answer.append('— What is your will, $master? \n')
		else:
			answer.append(globals.player.dictionaryplayer('— Your will be done, $sir $name. \n'))
			answer.append(globals.player.dictionaryplayer('— As you wish, $master. \n'))
			answer.append(globals.player.dictionaryplayer('— What is your will, $sir $name? \n'))
		
		if person.loyal < 25:
			answer.append("— With respect, $master, I'd prefer not to talk with you right now!\n")
			if shy:
				answer.append( "— It wasn't easy at first, but I think warmly of you, $master. \n" )
		elif person.loyal < 60:
			if bold:
				answer.append(globals.player.dictionaryplayer("— I like you, $master! \n"))
			answer.append( "— It wasn't easy at first, but I think warmly of you, $master. \n" )
			answer.append( "— It isn't always easy, but I rather like you, $master. \n" )
		else:
			answer.append(globals.player.dictionaryplayer("— I'll try my best for you, $master. Despite what others might think, you are invaluable to me!\n"))
			answer.append(globals.player.dictionaryplayer("— I'm happy to serve you, $master. You're the best!\n"))
	return answer
	
	
func geteffectreplies(person):
	var answer = []
	var text = ""
	# captured can also mean that she's rebellious, e.g. because you forced her into sexual relations
	if person.effects.has('captured') == true:
		if bold && rude:
			answer.append("— Leave me alone! Don't you come near me!\n")
		answer.append("— Let me go! I don't want to be here...\n")
		answer.append("— I don't wanna be here...\n")
	return answer

func getadditionalcomment(person):
	var text = '\n'
	var answer = []
	var comment_chosen = false
	
	if person.brand != 'none':
		if person.loyal < 40:
			answer.append ("— I'm all out of options now. \n$name gives you a trapped look, and touches $his brand. ")
			answer.append ("— I'm just your little person now, huh? \n$name gives you a trapped look, and touches $his brand. ")			
		elif person.loyal < 60:
			answer.append("— I'm your little person now, am I not? \n$His manners are detached and professional. \n")
		else:
			if shy:
				answer.append("$name's finger traces $his brand as $he " +globals.fastif(person.sex == 'male', 'bows', 'curtsies') +" deeply.\n$He smiles at you, and seems to enjoy your company. \n")
			answer.append("— I'm just your little person now, $master. \nDespite $his words $he smiles at you, and seems to enjoy your company. \n")
			answer.append("—It wasn't easy at first, but I think warmly of you, $master. \n$name touches $his brand as $he bows to you. ")
	
	# 20 % of the time, talk about the brand
	if rand_range(0,1) > 0.2:
		comment_chosen = true
		text += randomitemfromarray(answer)
		
	# if not already talking about a brand, get unique NPC lines 50 % of the time
	if comment_chosen == false && rand_range(0,1) > 0.5:
		if person.name == "Tamamo" && person.race.find("Fox") >= 0: 
			text += "— One tail is not what I'm used to, but at least it's just as fluffy as you'd expect. "	
	
	# if not already talking about something, ask for a break or for sex (if appopriate)
	if person.obed > 50:
		if person.stress > 60:
			text = text + "— It has been tough for me recently... Could you consider giving me a small break, please?\n"
			comment_chosen = true
		if horny && shy == false:
			if person.sexuals.actions.has('pussy'):
				text = text + "— I actually would love to fuck right now. \n"
				comment_chosen = true
			else: 
				text = text + "— Uhm... would you like to give me some private attention? \n[color=#ffa7b6] $name gives you a deep lusting look.[/color] \n"
				comment_chosen = true

	# if nothing else and player was the person's first sex partner, talk about that
	if person.pussy.has == true && comment_chosen == false && person.pussy.first == 'you':
		if person.loyal < 20:
			text = text + "— I haven't forgotten how you took my virginity, $master.\n $name glares at you.\n"
		elif person.loyal < 60:
			text = text + "— You do remember, $master, that you were my first, don't you?\n"
		else:
			text = text + "— I'm very glad you have been my first, $master.\n"
	return text
	
func getfamilyplies(person):
	var answer = []
	
	return answer	