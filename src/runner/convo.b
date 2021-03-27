def startConvo(npc) {
    player.mode := MODE_CONVO;
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
            player.convo.parsed := parseTopic(player.convo.npc.convo[player.convo.topic]);
        }
        displayConvoMessages();
        player.convo.update := false;        
    }
}

def endConvo() {
    delConvoMessages();
    player.convo := null;
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
        player.convo.topic := t;
        player.convo.parsed := null;
        player.convo.update := true;
    }
}

def displayConvoMessages() {
    delConvoMessages();
    array_foreach(player.convo.parsed.lines, (i, line) => addConvoMessage(10, 20 + i * LINE_HEIGHT, line, 255, 220, 30));
    array_foreach(player.convo.parsed.answers, (i, answer) => {
        fg := 128;
        if(i = player.convo.answerIndex) {
            fg := 255;
        }
        addConvoMessage(10, 20 + len(player.convo.parsed.lines) * LINE_HEIGHT + i * LINE_HEIGHT, "" + (i + 1) + ": " + answer, fg, fg, fg);
    });
}

def addConvoMessage(x, y, msg, r,g,b) {
    player.convo.indexes[len(player.convo.indexes)] := addMessage(x, y, msg, r, g, b);
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

def addWord(topic, i, wordStart, d) {
    word := substr(topic, wordStart, (i - wordStart));
    if(substr(word, 0, 1) = "$") {
        word := substr(word, 1, len(word) - 1);
        d.answers[len(d.answers)] := word;
    }
    lastLine := d.lines[len(d.lines) - 1];
    lineLen := messageWidth(lastLine + " " + word);
    if(lineLen < SCREEN_WIDTH) {
        d.lines[len(d.lines) - 1] := lastLine + " " + word;
    } else {
        d.lines[len(d.lines)] := word;
    }
}
