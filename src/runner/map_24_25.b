const necromancer = {
    "name": "necromancer",
    "label": "The Necromancer",
    "creature": "monk-blue",
    "convo": {
        "": "Ah, $Lydell my boy... there you are. Hiding from your $chores as usual? There is plenty of work on this $island and I need your $help more than ever.",
        "Lydell": "Why Lydell is you: my trusted apprentice. You have been assisting me in my necromantic ventures for as long as I can remember. Time flies on this $island that is for sure.",
        "chores": () => {
            if(player.gameState["chores_done"] = null) {
                return "For the upcoming lunar alignment, I need you to bring me some spell $components. They're in the $basement $somewhere I think...";
            } else {
                return "Look busy, my young apprentice, there is plenty to do on this $island. Maybe go and investigate our $ghost problem!";
            }
        },
        "components": () => {
            idx := player.inventory.findIndex("vial.nercromancer");
            if(idx > -1) {
                player.inventory.remove(idx, "inventory");
                player.gameState["chores_done"] := 1;
                return "Aha! I'll take this, thank you. It's just the spell component I need! You have done well, $Lydell, now get back to your $chores.";
            } else {
                return "Yes, I need you to bring it to me. It should be a small vial with some liquid in it. You'll find it in the $basement.";
            }
        },
        "basement": "You can get there via the north stairs. You will need the $key to the storage room. I think you will find that upstairs.",
        "key": "You will need the key to get into the storage room in the $basement. I think I last saw it upstairs somewhere... Good luck with your $chores.",
        "somewhere": "I would try the storage room. But beware, there are $things down there you do not want to disturb.",
        "things": "Necromancy is a dangerous business. There are spell reagents, half-finished conjurings and the like in the basement so stay away from those. Then there is also the $ghost .",
        "island": "Our island is our home and the center of all my necromantic research. You, my assistant, are invaluable in getting this operation runnig smoothly. This is why I need you to focus on your $chores and other work.",
        "help": "After you're done with your $chores, I need you to look into our $ghost problem. Come back after you're done with the chores.",
        "ghost": () => {
            if(player.gameState["ghost_warning"] = null) {
                return "You may have noticed that our corn-field is haunted by a strange specter sometimes. I need you to figure out what it $wants and get rid of it.";
            } else {
                return "You have spoken with the ghost, you say? I feel you are becoming an indispensible assistant to me, Lydell. In fact, I have a new $task for you!";
            }
        },
        "wants": "Honestly, I'm not surprised - our line of work does upset the dead occasionally. But I can't have a $ghost traipsing around the $island so let me know when you've taken care of it.",
        "task": () => {
            player.gameState["gate_to_ruins"] := 1;
            restartActiveSections();
            return "I need you to $travel to the ruined monastery of $Ourdlen and see if you can find some... uh... $paperwork there.";
        },
        "Ourdlen": "The monastery at Ourdlen housed a group of monks some years ago, venerating their god Vreit. No one knows why their island fell to $hard times nor what happened to the monks.",
        "hard": "Since the monastery island is only reachable by sea, I was unable to retrieve my $paperwork until I devised a magical way to $travel there.",
        "travel": "I have enabled a dimensional door to $Ourdlen. You will find it in the storage room. Simply walk through it, like any other portal, and you will find yourself transported to Ourdlen. Remember to look for my $paperwork!",
        "paperwork": "Yes, well, it's a bit of a delicate matter... You see the scroll I'm after is an agreement of sorts with the monks or $Ourdlen that I wish to recover. Just bring it back and then get back to your $chores!",
    },
    "schedule": [
        { "from": 8, "to": 18, "pos": [ 5010, 5000, 1 ], "movement": "anchor" },
        { "from": 18, "to": 8, "pos": [ 5000, 5005, 8 ], "movement": "anchor" },
    ],
};
addNpcDef(necromancer);


SECTIONS["24,25"] := {
    "init": this => {
        setNpc(4998, 5001, 1, necromancer);
        setBook(4984, 5009, 3, "map", "On ghosts and spirits");
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
