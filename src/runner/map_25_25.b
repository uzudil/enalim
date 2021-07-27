const armin = {
    "name": "armin",
    "label": "Brother Armin",
    "creature": "monk",
    "convo": {
        "": "Welcome to $Ourdlen traveler. The outside world has $forgot about our humble monastery.",
        "Ourdlen": "Once a majestic homage to our Lord $Vreit and a libray of rare $documents, our monastery is now mostly a ruin. Dangerous $goblins roam the grounds above and so we are forced to now dwell $underground.",
        "underground": "Because of the threat from the $goblins, we were forced to move our worship of Lord $Vreit here to the lower levels of the monastery.",
        "Vreit": "Lord Vreit is the god of the underworld, so it is only fitting that we should worship him $underground. He's the protector of the dead who guards the souls of those passed on to the other side.",
        "forgot": "There aren't many left who remember our monastery at $Ourdlen. Once we were openly venerating Lord $Vreit and generating much of our income from the research of rare $documents.",
        "documents": "You seek such a document? A paperwork for your master, the Necromancer? If we still have the scroll, it would be in the locked $storage room. Ask Brother $Hermil for the key.",
        "storage": "The storage room is locked most of the time. If the $goblins should ever breach our $underground halls, this will hopefully prevent the destruction of the $documents.",
        "goblins": "Wretched monsters they are! No one knows where they came from but their appearance forced us $underground and signalled an end of an era for $Ourdlen.",
        "Hermil": "Brother Hermil is the keeper of keys to the $storage room. He is a mighty scholar, able to decode even the most ancient tomes."
    },
    "schedule": [
        { "from": 8, "to": 18, "pos": [ 5127, 5002, 1 ], "movement": "anchor" },
        { "from": 18, "to": 8, "pos": [ 5129, 5012, 1 ], "movement": "anchor" },
    ],
};
addNpcDef(armin);


SECTIONS["25,25"] := {
    "init": this => {
        setNpc(5127, 5002, 1, armin);
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
        if(x = 5000 && y <= 5034 && y >= 5030 && z = 1) {
            return [4998, 4989, 1];
        }
        if(x = 5149 && y <= 5045 && y >= 5041 && z = 1) {
            return [5015, 5056, 2];
        }
        return null;
    }    
};
