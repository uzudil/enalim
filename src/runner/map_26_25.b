const hermil = {
    "name": "hermil",
    "label": "Brother Hermil",
    "creature": "monk",
    "convo": {
        "": "Hello there!",
    },
    "schedule": [
        { "from": 8, "to": 18, "pos": [ 5223, 5014, 1 ], "movement": "anchor" },
        { "from": 18, "to": 8, "pos": [ 5217, 5035, 1 ], "movement": "anchor" },
    ],
};
addNpcDef(hermil);


SECTIONS["26,25"] := {
    "init": this => {
        setNpc(5223, 5014, 1, hermil);
    },
    "teleport": (this, x, y, z) => {
        return null;
    }
};
