SECTIONS["26,24"] := {
    "init": this => {
        setCreature(5391, 4884, 1, creaturesTemplates.goblin);
        setCreature(5376, 4936, 1, creaturesTemplates.goblin);
        setCreature(5376, 4945, 1, creaturesTemplates.goblin);
        setCreature(5378, 4959, 1, creaturesTemplates.ogre);
        setCreature(5367, 4961, 1, creaturesTemplates.goblin);
        setCreature(5375, 4981, 1, creaturesTemplates.spirit);
        setCreature(5367, 4981, 1, creaturesTemplates.spirit);
        setCreature(5359, 4981, 1, creaturesTemplates.spirit);
        setCreature(5333, 4959, 1, creaturesTemplates.goblin);
        setCreature(5327, 4959, 1, creaturesTemplates.goblin);
        setCreature(5311, 4991, 1, creaturesTemplates.goblin);
    },
    "teleport": (this, x, y, z) => {
        if(x >= 5396 && x < 5400 && y >= 4908 && y < 4912 && z = 1) {
            return [ 5370, 4909, 1 ];    
        } else if(x = 5368 && y >= 4908 && y < 4912 && z = 1) {
            return [ 5397, 4914, 1 ];
        } else if(x = 5293 && y >= 4986 && y < 4990 && z = 1) {
            return [ 5510, 5067, 1 ];
        }
        return null;
    },
    "locked": (this, x, y, z) => {
        return null;
    },
};
