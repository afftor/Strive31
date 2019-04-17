extends Node
#warning-ignore:unused_class_variable
var basehealth = 50.0
#warning-ignore:unused_class_variable
var healthperend = 25.0
#warning-ignore:unused_class_variable
var geardropchance = 15.0
#warning-ignore:unused_class_variable
var enchantitemprice = 1.5
#warning-ignore:unused_class_variable
var sellingitempricemod = 0.2
#warning-ignore:unused_class_variable
var basefoodconsumption = 10.0
#warning-ignore:unused_class_variable
var skillpointsperlevel = 2.0
#warning-ignore:unused_class_variable
var timeforinteraction = 20.0
#warning-ignore:unused_class_variable
var consumerope = 1.0
#warning-ignore:unused_class_variable
var learnpointsperstat = 3.0
#warning-ignore:unused_class_variable
var attributepointsperupgradepoint = 1.0


#warning-ignore:unused_class_variable
var playerstartbeauty = 40.0
#warning-ignore:unused_class_variable
var characterstartbeauty = 40.0

#warning-ignore:unused_class_variable
var basesexactions = 1.0
#warning-ignore:unused_class_variable
var basenonsexactions = 1.0

#warning-ignore:unused_class_variable
var playerbonusstatpoint = 2.0

#warning-ignore:unused_class_variable
var banditishumanchance = 70.0

#Pregnancies
#warning-ignore:unused_class_variable
var pregduration = 31.0
#warning-ignore:unused_class_variable
var growuptimechild = 15.0
#warning-ignore:unused_class_variable
var growuptimeteen = 20.0
#warning-ignore:unused_class_variable
var growuptimeadult = 25.0
#warning-ignore:unused_class_variable
var traitinheritchance = 80.0
#warning-ignore:unused_class_variable
var babynewtraitchance = 20.0

#slave stats & combat
#warning-ignore:unused_class_variable
var damageperstr = 3.0
#warning-ignore:unused_class_variable
var speedperagi = 3.0
#warning-ignore:unused_class_variable
var speedbase = 10.0
#warning-ignore:unused_class_variable
var baseattack = 5.0
#warning-ignore:unused_class_variable
var basecarryweight = 10.0
#warning-ignore:unused_class_variable
var carryweightperstrplayer = 4.0
#warning-ignore:unused_class_variable
var baseslavecarryweight = 3.0
#warning-ignore:unused_class_variable
var slavecarryweightperstr = 5.0


#slave prices constants
#warning-ignore:unused_class_variable
var priceperlevel = 40.0
#warning-ignore:unused_class_variable
var priceperbasebeauty = 2.5
#warning-ignore:unused_class_variable
var priceperbonusbeauty = 1.5
#warning-ignore:unused_class_variable
var pricebonusvirgin = 0.15
#warning-ignore:unused_class_variable
var pricebonusfuta = 0.1
#warning-ignore:unused_class_variable
var pricebonusbadtrait = -0.1
#warning-ignore:unused_class_variable
var pricebonustoxicity = -0.33
#warning-ignore:unused_class_variable
var priceuncivilized = -0.5
#warning-ignore:unused_class_variable
var priceminimum = 5.0
#warning-ignore:unused_class_variable
var priceminimumsell = 10.0

#globals arrays
#var starting_pc_races = ['Human', 'Elf', 'Dark Elf', 'Orc', 'Demon', 'Beastkin Cat', 'Beastkin Wolf', 'Beastkin Fox', 'Halfkin Cat', 'Halfkin Wolf', 'Halfkin Fox', 'Taurus']
#var wimbornraces = ['Human', 'Elf', 'Dark Elf', 'Demon', 'Beastkin Cat', 'Beastkin Wolf','Beastkin Tanuki','Beastkin Bunny', 'Halfkin Cat', 'Halfkin Wolf', 'Halfkin Tanuki','Halfkin Bunny','Taurus','Fairy']
#var gornraces = ['Human', 'Orc', 'Goblin', 'Gnome', 'Taurus', 'Centaur','Beastkin Cat', 'Beastkin Tanuki','Beastkin Bunny', 'Halfkin Cat','Halfkin Bunny','Harpy']
#var frostfordraces = ['Human','Elf','Drow','Beastkin Cat', 'Beastkin Wolf', 'Beastkin Fox', 'Beastkin Tanuki','Beastkin Bunny', 'Halfkin Cat', 'Halfkin Wolf', 'Halfkin Fox','Halfkin Bunny', 'Nereid']
#var allracesarray = ['Human', 'Elf', 'Dark Elf', 'Orc', 'Drow','Beastkin Cat', 'Beastkin Wolf', 'Beastkin Fox','Beastkin Tanuki','Beastkin Bunny', 'Halfkin Cat', 'Halfkin Wolf', 'Halfkin Fox','Halfkin Tanuki','Halfkin Bunny','Taurus', 'Demon', 'Seraph', 'Gnome','Goblin','Centaur','Lamia','Arachna','Scylla', 'Slime', 'Harpy','Dryad','Fairy','Nereid','Dragonkin']
#var banditraces = ['Human', 'Elf', 'Dark Elf', 'Demon', 'Cat', 'Wolf','Bunny','Taurus','Orc','Goblin']
#var monsterraces = ['Centaur','Lamia','Arachna','Scylla', 'Slime', 'Harpy','Nereid']


#sidecharacters
#warning-ignore:unused_class_variable
var oldemily = false

#warning-ignore:unused_class_variable
var gradepricemod = { # grade and age mods will be added as bonus to base price which starts at 1 [baseprice*(1+value)]
	"slave": -0.2, poor = 0, commoner = 0.2, rich = 0.5, noble = 1
	}
#warning-ignore:unused_class_variable
var agepricemods = {
	child = 0, teen = 0, adult = 0
}

#warning-ignore:unused_class_variable
var luxuryreqs = {"slave" : 0, poor = 5, commoner = 15,rich = 25, noble = 40}


#warning-ignore:unused_class_variable
var list = {
basehealth = {descript = "Character's health before modifiers", default = 50, min = 1, max = 1000},
healthperend = {descript = "Bonus health per point of endurance",default = 25, min = 0, max = 1000},
geardropchance = {descript = "Percent chance of getting enemy's gear on defeat", default = 15, min = 0, max = 100},
pregduration = {descript = "Basic pregnancy duration in days", default = 31, min = 1, max = 1000},
enchantitemprice = {descript = "Selling price modifier for enchanted gear", default = 1.5, min = 0, max = 10},
sellingitempricemod = {descript = "Selling price modifier for all items", default = 0.2, min = 0, max = 1},
basefoodconsumption = {descript = "Basic food consumption for characters per day", default = 10, min = 1, max = 100},
skillpointsperlevel = {descript = "Attribute points gained on levelup", default = 2, min = 1, max = 10},
timeforinteraction = {descript = "Number of actions you can perform during interaction sequence", default = 20, min = 1, max = 50},
consumerope  = {descript = "Number of ropes to be consumed when capturing a slave in the wild", default = 1, min = 0, max = 5,},
learnpointsperstat = {descript = "Number of skill points required to increase mental stat by 1", default = 3, min = 1, max = 100},
playerstartbeauty = {descript = "Player's starting beauty stat"},
characterstartbeauty = {descript = "Starting slave's starting beauty stat"},
basesexactions = {descript = 'Number of sex actions per day (before bonus from endurance)'},
basenonsexactions = {descript = 'Number of non-sex actions per day (before bonus) '},
growuptimechild = {descript = 'Time required for baby to mature'},
growuptimeteen = {descript = 'Time required for baby to mature'},
growuptimeadult = {descript = 'Time required for baby to mature'},
traitinheritchance = {descript = "Chance to inherit a parent's trait"},
babynewtraitchance = {descript = "Chance to gain a new trait"},
damageperstr = {descript = 'Raw damage per strength'},
speedperagi = {descript = 'Raw speed per agility'},
speedbase = {descript = 'Base speed for all characters'},
baseattack = {descript = 'Base attack for all characters'},
priceperlevel = {descript = 'Slave price modificator per level'},
priceperbasebeauty = {descript = 'Slave price modificator per beauty'},
priceperbonusbeauty = {descript = 'Slave price modificator per bonus beauty'},
pricebonusvirgin = {descript = 'Slave price modificator for virgins'},
pricebonusfuta = {descript = 'Slave price modificator for futa'},
pricebonusbadtrait = {descript = 'Slave price modificator for bad traits'},
pricebonustoxicity = {descript = 'Slave price modificator for high toxicity'},
priceuncivilized = {descript = 'Slave price modificator for uncivilized trait'},
priceminimum = {descript = 'Minimum slave buy price'},
priceminimumsell = {descript = 'Minimum slave sell price'},
oldemily = {descript = 'Use old Emily sprite'},

playerbonusstatpoint = {descript = 'Bonus player stat points during char creation'},
basecarryweight = {descript = 'Base carry weight'},
carryweightperstrplayer = {descript = 'Bonus carry weight from player strength'},
baseslavecarryweight = {descript = 'Bonus carry weight for having a slave in party'},
slavecarryweightperstr = {descript = "Bonus carry weight per slave's point of strength"},

}