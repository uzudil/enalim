BOOKS := {
    "Raising the dead": "On Raising the Dead\n\n" + 
        "A word of warning: this is not a book of necromancy to the lay or neophite. One should begin their vocation in the dark arts by studying the beginner materials, such as 'Return to Unlife' by Randolph X, or 'Necromantic Basics' by Samantha K.\n\n" + 
        "With the warning out of the way, let's dive into more advanced topics.\n\n" + 
        "Chapter 1: Barring a Spirit from Re-entry\n\n" +
        "The master of necrotic arts may at times be beset by an unfortunate event: the nagging re-entry of an unwanted spirit into the sacred circles.\n" +
        "Several studies (Lahrum G. Smith F. et al, etc.) point to the root cause of this being the administration of too little or too much of the reagent Envinidum.\n" +
        "Envinidum is a fussy substance to begin with and it seems its use must be specifically measured for the task at hand.\n\n" +
        "Chapter 2: On the Binding of Demons",
    "Necromantic reagents": "bbb",
    "On ghosts and spirits": "ccc",
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
