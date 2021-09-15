def registerNpc(npc) {
    npc.creature := creaturesTemplates[npc.creature];
    
    # assign a pos if one is not given
    if(npc.schedule[0].pos = null) {
        w := npc.waypoints;
        if(npc.schedule[0].waypointDir = 1) {
            npc.schedule[0].pos := w[len(w) - 1];
        } else {
            npc.schedule[0].pos := w[0];
        }
    }
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
                    c.npc["waypointIndex"] := getClosestWaypointIndex(c);
                    print(c.npc.name + " active schedule is now:" + c.npc.activeSchedule);
                }
            }
        }
    });
}

def getClosestWaypointIndex(c) {
    if(c.npc.waypoints = null) {
        return 0;
    }
    closest := [];
    array_foreach(c.npc.waypoints, (i, w) => {
        d := distance(w[0], w[1], w[2], c.move.x, c.move.y, c.move.z);
        if(len(closest) = 0 || closest[1] > d) {
            closest[0] := i;
            closest[1] := d;
        }
    });
    return closest[0];
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

    if(c.npc.waypoints != null) {
        p := c.npc.waypoints[c.npc.waypointIndex];
    } else {
        p := c.npc.schedule[c.npc.activeSchedule].pos;
    }
    return pathMove(c, delta, {
        "name": c.npc.name, 
        "dest": { "x": p[0], "y": p[1], "z": p[2] }, 
        "nearDistance": 0,
        "farDistance": 0,
        "onSuccess": self => npcPathMoveSuccess(c, p, delta),
    });
}

def npcPathMoveSuccess(c, pos, delta) {
    w := c.npc.waypoints;
    wDir := c.npc.schedule[c.npc.activeSchedule].waypointDir;
    if(w != null && ((wDir = 1 && c.npc.waypointIndex < len(w) - 1) || (wDir = -1 && c.npc.waypointIndex > 0))) {
        # move to next waypoint        
        c.npc.waypointIndex :+ wDir;
        print(c.npc.name + " moving to waypoint " + c.npc.waypointIndex);
    } else {
        print(c.npc.name + " arrived at destination.");
        del c.npc["activeScheduleChange"];
        c["anchor"][0] := pos[0];
        c["anchor"][1] := pos[1];
        c["anchor"][2] := pos[2];
        c.movement := c.npc.schedule[c.npc.activeSchedule].movement;    
    }
    return null;
}
