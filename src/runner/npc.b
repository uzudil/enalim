def setNpc(x, y, z, npc) {
    creature := setCreature(x, y, z, npc.creature);
    creature.npc := npc;
}

def getNpc(x, y, z) {
    c := getCreature(x, y, z);
    if(c != null) {
        return c.npc;
    }
    return null;
}

# prepare npc to be saved
def encodeNpc(npc) {
    if(npc = null) {
        return {};
    }
    print("* Saving npc " + npc.name);
    return {
        "name": npc.name
    };
}

# restore npc from saved copy
def decodeNpc(savedNpc) {
    if(savedNpc["name"] = null) {
        return null;
    }
    print("* Restoring npc " + savedNpc.name);
    n := npcDefs[array_find(keys(npcDefs), k => npcDefs[k].name = savedNpc.name)];
    return n;
}
