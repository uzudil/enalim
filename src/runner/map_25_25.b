const MAP_25_25 = {
    "init": this => {
        setCreature(5023, 5001, 1, creaturesTemplates.cow);
    },
    "teleport": (this, x, y, z) => {
        if(x = 5000 && y <= 5034 && y >= 5030 && z = 1) {
            return [4998, 4993, 1];
        }
        return null;
    }    
};
