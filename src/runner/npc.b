
const npcs = {};

def initNpcs() {
    npcs["necromancer"] := { 
        "name": "The Necromancer",
        "creature": creaturesTemplates["monk-blue"] 
    };
}

def setNpc(x, y, z, npc) {
    creature := setCreature(x, y, z, npc.creature);
    creature.npc := npc;
}

# prepare npc to be saved
def encodeNpc(npc) {
    if(npc = null) {
        return {};
    }
    return {
        "name": npc.name
    };
}

# restore npc from saved copy
def decodeNpc(savedNpc) {
    print("savedNpc=" + savedNpc + " len=" + len(keys(savedNpc)));
    if(savedNpc["name"] = null) {
        print("savedNpc 1");
        return null;
    }
    print("savedNpc 2");
    n := npcs[array_find(keys(npcs), k => npcs[k].name = savedNpc.name)];
    print("savedNpc n=" + n);
    return n;
}
