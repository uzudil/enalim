addNpcDef({
    "name": "hermil",
    "label": "Brother Hermil",
    "creature": "monk",
    "convo": {
        "": "Welcome traveler to $Ourdlen. If you are looking for rare $documents or help with $translations, let me know!",
        "Ourdlen": "Ourdlen is a monastery and library of rare $documents. If you want to hear the history of Ourdlen, talk to Brother Armin.",
        "translations": "Brother Armin is our resident historian, but I deal with rare documents and translations. Come back to $Ourdlen again when you need something translated!",
        "documents": "Aha, you're looking for a specific scroll for your master the Necromancer? If it's here, it will be in our $storage room.",
        "storage": "We keep the storage room locked because of the $goblins. The key can be found in the $grain chamber to the north of here.",
        "goblins": "Lately $Ourdlen has been plagued by goblins so we now conduct much of our business underground. See Brother Armin about the history of these attacks.",
        "grain": "Yes, the grain chamber is where we keep our dry food. However, we keep it locked because two hideous $monsters became trapped there.",
        "monsters": "I can give you the $key to the $grain chamber but be warned the horrors walking around there will test your very sanity!",
        "key": () => {
            if(player.gameState["ourdlen.grain.key"] = null) {
                player.gameState["ourdlen.grain.key"] := 1;
                player.inventory.add("key.ourdlen", -1, -1);
                return "Here you go. If you are able to clear out the $grain chamber, you're welcome to take whatever you find there. The monks of $Ourdlen will be forever in your debt!";
            } else {
                return "The key I gave you should give you access to the $grain chamber. If you are able to clear it out, you're welcome to take whatever you find there. The monks of $Ourdlen will be forever in your debt!";
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
});
