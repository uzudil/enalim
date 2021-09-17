const CONVO_R=160;
const CONVO_G=150;
const CONVO_B=100;

const CMD_SELL = "_sell_";
const CMD_SELL_PRICE = "_sell_price_";
const CMD_SELL_CONFIRM = "_sell_confirm_";
const CMD_BUY = "_buy_";
const CMD_BUY_PRICE = "_buy_price_";
const CMD_BUY_CONFIRM = "_buy_confirm_";

def startConvo(npc) {
    player.mode := MODE_CONVO;
    setOverlayBackground(0, 0, 0, 200);
    setCalendarPaused(true);
    player.convo := {
        npc: npc,
        topic: "",
        update: true,
        indexes: [],
        parsed: null,
        cmd: null,
        context: null,
        answerIndex: 0,
        quote: false,
        action: false,
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
            if(player.convo.cmd = null) {
                player.convo.parsed := parseTopic(t);
                appendConvoCommands(player.convo.parsed.answers);
            } else {
                player.convo.parsed := parseConvoCommand(player.convo.cmd, player.convo.topic);
            }
            player.convo.quote := false;
            player.convo.action := false;
        }
        displayConvoMessages();
        player.convo.update := false;        
    }
}

def endConvo() {
    setOverlayBackground(0, 0, 0, 0);
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
    if(player.convo.parsed.cmd = null && player.convo.npc.convo[t] = null) {
        print("Error: missing convo topic: '" + t + "'. Talking to " + player.convo.npc.name);
    } else {
        if(typeof(player.convo.npc.convo[t]) = "string") {
            if(startsWith(player.convo.npc.convo[t], ">")) {
                t := substr(player.convo.npc.convo[t], 1, len(player.convo.npc.convo[t]) - 1);
            }
        }
        player.convo.topic := t;
        player.convo.cmd := player.convo.parsed.cmd;
        player.convo.parsed := null;
        player.convo.update := true;
    }
}

def setConvoAnswerIndexAt(x, y) {
    if(player.convo = null || player.convo.parsed = null) {
        return;
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
    array_foreach(player.convo.parsed.lines, (i, line) => addConvoMessage(10, 20 + i * LINE_HEIGHT, line, CONVO_R, CONVO_G, CONVO_B));
    array_foreach(player.convo.parsed.answers, (i, answer) => {
        fg := 128;
        if(i = player.convo.answerIndex) {
            fg := 255;
        }
        addConvoMessage(10, 20 + len(player.convo.parsed.lines) * LINE_HEIGHT + i * LINE_HEIGHT, answer, fg, fg, fg);
    });
}

def addConvoMessage(x, y, msg, r,g,b) {
    i := 0;    
    s := "";
    if(player.convo.quote) {
       s := s + "|&c255,220,30|";
    }
    if(player.convo.action) {
       s := s + "|&c50,255,30|";
    }
    while(i < len(msg)) {
        c := substr(msg, i, 1);        
        if(c = "\"") {
            player.convo.quote := player.convo.quote = false;
            if(player.convo.quote) {
                s := s + "|&c255,220,30|\"";
            } else {
                s := s + "\"|&c" + CONVO_R + "," + CONVO_G + "," + CONVO_B + "|";
            }
        } else if(c = "^") {
            player.convo.action := player.convo.action = false;
            if(player.convo.action) {
                s := s + "|&c50,255,30|";
            } else {
                s := s + "|&c" + CONVO_R + "," + CONVO_G + "," + CONVO_B + "|";
            }
        } else {
            s := s + c;
        }        
        i := i + 1;
    }
    player.convo.indexes[len(player.convo.indexes)] := addMessage(x, y, s, 0, r, g, b);
}

def delConvoMessages() {
    if(len(player.convo.indexes) > 0) {
        array_foreach(player.convo.indexes, (i, idx) => delMessage(idx));
        player.convo.indexes := [];
    }
}

def startConvoCommand(cmd, cat, scheduleIndex=0) {
    if(player.convo.npc.activeSchedule = scheduleIndex) {
        player.convo.cmd := cmd;
        player.convo.context := cat;
        return;
    } else {
        return "\"My store is closed. Please come back later.\"";
    }
}

def parseConvoCommand(cmd, topic) {
    if(cmd = CMD_BUY) {
        return parseConvoCommandBuy(topic);
    } else if(cmd = CMD_BUY_PRICE) {
        return parseConvoCommandBuyPrice(topic);
    } else if(cmd = CMD_BUY_CONFIRM) {
        return parseConvoCommandBuyConfirm(topic);
    } else if(cmd = CMD_SELL) {
        return parseConvoCommandSell(topic);
    } else if(cmd = CMD_SELL_PRICE) {
        return parseConvoCommandSellPrice(topic);
    } else if(cmd = CMD_SELL_CONFIRM) {
        return parseConvoCommandSellConfirm(topic);
    }
    print("Unknown command: " + cmd + " on topic: " + topic);
    return {
        lines: [""],
        answers: [],
        cmd: cmd,
    };
}

def parseConvoCommandSell(topic) {
    names := array_filter(array_map(player.inventory.items, item => {
        obj := array_find(OBJECTS, o => o.shape = item.shape);
        if(obj = null || obj.cat != player.convo.context) {
            return null;
        }
        return obj.name;
    }), name => name != null);
    if(len(names) = 0) {
        return {
            lines: ["\"Alas, you have nothing that interests me!\""],
            answers: appendConvoCommands(),
            cmd: null,
        };    
    } else {
        return {
            lines: ["\"What do you want to sell?\""],
            answers: names,
            cmd: CMD_SELL_PRICE
        };
    }
}

def parseConvoCommandSellPrice(topic) {
    item := array_find(OBJECTS, item => item.name = topic);
    player.convo.context := {
        item: item,
        price: round(item.price * 0.8),
    };
    return {
        lines: ["\"I will buy it from you for " + player.convo.context.price + " coins.", "Interested?\""],
        answers: ["Yes", "No"],
        cmd: CMD_SELL_CONFIRM
    };
}

def parseConvoCommandSellConfirm(topic) {
    if(topic = "Yes") {
        #player.inventory.add(player.convo.context.item.shape);
        player.coins :+ player.convo.context.price;
        return {
            lines: ["\"Pleasure doing business with you!", "Let me know if there is anything", "else you wish to sell.\""],
            answers: appendConvoCommands(),
            cmd: null,
        };    
    } else {
        return {
            lines: ["\"Ok, let me know if you change your mind.", "Is there is anything else you wish to sell?\""],
            answers: appendConvoCommands(),
            cmd: null,
        };
    }
}

def parseConvoCommandBuy(topic) {
    return {
        lines: ["\"What do you want to buy?\""],
        answers: array_map(getTraderInventory(player.convo.npc, player.convo.context), item => item.name),
        cmd: CMD_BUY_PRICE
    };
}

def parseConvoCommandBuyPrice(topic) {
    item := array_find(player.convo.npc.tradeInv, item => item.name = topic);
    player.convo.context := {
        item: item,
        price: round(item.price * 1.2),
    };
    return {
        lines: ["\"I will sell it to you for " + player.convo.context.price + " coins.", "Interested?\""],
        answers: ["Yes", "No"],
        cmd: CMD_BUY_CONFIRM
    };
}

def parseConvoCommandBuyConfirm(topic) {
    if(topic = "Yes") {
        if(player.coins >= player.convo.context.price) {
            player.inventory.add(player.convo.context.item.shape);
            player.coins :- player.convo.context.price;
            return {
                lines: ["\"May it serve you well! Let me know if", "there is anything else you wish to buy.\""],
                answers: appendConvoCommands(),
                cmd: null,
            };    
        } else {
            return {
                lines: ["\"Alas, you don't have enough funds!", "Let me know if there is anything else", "you wish to buy.\""],
                answers: appendConvoCommands(),
                cmd: null,
            };    
        }
    } else {
        return {
            lines: ["\"Ok, let me know if you change your mind.", "Is there is anything else you wisth to buy?\""],
            answers: appendConvoCommands(),
            cmd: null,
        };
    }
}

def parseTopic(topic) {
    d := {
        lines: [""],
        answers: [],
        cmd: null,
    };
    i := 0;
    wordStart := 0;
    topic := replaceRegexp(topic, "\\s+", " ");
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

def appendConvoCommands(a=[]) {
    if(player.convo != null && player.convo.npc.trade != null) {
        a[len(a)] := "Buy";
        a[len(a)] := "Sell";
        player.convo.npc.convo["Buy"] := () => startConvoCommand(CMD_BUY, player.convo.npc.trade);
        player.convo.npc.convo["Sell"] := () => startConvoCommand(CMD_SELL, player.convo.npc.trade);
    }
    return a;
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

def removePunctuation(word) {
    # remove ending punctuation
    w := [ word ];
    array_foreach(CONVO_SUFFIX, (i, p) => {
        while(endsWith(w[0], p)) {
            #w[0] := substr(w[0], 0, len(w[0]) - len(p));
            w[0] := stripSuffix(w[0]);
        }
    });
    return w[0];
}

def addWord(topic, i, wordStart, d) {
    word := substr(topic, wordStart, (i - wordStart));
    if(startsWith(word, "$")) {
        word := substr(word, 1, len(word) - 1);
        s := removePunctuation(word);
        d.answers[len(d.answers)] := s;
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
