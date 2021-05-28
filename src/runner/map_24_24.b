const ghost = {
    "name": "ghost",
    "label": "Ghost of Lydell",
    "creature": "ghost",
    "convo": {
        "": "I... oooo... arakw..."
    },
    "schedule": [
        { "from": 5, "to": 21, "pos": [ 4974, 4934, 1 ], "movement": "anchor" },
        { "from": 21, "to": 5, "pos": [ 4974, 4971, 1 ], "movement": "anchor" },
    ],    
};

const MAP_24_24 = {
    "staticInit": this => {
        registerNpc(ghost);
    },
    "init": this => {
        setNpc(4974, 4934, 1, ghost);
        setBook(4997, 4992, 10, "map", "Raising the dead");
    },
    "teleport": (this, x, y, z) => {
        if(x >= 4996 && x <= 4999 && y = 4986 && z = 1) {
            return [5004, 5031, 1];
        }
        return null;
    }
};
