SECTIONS["27,24"] := {
    "init": this => {
        setCreature(5409, 4917, 1, creaturesTemplates.goblin);
        setCreature(5414, 4931, 1, creaturesTemplates.goblin);
        setCreature(5406, 4937, 1, creaturesTemplates.goblin);
    },
    "teleport": (this, x, y, z) => {
        if(x = 5400 && y <= 4971 && y >= 4968 && z = 1) {
            return [5482, 5019, 1];
        }
        return null;
    },
    "locked": (this, x, y, z) => {
        return null;
    },
    "action": (this, x, y, z) => {
        if(x = 5401 && y = 4912 && z = 1) {
            timedMessage(x, y, z, "North entrance to Ravenous", false);
            return true;
        }
        return null;
    }
};
