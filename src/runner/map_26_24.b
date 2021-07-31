const ennid = {
    "name": "ennid",
    "label": "Ennid",
    "creature": "woman",
    "convo": {
        "": "Welcome traveler to Sylvanes",
    },
    "schedule": [
        { "from": 11, "to": 22, "pos": [ 5382, 4998, 1 ], "movement": "anchor" },
        { "from": 22, "to": 11, "pos": [ 5384, 4964, 1 ], "movement": "anchor" },
    ],
};
addNpcDef(ennid);

const hamid = {
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
};
addNpcDef(hamid);

const alton = {
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
};
addNpcDef(alton);

const zanka = {
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
};
addNpcDef(zanka);

SECTIONS["26,24"] := {
    "init": this => {
        setNpc(5382, 4998, 1, ennid);
        setNpc(5388, 4997, 1, hamid);
        setNpc(5388, 5003, 1, zanka);
        setNpc(5399, 4997, 1, alton);
    },
    "teleport": (this, x, y, z) => {
        return null;
    },
    "locked": (this, x, y, z) => {
        return null;
    },
};
