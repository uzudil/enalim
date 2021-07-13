def registerNpc(npc) {
    npc.creature := creaturesTemplates[npc.creature];
    npcDefs[npc.name] := npc;
}

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

def evalNpcSchedules(hour) {
    array_foreach(creatures, (i, c) => {
        if(c.npc != null) {
            if(c.npc["schedule"] != null) {
                index := array_find_index(c.npc.schedule, sched => {
                    if(sched.from < sched.to) {
                        return hour >= sched.from && hour < sched.to;
                    } else {
                        return hour >= sched.from || hour < sched.to;
                    }
                });
                if(index != c.npc["activeSchedule"]) {
                    c.npc["activeSchedule"] := index;
                    c.npc["activeScheduleChange"] := true;
                    print(c.npc.name + " active schedule is now:" + c.npc.activeSchedule);
                }
            }
        }
    });
}

def moveNpc(c, delta) {
    animation := moveNpcSchedule(c, delta);
    if(animation != null) {
        return animation;
    }
    return moveCreatureRandom(c, delta);
}

def moveNpcSchedule(c, delta) {
    if(c.npc["activeScheduleChange"] = null) {
        return null;
    }

    p := c.npc.schedule[c.npc.activeSchedule].pos;
    return pathMove(c, delta, {
        "name": c.npc.name, 
        "dest": { "x": p[0], "y": p[1], "z": p[2] }, 
        "nearDistance": 0,
        "farDistance": 0,
        "onSuccess": self => {
            del c.npc["activeScheduleChange"];
            c["anchor"][0] := p[0];
            c["anchor"][1] := p[1];
            c["anchor"][2] := p[2];
            c.movement := c.npc.schedule[c.npc.activeSchedule].movement;    
            return null;
        },
    });
}



##########################################################
##########################################################
##########################################################
# unused code - remove eventually
#
def findCloserReachablePos(c, dest) {
    minX := c.move.x - VIEW_SIZE/2 + 4;
    maxX := c.move.x + VIEW_SIZE/2 - 4;
    minY := c.move.y - VIEW_SIZE/2 + 4;
    maxY := c.move.y + VIEW_SIZE/2 - 4;
    changed := false;
    if(dest[0] < minX) {
        dest[0] := minX;
        changed := true;
    }
    if(dest[0] > maxX) {
        dest[0] := maxX;
        changed := true;
    }
    if(dest[1] < minY) {
        dest[1] := minY;
        changed := true;
    }
    if(dest[1] > maxY) {
        dest[1] := maxY;
        changed := true;
    }
    if(changed) {
        dest[2] := c.move.z;
    }
    return changed;
}
