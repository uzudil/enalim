SECTIONS["26,25"] := {
    "init": this => {
        setCreature(5307, 5012, 1, creaturesTemplates.goblin);
        setCreature(5312, 5033, 1, creaturesTemplates.goblin);
        setCreature(5323, 5051, 1, creaturesTemplates.goblin);
        setCreature(5353, 5036, 1, creaturesTemplates.goblin);
        setCreature(5365, 5024, 1, creaturesTemplates.goblin);
        setCreature(5365, 5024, 1, creaturesTemplates.goblin);
    },
    "teleport": (this, x, y, z) => {
        if(x = 5293 && y >= 5022 && y < 5026 && z = 1) {
            return [ 5400, 5146, 1 ];
        } else if(x = 5396 && y >= 5146 && y < 5150 && z = 1) {
            return [ 5297, 5022, 1 ];
        }
        return null;
    },
    "locked": (this, x, y, z) => {
        if(x = 5208 && y = 5017 && z = 1) {
            return "key.ourdlen2";
        }
        return null;
    },
    "action": (this, x, y, z) => {
        if(x = 5396 && y = 5010 && z = 1) {
            timedMessage(x, y, z, "Road to Trinest", false);
            return true;
        }
        return null;
    }
};
