
const MAP_24_25 = {
    "init": this => {
        setNpc(4998, 5001, 1, npcDefs.necromancer);
    },
    "teleport": (this, x, y, z) => {
        return null;
    },
    "action": (this, x, y, z) => {
        if(x = 4969 && y = 5001 && z = 1) {
            timedMessage(x, y, z, "Beware of ghosts!");            
            return true;
        }
        return null;
    }
};

const NECROMANCER_CONVO = {
    "": "Hiding from your $chores as usual? There is plenty of work on this $island and I need your $help more than ever.",
    "chores": "For the upcoming lunar alignment, I need you to bring me some spell components. They're in the $basement $somewhere I think...",
    "basement": "You can get there via the north stairs. You will need the storage room $key. I think you will find that upstairs.",
    "key": "You will need the key to get into the storage room in the $basement. Hurry and bring those spell components to me.",
    "somewhere": "I would try the storage room. But beware, there are $things down there you do not want to disturb.",
    "things": "Necromancy is a dangerous business. There are spell reagents, half-finished conjurings and the like in the basement so stay away from those. Then there is also the $ghost .",
    "island": "Our island is our home and the center of all my necromantic research. You, my assistant, are invaluable in getting this operation runnig smoothly. This is why I need you to focus on your $chores and other work.",
    "help": "After you're done with your $chores, I need you to look into our $ghost problem. Come back after you're done with the chores.",
    "ghost": "You may have noticed that our corn-field is haunted by a strange specter some nights. I need you to figure out what it $wants and get rid of it.",
    "wants": "Honestly, I'm not surprised - our line of work does upset the dead occasionally. But I can't have a $ghost traipsing around the $island so let me know when you've taken care of it.",
};
