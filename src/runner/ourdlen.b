addNpcDef({
    "name": "hermil",
    "label": "Brother Hermil",
    "creature": "monk",
    "convo": {
        "": "An ancient and incredibly decrepit monk stands before you. " + 
            "\"Welcome traveler to $Ourdlen. If you are looking for rare $documents or help with $translations, " + 
            "let me know!\" - he wheezes.",
        "Ourdlen": "His eyes light up - this is obviously one of his favorite topics: " +
            "\"Ourdlen is a monastery and library of rare $documents. If you want to hear the history of Ourdlen, " +
            "talk to Brother Armin.\"",
        "translations": "\"Brother Armin is our resident historian\" - he says - " + 
            "\", but I deal with rare documents and translations. " + 
            "Come back to $Ourdlen again when you need something translated!\"",
        "documents": "At the mention of documents, the monk becomes so animated you wonder if he'll break something: " + 
            "\"Aha, you're looking for a specific scroll for your master the Necromancer?\" - you wonder how he knows the Necromancer? - " + 
            "\" If it's here, it will be in our $storage room.\"",
        "storage": "He points to the east and continues: " + 
            "\"We keep the storage room locked because of the $goblins. " + 
            "The key can be found in the $grain chamber to the north of here.\"",
        "goblins": "He sighs deeply, shaking his head and finally says: " + 
            "\"Lately $Ourdlen has been plagued by goblins so we now conduct much of our business underground. " + 
            "See Brother Armin about the history of these attacks.\"",
        "grain": "The grain chamber sounds exciting, until the frail monk explains: " + 
            "\"Yes, the grain chamber is where we keep our dry food.\" - You feel let down. This is decidedly not exciting. - " +
            "\" However, we keep it locked because two hideous $monsters have become trapped there.\" Well maybe it is worth checking out, afterall.",
        "monsters": "The old monk squints at you as if he's trying to measure your worth. " + 
            "\"I can give you the $key to the $grain chamber\" - he says - " + 
            "\" but be warned the horrors walking around there will test your very sanity!\" " + 
            "You'll be fine, you tell yourself. After all you know the defense spell!",
        "key": () => {
            if(player.gameState["ourdlen.grain.key"] = null) {
                player.gameState["ourdlen.grain.key"] := 1;
                player.inventory.add("key.ourdlen", -1, -1);
                return "The ancient monk ^hands you a possibly even older brass key.^ " + 
                    "\"Here you go. If you are able to clear out the $grain chamber, you're welcome to take whatever you find there.\" - " + 
                    "you privatly scoff at the notion you'd want anything that belonged to these smelly hermits - " +
                    "\"The monks of $Ourdlen will be forever in your debt!\"";
            } else {
                return "\"The key I gave you should give you access to the $grain chamber.\" - the old monk reminds you - " +
                "\" If you are able to clear it out, you're welcome to take whatever you find there.\" - Treasures! You are sure. - " +
                "\" The monks of $Ourdlen will be forever in your debt!\"";
            }            
        },
    },
    "schedule": [
        { "from": 8, "to": 18, "pos": [ 5223, 5014, 1 ], "movement": "anchor" },
        { "from": 18, "to": 8, "pos": [ 5217, 5035, 1 ], "movement": "anchor" },
    ],
});

addNpcDef({
    "name": "armin",
    "label": "Brother Armin",
    "creature": "monk",
    "convo": {
        "": "You smell brother Armin before he even speaks. It is obvious that years of living underground have resulted in relaxed personal hygene habits... " +
            "\"Welcome to $Ourdlen traveler. The outside world may have $forgotten about this monastery, but rest assured...\" " + 
            "- he coughs spasmodically - \"...rest assured our sanctuary is in perfect health.\"",
        "Ourdlen": "He gestures around you with a thin, yet surprisingly malodorous arm: " + 
            "\"Once a majestic homage to our Lord $Vreit and a libray of rare $documents, our monastery is now mostly a ruin.\" " +
            "To call it that gives actual ruins a bad name. More of a pile of stones, you think. The pungent monk goes on: " + 
            "\"Dangerous $goblins roam the grounds above and so we are forced to now dwell $underground.\"",
        "underground": "With a dirty finger, he points to the world above: " + 
            "\"Because of the threat from the $goblins, we were forced to move our worship of Lord $Vreit " + 
            "here to the lower levels of the monastery.\" " + 
            "You decide to not ask where that finger's been.",
        "Vreit": "The old monk raises his filthy hands in what must be a gesture of adoration and says: " + 
            "\"Lord Vreit (may his name be glorified ever on) is the god of arcanum and books.\" " +
            "- his eyes shine with piety - \"And so it is only fitting that we house a large collection of ancient $documents. " +
            "Our library is unparalleled in all of Elanim!\" He's clearly proud of this fact.",
        "forgotten": "He sighs deeply inside the filthy cowl. \"There aren't many left who remember our monastery at $Ourdlen.\" " +
            " - he sighs again, clearly distraught over this loss of fortunes - \"Once we were openly venerating Lord $Vreit. " +
            "Much of our income came from the research of rare $documents. Nowadays however, \" - another sigh - \"hardly anyone remembers us.\"",
        "documents": "His eyes lit, he rubs his hands on his filthy habit. " +
            "\"You seek such a document? A paperwork for your master, the Necromancer?\" - You wonder how the monks know of the Necromancer? - " + 
            "\"If we still have the scroll, it would be in the locked $storage room. Ask Brother $Hermil for the key.\"",
        "storage": "\"The storage room is locked most of the time.\" - he mutters while inspecting one filth-caked fingernail - " + 
            "\"If the $goblins should ever breach our $underground halls, this will hopefully prevent the destruction of the $documents.\"",
        "goblins": "The monks face destorts in a grimace of hate. The effect is only ruined by the copious dirt on his face, making him look more comical than threatening. " +
            "\"Wretched monsters they are!\" - he shouts - \"No one knows where they came from but their appearance forced us $underground and signalled the end of an era for $Ourdlen.\"",
        "Hermil": "The monk points to the west: \"Brother Hermil is the keeper of keys to the $storage room. " + 
            "He is a mighty scholar, able to decode even the most ancient tomes.\""
    },
    "schedule": [
        { "from": 8, "to": 18, "pos": [ 5127, 5002, 1 ], "movement": "anchor" },
        { "from": 18, "to": 8, "pos": [ 5129, 5012, 1 ], "movement": "anchor" },
    ],
});
