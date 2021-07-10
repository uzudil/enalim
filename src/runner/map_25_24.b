SECTIONS["25,24"] := {
    "init": this => {
        setCreature(5019, 4993, 1, creaturesTemplates.cow);
        setCreature(5189, 4992, 1, creaturesTemplates.goblin);
        setCreature(5162, 4981, 1, creaturesTemplates.goblin);
        setCreature(5167, 4981, 1, creaturesTemplates.goblin);
        setCreature(5182, 4932, 1, creaturesTemplates.ogre);
        setCreature(5182, 4932, 1, creaturesTemplates.ogre);
        setCreature(5170, 4932, 1, creaturesTemplates.ogre);
        setContainer("chest", 5015, 4961, 3, "map", [ "vial.nercromancer", { "shape": "item.book.2", "book": "Raising the dead" } ]);
        setContainer("chest", 5003, 4961, 1, "map", [ "item.candle", "item.candle", "item.candle" ]);
    },
    "start": this => {
        eraseShape(5005, 4967, 1);
        if(player.gameState["gate_to_ruins"] != null) {
            setShape(5005, 4967, 1, "teleport.x");
        }
    },
    "teleport": (this, x, y, z) => {
        if(player.gameState["gate_to_ruins"] != null && x = 5005 && y <= 4971 && y >= 4967 && z = 1) {
            return [5178, 5084, 2];
        }
        return null;
    },
    "locked": (this, x, y, z) => {
        if(x = 5023 && y = 4962 && z = 1) {
            return "key.storage_room";
        }
        return null;
    },
};
