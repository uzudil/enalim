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
    schedule: [
        { from: 8, to: 18, pos: [ 5439, 5042, 1 ], movement: "anchor", radius: 2 },
        { from: 18, to: 8, pos: [ 5440, 5014, 1 ], movement: "anchor" },
    ],
});

addNpcDef({
    "name": "hamid",
    "label": "Hamid",
    "creature": "man-blue",
    "convo": {
        "": "Welcome traveler to Sylvanes",
    },
    "schedule": [
        { "from": 18, "to": 22, "pos": [ 5388, 4997, 1 ], "movement": "anchor" },
        { "from": 22, "to": 18, "pos": [ 5421, 5005, 1 ], "movement": "anchor" },
    ],
});

addNpcDef({
    "name": "alton",
    "label": "Alton",
    "creature": "man-yellow",
    "convo": {
        "": "Welcome traveler to Sylvanes",
    },
    "schedule": [
        { "from": 17, "to": 22, "pos": [ 5399, 4997, 1 ], "movement": "anchor" },
        { "from": 22, "to": 17, "pos": [ 5449, 5032, 1 ], "movement": "anchor" },
    ],
});

addNpcDef({
    "name": "zanka",
    "label": "Zanka",
    "creature": "woman.brown",
    "convo": {
        "": "Welcome traveler to Sylvanes",
    },
    "schedule": [
        { "from": 15, "to": 22, "pos": [ 5388, 5003, 1 ], "movement": "anchor" },
        { "from": 22, "to": 15, "pos": [ 5413, 4975, 1 ], "movement": "anchor" },
    ],
});
