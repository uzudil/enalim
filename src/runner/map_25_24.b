const MAP_25_24 = {
    "init": this => {
        setCreature(5019, 4993, 1, creaturesTemplates.cow);
    },
    "teleport": (this, x, y, z) => {
        if(x = 5005 && y <= 4971 && y >= 4967 && z = 1) {
            return [5178, 5084, 2];
        }
        return null;
    }    
};
