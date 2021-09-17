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

# addNpcDef({
#     "name": "alton",
#     "label": "Alton",
#     "creature": "man-yellow",
#     "convo": {
#         "": "Welcome traveler to Sylvanes",
#     },
#     "schedule": [
#         { "from": 17, "to": 22, "pos": [ 5399, 4997, 1 ], "movement": "anchor" },
#         { "from": 22, "to": 17, "pos": [ 5449, 5032, 1 ], "movement": "anchor" },
#     ],
# });

# addNpcDef({
#     "name": "zanka",
#     "label": "Zanka",
#     "creature": "woman.brown",
#     "convo": {
#         "": "Welcome traveler to Sylvanes",
#     },
#     "schedule": [
#         { "from": 15, "to": 22, "pos": [ 5388, 5003, 1 ], "movement": "anchor" },
#         { "from": 22, "to": 15, "pos": [ 5413, 4975, 1 ], "movement": "anchor" },
#     ],
# });
