# make sure the template's name (key) is the same as their shape.
creaturesTemplates := {
    "cow": {
        "shape": "cow",
        "speed": 0.5,
        "animSpeed": 0.2,
        "baseWidth": 4,
        "baseHeight": 4,
    },
    "monk-blue": {
        "shape": "monk-blue",
        "speed": 0.25,
        "animSpeed": 0.2,
        "baseWidth": 2,
        "baseHeight": 2,
    },
    "ghost": {
        "shape": "ghost",
        "speed": 0.2,
        "animSpeed": 0.2,
        "baseWidth": 2,
        "baseHeight": 2,
    }
};

creatures := [];

def getCreature(x, y, z) {
    # todo: if this is too slow, keep track of creaturePos in a global table
    return array_find(creatures, c => c.pos[0] = x && c.pos[1] = y && c.pos[2] = z);
}

def pruneCreatures(sectionX, sectionY) {
    removes := [];
    array_remove(creatures, c => {
        sectionPos := getSectionPos(c.pos[0], c.pos[1]);
        b := sectionPos[0] = sectionX && sectionPos[1] = sectionY;
        if(b) {
            eraseShape(c.pos[0], c.pos[1], c.pos[2]);
            removes[len(removes)] := {
                "id": c.id,
                "shape": c.template.shape,
                "pos": c.pos,
                "dir": c.dir,
                "npc": encodeNpc(c.npc),
            };
            print("* Pruning creature: " + c.template.shape + " " + c.id);
        }
        return b;
    });
    #debugCreatures();
    return removes;
}

def restoreCreature(savedCreature) {
    # todo: this is technically wrong: shape != template name...
    tmpl := creaturesTemplates[savedCreature.shape];
    print("* Restoring creature " + tmpl.shape + " " + savedCreature.id);
    setShape(savedCreature.pos[0], savedCreature.pos[1], savedCreature.pos[2], tmpl.shape);
    creatures[len(creatures)] := {
        "id": savedCreature.id,
        "template": tmpl,
        "pos": savedCreature.pos,
        "dir": savedCreature.dir,
        "scrollOffset": [0, 0],
        "standTimer": 0,
        "npc": decodeNpc(savedCreature.npc),
    };
}

def setCreature(x, y, z, creature) {
    id := "c." + x + "." + y + "." + z;
    c := array_find(creatures, c => c.id = id);
    if(c = null) {
        print("* Adding creature: " + creature.shape + " " + id);
        setShape(x, y, z, creature.shape);
        c := {
            "id": id,
            "template": creature,
            "pos": [x, y, z],
            "dir": DirW,
            "scrollOffset": [0, 0],
            "standTimer": 0,
            "npc": null,
        };
        creatures[len(creatures)] := c;
        #debugCreatures();
    }
    return c;
}

def debugCreatures() {
    print("+++ Creatures: " + array_join(array_map(creatures, c => c.template.shape + " " + c.id), "|"));
}

def stopCreatures() {   
    array_foreach(creatures, (i, c) => {
        setAnimation(c.pos[0], c.pos[1], c.pos[2], ANIM_STAND, c.dir, c.template.animSpeed);
    });
}

def moveCreatures(delta) {
    array_foreach(creatures, (i, c) => {
        # todo: instead of isInView, the view should maintain "origins" outside its borders (an extra VIEW_BORDER size?)
        # and just use the regular validPos returned by toViewPos
        if(isInView(c.pos[0], c.pos[1]) = false) {
            return true;
        }

        if(c.npc = null) {
            animation := moveCreatureRandom(c, delta);
        } else {
            animation := moveNpc(c, delta);
        }
        setAnimation(c.pos[0], c.pos[1], c.pos[2], animation, c.dir, c.template.animSpeed);
    });
}

def moveNpc(c, delta) {
    if(c.standTimer > 0) {
        animation := ANIM_STAND;
        c.standTimer := c.standTimer - delta;
    } else {
        animation := ANIM_MOVE;
        moveCreatureRandomMove(c, delta);
        if(random() > 0.995) {
            c.standTimer := 3;
        }
    }
    return animation;
}

# directional random walk with pausing
def moveCreatureRandom(c, delta) {
    if(c.standTimer > 0) {
        animation := ANIM_STAND;
        c.standTimer := c.standTimer - delta;
    } else {
        animation := ANIM_MOVE;
        moveCreatureRandomMove(c, delta);
        if(random() > 0.995) {
            c.standTimer := 3;
        }
    }
    return animation;
}

def moveCreatureRandomMove(c, delta) {
    # todo: unify this with player directional movement code?
    d := getDirMove(c.dir);
    newXf := c.pos[0] + c.scrollOffset[0] + (d[0] * delta / c.template.speed);
    newYf := c.pos[1] + c.scrollOffset[1] + (d[1] * delta / c.template.speed);
    newX := int(newXf + 0.5);
    newY := int(newYf + 0.5);

    moved := true;
    if(newX != c.pos[0] || newY != c.pos[1]) {
        fitOk := fits(newX, newY, c.pos[2], c.pos[0], c.pos[1], c.pos[2]);
        underOk := inspectUnder(newX, newY, c.pos[2], c.template.baseWidth, c.template.baseHeight);
        if(fitOk && underOk) {
            moveShape(c.pos[0], c.pos[1], c.pos[2], newX, newY, c.pos[2]);
            c.pos[0] := newX;
            c.pos[1] := newY;
        } else {
            moved := false;
            c.dir := int(random() * 8);
        }
    }    

    if(moved) {
        # pixel scrolling
        c.scrollOffset[0] := newXf - newX;
        c.scrollOffset[1] := newYf - newY;
        setOffset(c.pos[0], c.pos[1], c.pos[2], c.scrollOffset[0], c.scrollOffset[1]);
    }
}


def getDirMove(dir) {
    if(dir = DirW) {
        return [1, 0];
    }
    if(dir = DirE) {
        return [-1, 0];
    }
    if(dir = DirN) {
        return [0, -1];
    }
    if(dir = DirS) {
        return [0, 1];
    }
    if(dir = DirNW) {
        return [1, -1];
    }
    if(dir = DirNE) {
        return [-1, -1];
    }
    if(dir = DirSW) {
        return [1, 1];
    }
    if(dir = DirSE) {
        return [-1, 1];
    }
    return [0, 0];
}
