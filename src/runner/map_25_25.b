const MAP_25_25 = {
    "init": this => {
        setCreature(5040, 5075, 1, creaturesTemplates.cow);
        setCreature(5032, 5061, 1, creaturesTemplates.cow);
    },
    "teleport": (this, x, y, z) => {
        return null;
    }    
};
