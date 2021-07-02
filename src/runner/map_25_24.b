const MAP_25_24 = {
    "init": this => {
        setCreature(5019, 4993, 1, creaturesTemplates.cow);
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
