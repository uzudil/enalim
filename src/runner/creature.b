# make sure the template's name (key) is the same as their shape.
creaturesTemplates := {
    "cow": {
        "shape": "cow",
        "speed": 0.5,
        "animSpeed": 0.2,
        "baseWidth": 4,
        "baseHeight": 4,
    }
};

creatures := [];

const SECTION_SIZE = 200;

def pruneCreatures(sectionX, sectionY) {
    removes := [];
    array_remove(creatures, c => {
        creatureSectionX := int(c.pos[0] / SECTION_SIZE);
        creatureSectionY := int(c.pos[1] / SECTION_SIZE);
        b := creatureSectionX = sectionX && creatureSectionY = sectionY;
        if(b) {
            eraseShape(c.pos[0], c.pos[1], c.pos[2]);
            removes[len(removes)] := {
                "id": c.id,
                "shape": c.template.shape,
                "pos": c.pos,
                "dir": c.dir,
            };
            print("* Pruning creature: " + c.template.shape + " " + c.id);
        }
        return b;
    });
    debugCreatures();
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
        "move": moveCreatureRandom,
    };
}

def setCreature(x, y, z, creature) {
    id := "c." + x + "." + y + "." + z;
    if(array_find(creatures, c => c.id = id) = null) {
        print("* Adding creature: " + creature.shape + " " + id);
        setShape(x, y, z, creature.shape);
        creatures[len(creatures)] := {
            "id": id,
            "template": creature,
            "pos": [x, y, z],
            "dir": DirW,
            "scrollOffset": [0, 0],
            "standTimer": 0,
            "move": moveCreatureRandom,
        };
        #debugCreatures();
    }
}

def debugCreatures() {
    print("+++ Creatures: " + array_join(array_map(creatures, c => c.template.shape + " " + c.id), "|"));
}

def moveCreatures(delta) {
    array_foreach(creatures, (i, c) => {
        # todo: instead of isInView, the view should maintain "origins" outside its borders (an extra VIEW_BORDER size?)
        # and just use the regular validPos returned by toViewPos
        if(isInView(c.pos[0], c.pos[1]) = false) {
            return true;
        }

        animation := c.move(delta);
        setAnimation(c.pos[0], c.pos[1], c.pos[2], animation, c.dir, c.template.animSpeed);
    });
}

# directional random walk with pausing
def moveCreatureRandom(c, delta) {
    if(c.standTimer > 0) {
        animation := "stand";
        c.standTimer := c.standTimer - delta;
    } else {
        animation := "move";
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
