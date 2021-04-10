const TITLE_X = 4204;
const TITLE_Y = 4175;

const MODE_INIT = "init";
const MODE_GAME = "game";
const MODE_TELEPORT = "teleport";
const MODE_CONVO = "convo";
const MODE_TITLE = "title";
const MODE_TITLE2 = "title2";
const MODE_TITLE3 = "title3";

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

const EVENTS_MAP = {};

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

    EVENTS_MAP[player.mode](delta, fadeDir);

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
        player.mode := MODE_TITLE;
        addMessage(110, 250, "2021 (c) Gabor Torok", 200, 200, 200);
        addMessage(110, 275, "Press SPACE to start", 128, 128, 128);
    }
}

def eventsTitle(delta, fadeDir) {
    if(isPressed(KeySpace)) {
        delAllMessages();
        player.mode := MODE_TITLE2;
        # all black
        fadeViewTo(100, 100); 
    } else {
        moveCreatures(delta);
    }
}

def eventsTitle2(delta, fadeDir) {
    if(fadeDir = 1) {
        player.mode := MODE_TITLE3;
        addMessage(10, 25, "The story so far...", 200, 200, 200);
        o := parseTopic("Your name is Lydell and you have always lived on the island, serving the Necromancer. One day he will train you to be a powerful wizard, you are sure.");
        array_foreach(o.lines, (index, line) => addMessage(10, 75 + (index * LINE_HEIGHT), line, 128, 128, 128));
        o := parseTopic("Strangely, you don't seem to recall how you got to the island...");
        array_foreach(o.lines, (index, line) => addMessage(10, 200 + (index * LINE_HEIGHT), line, 128, 128, 128));
        addMessage(110, 275, "Press SPACE to continue", 128, 128, 128);
    }
}

def eventsTitle3(delta, fadeDir) {
    if(isPressed(KeySpace)) {
        delAllMessages();
        player.mode := MODE_GAME;
        player.move := newMovement(5000, 5015, 1, PLAYER_X, PLAYER_Y, PLAYER_MOVE_SPEED, true);
        player.move.setShape(PLAYER_SHAPE);
        player.move.setAnimation(ANIM_STAND, PLAYER_ANIM_SPEED);
        stopCreatures();
        fadeViewTo(player.move.x, player.move.y);
    }
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

def eventsGameplay(delta, fadeDir) {
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
                if(operateWindow() = false) {
                    if(findShapeNearby("clock.y", (x, y, z) => timedMessage(x, y, z, getTime())) = false) {
                        scriptedActionNearby();
                    }
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

const WIN_X_POS = [
    [ 2, 0, 0, 0, 1, 0 ],
    [ -2, 0, 1, 0, 0, 0 ],
    [ 0, 3, 0, 0, 0, -1 ],
    [ 0, -3, -1, 0, 0, 0 ],
];
const WIN_Y_POS = [
    [ 0, 2, 0, 0, 0, 1 ],
    [ 0, -2, 1, 0, 0, 0 ],
    [ 3, 0, 0, 0, -1, 0 ],
    [ -3, 0, -1, 0, 0, 0 ],
];

def operateWindow() {
    winX := [0, 0, 0];
    winY := [0, 0, 0];
    findShapeNearby("window.x", (x,y,z) => {
        winX[0] := x;
        winX[1] := y;
        winX[2] := z;
    });
    findShapeNearby("window.y", (x,y,z) => {
        winY[0] := x;
        winY[1] := y;
        winY[2] := z;
    });

    # no windows near
    if(winX[0] = 0 && winY[0] = 0) {
        return false;
    }

    a := [0, 0, 0];
    if(winX[0] > 0) {
        a := winX;
        pos := array_find(WIN_X_POS, e => isShapeAt("window.x", a[0] + e[0], a[1] + e[1], a[2]));
        if(pos != null) {
            changeWindowState(a, pos, "window.x", "window.y");
        }
    } else {
        a := winY;
        pos := array_find(WIN_Y_POS, e => isShapeAt("window.y", a[0] + e[0], a[1] + e[1], a[2]));
        if(pos != null) {            
            changeWindowState(a, pos, "window.y", "window.x");
        }
    }
    
    return true;
}

def changeWindowState(a, pos, oShape, nShape) {
    b := [a[0] + pos[0], a[1] + pos[1], a[2]];
    eraseShape(a[0], a[1], a[2]);
    eraseShape(b[0], b[1], b[2]);
    if(isEmpty(a[0] + pos[2], a[1] + pos[3], a[2], nShape) && isEmpty(b[0] + pos[4], b[1] + pos[5], b[2], nShape)) {
        setShape(a[0] + pos[2], a[1] + pos[3], a[2], nShape);
        setShape(b[0] + pos[4], b[1] + pos[5], b[2], nShape);
    } else {
        print("player blocks!");
        setShape(a[0], a[1], a[2], oShape);
        setShape(b[0], b[1], b[2], oShape);
    }
}

def isShapeAt(shape, x, y, z) {
    info := getShape(x, y, z);
    if(info != null) {
        return info[0] = shape;
    }
    return false;
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

    EVENTS_MAP[MODE_INIT] := (s, d,f) => eventsInit(d, f);
    EVENTS_MAP[MODE_TELEPORT] := (s, d,f) => eventsTeleport(d, f);
    EVENTS_MAP[MODE_CONVO] := (s, d,f) => eventsConvo(d, f);
    EVENTS_MAP[MODE_TITLE] := (s, d,f) => eventsTitle(d, f);
    EVENTS_MAP[MODE_TITLE2] := (s, d,f) => eventsTitle2(d, f);
    EVENTS_MAP[MODE_TITLE3] := (s, d,f) => eventsTitle3(d, f);
    EVENTS_MAP[MODE_GAME] := (s, d,f) => eventsGameplay(d, f);

    fadeViewTo(TITLE_X, TITLE_Y);    
}
