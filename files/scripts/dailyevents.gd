extends Control

var person #triggering person
var slave2 #additional person spot
var showntext setget showntext_set
var buttons
var currentevent

func showntext_set(value):
	showntext = dictionary(value)

var eventstext = {
	play = ["During the morning you are visited by $name who seems to be desperate for your attention. After a brief talk you realize that the young $race $child seems to be bored or even feeling lonely and hasn't matured enough to not completely rely on others. Perhaps, providing $him some attention might benefit $his well-being. ", "You spend a couple of hours going through the mansion's yard and surrounding forest while $name carelessly strolls around talking. After it's over $name addresses you. \n\n— Thank you, $master, I had lots of fun!", "You introduce $name to one of the numerous tabletop games scattered around one of your cabinets. $He does not appear to be very interested at first, but eventually with your guidance $he grasps it and $he becomes completely immersed in it. After it's over, $child addresses you before resuming $his duty. \n\n— Thank you, $master, that was really fun!", "Deciding it’s a great day to start with some naughty stuff, you invite $name into a private room, in short time freeing $him from $his clothes. After spending some time exploring each other's bodies, you finally relax next to an exhausted $child, satisfied from your activities. $His satisfied face gives you a shy smile as $he grabs your hand. ","You roughly send $name away announcing you have more important things to take care of. $He leaves clearly upset."],#options: play active games, play logic games, play lewd games, send $him off
	spendtime = ["During the morning you are visited by $name who seems to be very bored and wonders if you would spend some time with $him. ", "You go for a date with $name to Wimborn and spend some time together. By the end of the date you have grown closer. ", "You and $name spend some time having a pleasant conversation. ", "Without further delay you drag $name to a private room spending the rest of the morning pleasuring yourself with $his body.", "You roughly send $name away announcing you have more important things to take care of. $He leaves clearly upset."],#options: visit town, have intimate talk, fuck, send $him off
	horny = ["During the morning you are visited by $name who seems to be very aroused and restless. $He gives you a long meaningful look, relaying $his overwhelming desire. ", "You embrace $name and give $him a long lustful kiss which slowly shifts into a passionate session of carnal pleasure. Fully satisfied, $name leaves you to your work. ", "You order $name to control $his lust. $he does so but is clearly still aroused. You decide to keep an eye on $him and force $him to stay around you for some time playing on his arousal and denying $him any relief making sure $he learns $his place.", "You roughly send $name away announcing you have more important things to take care of. $He leaves clearly upset and still horny."], #options: Accept, discipline, ignore
	forestfind = ["As $name returns from $his work in the forests, $he announces to you that $he brought a lost person. ", "You decide to make the newly found child your servant, to which $he meekly complies/which seems to agitate $him. You praise $name and continue on your daily plans. ","You send the $child to the city to try finding $his relatives. After some time your servants report that $child has been delivered to $his parents and they sent you their thanks and a small reward. ", "You order $name to take $child away from the mansion and you do not want to have anything to do with it. " ], #finds child/teen. options:keep them to yourself, send them to town, leave them to destiny
	prositutebuyout = ["During the morning you are visited by a seemingly unknown man who proposes you sell him $name, whom he has been visiting at the brothel for the last few days. Having fallen in love with $him, he offers you a hefty sum of gold for $him. ", "You accept the offer and give up your ownership of $name. $He seems puzzled but the man is very grateful for your decision. ", "You decide to keep $name for yourself, as $he's more valuable while working for you. You send the man away.", "You bring $name to you and ask $him if $he wishes to leave your estate and belong to the man. After some consideration $he agrees and you send them away./$He hastily rejects this offer and declares $he can only acknowledge you as $his master. "], #options: sell person, reject, let person decide
	abortion = ["During the morning you are visited by $name who has a personal request. After a  brief explanation you realize $he wants to abort $his fetus being pessimistic about $his future life and hardship in slavery. ", "You decide to accept $name's request and provide $him with a miscarriage potion. $He is scared but pleased with your approval of $his request. ", "You spend some time with $name reassuring $him and promising that both $he and child will have your support. Giving birth will not make $him any less useful to you. ", "You decide to dismiss $name rejecting $his demand. $He leaves clearly distressed. " ], #options: accept, reassure, ignore
	vacation = ["During the morning you are visited by $name who has a personal request. $He asks you to give $him a couple of days away from work so $he could visit $his friends and relatives outside/spend some time resting. $name says that $he has faithfully served you, $he also would like to have a rest once in awhile. ", "You grant $his request and after hearing $his words of gratitude, return to your business", "You tell $name, that you can't currently allow $him to skip $his work as it's very important, and instead offer $him some pocket money to spend. $name seems slightly disappointed, but taking your words seriously and after accepting your money, does not offer any visible hostility. ", "You refuse $name's demands, saying $he does not deserve any rest in the first place and continue on your business leaving $him clearly distressed. "], #options: accept, give some money, refuse
	accident = ["During the morning you receive a report that $name has accidentally broken a valuable object you have in your mansion. The replacement cost will have to be covered by yourself but you also have to decide on $his punishment. ", "No bad deed should go unpunished and you decide to personally administer a strict punishment. After long minutes of cries and pledges for mercy you let $name go, making sure $he learned the lesson for good. ", "After some consideration you decide to let the incident slip this time. $name looks really relieved and thanks you for your mercy. "], #options: punish, forgive
	strangerdisrespect = ["During the morning you are visited by an unknown man, who appears to be a fairly well-known official and proclaims that your person, $name acted disrespectfully towards him while in town. He demands compensation and your person to be properly disciplined. ", "You bribe the official so he will forget $name's misbehavior, after which he leaves. $name approaches you and express $his deep gratitude for covering $his mistakes. ", "You decide that it would be best to let $name pay for $his wrongdoings personally. The man seems fairly happy with your decision and leaves with an unhappy $name by his side. ", "You tell the official it must be some mistake and you are not going to give him anything for wasting your time. As the official leaves you wonder how badly it's gonna hurt your reputation, but $name appears to be happy with your support. "], #options: compensate, let him use $name for a day, reject
	escape = ["Early in the morning you receive a report that $name has recently been planning to escape. This is a serious issue and you should consider some measures to prevent this from happening again. ", "You call $name over and discuss $his motives. You tell $him that you are not going to harshly punish $him, but it is in $his best interest to stay with you, as you promise to treat $him fairly. $name seemingly acknowledges your arguments and promises to act properly from now on. ", "You call $name over and administer a harsh punishment. Your treatment has left $him considerably more scared and obedient which should prevent further problems for the time being. ", "You decide to ignore the issue right now. This will likely encourage $name's actions and lower $his respect of you. "], #options: be forgiveful, be strict, pay no attention
	kidnap = ["Early in the morning you receive a report that $name did not come back yesterday and according to a few witnesses, may have been kidnapped. ", "You hastily initiate a rescue operation and with the help of the Mage's Order you find $name unharmed ", "You leave searches to your appointed headgirl, deciding $he should be able to take care of it by the end of the day. ","You decide to not spend any resources on searching $name. "], #options: Rush to search, leave it to the headgirl, do nothing
	gift = ["During the morning you are visited by $name, who recently saw a very pretty piece of jewelry possessed by a strange trader and making big eyes asks you to purchase it for $him while the trader is still around. ", "After some thoughts, you decide that spoiling your $child once in awhile is not really detrimental to $his behavior and send $him off with some gold. $name happily takes the money and thanks you for your generosity before running away. ", "You deny $name $his request making it clear that $he doesn't deserve such praise. Perhaps, another time if $he behaves properly. ", "After some consideration, you give $name a nasty smirk and tell $child, that if $he wants something from someone, $he should give something in return. "], #options: purchase, deny, make $him earn it
	injure = ["During the early part of the day you receive a report that $name has injured $himself at work and is having some troubles moving around. After visiting and inspecting $him, you decide it’s nothing life threatening, but $name could use some rest. ", "You tell $name, that $he can take it easy for a few days until $he gets better. $name is surprised with your attention and expresses $his gratitude. ", "You tell $name that $he can have a day off to rest and get better. $name warmly thanks you for your care. ", "You decide that $name's work is too important to let $him waste time laying around. $name acts stoically, even though $he hoped you would show a little bit of compassion. "], #options: let $name rest for 3 days, let $name rest for day, no rest
	escapedslave = ["During the morning you receive a report that $name has caught a trespasser on the mansion grounds. Apparently, it's a runaway slave who recently escaped from the town. You speak to the $2child, $2he tells you that he has been treated very badly by $2his masters, which you confirm by numerous visible bruises. $2He says $2he couldn't find much food in the past few days. ", "You offer $2name the chance to join your household and be provided with food and shelter. You also promise to treat $2him better than $2his previous owners. With little options and an empty stomach, $2he takes your offer, at least for now. $2name now belongs to you.", "You order the escaped slave to be tied up tightly and return $2him to town. After finding $2his previous owners you manage to earn some gold for your service.", "You decide that the $2child's life is of no interest to you. You threaten to punish $2him greatly if you see $2him again. "], #options: keep person to yourself, return person to city, act disinterested
	teenagersflirt = ["As you stroll around the mansion, you spot $name being wooed over by a few male teenagers. Apparently they find $him fairly attractive and are trying their best at flirting with $him. ", "Without much deliberation you appear before them and quickly indicate that $name belongs solely to you and they will be in big trouble if you see them again anywhere near your mansion. They swiftly retreat and $name thanks you for the help, showing some additional respect as $he does so. ", "You decide it would be amusing to make $name submit to a bunch of horny teens. You show up and tell $name that you demand $he responds to $his admirers in a most sincere way. The teenagers cheer at your commands and under pressure $name has no choice but to follow your order. Surrounded, $he's quickly freed of $his clothes and proceeds to give simultaneous blowjobs. ", "You decide to not waste your time and continue with your business. "], #options: Drive them away, Make $name serve them, Ignore
	devotedevent = ["During the morning you are visited by $name, who tells you how $he talked one of the citizens $he's familiar with, into offering $2himself to you. You invite them over and inspect $2him. \n$2He tells you how great the opinion of $name is of you, and how recent hardships have made $2his life very complicated to the point that $2he's ready to become a slave to have some stability and not die from starvation. ", "You accept $2child's proposal and introduce $2him to your household. ", "You reject the $2child's offer telling $2him that your current situation does not allow you to take just about anyone in. $2He leaves with a disappointed look. "], #options: accept,reject
	passiveevent = ["Walking through the mansion you spot how $name is being bullied and made fun of by couple of the other servants. $His meek personality apparently prevents $him from rebuking or putting an end to this treatment. ", "You approach the group and immediately put a stop to the verbal abuse. You harshly criticize the aggressors and explain that it is in their best interest not to pick on the others and you are not going to excuse any quarrels. They react with fright and remorse. After they leave $name expresses $his heartfelt appreciation. ", "Succumbing to the mob mentality you walk over to $name and passively observe the bullying with a smirk. Weak. Vulnerable. It strikes you that it might be fun to pay $name a visit later. To do it more. The servants seem to like you more now. ", "You decide it's not your business and move on your way. "], #options: defend $name, support bullying, ignore
	masochistevent = ["During the morning you receive a report that $name has accidently broken one of the valuable pieces of clutter you have at your mansion. As you inspect it, apparently nothing really important was damaged, but $name acts like $he did it purposefully to aggravate you. You realize $he really seeks punishment. ", "No bad deed should go unpunished and you decide to personally administer a strict punishment. As you give $name some painful spanking and let $him go, you notice, that even though $he looks somewhat satisfied, $he's also acting way more excited and $his underwear is slightly stained. ", "Knowing just exactly what $name is waiting for, you tie $him up and actively aim for $his genitalia with light hits. As $he quickly gets aroused, you finish the punishment by penetrating $him with your $penis, making $him yelp in ecstasy. \n\nAfter you finish, you send a very satisfied $name back to $his duties and move on with your business. ", "As there was no real damage done and you don't really have time to deal with $name, you decide to drop the whole issue and continue with your business. "], #options: punish, punish sexually, ignore
	sluttyevent = ["Walking through the mansion you spot how $name advocates to $2name how $he should be more open to $his body and pleasure $he can get with it. Unsure about it, $2name gives $name a doubting look, but you can spot that conversation certainly interests $him and $he'll likely be swayed at least a bit into new thoughts. You decide there's no need for your intervention and continue on your way. "], #options: none
	prudeevent = ["Walking through the mansion you spot $name advocating to $2name how $he should be a lot more thoughtful about $his actions and dress, as it's not proper behavior for them. Unsure about it, $2name gives $name a doubting look, but you can spot that conversation certainly had some effect on $him. You decide there's no reason to interfere now, but you might do something about prudish person later on. "], #options: none
	fickleevent = ["As you stroll around the mansion, you spot $name openly flirting with a $sex stranger in a deserted place. Their conversation looks very passionate and it seems they are about to get wild. ", "You abruptly interrupt their affair and send the stranger away. As you scold $name, $he gives you unpleasant look. ", "Initially startled by your approach, both the stranger and $name still take up your offer and you indulge in a small passionate orgy over $name's body. ", "You decide to leave two lovebirds to their intrigues. "], #options shoo them away, have threesome, ignore 
	pervertevent = ["Walking through the mansion you spot how $name distracts $2name frobm their work with various suggestive actions. As you subtly watch over them, you spot that $2name mostly tries to finish $2his work, but they both appear to be growing more aroused. ", "You show up and strictly order servants to get back to their duties. $name gives you gloomy look for interrupting them, while $2name looks somewhat relieved. ", "You show up and playfully order both servants to follow you to the private room. Once there, you go through what you saw, eventually making your followers blush badly. After getting them very excited, you finally move onto $2name while, ordering $name to undress everyone and join the fray. \n\nAfter the encounter is over, you spot that both servants have very satisfied looks on their faces. As you order them return to duty, you go on your business. ", "You decide the situation not worth your time and move on. "], #options: interrupt them, escalate the situation, ignore
	gardenevent = ["You are wandering through your garden in the evening when you happen to hear several throaty murmurs and chuckles from behind a nearby bush. Curious, you quietly peer over the top of the bush to investigate.\n\nHidden by the bush just off the path, you see $name and $2name enjoying an intimate moment together. They seem to be limiting themselves to kisses and caresses through clothing, but it seems obvious to you that they will soon progress to something more.","You find yourself momentarily entranced by the passion between $name and $2name, drawn in by the sinuous motion of their lithe bodies against the grass. It is only when $name’s hand slips beneath $2name’s clothing that you realize it would be inappropriate for you to continue spying on the two lovers.\n\nAs you begin to turn to leave, $name’s head turns, catching a glimpse of you. $He looks momentarily abashed, then gives you a grateful smile as you leave them to their privacy.","$name and $2name look up, shocked, as you push past the bush and demand to know what’s going on. Cutting off their shocked attempts at an explanation with an abrupt movement of your hand, you tell them that they shouldn’t be selfish: If they are going to play with each other, they should display their actions, and their bodies, for everyone in the garden. Trading a look between them, it’s clear that $name and $2name see no way out.\n\nHeads bowed, the two strip and move to the path, once again kissing and caressing each other as they flush with shame. You begin to hear low moans and gasps from the two, as they begin to grow aroused despite themselves, but their blushing bodies clearly reveal that they wish they could hide from your gaze, and the gaze of everyone passing by.\n\nFinally, once you are satisfied with their humiliation, you tell them they can leave. Clutching their discarded clothing to their nude bodies, they hurry away, avoiding your gaze as well as each other’s.","The romantic affairs of your servants are of little interest to you. Having discovered the source of the noise, and determined that it poses no risk to yourself or your household, you return to the path and continue on your evening stroll."],
	loverequestevent = ["You are surprised to be approached by $name first thing in the morning. After asking for permission to speak with you, $he begins to explain why $he’s here.\n\nIt seems that $name has developed a deep friendship with another of your servants, $2name, and $he hopes to pursue something further. After spending a while nervously dancing around the topic, $name asks for your permission to romantically pursue $2name.","You spend a while thinking over $name’s request while $he watches you anxiously. After long consideration, you tell $name that you give your consent, so long as $2name is willing.\n\nLetting out a relieved breath, $name breaks into a big smile and thanks you profusely. You remind $him that any relationship between the two of them cannot be allowed to interfere with their duties, and $he assures you that it will not. Still smiling, $name leaves.","Standing abruptly as $name finishes $his request, you order $him to follow you. $He looks confused, but obeys, $his face displaying hints of trepidation.\n\nYou move quickly through your mansion, first finding $2name and ordering $2him to follow, and then gathering a collection of other servants and visitors you happen to pass. Finally, ushering everyone into one of the mansion’s larger rooms, you order $2name to get on $2his knees.\n\nWith $2name on $2his knees, and $name watching in horror, you briskly explain that there is no room for ‘love’ between your servants. They will service who you tell them to, when you tell them to. To demonstrate your point, you order $2name to pleasure everyone present, except for $name and yourself.\n\nThe room slowly empties over the next hour, as the various observers leave after $2name finishes them, until you are left alone in the room with $name and $2name. $2name remains kneeling, $2his lips somewhat swollen, while $name looks down with tears in $his eyes.You remind the two slaves of the consequences if you discover any hints of an illicit affair, and send them back to their duties.","You tell $name to take a seat while you think over $his request, and offer $him a drink. $He looks somewhat uncomfortable as you hand $him the drink you mixed, but obediently takes a sip, an odd look crossing $his face as $he notices the odd taste. $He looks up at you as if to ask a question as your amnesia potion takes effect and his eyes go blank and complacent.\n\nSitting across from $name, you carefully manage the effects of the amnesia potion, using your words to mold $his mind. You instruct $him to forget everything about his love for $2name, to forget almost everything about $2him aside from his name.\n\nWhen $name eventually comes-to, $he appears dazed and confused, apologizing for falling asleep in your presence and asking why $he came to you in the first place. You tell $him not to worry about it, and instruct $him to return to $his duties."],
	standupevent = ["Walking the streets near your mansion, you encounter a small commotion. It seems that several local boys were attempting to flirt with $name, and when $he responded coldly to their overtures, the boys’ attempts grew more aggressive. $2name saw $2his friend being harrassed, and quickly jumped in, attempting to break up the crowd.\n\nAs you watch, you see a few of the boys share a look as $2name yells at them. No one has spotted you yet, but you know that the two servants are in trouble without further help.","The group of boys slowly take notice your presence, as you move closer to confront them. Calmly, you ask them what they think they are doing, attacking two defenseless people, much less two servants of yours. You ponder aloud whether they might like to see what happens to people who face the displeasure of a mage. Their bravado gone in the face of your calm authority, the boys slowly back away from you, then turn and run off.\n\nYou watch the last of the boys flee before turning around to see $2name helping $name to $his feet from where $he had fallen in the commotion. Asking them if they are okay, they reassure you that they are, and thank you for your help. You point out that it’s really $2name who deserves thanks, since $2he rushed in to help $2his friend without knowing if anyone was around to back $2him up. \n\nComplimenting them both on their friendship and loyalty, you send them back to the safety of your mansion.","You saunter forward slowly, watching as the boys move to surround both servants, rather than just $name. As you approach, people begin to notice you, including $name and $2name, their eyes filled with hope: Hope that is shattered by what you do next.\n\nYou apologize to the boys for the temerity of one of your servants, to shout at them. To make things right, you offer them the use of $name and $2name, for the rest of the day, so long as they do no permanent damage.\n\n$Name and $2name cast several desperate, pleading glances behind them as they are pulled away into the city, as if hoping for some reprieve from you. Chuckling to yourself and shaking your head, you return to your mansion.\n\nYou don’t see $name or $2name until the next morning, when you spot them walking up to the mansion doors, a small but noticeable distance between them. They each have a hint of rope burn around their wrists, their clothing and hair are in disarray, and you imagine that they had a very interesting night.","You decide you can’t be bothered to interfere with the scene, and turn to leave. The last thing you see as you are turning is a group of the boys moving to surround $2name as well as $name. As you walk away, $2names angry shouts become increasingly frantic, before they are suddenly cut off, replaced by the sound of clothing being torn and muffled, distressed yells.\n\nWhen you see $name and $2name later that day, neither seems physically harmed, although both look stressed and close to tears."],
	gossipevent = ["As you wander about your mansion at the end of the day, you happen across a normally-empty room and hear giggling emerging from the doorway. Looking in, you find $name and $2name, engaged in some harmless gossip and friendly conversation while they finish the last of their tasks for the day. As you listen, the two servants talk expansively, the topic ranging from simple gossip to their to their opinions on recent events in our household.","$name and $2name look up as you enter the room, an apprehensive look in their eyes as they anticipate being reprimanded for shirking, but you quickly lay their fears to rest. You gesture for them to stay seated while they work and sit down to join them, telling them that you’re interested in hearing the goings-on around your mansion.\n\nAfter some encouragement, $name tells you some of the many rumours floating around your household staff, and $2name confides what $2he’s learned from listening in the markets. You ask if either of them believe there’s any truth in the wild stories they’re sharing, and $name slyly replies that it only matters if the story is boring.\n\nThe three of you are shortly reduced to laughter, and only part reluctantly at the end of the evening to go your separate ways.","$name and $2name look up as you enter the room, an apprehensive look in their eyes as they anticipate being reprimanded for shirking, and you quickly confirm their fears. Looking at $name, you tell $him to bare $his arse and bend over the back of $his chair. Then, turning to $2name, you ask $2him how many times $name deserves to be spanked. After some stammering, $2he tells you “four.”\n\n$name cries out slightly as your hand flies through the air, impacting the smooth flesh of $his arse. Then the positions are reversed, and $2name is bent over the chair, while $name tells you that $2he deserves six smacks, a slight vengeful glint in $his eye.\n\nYou continue this game for some time, going back and forth between $name and $2name as they name progressively higher numbers, until both servants have a fiery red arse. Then you tell them to cover themselves and go to their rooms, and to remember this the next time they are tempted to believe their opinions are worth discussion.","You decide that you are uninterested in whatever tawdry gossip the two servants might be discussing, and you can’t be bothered to expend the energy it would take to reprimand them properly. You continue walking down the hall, the happy giggles of the two servants quickly fading behind you."],
	mockeryevent = ["While taking an evening stroll through your mansion, you encounter $name and $2name. $name appears to be bullying $2name, verbally abusing the cringing servant with $his cruel words. $2name continues attempting to leave, but $name blocks $2his path, ridiculing $2him as $he lists $2name’s perceived faults.\n\nFinally, while $name pauses for breath, $2name sees her opportunity to escape and runs from the room, tears in $2his eyes as $2he dashes past you.","You allow $2name to run past you, knowing that $2he will be happiest with some chance for solitude. Once she is gone, however, you stalk into the room that still contains $name, finding $him moving furniture and hiding any evidence of $his presence. $He never even notices your presence, until you are on top of $him.\n\nIn the morning, your servants enter the main hall of your mansion to discover $name, gagged and bound against a pillar. Tacked to the wall above his head is a list of $name’s various failings, as well as an encouragement that everyone should add to the list as they like. You feel certain that this is a lesson that $name will not soon forget.","You reach out and grab $2name’s wrist as $2he runs past you, stopping $2his retreat. Ignoring $2his pleas that you allow $2him to return to $2his room, you drag $2him back towards $name. Throwing $2name to the floor at $name’s feet, you order $2him to strip for the two of you, and gesture to $name that $he may continue $his earlier critique.\n\n$Name goes on at some length, reaching down to tweak at $2names nipple as $he insults $2his chest, and smacking $2his arse to encourage $2him to undress faster. Under your gaze, $2name does not dare protest, but you can see $2him continue to cringe and wilt as $2he is subjected to the continuous verbal abuse.\n\nFinally, deciding that $name has had $his fun, you order $2name to dress, and send both of them to their rooms. $name has a satisfied, smirking expression as $he leaves; $2name merely hugs $2his arms around $2himself and scurries out of sight.","With $2name having fled, it seems to you that the situation has resolved itself for now, and no longer requires your involvement. If $name starts trouble again in the future, perhaps you will deal with it then.\n\nWhistling to yourself, you continue along your stroll."],
	thiefevent = ["$name approaches you while you are in your study, nearly in tears. It seems that one of $his treasured possessions disappeared several days ago, and $he just saw $2name walking around carrying it. $name asks you to retrieve $his possession for $him.","After hearing $name’s story, you quickly send for $2name. With both servant’s standing before you, you ask $2name about $name’s possession. Seeing the serious look on your face, $2name does not even attempt to lie. Shamefaced, $2he hands the item over to you.\n\nYou hand the retrieved item to $name, and tell $him that $he may choose how $2name is punished for the theft. Looking at $2name’s shamed face, and then at you, $name tells you that $he has $his belonging back, and does not want anyone punished. Then, cradling $his treasured possession to $his chest, $name quickly leaves your study.\n\nLeft alone with $2name, you inform $2him that $2he should be very grateful for $name’s mercy, but not to expect it if $2he repeats $2his actions. Bowing $2his head in shame, $2name assures you it won’t happen again, and hurries to follow $name out.","You tell $name to wait in your study, and leave to seek out $2name. It’s a simple matter to retrieve $name’s possession, and when you return to your study, $name cries out in joy to see it, reaching out for it. But you don’t hand it to $him.\n\n$name sees the acquisitive gleam in your eye as you look at $his belonging. In a distressed burst of words, $he tells you that $he’ll do anything you want, give you anything, to have it back. Looking at $him, so desperate to please, you smile.\n\nMoments later you find yourself leaning back in your chair and holding up $name’s item, watching the way it shines in the light from the window. Then you look down. Kneeling between your legs, $name begins to use $his lips and tongue to pleasure you, $his eyes showing how desperate $he is to convince you to return what was stolen from $him.","After hearing out $name’s request, you quickly deny $him, informing $him that it is not your responsibility to retrieve lost items for the likes of $him. You wave away any objections $he tries to make, as $he argues that it was stolen, not lost, and tell $him to be more careful with $his belongings in the future."],
	assaultevent = ["[color=yellow]– Please, please just let me go back to my room… Please, someone could walk by at any time![/color]\n\nYou hear the whimpers from one of the many unoccupied rooms in your mansion. Looking through the door, you see $name with $his back to the wall, $his hands stretched above $his head and held there by $2name. $name’s clothing is partially undone, and as $2name’s hand begins to slide down $name’s stomach and beneath $his waistband, it’s obvious from the look on $his face that $he is not a willing participant.","$2name jumps in shock as you shove the door fully open, allowing it to slam against the wall. $2He quickly steps away from $name and the wall, shoving $2his hands into $2his pockets and attempting to look innocent. Now free, $name scurries towards you as $his savior. With a nod, you tell $him to let you handle this, and gesture $him from the room. Then, you turn to face $2name.\n\n[color=yellow]– I can explain, Master. This is all just a misunderst--[/color]\n\nYou cut off $2name’s protestations with a curt shake of your head, and ask $2him in a cold voice if $2he believes $2he has the right to assault $2his fellow servants, your servants. You slap $2him when $2he tries to respond, and again as $he tries to explain, until finally $he is silent.\n\nAfter that, it’s a simple matter to drag $2name to your dungeon, $2his cries for forgiveness and mercy likely keeping some of your servants awake late into the night.","You watch the assault unfold, $2name’s hand pushing beneath $name’s clothing to the juncture of $his thighs. $name struggles to resist the sensations $2name is forcing on $him, but eventually $his face begins to flush, $his chest rising and falling in breathy moans until $he falls trembling to the ground at $2name’s feet. It’s at that moment that you choose to enter the room.\n\n$2name turns in surprise as you enter the room, but something about your expression informs $2him that you don’t entirely disapprove of $2his actions. Grinning deviously, $2he pushes $name to the floor, holding $him down while $2he looks up at you.\n\n[color=yellow]– $He’s all prepared, Master. Would you like me to hold $him down for you while you have some fun?[/color]\n\n$name tries to struggle, to catch your eye and plead for mercy. But you pay $him little heed as you begin to remove your clothing.","It take a bare minimum of magical effort to send $2name into a brief-but-deep sleep, $2his body collapsing to the floor. A moment’s more spellwork, and $2name’s unconscious form is shackled magically to the wall next to $name, who has begun to squirm as $he realizes you haven’t arrived as $his saviour.\n\n$2name comes-to a few moments later, eyes dazed and muscles tensing as $2he struggles against the magical bonds holding $2him immobile. You slap $2him a few times to still $2him, slapping $name a few times as well for good measure. You explain that their little show has left you quite aroused, and now you intend to do something to solve that little problem.\n\nTheir eyes widen as you begin to strip the clothing from their helpless bodies.","You chuckle to yourself, stepping away from the doorway as $name continues to whimper and protest against $2name’s assault. You decide that it’s not your job to police every interaction between your servants and, clasping your hands behind you back, you stroll away from the room and leave $name to $his feet."],
	sabotagevent = ["Your headgirl approaches you in the evening with some concerns about two of your servants. It seems that $name has been making a number of small mistakes lately, such as breaking some small items or leaving tasks undone. Since each of the mistakes was relatively minor your headgirl handled them personally, but the sheer number of incidents made her feel that you should be informed.\n\nWhen you look into the incidents, you begin to notice an odd coincidence. Every time $name broke an item, your other servant $2name was also nearby. Every time $name left a task undone, $2name was the one who reported $him. Although you have no hard evidence, you begin to suspect that $2name is sabotaging $name, perhaps due to some personal argument or dislike.","[color=yellow]– It’s not fair, Master, please, it’s not fair! I didn’t break those things, I don’t know how they--[/color]\n\n$name’s protestations of innocence are cut off as you force the ballgag into $his mouth, the crowd of servants watching in silence behind you. You bind $name’s arms behind $him and easily lift $him onto the sawhorse, listening to $him squeal as $his full weight falls down onto the sensitive area between $his thighs. A few well-placed spanks only add to the squeals, until $name is flushed in the face with tears in $his eyes.\n\nTurning to the crowd of watching servants, you tell them that $name is going to spend the night thinking about $his mistakes, and they would do well to think about them as well. Then you lead the crowd of servants out of the dungeon, leaving $name alone to suffer on the sawhorse. As you walk by $2name, you can’t help but notice a look of vindictive glee on $2his face.","Looking at the crowd of your servants, you tell them that sabotage, deception and false accusations will not be tolerated. $2name is silent behind you, standing bound and spread with a rope around each wrist and ankle, $2his mouth held open by a ring gag. $2He quickly becomes less silent as the whip begins to fly through the air.\n\nAgain and again the whip falls as $2name twists between the ropes you’ve bound $2him in, leaving light red marks on $2his chest, thighs and arse. Behind you, the crowd of servants inhales each time the whip whistles through the air, echoing $2name’s gasps and cries through the ring gag.\n\nFinally, you decided that $2name has had enough an put the whip down, leaving $2him crying in his bondage. You gesture for all of the watching servants to leave, wanting to have a private word with $2name before you release $2him. Catching a glimpse of $name as $he turns to leave, you see a gleam of justified satisfaction in $his eyes.","Calling both $name and $2name into your study, you tell them what you have learned, and you tell them that you expect them to end whatever feud exists between them, here and now. Shamefaced, they agree, and you order them to show you how friendly they can be with each other.\n\nLeaning back in your chair, you watch as the two servants kiss, their hands fumbling uncertainty up and down each other’s body. Then, once you’re properly excited from their ‘show,’ you order them to work together, to make up to you for your trouble and broken possessions.","You decide that it’s not your duty to dig into the enmities between your servants, or to investigate and second guess every punishable offense  they commit. That in mind, you tell your headgirl to continue punishing $name if $he seems responsible for a mistake, the same as she would any of your other servants."],
}

var eventsdict = {
	play = {function = 'play', reqs = "person.age in ['teen', 'child'] && person.mindage != 'adult'" },
	spendtime = {function = 'spendtime', reqs = "person.age in ['teen', 'adult'] && person.mindage != 'child'" },
	horny = {function = 'horny', reqs = "person.lust >= 50 && person.consent == true" },
	forestfind = {function = 'forestfind', reqs = "person.work in ['forage','hunt']" },
	prositutebuyout = {function = 'prositutebuyout', reqs = "person.work in ['prostitution','escort']" },
	abortion = {function = 'abortion', reqs = "person.preg.duration >= 9 && person.loyal < 40" },
	vacation = {function = 'vacation', reqs = "person.work != 'rest'" },
	accident = {function = 'accident', reqs = "person.sagi < 3"},
	strangerdisrespect = {function = 'strangerdisrespect', reqs = "person.conf > 35"},
	escape = {function = 'escape', reqs = "person.loyal < 15 && person.obed < 60"},
	kidnap = {function = 'kidnap', reqs = "person.work in ['escort','prostitution','fucktoy','store','entertainer','assistant']"},
	gift = {function = 'gift', reqs = "person.obed >= 60"},
	injure = {function = 'injure', reqs = "person.work != 'rest'"},
	escapedslave = {function = 'escapedslave', reqs = "person.work != 'rest'"},
	teenagersflirt = {function = 'teenagersflirt', reqs = "person.beauty >= 40"},
	devotedevent = {function = 'devotedevent', reqs = "person.traits.has('Devoted')"},
	passiveevent = {function = 'passiveevent', reqs = "person.traits.has('Passive') && globals.slaves.size() > 6"},
	masochistevent = {function = 'masochistevent', reqs = "person.traits.has('Masochist')"},
	sluttyevent = {function = 'sluttyevent', reqs = "person.traits.has('Slutty') && globals.slaves.size() > 5"},
	prudeevent = {function = 'prudeevent', reqs = "person.traits.has('Prude') && globals.slaves.size() > 5"},
	fickleevent = {function = 'fickleevent', reqs = "person.traits.has('Fickle')"},
	pervertevent = {function = 'pervertevent', reqs = "person.traits.has('Pervert') && globals.slaves.size() > 5"},
	gardenevent = {function = 'gardenevent', reqs = "#haslover"},
	loverequestevent = {function = 'loverequestevent', reqs = "#haslover"},
	standupevent = {function = 'standupevent', reqs = "#hasfriend"},
	gossipevent = {function = 'gossipevent', reqs = "#hasfriend"},
	mockeryevent = {function = 'mockeryevent', reqs = "#hasenemy"},
	thiefevent = {function = 'thiefevent', reqs = "#hasenemy"},
	assaultevent = {function = 'assaultevent', reqs = "#hashate"},
	sabotagevent = {function = 'sabotagevent', reqs = "#hashate"},
}

func getrandomevent(tempslave):
	var rval
	var eventarray = []
	for i in eventsdict.values():
		if i.reqs.find('#') >= 0:
			findrelations(tempslave, i.reqs)
			if temppartner != null:
				eventarray.append(i.function)
		elif evaluate(i.reqs) == true:
			eventarray.append(i.function)
	if eventarray.size() > 0:
		rval = globals.randomfromarray(eventarray)
	else:
		print('No valid events')
	return rval

func getfixedevent(value):
	return eventsdict[value].function

var temppartner

func findrelations(person,type):
	var partnerarray = []
	for i in person.relations:
		var tempslave = globals.state.findslave(i)
		if tempslave == null || tempslave.away.duration != 0 || tempslave.sleep in ['jail','farm']:
			continue
		if type == '#haslover' && person.relations[i] >= 600:
			 partnerarray.append(globals.state.findslave(i))
		elif type == '#hasfriend' && person.relations[i] >= 200:
			 partnerarray.append(globals.state.findslave(i))
		elif type == '#hashate' && person.relations[i] <= -600:
			 partnerarray.append(globals.state.findslave(i))
		elif type == '#hasenemy' && person.relations[i] <= -200:
			 partnerarray.append(globals.state.findslave(i))
	if partnerarray.size() > 0:
		temppartner = partnerarray[randi()%partnerarray.size()]

func evaluate(input):
	var script = GDScript.new()
	script.set_source_code("var person \nvar person2 \nfunc eval():\n\treturn " + input)
	script.reload()
	var obj = Reference.new()
	obj.set_script(script)
	obj.person = person
	obj.person2 = slave2
	return obj.eval()

func findfreeslave():
	var slavearray = []
	for i in globals.slaves:
		if i.sleep != 'farm' && i.sleep != 'jail' && i.away.duration == 0 && i != person:
			slavearray.append(i)
	return globals.randomfromarray(slavearray)

func dictionary(text = null):
	if text == null:
		text = showntext
	text = person.dictionary(text)
	text = text.replace("$2", "$")
	if slave2 != null:
		text = slave2.dictionary(text)
	return text

func findrelatives(person, type):
	var result
	var candidates = []
	for i in person.relations:
		var tempslave = globals.state.findslave(i)
		if tempslave == globals.player || tempslave == null:
			continue
		if type == 'enemy' && person.relations[i] <= -200:
			candidates.append(tempslave)
		elif type == 'friend' && person.relations[i] >= 200:
			candidates.append(tempslave)
	result = candidates[randi()&candidates.size()]
	return result

func showevent():
	var button
	self.showntext = showntext
	get_node("textpanel/dailyeventtext").set_bbcode(showntext)
	for i in get_node("buttonpanel/buttonscroll/buttoncontainer").get_children():
		if i.name != 'Button':
			i.visible = false
			i.queue_free()
	if buttons == null:
		button = $buttonpanel/buttonscroll/buttoncontainer/Button.duplicate()
		get_node("buttonpanel/buttonscroll/buttoncontainer").add_child(button)
		button.visible = true
		button.set_text("Continue")
		button.connect("pressed", self, 'finishevent')
		return
	for i in buttons:
		button = get_node("buttonpanel/buttonscroll/buttoncontainer/Button").duplicate()
		get_node("buttonpanel/buttonscroll/buttoncontainer").add_child(button)
		button.visible = true
		button.set_text(dictionary(i[0]))
		button.connect("pressed", self, currentevent, [i[1]])
	if person.imageportait != null:
		if globals.canloadimage(person.imageportait):
			get_node("textpanel/Panel").visible = true
			get_node("textpanel/portrait").set_texture(globals.loadimage(person.imageportait))
		else:
			person.imageportait = null
			get_node("textpanel/Panel").visible = false
			get_node("textpanel/portrait").set_texture(null)
	else:
		get_node("textpanel/Panel").visible = false
		get_node("textpanel/portrait").set_texture(null)

var startsex = false
var startsextype = ''

func finishevent():
	self.visible = false
	if startsex:
		startsex = false
		match startsextype:
			'rape2':
				get_parent().sexmode = 'sex'
				get_parent().sexslaves = [slave2]
				get_parent().sexassist = [person]
			'rapeboth':
				get_parent().sexslaves = [person, slave2]
				get_parent().sexmode = 'sex'
		get_parent()._on_startbutton_pressed()
		

######################EVENTS


func play(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [['Play Active Games (-25 energy)', 1], ['Play Logic Games (-25 energy)',2], ['Play Lewd Games (-25 energy)', 3], ['Send $him off',4]]
	if stage == 1:
		person.cour += rand_range(0,10)
		person.conf += rand_range(0,10)
		person.loyal += rand_range(10,15)
		person.stress += -rand_range(15,25)
	elif stage == 2:
		person.wit += rand_range(0,10)
		person.charm += rand_range(0,10)
		person.loyal += rand_range(10,15)
		person.obed += rand_range(15,25)
		person.learningpoints += round(rand_range(3,6))
	elif stage == 3:
		person.lust = -rand_range(5,10)
		person.lewdness += rand_range(3,5)
		person.lastsexday = globals.resources.day
		globals.resources.mana += rand_range(2,3)
		if person.race == "Dark Elf":
			globals.resources.mana += 1
	elif stage == 4:
		person.loyal += -rand_range(5,10)
		person.obed += -rand_range(15,25)
	if stage != 0 && stage != 4:
		globals.player.energy -= 25
	buttons = tempbuttons
	showevent()

func spendtime(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [['Visit Town (-25 energy)', 1], ['Have intimate talk (-25 energy)',2], ['Sex (-25 energy)', 3], ['Send $him off',4]]
	if stage == 1:
		person.cour += rand_range(0,10)
		person.conf += rand_range(0,10)
		person.loyal += rand_range(10,15)
		person.obed += rand_range(15,25)
	elif stage == 2:
		person.wit += rand_range(0,10)
		person.charm += rand_range(0,10)
		person.loyal += rand_range(10,15)
		person.stress += -rand_range(15,25)
	elif stage == 3:
		person.lastsexday = globals.resources.day
		person.lust = -rand_range(15,25)
		globals.resources.mana += rand_range(3,5)
		if person.race == "Dark Elf":
			globals.resources.mana += 1
	elif stage == 4:
		person.loyal += -rand_range(5,10)
		person.obed += -rand_range(15,25)
	if stage != 0 && stage != 4:
		globals.player.energy -= 25
	buttons = tempbuttons
	showevent()

func horny(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [['Accept (-25 energy)', 1], ['Discipline (-25 energy)',2], ['Ignore ', 3]]
	if stage == 1:
		person.lastsexday = globals.resources.day
		person.lust = -rand_range(15,25)
		person.loyal += rand_range(5,10)
		person.stress += -rand_range(15,25)
		globals.resources.mana += rand_range(3,5)
		if person.race == "Dark Elf":
			globals.resources.mana += 1
	elif stage == 2:
		person.obed += rand_range(20,35)
		person.lust = rand_range(15,25)
	elif stage == 3:
		person.obed += -rand_range(25,35)
		person.loyal += -rand_range(5,10)
	if stage != 0 && stage != 3:
		globals.player.energy -= 25
	buttons = tempbuttons
	showevent()

func forestfind(stage = 0):
	var tempbuttons
	var age = ['child','teen']
	var origins = ['slave','poor','commoner']
	if stage == 0:
		slave2 = globals.newslave( globals.getracebygroup(globals.state.location), globals.randomfromarray(age), 'random', globals.randomfromarray(origins))
		showntext = eventstext[currentevent][stage]
		slave2.fromguild = true
		showntext += slave2.descriptionsmall() + "\nWhat would you like to do with $2him?"
		tempbuttons = [['Imprison the $2child', 1], ['Return $2him to town (-25 energy)',2], ["Don't bother with $2him", 3]]
	if stage == 1:
		showntext = eventstext[currentevent][stage]
		slave2.fromguild = false
		globals.get_tree().get_current_scene().get_node("explorationnode").captureeffect(slave2)
	elif stage == 2:
		showntext = eventstext[currentevent][stage]
		globals.resources.gold += rand_range(50,100)
		person.loyal += rand_range(5,10)
		globals.player.energy -= 25
	elif stage == 3:
		showntext = eventstext[currentevent][stage]
		person.loyal += -rand_range(5,10)
	buttons = tempbuttons
	showevent()

var price

func prositutebuyout(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		price = person.calculateprice() * 1.5
		showntext += "[color=yellow]You are offered " + str(round(price)) + " gold for $name. [/color]"
		tempbuttons = [['Sell $name', 1], ['Reject',2], ['Let $name decide.', 3]]
	if stage == 1:
		globals.slaves.remove(globals.slaves.find(person))
		globals.resources.gold += price
	elif stage == 2:
		person.loyal += rand_range(10,15)
		person.obed += rand_range(15,25)
	elif stage == 3:
		if person.loyal < 25:
			showntext += "After some consideration $he agrees and you send them away."
			globals.slaves.remove(globals.slaves.find(person))
			globals.resources.gold += price
		else:
			showntext += "$He hastily rejects this offer and declares $he can only acknowledge you as $his master."
			person.loyal += rand_range(10,15)
	buttons = tempbuttons
	showevent()

func abortion(stage = 0):
	var tempbuttons = null
	showntext = eventstext[currentevent][stage]
	var price
	if stage == 0:
		if globals.itemdict.miscariagepot.amount >= 1:
			tempbuttons.append(['Give miscarriage potion', 1])
		if globals.resources.gold >= 50:
			tempbuttons.append(["Take $name to the slaver's guild for abortion",2])
		tempbuttons.append(['Reassure (-25 energy)',3])
		tempbuttons.append(['Ignore', 4])
	if stage == 1:
		person.abortion()
		globals.itemdict.miscariagepot.amount = -1
		person.obed += rand_range(10,20)
	elif stage == 2:
		person.abortion()
		globals.resources.gold -= 50
		person.obed += rand_range(15,25)
		person.steres = rand_range(15,25)
	elif stage == 3:
		person.loyal += rand_range(10,15)
		person.stress -= rand_range(10,20)
		globals.player.energy -= 25
	elif stage == 4:
		person.loyal -= rand_range(10,15)
		person.stress += rand_range(20,40)
		person.obed -= rand_range(20,40)
	buttons = tempbuttons
	showevent()

func vacation(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [['Accept', 1], ["Refuse", 3]]
		if globals.resources.gold >= 50:
			tempbuttons.insert(1, ['Give some pocket money instead (-50 gold)',2])
	if stage == 1:
		person.away.duration = 4
		person.away.at = 'vacation'
		person.loyal += rand_range(10,15)
	elif stage == 2:
		globals.resources.gold -= 50
		person.loyal += rand_range(5,10)
		person.obed += rand_range(10,15)
	elif stage == 3:
		person.loyal += -rand_range(5,10)
		person.stress += rand_range(10,20)
	buttons = tempbuttons
	showevent()

func accident(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [['Punish (-25 energy)', 1], ["Forgive", 2]]
		globals.resources.gold -= 50
	if stage == 1:
		globals.player.energy -= 25
		person.obed += rand_range(20,35)
		person.fear += 35
	elif stage == 2:
		person.loyal += rand_range(3,6)
	buttons = tempbuttons
	showevent()

func strangerdisrespect(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [["Let him use $name for a day",2], ["Reject", 3]]
		if globals.resources.gold >= 100:
			tempbuttons.insert(0, ['Compensate', 1])
	if stage == 1:
		globals.resources.gold -= 100
		person.loyal += rand_range(10,20)
	elif stage == 2:
		person.away.duration = 1
		person.away.at = 'stranger'
		person.lastsexday = globals.resources.day
		person.loyal -= rand_range(10,15)
		person.obed -= rand_range(15,25)
		person.lewdness += rand_range(3,6)
	elif stage == 3:
		globals.state.reputation.wimborn -= rand_range(3,5)
		person.obed += rand_range(10,20)
		person.stress += rand_range(15,30)
	buttons = tempbuttons
	showevent()

func escape(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [["Be forgiveful (-25 energy)",1],["Be strict (-25 energy)",2], ["Ignore", 3]]
	if stage == 1:
		person.loyal += rand_range(7,15)
		person.obed += rand_range(10,15)
		globals.player.energy -= 25
	elif stage == 2:
		person.obed += rand_range(20,35)
		person.stress += rand_range(15,25)
		person.loyal += rand_range(3,7)
		globals.player.energy -= 25
	elif stage == 3:
		person.obed += -rand_range(10,25)
	buttons = tempbuttons
	showevent()

func kidnap(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		person.stress += rand_range(35,60)
		tempbuttons = [["Rush to the searches(-25 energy)", 1], ["Do nothing", 3]]
		if person.brand != 'none':
			showntext += "Finding a branded person shouldn't be too hard if you start right away. "
		else:
			showntext += "Finding an unbranded person might prove very difficult, especially if something bad happened to $him. "
		var headgirl
		for i in globals.slaves:
			if i.work == 'headgirl' && i.away.duration == 0:
				headgirl = i
				break
		if headgirl != null:
			tempbuttons.insert(1, ["Leave searches to the Headgirl",2])
			slave2 = headgirl
	if stage == 1:
		person.loyal += rand_range(10,20)
		person.obed += rand_range(10,15)
		person.stress += -25
		if person.brand != 'none':
			showntext +=  "in couple of hours."
			globals.player.energy -= 25
		else:
			showntext += "by the end of the day."
			globals.player.energy -= 25
	elif stage == 2:
		if person.brand != 'none':
			person.loyal += rand_range(5,10)
			showntext += " $name is returned to you unharmed. "
		else:
			globals.slaves.remove(globals.slaves.find(person))
			showntext += " there's no news or signs of $name's location and you have no faith $he will appear again. "
	elif stage == 3:
		globals.slaves.remove(globals.slaves.find(person))
	buttons = tempbuttons
	showevent()

func gift(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		if globals.resources.gold < 50:
			tempbuttons = [["Deny", 2]]
		else:
			tempbuttons = [["Comply (-50 gold)",1],["Deny",2], ["Make $name earn it (-25 energy)", 3]]
	if stage == 1:
		person.loyal += rand_range(5,10)
		person.obed += rand_range(10,15)
		globals.resources.gold -= 50
	elif stage == 2:
		person.obed += -rand_range(20,35)
		person.loyal += -rand_range(2,5)
	elif stage == 3:
		if person.consent == false:
			person.obed += -rand_range(20,40)
			person.loyal += -rand_range(5,10)
			showntext += "$name is disgusted by your implications and leaves infuriated. "
		else:
			person.lastsexday = globals.resources.day
			showntext += "You spread your legs and bare your crotch, inviting $name over to which $he readily responds. After couple pleasant minutes of $name's eager mouth work you pass $him the requested money and return to your work. "
			person.obed += rand_range(10,25)
			person.lust = rand_range(10,15)
			person.sexuals.affection += round(rand_range(1,3))
			globals.resources.gold -= 50
			globals.resources.mana += rand_range(3,6)
			if person.race == "Dark Elf":
				globals.resources.mana += 1
			globals.player.energy -= 25
	buttons = tempbuttons
	showevent()

func injure(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		person.health -= person.stats.health_max/3
		tempbuttons = [["Let $name rest for 3 days",1],["Let $name rest for a day",2], ["No rest", 3]]
	if stage == 1:
		person.loyal += rand_range(7,15)
		person.obed += rand_range(10,15)
		person.health += person.stats.health_max
		person.away.duration = 3
		person.away.at = 'rest'
	elif stage == 2:
		person.loyal += rand_range(5,10)
		person.away.duration = 1
		person.away.at = 'rest'
		person.health += person.stats.health_max/6
	elif stage == 3:
		person.stress += rand_range(10,25)
		person.loyal += -rand_range(5,10)
		person.obed += -rand_range(15,35)
	buttons = tempbuttons
	showevent()

func escapedslave(stage = 0):
	var tempbuttons
	var age = ['adult','teen']
	var origins = ['slave','poor']
	if stage == 0:
		slave2 = globals.newslave( globals.getracebygroup(globals.state.location), globals.randomfromarray(age), 'random', globals.randomfromarray(origins))
		slave2.fromguild = true
		tempbuttons = [["Keep $2him to yourself",1],["Return $2him to the city (-25 energy)",2], ["Ignore", 3]]
	if stage == 1:
		slave2.fromguild = false
		globals.slaves = slave2
	elif stage == 2:
		globals.resources.gold += rand_range(50,150)
		globals.player.energy -= 25
	elif stage == 3:
		person.obed += rand_range(5,10)
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func teenagersflirt(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [["Drive them away (-25 energy)",1],["Let $name serve them (-25 energy)",2], ["Ignore", 3]]
	if stage == 1:
		globals.player.energy -= 25
		person.loyal += rand_range(7,15)
		person.obed += rand_range(10,15)
	elif stage == 2:
		globals.player.energy -= 25
		person.metrics.randompartners += round(rand_range(3,5))
		person.metrics.sex += 1
		person.lastsexday = globals.resources.day
		if (person.metrics.vag > 0 || person.metrics.anal > 0) && person.traits.has("Monogamous") == false:
			globals.resources.mana += rand_range(5,10)
			if person.race == "Dark Elf":
				globals.resources.mana += 2
			person.loyal += -rand_range(5,10)
			showntext += "Getting caught up in the action, $name gets on all fours and lets one of the boys take $him from behind. "
			
			if person.vagina != 'none':
				person.metrics.vag += round(rand_range(1,3))
			if person.metrics.anal > 0:
				person.metrics.anal += round(rand_range(1,2))
		else:
			showntext += "$name greatly distressed with situation but having no ways out $he only keeps grudge against you. "
			person.stress += rand_range(15,25)
			person.loyal += -rand_range(10,20)
			person.obed += -rand_range(30,50)
		showntext += "After short time the boys shower the $child in semen. Satisfied with your hospitality, they leave happy. "
		globals.resources.mana += rand_range(3,6)
		if person.race == "Dark Elf":
			globals.resources.mana += 1
	elif stage == 3:
		pass
	buttons = tempbuttons
	showevent()

func devotedevent(stage = 0):
	var tempbuttons
	var origins = ['slave','poor', 'commoner']
	showntext = dictionary(eventstext[currentevent][stage])
	if stage == 0:
		slave2 = globals.newslave( globals.getracebygroup(globals.state.location), 'random', 'random', globals.randomfromarray(origins))
		showntext += '\n' + slave2.descriptionsmall()
		tempbuttons = [["Accept",1],["Reject",2]]
	if stage == 1:
		showntext = eventstext[currentevent][stage]
		globals.slaves = slave2
	elif stage == 2:
		showntext = eventstext[currentevent][stage]
		slave2 = null
	buttons = tempbuttons
	showevent()

func passiveevent(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [["Defend $name (-25 energy)",1],["Support Bullying (-25 energy)",2], ["Ignore", 3]]
	if stage == 1:
		person.loyal += rand_range(7,15)
		person.obed += rand_range(10,20)
		globals.player.energy -= 25
	elif stage == 2:
		person.loyal += -rand_range(10,20)
		person.obed += -rand_range(15,30)
		globals.player.energy -= 25
	elif stage == 3:
		person.stress += rand_range(25,50)
	buttons = tempbuttons
	showevent()

func masochistevent(stage = 0):
	var tempbuttons
	showntext = eventstext[currentevent][stage]
	if stage == 0:
		tempbuttons = [["Punish $name (-25 energy)",1],["Punish $name sexually (-25 energy)",2], ["Ignore", 3]]
	if stage == 1:
		person.lust += rand_range(5,10)
		person.obed += rand_range(15,25)
		person.loyal += rand_range(3,6)
		globals.player.energy -= 25
	elif stage == 2:
		person.lastsexday = globals.resources.day
		person.lust -= rand_range(15,25)
		person.obed += rand_range(15,25)
		person.loyal += rand_range(10,15)
		globals.impregnation(person, globals.player)
	elif stage == 3:
		person.loyal += -rand_range(5,10)
		person.obed += -rand_range(15,35)
	buttons = tempbuttons
	showevent()

func sluttyevent(stage = 0):
	var tempbuttons = null
	slave2 = findfreeslave()
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func prudeevent(stage = 0):
	var tempbuttons = null
	slave2 = findfreeslave()
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func fickleevent(stage = 0):
	var tempbuttons
	if stage == 0:
		tempbuttons = [["Shoo them away (-25 energy)",1],["Have threesome (-25 energy)",2], ["Ignore", 3]]
	if stage == 1:
		person.loyal += -rand_range(7,15)
		person.obed += -rand_range(10,20)
		person.lust = rand_range(15,25)
		globals.player.energy -= 25
	elif stage == 2:
		person.loyal += rand_range(5,10)
		person.consent = true
		globals.impregnation(person)
		person.lust = -rand_range(10,20)
		globals.player.energy -= 25
		globals.resources.mana += rand_range(4,10)
		person.lastsexday = globals.resources.day
		if person.race == "Dark Elf":
			globals.resources.mana += 2
	elif stage == 3:
		person.lastsexday = globals.resources.day
		person.lust = -rand_range(10,20)
	buttons = tempbuttons
	showntext = eventstext[currentevent][stage]
	
	showevent()

func pervertevent(stage = 0):
	var tempbuttons
	if stage == 0:
		slave2 = findfreeslave()
		tempbuttons = [["Interrupt them (-25 energy)",1],["Escalate the situtation (-25 energy)",2], ["Ignore", 3]]
	if stage == 1:
		person.loyal -= rand_range(5,10)
		slave2.loyal += rand_range(5,10)
		person.obed += -rand_range(10,20)
		globals.player.energy -= 25
	elif stage == 2:
		person.lastsexday = globals.resources.day
		slave2.lastsexday = globals.resources.day
		person.loyal += rand_range(5,10)
		person.lust = -rand_range(10,20)
		slave2.obed += -rand_range(10,30)
		slave2.lust = -rand_range(10,15)
		globals.player.energy -= 25
		globals.resources.mana += rand_range(5,10)
		if person.race == "Dark Elf":
			globals.resources.mana += 2
	buttons = tempbuttons
	showntext = eventstext[currentevent][stage]
	
	showevent()

func gardenevent(stage = 0):
	var tempbuttons
	match stage:
		0:
			findrelations(person, '#haslover')
			slave2 = temppartner
			tempbuttons = [['Let them continue', 1], ['Interrupt and humilate', 2]]
		1:
			person.loyal += 10
			slave2.loyal += 10
		2:
			person.stress += 25
			slave2.stress += 25
			globals.addrelations(person, slave2, -150)
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func loverequestevent(stage = 0):
	var tempbuttons
	match stage:
		0:
			findrelations(person, '#haslover')
			slave2 = temppartner
			tempbuttons = [['Allow it', 1], ['Deny and punish', 2]]
			if globals.itemdict.amnesiapot.amount >= 1:
				tempbuttons.append( ['Use Amnesia Potion',3])
		1:
			person.loyal += 10
			slave2.loyal += 5
			globals.addrelations(person, slave2, 50)
		2:
			person.stress += 25
			slave2.stress += 25
			globals.addrelations(person, slave2, -150)
		3:
			globals.itemdict.amnesiapot.amount -= 1
			slave2.stress += 20
			globals.addrelations(person, slave2, 0)
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func standupevent(stage = 0):
	var tempbuttons
	match stage:
		0:
			findrelations(person, '#hasfriend')
			slave2 = temppartner
			tempbuttons = [['Intervene to Help', 1], ['Bully with others', 2], ['Ignore',3]]
		1:
			person.loyal += 10
			slave2.loyal += 10
			globals.addrelations(person, slave2, 50)
		2:
			person.stress += 40
			slave2.stress += 40
			person.loyal -= 20
			slave2.loyal -= 200
			globals.addrelations(person, slave2, -150)
		3:
			person.stress += 10
			slave2.stress += 10
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func gossipevent(stage = 0):
	var tempbuttons
	match stage:
		0:
			findrelations(person, '#hasfriend')
			slave2 = temppartner
			tempbuttons = [['Join in', 1], ['Reprimand and Punish', 2], ['Ignore',3]]
		1:
			person.loyal += 10
			slave2.loyal += 10
			globals.addrelations(person, slave2, 50)
		2:
			person.stress += 25
			slave2.stress += 25
			globals.addrelations(person, slave2, -150)
		3:
			pass
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func mockeryevent(stage = 0):
	var tempbuttons
	match stage:
		0:
			findrelations(person, '#hasenemy')
			slave2 = temppartner
			tempbuttons = [['Punish $name', 1], ['Join the bullying', 2], ['Ignore',3]]
		1:
			person.stress += 20
			slave2.loyal += 10
			globals.addrelations(person, slave2, 75)
		2:
			person.loyal += 10
			slave2.stress += 40
			slave2.loyal -= 20
			globals.addrelations(person, slave2, -150)
		3:
			person.stress -= 15
			slave2.stress += 25
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()


func thiefevent(stage = 0):
	var tempbuttons
	match stage:
		0:
			findrelations(person, '#hasenemy')
			slave2 = temppartner
			tempbuttons = [['Help out and punish $2name', 1], ['Reprimand and Punish $name', 2], ['Ignore',3]]
		1:
			person.loyal += 15
			slave2.loyal -= 5
			slave2.stress += 20
			globals.addrelations(person, slave2, 100)
		2:
			person.stress += 25
			person.loyal -= 5
		3:
			person.obed -= 25
			globals.addrelations(person, slave2, -100)
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func assaultevent(stage = 0):
	var tempbuttons
	match stage:
		0:
			findrelations(person, '#hashate')
			slave2 = temppartner
			tempbuttons = [['Intervene and Punish $2name', 1], ['Join in', 2], ['Assault both',3], ['Ignore',4]]
		1:
			person.loyal += 15
			slave2.stress += 30
			globals.addrelations(person, slave2, 100)
		2:
			person.stress += 50
			slave2.loyal += 15
			globals.addrelations(person, slave2, -50)
			startsex = true
			startsextype = 'rape2'
		3:
			person.stress += 10
			slave2.stress += 10
			globals.addrelations(person, slave2, 100)
			startsex = true
			startsextype = 'rapeboth'
		4:
			person.stress += 40
			globals.addrelations(person, slave2, -150)
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()

func sabotagevent(stage = 0):
	var tempbuttons
	match stage:
		0:
			findrelations(person, '#hasenemy')
			slave2 = temppartner
			tempbuttons = [['Publicly punish $name', 1], ['Publicly punish $2name', 2], ['Privately punish both', 3], ['Ignore',4]]
		1:
			person.loyal -= 10
			person.stress += 25
			globals.addrelations(person, slave2, -100)
		2:
			slave2.obed += 25
			slave2.stress += 25
			globals.addrelations(person, slave2, -50)
		3:
			person.stress += 20
			slave2.stress += 20
			globals.addrelations(person, slave2, 100)
		4:
			globals.addrelations(person, slave2, -100)
	showntext = eventstext[currentevent][stage]
	buttons = tempbuttons
	showevent()
