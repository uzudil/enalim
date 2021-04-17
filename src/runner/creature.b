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
    return array_find(creatures, c => c.move.x = x && c.move.y = y && c.move.z = z);
}

def pruneCreatures(sectionX, sectionY) {
    removes := [];
    array_remove(creatures, c => {
        sectionPos := getSectionPos(c.move.x, c.move.y);
        b := sectionPos[0] = sectionX && sectionPos[1] = sectionY;
        if(b) {
            c.move.erase();
            removes[len(removes)] := {
                "id": c.id,
                "shape": c.template.shape,
                "move": c.move.encode(),
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
    move := decodeMovement(savedCreature.move, tmpl.baseWidth, tmpl.baseHeight, tmpl.speed, false);
    move.setShape(tmpl.shape);
    creatures[len(creatures)] := {
        "id": savedCreature.id,
        "template": tmpl,
        "move": move,
        "anchor": [ move.x, move.y, move.z ],
        "standTimer": 0,
        "npc": decodeNpc(savedCreature.npc),
    };
}

def setCreature(x, y, z, creature) {
    id := "c." + x + "." + y + "." + z;
    c := array_find(creatures, c => c.id = id);
    if(c = null) {
        print("* Adding creature: " + creature.shape + " " + id);
        c := {
            "id": id,
            "template": creature,
            "move": newMovement(x, y, z, creature.baseWidth, creature.baseHeight, creature.speed, false),
            "anchor": [ x, y, z ],
            "standTimer": 0,
            "npc": null,
        };
        c.move.setShape(creature.shape);
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
        c.move.setAnimation(ANIM_STAND, c.template.animSpeed);
    });
}

def moveCreatures(delta) {
    array_foreach(creatures, (i, c) => {
        # todo: instead of isInView, the view should maintain "origins" outside its borders (an extra VIEW_BORDER size?)
        # and just use the regular validPos returned by toViewPos
        if(isInView(c.move.x, c.move.y) = false) {
            return true;
        }

        if(c.npc = null) {
            animation := moveCreatureRandom(c, delta);
        } else {
            animation := moveNpc(c, delta);
        }
        c.move.setAnimation(animation, c.template.animSpeed);
    });
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
    d := getDelta(c.move.dir);
    dist := distance(
        c.anchor[0], c.anchor[1], c.anchor[2], 
        c.move.x + d[0], c.move.y + d[1], c.move.z
    );
    dirChange := false;
    if(dist > 8) {
        dirChange := true;
    } else {
        if(c.move.moveInDir(d[0], d[1], delta, null) = false) {
            dirChange := true;
        }
    }
    if(dirChange) {
        c.move.dir := int(random() * 8);
    }
}
