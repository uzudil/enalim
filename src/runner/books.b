const RAISE_DEAD = "On Raising the Dead
by Byron M. Sliddle

A word of warning: this is not a book of necromancy to the lay or neophite. One should begin their vocation in the dark arts by studying the beginner materials, such as 'Return to Unlife' by Randolph X, or 'Necromantic Basics' by Samantha K.

With the warning out of the way, let's dive into more advanced topics.

Chapter 1: Barring a Spirit from Re-entry

The master of necrotic arts may at times be beset by an unfortunate event: the nagging re-entry of an unwanted spirit into the sacred circles.
Several studies (Lahrum G. Smith F. et al, etc.) point to the root cause of this being the administration of too little or too much of the reagent Envinidum.
Envinidum is a fussy substance to begin with and it seems its use must be specifically measured for the task at hand.

Chapter 2: On the Binding of Demons

Only the most avid and experienced of magi should ever attempt the summoning of the fiends of the underworld. 
Yea, I must stress this point once more: if there be any doubt in your mind, dear reader, as to the prowess of your skill, 
or the constitution of your sanity and hardness of physical form, attempt not what I describe in the following pages. 
Alas, too many foolhardy and over-inflated of ego, practicioner of magics had made the ultimate sacrifice for their art at the 
hand, claw, beak or tenticle of abyssal abominations summonned too hastily. If you still wish to proceed, I encourage you 
purchase volumes XX-XXIII of this tome at fine bookstores throught Enalim.";

const ON_GHOSTS = "On ghosts and spirits
by Edina F. K. Livingston
 
Many homes large and small in the land of Enalim are home to un-quiet spirits. 
Sometimes this is due to the spirit having lost their way to the afterlife. 
In other instances, an unfinished earthly task draws the departed back from eternal rest.

Whatever the cause of the haunting, these spirits can be troublesome for the living.

The first thing one must resolve, when dealing with supernatural phenomena, is whether the 
spirit in question means to harm the living, or if they're merely coexisting in our world. 
In the case of the latter, perhaps one can learn to live alongside the ghost and let it 
become a benign and charming addition of the area. However if the ghost is of malicious intent, 
the sooner the problem is treated, the greater the chance of avoiding any potential unpleasentness. Often 
in such circumstances, professional assistance may be required. The patient reader may find a list 
of such services offered throught Enalim in volumes X-XIV.";

const ON_REAGENTS = "On spell reagents
by Sedim Addif Luq

Described herein are the most basic spell components a magic caster may need. 
Some of these components can be readily available to be found in the wild lands of Enalim,
while some others require extensive preparation by learned craftsmen. Without further ado,
here is the list:

Blackberry bark: the dark-bluish sheen of this bush is an element of night magic used in many spells.

Wortweed: found in the temperate ranges of Enalim, this weed is used in many healing spells.

Asp venom: a deadly poison that can be processed into a solid form to aid in the casting of many cold spells.

Firestone: found only underground, this vulcanic ore is a central component of heat-based spells.

Spectral mist: an ellusive component, harvested near haunted areas, it is used in spirit spells.

Hatemoss: a truly vile substance, luckily only found in ancient bogs, it is a component of evil magics.

Labradorite: this colorful gem is the main ingredient in light spells.

Thermex: the processed juice of certain berries, this ingredient is hard to find, however it is needed for knowledge spells.

Beware dear reader that this is not an exhaustive list of reagents. You may come across many more complex and specialized 
varieties during your study of the magical arts.
";

BOOKS := {
    "Raising the dead": RAISE_DEAD,
    "On ghosts and spirits": ON_GHOSTS,
    "Spell reagents": ON_REAGENTS,
};

const PAGE_LINE_COUNT = 15;
const PAGE_LINE_SIZE = 150;

openBook := {
    "pages": null,
    "currentPage": 0,
    "bookItem": null,
};

def turnBookPage(d) {
    newPage := openBook.currentPage + d*2;
    if(newPage >= 0 && newPage < len(openBook.pages)) {
        openBook.currentPage := newPage;
        updateBookUi(openBook.bookItem);
    }
}

def updateBookUi(c) {
    openBook.bookItem := c;
    parseText(BOOKS[c.book]);

    texts := [];
    if(len(openBook.pages) > openBook.currentPage) {
        array_foreach(openBook.pages[openBook.currentPage], (idx, line) => {
            texts[len(texts)] := {
                "type": "uiText",
                "text": line,
                "x": 25,
                "y": 30 + idx * LINE_HEIGHT_SMALL,
                "fontIndex": 1,
            };
        });
    }
    if(len(openBook.pages) > openBook.currentPage + 1) {
        array_foreach(openBook.pages[openBook.currentPage + 1], (idx, line) => {
            texts[len(texts)] := {
                "type": "uiText",
                "text": line,
                "x": 195,
                "y": 30 + idx * LINE_HEIGHT_SMALL,
                "fontIndex": 1,
            };
        });
    }    
    updatePanel(c.id, texts);
}

def parseText(text) {
    openBook.pages := [
        [""],
    ];
    i := 0;
    wordStart := 0;
    while(i < len(text)) {
        c := substr(text, i, 1);
        if(c = " " || c = "\n") {
            addTextWord(text, i, wordStart);
            wordStart := i + 1;
            if(c = "\n") {
                addTextLine("");
            }
        }        
        i := i + 1;
    }
    if(wordStart < i) {
        addTextWord(text, i, wordStart);
    }
}

def addTextWord(text, i, wordStart) {
    word := substr(text, wordStart, (i - wordStart));
    lastPage := openBook.pages[len(openBook.pages) - 1];
    lastLine := lastPage[len(lastPage) - 1];
    if(len(lastLine) = 0) {
        lastPage[len(lastPage) - 1] := word;
    } else {
        lineLen := messageWidth(lastLine + " " + word, 1);
        if(lineLen >= PAGE_LINE_SIZE) {
            addTextLine(word);
        } else {
            lastPage[len(lastPage) - 1] := lastLine + " " + word;
        }
    }
}

def addTextLine(word) {
    lastPage := openBook.pages[len(openBook.pages) - 1];
    if(len(lastPage) >= PAGE_LINE_COUNT) {
        # new page
        openBook.pages[len(openBook.pages)] := [ word ];
    } else {
        # new line
        lastPage[len(lastPage)] := word;
    }
}
