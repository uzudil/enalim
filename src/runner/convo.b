def startConvo(npc) {
    player.mode := MODE_CONVO;
    player.convo := {
        "npc": npc,
        "topic": "",
        "lastTopic": null,
    };
}

def renderConvo() {
    #if(convo.topic != convo.lastTopic) {
        printMessage(10, 50, player.convo.npc.convo[player.convo.topic]);
        convo.lastTopic := convo.topic;
    #}
}
