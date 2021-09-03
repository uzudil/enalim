# make sure the template's name (key) is the same as their shape.
creaturesTemplates := {
    "cow": {
        "shape": "cow",
        "speed": 0.5,
        "baseWidth": 4,
        "baseHeight": 4,
        "sizeZ": 2,
        "isFlying": false,
        "movement": "anchor",
        "hp": 10,
    },
    "monk-blue": {
        "shape": "monk-blue",
        "speed": 0.25,
        "baseWidth": 2,
        "baseHeight": 2,
        "sizeZ": 4,
        "isFlying": false,
        "movement": "anchor",
        "hp": 10,
    },
    "ghost": {
        "shape": "ghost",
        "speed": 0.2,
        "baseWidth": 2,
        "baseHeight": 2,
        "sizeZ": 4,
        "isFlying": true,
        "movement": "anchor",
        "hp": 10,
    },
    "monk": {
        "shape": "monk",
        "speed": 0.25,
        "baseWidth": 2,
        "baseHeight": 2,
        "sizeZ": 4,
        "isFlying": false,
        "movement": "anchor",
        "hp": 10,
    },
    "goblin": {
        "shape": "goblin",
        "speed": 0.25,
        "baseWidth": 2,
        "baseHeight": 2,
        "sizeZ": 4,
        "isFlying": false,
        "movement": "hunt",
        "attackSteps": 2,
        "attack": [1,3],
        "hp": 20,
    },
    "ogre": {
        "shape": "ogre",
        "speed": 0.5,
        "baseWidth": 4,
        "baseHeight": 4,
        "sizeZ": 4,
        "isFlying": false,
        "movement": "hunt",
        "attackSteps": 2,
        "attack": [2,5],
        "hp": 40,
    },
    "man-blue": {
        "shape": "man-blue",
        "speed": 0.25,
        "baseWidth": 2,
        "baseHeight": 2,
        "sizeZ": 4,
        "isFlying": false,
        "movement": "anchor",
        "hp": 10,
    },
    "man-yellow": {
        "shape": "man-yellow",
        "speed": 0.25,
        "baseWidth": 2,
        "baseHeight": 2,
        "sizeZ": 4,
        "isFlying": false,
        "movement": "anchor",
        "hp": 10,
    },
    "woman": {
        "shape": "woman",
        "speed": 0.25,
        "baseWidth": 2,
        "baseHeight": 2,
        "sizeZ": 4,
        "isFlying": false,
        "movement": "anchor",
        "hp": 10,
    },
    "woman.brown": {
        "shape": "woman.brown",
        "speed": 0.25,
        "baseWidth": 2,
        "baseHeight": 2,
        "sizeZ": 4,
        "isFlying": false,
        "movement": "anchor",
        "hp": 10,
    },

};

creatures := [];

def getCreature(x, y, z) {
    # todo: if this is too slow, keep track of creaturePos in a global table
    return array_find(creatures, c => c.move.x = x && c.move.y = y && c.move.z = z);
}

def pruneCreatures(sectionX, sectionY) {
    print("pruneCreatures: " + sectionX + "," + sectionY);
    removes := [];
    array_remove(creatures, c => {
        sectionPos := getSectionPos(c.move.x, c.move.y);
        b := sectionPos[0] = sectionX && sectionPos[1] = sectionY;
        if(b) {
            # not needed: shapes with animations are marked IsSave=false
            # c.move.erase();
            removes[len(removes)] := {
                "id": c.id,
                "shape": c.template.shape,
                "move": c.move.encode(),
                "npc": encodeNpc(c.npc),
                "movement": c.movement,
                "hp": c.hp,
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
    move := decodeMovement(savedCreature.move, tmpl.baseWidth, tmpl.baseHeight, tmpl.sizeZ, tmpl.shape, tmpl.speed, false, tmpl.isFlying);
    move.setShape(tmpl.shape);
    creatures[len(creatures)] := {
        "id": savedCreature.id,
        "template": tmpl,
        "move": move,
        "anchor": [ move.x, move.y, move.z ],
        "standTimer": 0,
        "npc": decodeNpc(savedCreature.npc),
        "movement": savedCreature.movement,
        "hp": savedCreature.hp,
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
            "move": newMovement(x, y, z, creature.baseWidth, creature.baseHeight, creature.sizeZ, creature.shape, creature.speed, false, creature.isFlying),
            "anchor": [ x, y, z ],
            "standTimer": 0,
            "npc": null,
            "movement": creature.movement,
            "hp": creature.hp,
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
        c.move.setAnimation(ANIM_STAND);
    });
}

def moveCreatures(delta) {
    array_foreach(creatures, (i, c) => {
        if(isInView(c.move.x, c.move.y) = false) {
            return true;
        }

        if(c.npc != null) {
            animation := moveNpc(c, delta);
        } else if(c.template.movement = "hunt") {
            animation := moveMonster(c, delta);
        } else {
            animation := moveCreatureRandom(c, delta);
        }        
        c.move.setAnimation(animation);
    });
}

def anchorAndMoveCreatureRandom(c, delta) {
    # re-anchor at current location
    c.anchor := [ c.move.x, c.move.y, c.move.z ];
    return moveCreatureRandom(c, delta);
}

# directional random walk with pausing
def moveCreatureRandom(c, delta) {
    if(c.movement = "stand") {
        return ANIM_STAND;
    } else if(c.standTimer > 0) {
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
    distXy := distance(
        c.anchor[0], c.anchor[1], c.anchor[2], 
        c.move.x + d[0], c.move.y + d[1], c.anchor[2]
    );
    dirChange := false;
    if(distXy > 8) {
        dirChange := true;
    } else if(c.move.moveInDir(d[0], d[1], delta, null, null) = false) {
        dirChange := true;
    }
    if(dirChange) {
        c.move.dir := int(random() * 8);
    }
}

def takeDamage(c, dam, onDeath) {
    if(dam > 0) {
        showMessageAt(
            c.move.x, 
            c.move.y, 
            c.move.z, 
            "-" + dam, 
            2, 
            DAM_R, DAM_G, DAM_B, 
            true
        );
        c.hp := c.hp - dam;
        if(c.hp <= 0) {
            c.hp := 0;
            setShapeExtra(
                c.move.x + int(random() * (c.move.width + 2)) - 1,
                c.move.y + int(random() * (c.move.height + 2)) - 1,
                c.move.z,
                "splat.blood.small"
            );
            onDeath(c);
        } else if(random() >= 0.75) {
            setShapeExtra(
                c.move.x + int(random() * (c.move.width + 2) - 1),
                c.move.y + int(random() * (c.move.height + 2) - 1),
                c.move.z,
                "splat.blood.small"
            );
        }
    }
}