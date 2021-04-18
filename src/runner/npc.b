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

    dest := c.npc.schedule[c.npc.activeSchedule].pos;
    # print(c.npc.name + " move to " + dest[0] + "," + dest[1] + "," + dest[2] + 
    #    " curr=" + c.move.x + "," + c.move.y + "," + c.move.z);

    # already there?
    if(c.move.isAt(dest[0], dest[1], dest[2])) {
        print(c.npc.name + " schedule change done");
        del c.npc["activeScheduleChange"];
        if(c.npc["path"] != null) {
            del c.npc["path"];
            del c.npc["step"];
        }
        c["anchor"][0] := dest[0];
        c["anchor"][1] := dest[1];
        c["anchor"][2] := dest[2];
        return null;
    }

    # are we on a path?
    if(c.npc["path"] != null) {
        if(c.npc.step >= len(c.npc.path)/3) {
            # finished path?
            del c.npc["path"];
            del c.npc["step"];
            print(c.npc.name + " path done, will try new path");
        } else {
            return takePathStep(c, delta);
        }
    }

    # can't call findPath yet
    if(c.npc["nextPathSearch"] != null) {
        c.npc.nextPathSearch := c.npc.nextPathSearch - delta;
        if(c.npc.nextPathSearch < 0) {
            del c.npc["nextPathSearch"];
        } else {
            return moveCreatureRandom(c, delta);
        }
    }
    
    # try to get there via astar            
    print("+++ " + c.npc.name + " calling findPath!");
    path := c.move.findPath(dest[0], dest[1], dest[2]);
    print("+++ " + c.npc.name + " path finder: " + path);
    if(path = null) {
        if(findCloserReachablePos(c, dest)) {
            print("+++ trying findPath again to closer pos: " + dest);
            path := c.move.findPath(dest[0], dest[1], dest[2]);
            print("+++ " + c.npc.name + " closer path finder: " + path);
        }
    }   
    if(path != null) {
        c.npc["path"] := path;
        c.npc["step"] := 0;
        return takePathStep(c, delta);
    }

    # can't find path: try again in 1/2 sec
    c.npc["nextPathSearch"] := 0.5;
    return ANIM_STAND;
}

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

def takePathStep(c, delta) {
    # take a step on path
    nextX := c.npc.path[c.npc.step * 3];
    nextY := c.npc.path[(c.npc.step * 3) + 1];
    deltaX := nextX - c.move.x;
    deltaY := nextY - c.move.y;
    moved := c.move.moveInDir(deltaX, deltaY, delta, null, (newX, newY, newZ) => {
        c.npc.step := c.npc.step + 1;
    });
    if(moved) {
        return ANIM_MOVE;
    }
    print(c.npc.name + " failed to move on path. From: " + c.move.x + "," + c.move.y + " To:" + nextX + "," + nextY);
    return ANIM_STAND;
}
