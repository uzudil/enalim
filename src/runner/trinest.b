addNpcDef({
    name: "ennid",
    label: "Ennid",
    creature: "woman",
    trade: CAT_WEAPON,
    convo: {
        "": "You see sharp-eyed woman before you. \"I am Ennid and run he weapons shop here in $Trinest.\"",
        "Trinest": "\"Trinest is the east-most town on the Enalim mainland. East of us is just the ocean and some $insignificant small islands.\"",
        "insignificant": "Hmm, seems like she doesn't know about the Necromancer's island. Maybe you should $tell her. Then again, that's the kind of detail that gets one killed in places like this. Maybe buy something instead.",
        "tell": "You pointificate about the island of the Necromancer. \"Fascinating.\" - she says, without a hint of interest - \"Well, let me know if you need any weapons!\" - she continues.",
    },
    waypoints: [ [ 5441, 5015, 1 ], [ 5440, 5027, 1 ], [ 5456, 5027, 1 ], [ 5454, 5044, 1 ], [ 5439, 5042, 1 ] ], 
    schedule: [
        { name: "store", from: 8, to: 18, movement: "anchor", waypointDir: 1 },
        { name: "home", from: 18, to: 8, movement: "anchor", waypointDir: -1 }
    ],
});

addNpcDef({
    name: "hamid",
    label: "Hamid",
    creature: "man-blue",
    trade: CAT_ARMOR,
    convo: {
        "": "A man with a warm smile says: \"Be welcome in Trinest wanderer. I buy and sell armor at my shop. Our $town may be small but rest assured my shop is well equipped. Just ask if you need anything.\"",
        "town": "\"Trinest is the last town on the east side of the Enalim mainland. My name is Hamid and I trade in high quality armor.\"",
    },
    waypoints: [ [ 5413, 5036, 1 ], [ 5426, 5039, 1 ], [ 5414, 5051, 1 ], [ 5405, 5065, 1 ], [ 5419, 5079, 1 ], [ 5416, 5063, 1 ] ],
    schedule: [
        { name: "store", from: 8, to: 18, movement: "anchor", waypointDir: 1 },
        { name: "home", from: 18, to: 8, movement: "anchor", waypointDir: -1 },
    ],
});

addNpcDef({
    name: "ender",
    label: "Ender",
    creature: "man-yellow",
    convo: {
        "": () => {
            if(player.convo.npc.activeSchedule = 0) {
                return "You see a portly man who has obviously been sampling the local ale: \"Hello there stranger\"
                     - he slurs slightly - \"you have the look of an $adventurer. I also used to roam the lands freely, 
                     but lately I've been $stuck in Trinest.\"";
            } else {
                return "The portly man seems irritated by the interruption: \"Yes, yes that's very interesting but 
                    you see I'm quiet tired. Talk to me tomorrow in the $pub.\"";
            }
        },
        "pub": "He points to the inn's downstairs pub: \"By that I mean the pub downstairs. I'll talk to you there tomorrow.\"",
        "adventurer": "He looks you up and down: \"I could be wrong, but you have the look of somone who is on a mission. 
            What is it that you $seek?\"",
        "seek": "You can't decide if he's trustworthy or not. Will you mention that you're looking for $Fearon? Or ask 
            why he's $stuck in Trinest?",
        "stuck": "He nods and says: \"Aye, I also was an $adventurer for a time and my quest led me here to Trinest.\". 
            He sighs and continues: \"I was on the trail of a jewel thief for a large reward, however the thief entered the
            dungeon $Ravenous and I dare not follow him there.\"",
        "Ravenous": "\"Ravenous is a large dungeon just north-east of here. Follow the road and it will guide you there. But beware, 
            its depths are fill with loathsome horrors. Unless you're very foolish or very brave, I would not advise you to enter there. 
            Many an $adventurer paid the ultimate price for their curiosity in Ravenous!\"",
        "Fearon": "You mention that you're looking for a man named Fearon. The portly man nods and says: \"I know Fearon well. I would 
            gladly direct you to him if you could just do me a small $favor.\"",
        "favor": "He moves closes and whispers conspiratorially: \"You seem like a very brave and experienced $adventurer.\" - he
            smiles creepily - \"Despite my personal misgivings about the dungeon $Ravenous, I believe you could brave its depths 
            and bring me the $jewel the thief was carrying. Do that and I will show you the way to Fearon.\"",
        "jewel": "He winks at you and says: \"You could certainly keep the jewel, but then you'll never find $Fearon. Bring it to
            me instead and I will personally give you his location.\". Seems like a reasonable trade, you think."
    },
    waypoints: [ [ 5472, 5028, 1 ], [ 5481, 5017, 1 ], [ 5465, 5021, 8 ], [ 5482, 5034, 8 ] ],
    schedule: [
        { name: "pub", from: 10, to: 22, movement: "anchor", waypointDir: -1 },
        { name: "room", from: 22, to: 10, movement: "anchor", waypointDir: 1 },
    ],
});

addNpcDef({
    name: "zanka",
    label: "Zanka",
    creature: "woman.brown",
    convo: {
        "": () => {
            if(player.convo.npc.activeSchedule = 0) {
                return "You see a well dressed woman with a regal air: \"What is it you want $commoner? Can't you see
                I'm enjoying my privacy? Bother me no longer!\" - she pauses to look at you and adds: \"Unless you
                have come to bring me news of my $estate.\"";
            } else {
                return "The well dressed woman seems alarmed to see you: \"What do you think you're doing bothering me 
                so late? Away with you!\" - she pauses, then adds: \"But if you have news about my $estate then I suppose
                I will forgive your intrusion.\"";
            }
        },
        "commoner": "You are not sure what this means but you decide to take offence nonetheless. You entertain the idea
            of stomping off in a huff but then you remember that she said something about here $estate. You sense there's
            money to be made and an adventure waiting here.",
        "estate": "She sighs heavily and continues: \"Despite my best efforts at traveling incognito, I'm sure you $recognize me
            as the Grand Duchess of and Heiress of $Wyntergale. You may refer to me as 'your $Eminance.'\" - she pauses for effect.",
        "Eminance": "You mock-bow to show you understand. This seems to please her: \"That's better. It's good to see a youth of
            culture and good upbringing. Perhaps you can help me get back to my $estate.\"",
        "Wyntergale": "She nods: \"Aye Wyntergale is my castle along the banks of the Efron river. However its warm hearth is cold now,
            for an evil presence has taken home there. I was forced to go abroad and now dwell in this\" - she motions around you
            \"rather squalid inn. If someone brave and heroic could $vanquish the $demon that dwells in my castle, I'd be 
            forever grateful.\"",
        "vanquish": "She clutches her pearl necklace and says desperately: \"Oh please, please give it a try! Tell me when I can 
            safely return home to $Wyntergale and I will be sure to reward you! You can always find me here at the inn.\"",
        "demon": "\"I don't actually know what manner of beast has taken home in my former $estate. But from the vile smells that
            emanate from the lower levels, I can only assume it must a fiend from the pits! Please do $vanquish it for me!\"",
    },
    waypoints: [ [ 5472, 5035, 1 ], [ 5482, 5017, 1 ], [ 5465, 5021, 8 ], [ 5482, 5021, 8 ] ],
    schedule: [
        { name: "pub", from: 11, to: 23, movement: "anchor", waypointDir: -1 },
        { name: "room", from: 23, to: 11, movement: "anchor", waypointDir: 1 },
    ],
});

addNpcDef({
    name: "Arenil",
    label: "Arenil",
    creature: "woman2",
    convo: {
        "": () => {
            if(player.convo.npc.activeSchedule = 0) {
                return "A woman greets you with a friendly smile: \"Welcome to the Last Chance $Inn at $Trinest, friend. 
                    Let me know if you're looking to buy or sell food or other traveling supplies.\"";
            } else {
                return "\"Please come back later when the $Inn is open!\"";
            }
        },
        "Inn": "\"The Last Chance Inn is the east-most Inn in all of Enalim. We're in the center of the town of $Trinest 
            serving both $regulars and travelers. I also sell supplies to traveling adventurers like yourself.\"",
        "Trinest": "\"Trinest is the east-most town in the land of Enalim, though\" - she nods conspiratorially - \"I've heard
            rumors that a chain of small islands lies in the ocean to the east of us. Home to people who don't want to be found, I guess.\"",
        "regulars": "She points to the upstairs rooms and says: \"I usually have a few longer-term guests staying upstairs. 
        You can ask them about their business, but please don't bother them in their rooms.\""
    },
    waypoints: [ [ 5467, 5041, 1 ], [ 5472, 5036, 1 ], [ 5481, 5017, 1 ], [ 5465, 5022, 8 ], [ 5468, 5029, 8 ] ],
    schedule: [
        { name: "pub", from: 11, to: 23, movement: "anchor", waypointDir: -1 },
        { name: "room", from: 23, to: 11, movement: "anchor", waypointDir: 1 },
    ],    
});
