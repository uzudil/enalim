# the global player state
player := {
    "x": 4989,
    "y": 5085,
    "z": 1,
    "scrollOffsetX": 0,
    "scrollOffsetY": 0,
    "dir": DirN,
    "underRoof": false,
};

# the player's shape size
const PLAYER_X = 2;
const PLAYER_Y = 2;
const PLAYER_Z = 4;

const PLAYER_MOVE_SPEED = 0.085;
const PLAYER_ANIM_SPEED = 0.05;

const PLAYER_SHAPE = "man";

# called on every frame
def events(delta) {
    animationType := "stand";
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
        animationType := "move";
        playerMove(dx, dy, delta);
    }

    if(isPressed(KeySpace)) {
        if(findShapeNearby("door.wood.y", (x,y,z) => replaceShape(x, y, z, "door.wood.x")) = false) {
            if(findShapeNearby("door.wood.x", (x,y,z) => replaceShape(x, y, z, "door.wood.y")) = false) {
                # do something else
            }
        }
    }

    setAnimation(player.x, player.y, player.z, animationType, player.dir, PLAYER_ANIM_SPEED);

    moveCreatures(delta);
}

def playerMove(dx, dy, delta) {
    moved := playerMoveDir(dx, dy, delta);
    if(moved = false && dx != 0 && dy != 0) {
        moved := playerMoveDir(0, dy, delta);
    }
    if(moved = false && dx != 0 && dy != 0) {
        moved := playerMoveDir(dx, 0, delta);
    }
    if(moved) {
        # if under a roof, hide the roof
        player.underRoof := isUnderRoof();
        if(player.underRoof) {
            setMaxZ(getRoofZ(player.z));
        } else {
            setMaxZ(24);
        }
    }
    return moved;
}

def playerMoveDir(dx, dy, delta) {
    player.dir := getDir(dx, dy);
    moved := true;

    # adjust speed for diagonal movement... maybe this should be computed from iso angles?
    speed := PLAYER_MOVE_SPEED;
    if(dx != 0 && dy != 0) {
        speed := PLAYER_MOVE_SPEED * 1.5;
    }
    newXf := player.x + player.scrollOffsetX + (dx * delta / speed);
    newYf := player.y + player.scrollOffsetY + (dy * delta / speed);
    newX := int(newXf + 0.5);
    newY := int(newYf + 0.5);

    if(newX != player.x || newY != player.y) {
        # check teleport locations
        teleportPos := teleport(newX, newY, player.z);
        if(teleportPos != null) {
            print("teleport!");
            eraseShape(player.x, player.y, player.z);
            moveViewTo(teleportPos[0], teleportPos[1]);            
            player.x := teleportPos[0];
            player.y := teleportPos[1];
            player.z := teleportPos[2];
            setShape(player.x, player.y, player.z, PLAYER_SHAPE);
            return true;
        }

        # find the new z coord        
        newZ := -1;
        if(fits(newX, newY, player.z, player.x, player.y, player.z)) {
            newZ := player.z;
        } else {
            # step up if you can
            if(fits(newX, newY, player.z + 1, player.x, player.y, player.z)) {
                newZ := player.z + 1;
            }
        }

        if(newZ > 0 && newZ <= player.z + 1 && inspectUnder(newX, newY, newZ, PLAYER_X, PLAYER_Y)) {
            # drop down
            while(newZ > 0 && standOnShape(newX, newY, newZ, PLAYER_X, PLAYER_Y) = false) {
                newZ := newZ - 1;
            }
            
            moveViewTo(newX, newY);
            moveShape(player.x, player.y, player.z, newX, newY, newZ);
            player.x := newX;
            player.y := newY;
            player.z := newZ;
        } else {
            # player is blocked
            moved := false;
        }
    }

    if(moved) {
        # pixel scrolling
        player.scrollOffsetX := newXf - newX;
        player.scrollOffsetY := newYf - newY;
        #setViewScroll(player.scrollOffsetX, player.scrollOffsetY, player.z - 1);
        setViewScroll(player.scrollOffsetX, player.scrollOffsetY, int(player.z / 7) * 7);
        setOffset(player.x, player.y, player.z, player.scrollOffsetX, player.scrollOffsetY);
    }
    return moved;
}

def standOnShape(x, y, z, baseWidth, baseHeight) {
    found := [false];
    findShapeUnder(x, y, z, baseWidth, baseHeight, info => {
        found[0] := true;
    });
    return found[0];
}

def inspectUnder(x, y, z, baseWidth, baseHeight) {
    # todo: check for water, lava, etc.
    blocked := [false];
    findShapeUnder(x, y, z, baseWidth, baseHeight, info => {
        if(info[0] = "ground.water") {
            blocked[0] := true;
        }
    });
    return blocked[0] = false;
}

def replaceShape(x, y, z, name) {
    if(intersectsShapes(x, y, z, name, PLAYER_SHAPE) = false) {
        eraseShape(x, y, z);
        setShape(x, y, z, name);
    } else {
        print("player blocks!");
    }
}

def forBase(w, h, fx) {
    range(0, w, 1, x => {
        range(0, h, 1, y => {
            fx(x, y);
        });
    });
}

def findShapeUnder(px, py, pz, baseWidth, baseHeight, fx) {
    forBase(baseWidth, baseHeight, (x, y) => {
        info := getShape(px + x, py + y, pz - 1);
        if(info != null) {
            fx(info);
        }
    });
}

def findShapeNearby(name, fx) {
    found := [false];
    range(-1, PLAYER_X + 1, 1, x => {
        range(-1, PLAYER_Y + 1, 1, y => {
            range(0, PLAYER_Z, 1, z => {
                if(found[0] = false) {
                    info := getShape(player.x + x, player.y + y, player.z + z);
                    if(info != null) {
                        if(info[0] = name) {
                            fx(info[1], info[2], info[3]);
                            found[0] := true;
                        }
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

def isUnderRoof() {
    # roofs are only at certain heights
    testZ := player.z;
    while(testZ < 24) {
        z := getRoofZ(testZ);
        found := [true];
        forBase(PLAYER_X, PLAYER_Y, (x, y) => {
            info := getShape(player.x + x, player.y + y, z);
            if(info = null) {
                found[0] := false;
            } else {
                if(substr(info[0], 0, 5) != "roof." && substr(info[0], 0, 6) != "floor.") {
                    found[0] := false;
                }
            }
        });
        if(found[0]) {
            return true;
        }
        testZ := testZ + 7;
    }
    return false;
}

# Put main last so if there are parsing errors, the game panic()-s.
def main() {
    moveViewTo(player.x, player.y);
    setShape(player.x, player.y, player.z, PLAYER_SHAPE);
}
