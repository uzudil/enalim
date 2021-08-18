def startConvo(npc) {
    player.mode := MODE_CONVO;
    setCalendarPaused(true);
    player.convo := {
        "npc": npc,
        "topic": "",
        "update": true,
        "indexes": [],
        "parsed": null,
        "answerIndex": 0,
    };
}

def renderConvo() {
    if(player.convo.update) {
        if(player.convo.parsed = null) {
            player.convo.answerIndex := 0;
            t := player.convo.npc.convo[player.convo.topic];
            if(typeof(t) = "function") {
                t := t();
            }
            player.convo.parsed := parseTopic(t);
        }
        displayConvoMessages();
        player.convo.update := false;        
    }
}

def endConvo() {
    delConvoMessages();
    player.convo := null;
    setCalendarPaused(false);
    player.mode := MODE_GAME;
}

def incrConvoAnswerIndex() {
    player.convo.answerIndex := player.convo.answerIndex + 1;
    if(player.convo.answerIndex >= len(player.convo.parsed.answers)) {
        player.convo.answerIndex := 0;
    }
    player.convo.update := true;
}

def decrConvoAnswerIndex() {
    player.convo.answerIndex := player.convo.answerIndex - 1;
    if(player.convo.answerIndex < 0) {
        player.convo.answerIndex := len(player.convo.parsed.answers) - 1;
    }
    player.convo.update := true;
}

def fireConvoAnswerIndex() {
    t := player.convo.parsed.answers[player.convo.answerIndex];
    if(player.convo.npc.convo[t] = null) {
        print("Error: missing convo topic: '" + t + "'. Talking to " + player.convo.npc.name);
    } else {
        if(typeof(player.convo.npc.convo[t]) = "string") {
            if(startsWith(player.convo.npc.convo[t], ">")) {
                t := substr(player.convo.npc.convo[t], 1, len(player.convo.npc.convo[t]) - 1);
            }
        }
        player.convo.topic := t;
        player.convo.parsed := null;
        player.convo.update := true;
    }
}

def setConvoAnswerIndexAt(x, y) {
    if(player.convo = null) {
        return 1;
    }
    if(player.convo.parsed = null) {
        return 1;
    }
    lineCount := len(player.convo.parsed.lines);
    i := int((y - 20 - (lineCount - 1) * LINE_HEIGHT) / LINE_HEIGHT);
    if(i >= 0 && i < len(player.convo.parsed.answers) && i != player.convo.answerIndex) {
        answerLength := messageWidth("" + (i + 1) + ": " + player.convo.parsed.answers[i], 0);
        if(x >= 10 && x < 10 + answerLength) {
            player.convo.answerIndex := i;
            player.convo.update := true;
        }
    }
}

def displayConvoMessages() {
    delConvoMessages();
    array_foreach(player.convo.parsed.lines, (i, line) => addConvoMessage(10, 20 + i * LINE_HEIGHT, line, MESSAGE_R, MESSAGE_G, MESSAGE_B));
    array_foreach(player.convo.parsed.answers, (i, answer) => {
        fg := 128;
        if(i = player.convo.answerIndex) {
            fg := 255;
        }
        addConvoMessage(10, 20 + len(player.convo.parsed.lines) * LINE_HEIGHT + i * LINE_HEIGHT, "" + (i + 1) + ": " + answer, fg, fg, fg);
    });
}

def addConvoMessage(x, y, msg, r,g,b) {
    player.convo.indexes[len(player.convo.indexes)] := addMessage(x, y, msg, 0, r, g, b);
}

def delConvoMessages() {
    if(len(player.convo.indexes) > 0) {
        array_foreach(player.convo.indexes, (i, idx) => delMessage(idx));
        player.convo.indexes := [];
    }
}

def parseTopic(topic) {
    d := {
        "lines": [""],
        "answers": []
    };
    i := 0;
    wordStart := 0;
    while(i < len(topic)) {
        c := substr(topic, i, 1);
        if(c = " ") {
            addWord(topic, i, wordStart, d);
            wordStart := i + 1;
        }
        i := i + 1;
    }
    if(wordStart < i) {
        addWord(topic, i, wordStart, d);
    }
    return d;
}

const CONVO_SUFFIX = [ ",", "!", "?", ".", ":", ";", "\"", "'" ];

def stripSuffix(w) {
    m := 0;
    while(m < len(w)) {
        i := 0;
        while(i < len(CONVO_SUFFIX)) {
            if(substr(w, m, 1) = CONVO_SUFFIX[i]) {
                return substr(w, 0, m);
            }
            i := i + 1;
        }
        m := m + 1;
    }
    return w;
}

def addWord(topic, i, wordStart, d) {
    word := substr(topic, wordStart, (i - wordStart));
    if(substr(word, 0, 1) = "$") {
        word := substr(word, 1, len(word) - 1);
        
        # remove ending punctuation
        w := [ word ];
        array_foreach(CONVO_SUFFIX, (i, p) => {
            while(endsWith(w[0], p)) {
                #w[0] := substr(w[0], 0, len(w[0]) - len(p));
                w[0] := stripSuffix(w[0]);
            }
        });
        d.answers[len(d.answers)] := w[0];
    }
    lastLine := d.lines[len(d.lines) - 1];
    if(len(lastLine) = 0) {
        d.lines[len(d.lines) - 1] := word;
    } else {
        lineLen := messageWidth(lastLine + " " + word, 0);
        if(lineLen >= SCREEN_WIDTH - 20) {
            d.lines[len(d.lines)] := word;
        } else {
            d.lines[len(d.lines) - 1] := lastLine + " " + word;
        }
    }
}
