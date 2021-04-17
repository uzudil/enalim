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
                index := array_find_index(c.npc.schedule, sched => hour >= sched.from && hour < sched.to);
                if(index != c.npc["activeSchedule"]) {
                    c.npc["activeSchedule"] := index;
                    c.npc["activeScheduleChange"] := true;
                    print(c.npc.name + " active schedule is now:" + c.npc.activeSchedule);
                    #dest := c.npc.schedule[c.npc.activeSchedule].pos;
                    #print(c.npc.name + " schedule change movement to " + dest[0] + "," + dest[1] + "," + dest[2]);
                    #dist := c.move.distanceTo(dest[0], dest[1], dest[2]);
                    #print(c.npc.name + " schedule change distance=" + dist);
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
    dist := c.move.distanceTo(dest[0], dest[1], dest[2]);
    print(c.npc.name + " move to " + dest[0] + "," + dest[1] + "," + dest[2] + " distance=" + dist);

    # already there?
    if(dist <= 8) {
        print(c.npc.name + " schedule change done");
        del c.npc["activeScheduleChange"];
        if(c.npc["path"] != null) {
            del c.npc["path"];
            del c.npc["step"];
        }
        return null;
    }

    # are we on a path?
    if(c.npc["path"] != null) {
        if(c.npc.step >= len(c.npc.path)) {
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
            # try to move in the right direction
            dx := normalize(dest[0] - c.move.x);
            dy := normalize(dest[1] - c.move.y);
            print(c.npc.name + " abs move: " + dx + "," + dy);
            if(c.move.moveInDir(dx, dy, delta, null)) {
                return ANIM_MOVE;
            }
            return ANIM_STAND;
        }
    }
    
    # try to get there via astar            
    path := c.move.findPath(dest[0], dest[1], dest[2]);
    print("+++ " + c.npc.name + " path finder: " + path);
    if(path != null) {
        c.npc["path"] := path;
        c.npc["step"] := 0;
        return takePathStep(c, delta);
    }

    # can't find path: try again in 1/2 sec
    c.npc["nextPathSearch"] := 0.5;
    return ANIM_STAND;
}


def takePathStep(c, delta) {
    # take a step on path
    nextPos := c.npc.path[c.npc.step]
    dx := nextPos[0] - c.move.x;
    dy := nextPos[1] - c.move.y;
    print(c.npc.name + " path step (" + c.npc.step + "/" + len(c.npc.path) + "): " + dx + "," + dy);
    moved := c.move.moveInDir(dx, dy, delta, (newX, newY, newZ) => {
        c.npc.step := c.npc.step + 1;
        # return false to not interrupt the move
        return false;
    });
    if(moved) {
        return ANIM_MOVE;
    }
    return ANIM_STAND;
}
