SECTIONS["21,20"] := {
    "init": this => {
        setCreature(4210, 4176, 1, creaturesTemplates["woman2"]);
        setCreature(4196, 4178, 1, creaturesTemplates["woman2"]);
        setCreature(4205, 4162, 1, creaturesTemplates["woman2"]);
        setCreature(4200, 4189, 1, creaturesTemplates["woman2"]);
        setCreature(4207, 4185, 1, creaturesTemplates["monk-blue"]);
        setCreature(4209, 4168, 1, creaturesTemplates["monk-blue"]);
        setCreature(4217, 4168, 1, creaturesTemplates["monk-blue"]);
    },
    "teleport": (this, x, y, z) => {
        return null;
    }
};
