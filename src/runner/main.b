const MODE_INIT = 0;
const MODE_GAME = 1;
const MODE_TELEPORT = 2;
const MODE_CONVO = 3;

# the global player state
player := {
    "mode": MODE_INIT,
    "move": null,
    "underRoof": false,
    "roof": null,
    "teleportPos": null,
    "convo": null,
    "elapsedTime": 0,
    "timeouts": [],
};

# the player's shape size
const PLAYER_X = 2;
const PLAYER_Y = 2;
const PLAYER_Z = 4;

const PLAYER_MOVE_SPEED = 0.085;
const PLAYER_ANIM_SPEED = 0.05;

const PLAYER_SHAPE = "lydell";

# called on every frame
def events(delta, fadeDir) {
    player.elapsedTime := player.elapsedTime + delta;

    # expire any timeouts
    array_remove(player.timeouts, e => {
        if(player.elapsedTime >= e[0]) {
            e[2](e[1]);
            return true;
        }
        return false;
    });

    if(player.mode = MODE_INIT) {
        eventsInit(delta, fadeDir);
    } else {
        if(player.mode = MODE_TELEPORT) {
            eventsTeleport(delta, fadeDir);
        } else {
            if(player.mode = MODE_CONVO) {
                eventsConvo(delta, fadeDir);
            } else {
                eventsGameplay(delta);
            }
        }
    }

    if(isPressed(KeyX)) {
        player.move.erase();
        saveGame();
        player.move.setShape(PLAYER_SHAPE);
        setRoofVisiblity();
    }
}

def eventsConvo(delta, fadeDir) {
    if(isPressed(KeyEscape)) {
        endConvo();
    } else {
        if(isPressed(KeyW) || isPressed(KeyUp)) {
            decrConvoAnswerIndex();
        }
        if(isPressed(KeyS) || isPressed(KeyDown)) {
            incrConvoAnswerIndex();
        }
        if(isPressed(KeySpace)) {
            fireConvoAnswerIndex();
        }
        player.move.setAnimation(ANIM_STAND, PLAYER_ANIM_SPEED);
        stopCreatures();
        renderConvo();    
    }
}

def eventsInit(delta, fadeDir) {
    if(fadeDir = 1) {
        player.move.setShape(PLAYER_SHAPE);
        player.mode := MODE_GAME;
    }
    player.move.setAnimation(ANIM_STAND, PLAYER_ANIM_SPEED);
    stopCreatures();
}

def eventsTeleport(delta, fadeDir) {
    if(fadeDir = 1) {
        player.move.erase();
        player.move.set(player.teleportPos[0], player.teleportPos[1], player.teleportPos[2]);
        player.move.setShape(PLAYER_SHAPE);
        player.teleportPos := null;
        setRoofVisiblity();
        player.mode := MODE_GAME;
    }
    player.move.setAnimation(ANIM_STAND, PLAYER_ANIM_SPEED);
    stopCreatures();
}

def eventsGameplay(delta) {
    animationType := ANIM_STAND;
    dx := 0;
    dy := 0;
    if(isDown(KeyA) || isDown(KeyLeft)) {
        dx := 1;
    }
    if(isDown(KeyD) || isDown(KeyRight)) {
        dx := -1;
    }
    if(isDown(KeyW) || isDown(KeyUp)) {
        dy := -1;
    }
    if(isDown(KeyS) || isDown(KeyDown)) {
        dy := 1;
    }

    if(dx != 0 || dy != 0) {
        animationType := ANIM_MOVE;
        playerMove(dx, dy, delta);
    }

    if(isPressed(KeySpace)) {
        if(findShapeNearby("door.wood.y", (x,y,z) => replaceShape(x, y, z, "door.wood.x")) = false) {
            if(findShapeNearby("door.wood.x", (x,y,z) => replaceShape(x, y, z, "door.wood.y")) = false) {
                if(findShapeNearby("clock.y", (x, y, z) => timedMessage(x, y, z, getTime())) = false) {
                    scriptedActionNearby();
                }
            }
        }
    }

    if(isPressed(KeyT)) {
        findNpcNearby(startConvo);
    }

    player.move.setAnimation(animationType, PLAYER_ANIM_SPEED);
    moveCreatures(delta);
}

def playerMove(dx, dy, delta) {
    moved := player.move.moveInDir(dx, dy, delta, checkTeleportLocations);
    if(moved = false && dx != 0 && dy != 0) {
        moved := player.move.moveInDir(0, dy, delta, checkTeleportLocations);
    }
    if(moved = false && dx != 0 && dy != 0) {
        moved := player.move.moveInDir(dx, 0, delta, checkTeleportLocations);
    }
    if(moved) {
        setRoofVisiblity();
    }
    return moved;
}

def setRoofVisiblity() {
    # if under a roof, hide the roof
    inspectRoof();
    if(player.underRoof) {
        if(startsWith(player.roof, "roof.mountain")) {
            setMaxZ(getRoofZ(player.move.z), player.roof);
        } else {
            setMaxZ(getRoofZ(player.move.z), null);
        }
    } else {
        setMaxZ(24, null);
    }
}

def checkTeleportLocations(newX, newY, newZ) {
    # check teleport locations
    player.teleportPos := teleport(newX, newY, player.move.z);
    if(player.teleportPos != null) {
        # start fade out
        player.mode := MODE_TELEPORT;
        fadeViewTo(player.teleportPos[0], player.teleportPos[1]);
        return true;
    }
    return false;
}

def replaceShape(x, y, z, name) {
    if(intersectsShapes(x, y, z, name, PLAYER_SHAPE) = false) {
        eraseShape(x, y, z);
        setShape(x, y, z, name);
    } else {
        print("player blocks!");
    }
}

def findShapeNearby(name, fx) {
    return findNearby(1, (x,y,z) => {
        info := getShape(x, y, z);
        if(info != null) {
            if(info[0] = name) {
                return info;
            }
        }
        return null;
    }, info => fx(info[1], info[2], info[3]));
}

def findNpcNearby(fx) {
    if(findNearby(4, getNpc, fx) = false) {
        print("Not near any npc-s.");
    }
}

def scriptedActionNearby() {
    findNearby(1, scriptedAction, null);
}

def findNearby(radius, evalFx, successFx) {
    found := [false];
    range(-1 * radius, PLAYER_X + radius, 1, x => {
        range(-1 * radius, PLAYER_Y + radius, 1, y => {
            range(0, PLAYER_Z, radius, z => {
                if(found[0] = false) {
                    e := evalFx(player.move.x + x, player.move.y + y, player.move.z + z);
                    if(e != null) {
                        if(successFx != null) {
                            successFx(e);
                        }
                        found[0] := true;
                    }
                }
            });
        });
    });
    return found[0];
}

def getRoofZ(z) {
    # roofs are only at certain heights
    return (int(z / 7) + 1) * 7;
}

def inspectRoof() {
    # roofs are only at certain heights
    testZ := player.move.z;
    while(testZ < 24) {
        z := getRoofZ(testZ);
        player.underRoof := true;
        player.roof := null;
        forBase(PLAYER_X, PLAYER_Y, (x, y) => {
            info := getShape(player.move.x + x, player.move.y + y, z);
            if(info = null) {
                player.underRoof := false;
                player.roof := null;
            } else {
                if(substr(info[0], 0, 5) != "roof." && substr(info[0], 0, 6) != "floor.") {
                    player.underRoof := false;
                    player.roof := null;
                } else {
                    player.roof := info[0];
                }
            }
        });
        if(player.underRoof) {
            return true;
        }
        testZ := testZ + 7;
    }
    return false;
}

def addTimeout(ttl, cleanupFx, param) {
    player.timeouts[len(player.timeouts)] := [player.elapsedTime + ttl, param, cleanupFx];
}

def timedMessage(x, y, z, message) {
    showMessageAt(x, y, z, message, MESSAGE_R, MESSAGE_G, MESSAGE_B);
}

# Put main last so if there are parsing errors, the game panic()-s.
def main() {
    staticInitSections();
    player.move := newMovement(5000, 5015, 1, PLAYER_X, PLAYER_Y, PLAYER_MOVE_SPEED, true);
    fadeViewTo(player.move.x, player.move.y);    
}
