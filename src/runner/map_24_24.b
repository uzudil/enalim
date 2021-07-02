const ghost = {
    "name": "ghost",
    "label": "Ghost of Lydell",
    "creature": "ghost",
    "convo": {
        "": "I... oooo... arakw... Beware $Lydell lest the $endless cycle reach for thee...",
        "Lydell": "Oh yes I know ye well... better even than you know yourself. A $warning I bring for thee...",
        "endless": "Life, death and undeath... I wish to escape this endless cycle but alas... But that is not why I'm $here.",
        "here": "I bring ye news from another place, $Lydell. A grave $warning I have for thee.",
        "warning": "Ye know not how ye came to be on this $island and yet ye never wondered? A lazy mind brings few rewards! Now $hear my message.",
        "hear": () => {
            player.gameState["ghost_warning"] := 1;
            return "Ye are not $safe here. The $Necromancer is not as he appears. I've seen what he wrought in other place... times...";
        },
        "safe": "Away ye must as $soon as possible! And beware of the $Necromancer for he aims to bring ye much harm.",
        "soon": "Speak nothing to the $Necromancer about what I told ye... I... oooo... must go now. Good luck, $Lydell...",
        "Necromancer": "Much calamity ha has caused elsewhere and will again soon here as well. Hence my $warning to ye... Remember, tell him nothing of this!",
    },
    "schedule": [
        { "from": 5, "to": 21, "pos": [ 4974, 4934, 1 ], "movement": "anchor" },
        { "from": 21, "to": 5, "pos": [ 4974, 4971, 1 ], "movement": "anchor" },
    ],    
};

const MAP_24_24 = {
    "staticInit": this => {
        registerNpc(ghost);
    },
    "init": this => {
        setNpc(4974, 4934, 1, ghost);
        setBook(4997, 4992, 10, "map", "Raising the dead");
    },
    "teleport": (this, x, y, z) => {
        if(x >= 4996 && x <= 4999 && y = 4986 && z = 1) {
            return [5004, 5031, 1];
        }
        return null;
    }
};
