const hermil = {
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
            player.inventory.add("key.ourdlen", -1, -1);
            return "Here you go. If you are able to clear out the $grain chamber, you're welcome to take whatever you find there. The monks of $Ourdlen will be forever in your debt!";
        },
    },
    "schedule": [
        { "from": 8, "to": 18, "pos": [ 5223, 5014, 1 ], "movement": "anchor" },
        { "from": 18, "to": 8, "pos": [ 5217, 5035, 1 ], "movement": "anchor" },
    ],
};
addNpcDef(hermil);


SECTIONS["26,25"] := {
    "init": this => {
        setNpc(5223, 5014, 1, hermil);
    },
    "teleport": (this, x, y, z) => {
        return null;
    },
    "locked": (this, x, y, z) => {
        if(x = 5208 && y = 5017 && z = 1) {
            return "key.ourdlen2";
        }
        return null;
    },
};
