addNpcDef({
    name: "ennid",
    label: "Ennid",
    creature: "woman",
    convo: {
        "": "You see sharp-eyed woman before you. \"I am Ennid and run he $weapons shop here in $Trinest.\"",
        "weapons": () => {
            # trading goes here... (it should only work on schedule 0)
            return "todo";
        },
        "Trinest": "\"Trinest is the east-most town on the Enalim mainland. East of us is just the ocean and some $insignificant small islands.\"",
        "insignificant": "Hmm, seems like she doesn't know about the Necromancer's island. Maybe you should $tell her. Then again, that's the kind of detail that gets one killed in places like this. Ask her about $weapons instead.",
        "tell": "You pointificate about the island of the Necromancer. \"Fascinating.\" - she says, without a hint of interest - \"Well, let me know if you need any $weapons!\" - she continues.",
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
    convo: {
        "": "Welcome traveler to Sylvanes",
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
