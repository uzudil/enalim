addNpcDef({
    "name": "necromancer",
    "label": "The Necromancer",
    "creature": "monk-blue",
    "convo": {
        "": () => {
            if(player.gameState["ourdlen_done"] != null) {
                return "The Necromancer starts when he sees you: \"Why haven't you left yet? It is you Lydell, you must go $immediately!\"";
            } else {
                idx := player.inventory.findIndex("doc.ourdlen");
                if(idx > -1) {
                    player.inventory.remove(idx, "inventory");
                    player.gameState["ourdlen_done"] := 1;
                    return "The Necromancer takes the manuscript from you and reads it intently. After what seems like several intense minutes he gazes at you with a deranged expression: \"You must leave $immediately.\"";
                } else {
                    if(player.gameState["chores_done"] = null || player.gameState["ghost_warning"] = null) {
                        return "The Necromancer seems lost in his thoughts today. " + 
                            "\"The time is here, $Lydell. The Alturian $conjunction is near and we have still have much work to do!\" " + 
                            "He impatiently motions for you to come closer.";
                    } else {
                        return "The Necromancer says with eyes gleaming: \"Excellent work $Lydell. Now that I have the vial of reagents and your assurance that the spectral trash in the corn field won't interfere, We're ready to begin the $ritual. Let me $explain how it will work.\"";
                    }
                }
            }
        },
        "Lydell": "The Necromancer gives you that look you've seen many times before. " +
            "\"Lydell is your name.\" " + 
            "(You feel immensely stupid.) " + 
            "\"You are my assistant here on my $island. \" " + 
            "- He continues, while glaring at you. You blush intensly, wishing you could be invisible.",
        "island": "His eyes narrow as he inspects you with an expression of disgust, usually reserved for cleaning a particularly pungent latrine. \"Surely you jest. We have been living here on my island for years, preparing for the coming $conjunction of planets. We are just off the coast of the $Enalim mainland.\"",
        "Enalim": "The Necromancer sighs heavily and stares at the sea. His eyes far away, " + 
            "as he's clearly contemplating a spell to end both your existence and the drain on his last bit of patience. " + 
            "\"Enalim,\" - he says slowly - \"is the world we live in. It is all you see around you. " + 
            "Now, can we get back to planning for the $conjunction? Or perhaps you have more inane questions " + 
            "to waste my day with?\"",
        "conjunction": "A change comes over the Necromancer, a look of intense focus. \"The Alturian conjunction is the alignment of the planet $Altur and its moons with our sun. As you know ancient tomes connect this event with the awakening of $Vesnu. I'm sured you have everything $prepared for this event.\"",
        "Altur": "\"Altur is the closest planet to $Enalim, as I'm sure you're aware.\" The Necromancer seems irritated he has to remind you of this.",
        "VESNU": ">Vesnu",
        "Vesnu": "The Necromancer's look is somewhere between concern and barely checked irritation. \"Vesnu is an ancient being - some call him a god - of pure malignant energy. Nothing good can come of his awakening. Of course, \" - he adds - \"we have gone over this many times. You are $prepared for the $conjunction, correct?\"",
        "prepared": () => {
            if(player.gameState["chores_done"] = null) {
                idx := player.inventory.findIndex("vial.nercromancer");
                if(idx > -1) {
                    player.inventory.remove(idx, "inventory");
                    player.gameState["chores_done"] := 1;
                    return "The Necromancer takes the vial of reagents from you. \"Thank you for bringing me this.\" - his expression looks more judgemental than thankful - \"Now before we begin the $ritual, there is the issue of the $ghost in the cornfield you need to deal with...\"";
                } else {
                    return "He seems relieved: \"Good. I'm glad to hear that my trusted assistant $Lydell has organized everything for the coming $ritual so we can prevent a potentially era-ending $calamity.\"";
                }
            } else {
                if(player.gameState["ghost_warning"] = null) {
                    return "He eyes you expectantly: \"Well? What does our $ghost want? Can we finally begin the $ritual?\"";
                } else {
                    return "He waves his hands: \"So the corn field stalker is not a threat. Good work $Lydell. We are ready to begin the ritual - let me $explain how it will work.\"";
                }
            }
        },
        "calamity": "The Necromancer seems concerned: \"Yes, the awakening of $Vesnu, following the Alturian $conjunction. $Lydell, you are $prepared for this, are you not?\"",
        "ritual": "\"Which ritual?!\" - He appears fully committed to an apoplectic fit - \"THE RITUAL TO PREVENT THE COMING OF $VESNU!\" - He shouts - \"Tell me you have the $reagents from the basement...\" - He trails off clearly exhausted by a deep sense of disappointment in you.",
        "reagents": () => {
            if(player.gameState["chores_done"] = null) {
                return "After a few deep breaths, the Necromancer calms down and says slowly: \"The vial of spell components in the basement. You will need the $key to get into the basement. Once you have the vial, bring it to me so we can begin the $ritual.\"";
            } else {
                return "After a few deep breaths, the Necromancer calms down and says: \"Yes, you're right. You did bring me the vial. Have you also attended to our $ghost problem?\"";
            }
        },
        "key": "The Necromancer waves his hands: \"I left it somewhere upstairs, I think. Find the key and then bring me the vial of $reagents from the basement so we can finally $begin.\"",
        "begin": ">conjunction",
        "ghost": "The Necromancer is clearly annoyed: \"The $ritual requires absolute focus. The necromantic energies can be disruptepted by that halfwit apparition traipsing around in our corn field. I need you to find out what it wants and ensure it will stay out of our way.\"",
        "explain": "Nodding maniacally, he continues: \"I need you to $travel to the ruined monastery at $Ourdlen. There you must find the ancient $manuscript the monks have been guarding for me.\" The Necromancer's eyes shine in frightful anticipation.",
        "Ourdlen": "He points vaguely westward: \"They're the next island across the sea. Once actually a place of learning, today the followers of $Vreit have fallen on hard times. Nevertheless that is where you must $travel. And also, \" - he adds - \"while there you may have to $defend yourself.\"",
        "monks": ">Ourdlen",
        "Vreit": "\"Vreit is a lesser god of languages and arcanum.\" - the Necromancer says dismissively - \"What is more important is that you must find that $manuscript at $Ourdlen.\"",
        "manuscript": "The Necromancer's eyes light up again with baleful glee: \"It's nothing special, just a bit of paper. The $monks will know where it is. Once you have $arrived at $Ourdlen, ask them about it.\"",
        "arrived": ">travel",
        "travel": () => {
            if(player.gameState["gate_to_ruins"] = null) {
                player.gameState["gate_to_ruins"] := 1;
                restartActiveSections();
            }
            return "He motions towards the basement: \"In the basement I have created a dimensional gate to $Ourdlen. Simply step through it like any other portal. When you wish to return, you will find a similar gate outside the monastery.\"";
        },
        "defend": "You sense a certain unease when the Necromancer continues: \"Right, yes. Like I said $Ourdlen is now a ruin. Before you find the monks you may encounter hostile beings intent on...\" - he searches for words - \"well, they hunger for human flesh. You must use the spell of $defense I taught you.\"",
        "defense": "You are starting to see why you were chosen for this. \"Do not get eaten.\" - he adds helpfully - \"Find the $manuscript and bring it back to me.\" With that he motions you towards the basement.",
        "immediately": "The Necromancer seems both sad and disturbed: \"I can't... I can't perform the ritual. It is too late. Vesnu has $risen and you, Lydell are somehow the only one who can stop him.\". He suddenly seems small and frightened as he stares at you with what can only be described as a look of admiration.",
        "risen": "He babbles on hopelessly: \"I don't understand it myself, but...\" - he waves the manuscript page - \"the portents are real: Vesnu has risen and all will soon be lost. Our only hope is that\" - here he reads the page to you, \"one born kinless, crimson of complexion and heir to Krynt will rise to the $challenge.\"",
        "challenge": () => {
            if(player.gameState["start_journey"] = null) {
                player.gameState["start_journey"] := 1;
                restartActiveSections();
            }
            return "\"I never told you about your past - because I don't know it myself.\" " +
                "- he goes on with a bewildered expression - \"One day you were... just here... \"" +
                " Secretly, you're pleased hearing about your mysterious past. Before you could get too giddy, the Necromancer continues: " +
                "\"You must seek out Fearol on the $mainland, perhaps he will know what to do. And beware of the $agents of Vesnu along the way!\"";
            },
        "mainland": "The Necromancer is back to his old impatient self again: " + 
            "\"Yes, yes, it's all been arranged. I have reconfigured the dimensional portal in the basement. " + 
            "It will now take you to the mainland.\" - That portal gives you the creeps. - " + 
            "\" Hurry, there is no time to loose! When you arrive seek out $Fearol!\"",
        "Fearol": ">challenge",
        "agents": "\"Vesnu is quickly becoming be a powerful being of eldritch energy. " + 
            "Because so far he has only partially entered Enalim,\" - he explains - \"you must beware of evil men, " +
            "monsters and other beings in his service. You are our last hope to stop Vesnu, so $hurry!\" " + 
            "He's practically pushing you towards the portal in the basement.",
        "hurry": ">mainland",
    },
    "schedule": [
        { "from": 8, "to": 18, "pos": [ 5010, 5000, 1 ], "movement": "anchor" },
        { "from": 18, "to": 8, "pos": [ 5000, 5005, 8 ], "movement": "anchor" },
    ],
});

addNpcDef({
    "name": "ghost",
    "label": "Ghost of Lydell",
    "creature": "ghost",
    "convo": {
        "": "An apparition floats before you, clothed in the dusty robes of yore. \"I... oooo... arakw...\" - it croaks - \"I hath come to warn thee $Lydell, of events foretold.\" It apprently knows who you are.",
        "Lydell": "Before you can come to grips with the fact that your fame extends to the unlife, it continues: \"Tidings I bring thee, tidings I was bound to deliver. A $doom hangs on thee - its claws holding thee fast as coffin's nails.\" A fitting remark indeed.",
        "doom": "The ghost warbles on: \"Thou willst travel far to eventually meet thy fate.\" - this can mean anything, you think, until it clarifies: \"An evil presence bleeds into this world from whence I hail. I have come to warn thee that it is thy doom to seek out and $prove thyself against it.\"",
        "prove": "You're about to ignore these ramblings when it adds \"On thy travels seek thee the Azure Chalice of Krynt.\" - you swear it winks at you from under its hood - \"Now hurry Lydell back to thy $master. Aid him in his work, for he knows not what truly will come to pass.\"",
        "master": () => {
            player.gameState["ghost_warning"] := 1;
            return "After a dusty coughing fit, the ghost mumbles: \"Doth not know, I tell thee. I will not bother thee anymore - but shoulds't thou need to hear my warning anew, just ask and I will $repeat it.\". With that it hovers nearby, bobbing expectantly. You decie it looks harmless enough.";
        },
        "repeat": ">",
    },
    "schedule": [
        { "from": 5, "to": 10, "pos": [ 4974, 4934, 1 ], "movement": "anchor" },
        { "from": 10, "to": 15, "pos": [ 4974, 4971, 1 ], "movement": "anchor" },
        { "from": 15, "to": 20, "pos": [ 4974, 4934, 1 ], "movement": "anchor" },
        { "from": 20, "to": 5, "pos": [ 4974, 4971, 1 ], "movement": "anchor" },
    ],    
});
