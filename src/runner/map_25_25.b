SECTIONS["25,25"] := {
    "init": this => {
        setCreature(5023, 5001, 1, creaturesTemplates.cow);
        
        setCreature(5158, 5025, 1, creaturesTemplates.goblin);
        setCreature(5179, 5023, 1, creaturesTemplates.goblin);
        setCreature(5170, 5033, 1, creaturesTemplates.goblin);
        
        setContainer("chest", 5015, 5017, 1, "map", [ "item.bottle", { "shape": "item.book.1", "book": "On ghosts and spirits" } ]);
        
        setContainer("chest", 5010, 5021, 1, "map", [ "item.candle", { "shape": "item.book.2", "book": "On ghosts and spirits" }, "item.candle" ]);

        setBook(5027, 5017, 3, "map", "Raising the dead");
        setBook(5031, 5013, 6, "map", "Necromantic reagents");        
        setBook(5197, 5016, 3, "map", "On ghosts and spirits");        
    },
    "teleport": (this, x, y, z) => {
        if(x = 5000 && y <= 5039 && y >= 5036 && z = 1) {
            return [4998, 4989, 1];
        }
        if(x = 5149 && y <= 5045 && y >= 5041 && z = 1) {
            return [5015, 5056, 2];
        }
        return null;
    }    
};
