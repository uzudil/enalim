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
