const TITLE_X = 4204;
const TITLE_Y = 4175;

const MODE_INIT = "init";
const MODE_GAME = "game";
const MODE_TELEPORT = "teleport";
const MODE_CONVO = "convo";
const MODE_TITLE = "title";
const MODE_TITLE2 = "title2";
const MODE_TITLE3 = "title3";
const MODE_BOOK = "book";

# the global player state
player := {
    "mode": MODE_INIT,
    "move": null,
    "underRoof": false,
    "roof": null,
    "teleportPos": null,
    "convo": null,
    "elapsedTime": 0,
    "dragShape": null,
    "inventoryUi": null,
    "inventory": null,
};    

# the player's shape size
const PLAYER_X = 2;
const PLAYER_Y = 2;
const PLAYER_Z = 4;

const PLAYER_MOVE_SPEED = 0.085;
const PLAYER_ANIM_SPEED = 0.05;

const PLAYER_SHAPE = "lydell";

const EVENTS_MAP = {};

const REPLACE_SHAPES = {
    "door.wood.y": "door.wood.x",
    "door.wood.x": "door.wood.y",
    "door.black.y": "door.black.x",
    "door.black.x": "door.black.y",
};

# called when the hour changes
def onHour(hour) {
    print("* HOUR tick: " + hour);
    evalNpcSchedules(hour);
    print("* HOUR tick done");
}

# called on every frame
def events(delta, fadeDir, mouseX, mouseY) {
    player.mouseX := mouseX;
    player.mouseY := mouseY;
    player.elapsedTime := player.elapsedTime + delta;

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
        addMessage(110, 250, "2021 (c) Gabor Torok", 1, 200, 200, 200);
        addMessage(110, 275, "Press SPACE to start", 1, 128, 128, 128);
    }
}

def eventsTitle(delta, fadeDir) {
    if(isPressed(KeySpace)) {
        delAllMessages();
        player.mode := MODE_TITLE2;
        # all black
        fadeViewTo(500, 500); 
    } else {
        moveCreatures(delta);
    }
}

def eventsTitle2(delta, fadeDir) {
    if(fadeDir = 1) {
        player.mode := MODE_TITLE3;
        addMessage(10, 25, "The story so far...", 0, 200, 200, 200);
        o := parseTopic("Your name is Lydell and you have always lived on the island, serving the Necromancer. One day he will train you to be a powerful wizard, you are sure.");
        array_foreach(o.lines, (index, line) => addMessage(10, 75 + (index * LINE_HEIGHT), line, 0, 128, 128, 128));
        o := parseTopic("Strangely, you don't seem to recall how you got to the island...");
        array_foreach(o.lines, (index, line) => addMessage(10, 200 + (index * LINE_HEIGHT), line, 0, 128, 128, 128));
        addMessage(110, 275, "Press SPACE to continue", 1, 128, 128, 128);
    }
}

def eventsTitle3(delta, fadeDir) {
    if(isPressed(KeySpace)) {
        delAllMessages();
        player.mode := MODE_GAME;
        player.move := newMovement(5000, 5015, 1, PLAYER_X, PLAYER_Y, PLAYER_Z, PLAYER_SHAPE, PLAYER_MOVE_SPEED, true, false);
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

    if(didClick()) {
        pos := getClick();
        dragging := pos[3];
        isDragStart := pos[4];
        dragAction := pos[5];
        dragIndex := pos[6];
        if(dragging) {
            if(isDragStart) {
                startDrag(pos, dragAction, dragIndex);
            } else {
                endDrag(pos);
            }
        } else {            
            # handle click
            if(dragAction = "") {
                panel := getOverPanel();
                if(panel[0] != null) {
                    print("click on panel " + panel[0]);
                    # raise clicked panel
                    if(panel[0] = "inventory") {
                        openInventory();
                    } else {
                        c := getItemById(panel[0]);
                        raisePanel(c.id, c.uiImage);
                    }
                } else {
                    done := player.move.operateDoorAt(pos[0], pos[1], pos[2]);
                    if(done = false) {
                        shape := getShape(pos[0], pos[1], pos[2]);
                        if(shape != null) {
                            done := openContainer(shape[1], shape[2], shape[3], "map");
                            if(done = false) {
                                if(shape[0] = "lydell") {
                                    openInventory();
                                }
                            }
                        }
                    }
                }
            } else {
                openContainer(dragIndex, -1, -1, dragAction);
            }
        }
    }

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
        if(player.move.operateDoorNearby() = null) {
            if(operateWindow() = false) {
                if(player.move.findShapeNearby("clock.y", (x, y, z) => timedMessage(x, y, z, getTime())) = false) {
                    player.move.findNearby(1, scriptedAction, null);
                }
            }
        }
    }

    if(isPressed(KeyT)) {
        player.move.findNpcNearby(startConvo);
    }

    if(isPressed(KeyI)) {
        openInventory();
    }

    if(isPressed(KeyEscape)) {
        closeTopPanel();
    }

    player.move.setAnimation(animationType, PLAYER_ANIM_SPEED);
    moveCreatures(delta);
}

def eventsBook(delta, fadeDir) {
    if(isPressed(KeyEscape)) {
        closeTopPanel();
        setCalendarPaused(false);
        player.mode := MODE_GAME;
    }

    if(isPressed(KeyA) || isPressed(KeyLeft)) {
        turnBookPage(-1);
    }
    if(isPressed(KeyD) || isPressed(KeyRight)) {
        turnBookPage(1);
    }
}

def openInventory() {
    raisePanel("inventory", "inventory");
    updateInventoryUi();
}

def updateInventoryUi() {
    updatePanel("inventory", player.inventory.render());
}

def openContainer(x, y, z, location) {
    c := getItem(x, y, z, location);
    print("openContainer: c=" + c);
    if(c = null) {
        return false;
    }
    print("openContainer: type=" + c.type);
    if(c.type = CONTAINER_TYPE) {
        raisePanel(c.id, c.uiImage);
        updateContainerUi(c);
        return true;
    }
    if(c.type = BOOK_TYPE) {
        raisePanel(c.id, c.uiImage);
        openBook.currentPage := 0;
        updateBookUi(c);
        setCalendarPaused(true);
        player.mode := MODE_BOOK;
        return true;
    }
    return false;
}

def updateContainerUi(c) {
    updatePanel(c.id, c.items.render());
}

def startDrag(pos, action, index) {
    if(action = "inventory") {
        # drag from inventory ui
        item := player.inventory.remove(index, action);
        player.dragShape := {
            "shape": item.shape,
            "pos": [item.x, item.y, -1],
            "fromUi": action,
            "draggedContainer": getItem(index, -1, -1, action),
        };
        updateInventoryUi();
    } else {
        if(startsWith(action, "i.")) {
            # drag from a container ui
            c := getItemById(action);
            item := c.items.remove(index, action);
            player.dragShape := {
                "shape": item.shape,
                "pos": [item.x, item.y, -1],                
                "fromUi": action,
                "draggedContainer": getItem(index, -1, -1, action),
            };
            updateContainerUi(c);
        } else {
            info := getShape(pos[0], pos[1], pos[2]);
            if(info != null) {
                # drag from map
                player.dragShape := {
                    "shape": info[0],
                    "pos": [info[1], info[2], info[3]],
                    "fromUi": "map",
                    "draggedContainer": getItem(info[1], info[2], info[3], "map"),
                };
                eraseShape(info[1], info[2], info[3]);
            }
        }
    }
    setCursorShape(player.dragShape.shape);
}

def endDrag(pos) {
    if(player.dragShape != null) {
        handled := false;
        if(pos[2] > 0) {
            info := getShape(pos[0], pos[1], pos[2] - 1);
            if(info != null) {
                if(info[0] = "lydell") {
                    # drop over character
                    index := player.inventory.add(player.dragShape.shape, -1, -1);
                    updateInventoryUi();
                    if(player.dragShape.draggedContainer != null) {
                        updateItemLocation(player.dragShape.draggedContainer, index, -1, -1, "inventory");
                    }
                    handled := true;
                } else {
                    # drop over container
                    c := getItem(info[1], info[2], info[3], "map");
                    if(c != null) {
                        index := c.items.add(player.dragShape.shape, -1, -1);
                        updateContainerUi(c);
                        if(player.dragShape.draggedContainer != null) {
                            updateItemLocation(player.dragShape.draggedContainer, index, -1, -1, c.id);
                        }
                        handled := true;
                    }
                }
            }
        }

        if(handled = false) {
            panel := getOverPanel();
            if(panel[0] = "inventory") {
                # drop over inventory panel
                index := player.inventory.add(player.dragShape.shape, panel[1], panel[2]);
                updateInventoryUi();
                if(player.dragShape.draggedContainer != null) {
                    updateItemLocation(player.dragShape.draggedContainer, index, -1, -1, "inventory");
                }
                handled := true;
            } else {
                if(panel[0] != null) {
                    # drop over a container panel
                    targetContainer := getItemById(panel[0]);
                    if(player.dragShape.draggedContainer != null) {
                        if(targetContainer.id = player.dragShape.draggedContainer.id) {
                            # trying to drop container on itself?
                            cancelDrag();
                            handled := true;
                        }
                    }
                    if(handled = false) {
                        index := targetContainer.items.add(player.dragShape.shape, panel[1], panel[2]);
                        updateContainerUi(targetContainer);
                        if(player.dragShape.draggedContainer != null) {
                            updateItemLocation(player.dragShape.draggedContainer, index, -1, -1, targetContainer.id);
                        }
                    }
                    handled := true;
                }
            }
        }

        if(handled = false) {
            # drop on map
            x := pos[0];
            y := pos[1];
            z := findTop(x, y, player.dragShape.shape);        
            if(z = 0) {
                cancelDrag();
            } else {
                # drop on map
                setShape(x, y, z, player.dragShape.shape);
                if(player.dragShape.draggedContainer != null) {
                    updateItemLocation(player.dragShape.draggedContainer, x, y, z, "map");
                }
            }
        }

        # dragging is done
        player.dragShape := null;
        clearCursorShape();
    }
}

def cancelDrag() {
    print("Can't drop item there.");
    if(player.dragShape.fromUi = "inventory") {
        # return to inventory
        player.inventory.add(player.dragShape.shape, player.dragShape.pos[0], player.dragShape.pos[1]);
        updateInventoryUi();
    } else {
        if(player.dragShape.fromUi = "map") {
            # return to original map location
            x := player.dragShape.pos[0];
            y := player.dragShape.pos[1];
            z := player.dragShape.pos[2];
            # drop on map
            setShape(x, y, z, player.dragShape.shape);
            if(player.dragShape.draggedContainer != null) {
                updateItemLocation(player.dragShape.draggedContainer, x, y, z, "map");
            }
        } else {
            # return to container
            c := getItemById(player.dragShape.fromUi);
            c.items.add(player.dragShape.shape, player.dragShape.pos[0], player.dragShape.pos[1]);
            updateContainerUi(c);
        }
    }
}

def playerMove(dx, dy, delta) {
    moved := player.move.moveInDir(dx, dy, delta, checkTeleportLocations, null);
    if(moved = false && dx != 0 && dy != 0) {
        moved := player.move.moveInDir(0, dy, delta, checkTeleportLocations, null);
    }
    if(moved = false && dx != 0 && dy != 0) {
        moved := player.move.moveInDir(dx, 0, delta, checkTeleportLocations, null);
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
    player.move.findShapeNearby("window.x", (x,y,z) => {
        winX[0] := x;
        winX[1] := y;
        winX[2] := z;
    });
    player.move.findShapeNearby("window.y", (x,y,z) => {
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
        player.move.forBase((x, y) => {
            info := getShape(x, y, z);
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

def timedMessage(x, y, z, message) {
    showMessageAt(x, y, z, message, 0, MESSAGE_R, MESSAGE_G, MESSAGE_B);
}

def main() {
    staticInitSections();

    EVENTS_MAP[MODE_INIT] := (s, d,f) => eventsInit(d, f);
    EVENTS_MAP[MODE_TELEPORT] := (s, d,f) => eventsTeleport(d, f);
    EVENTS_MAP[MODE_CONVO] := (s, d,f) => eventsConvo(d, f);
    EVENTS_MAP[MODE_TITLE] := (s, d,f) => eventsTitle(d, f);
    EVENTS_MAP[MODE_TITLE2] := (s, d,f) => eventsTitle2(d, f);
    EVENTS_MAP[MODE_TITLE3] := (s, d,f) => eventsTitle3(d, f);
    EVENTS_MAP[MODE_GAME] := (s, d,f) => eventsGameplay(d, f);
    EVENTS_MAP[MODE_BOOK] := (s, d,f) => eventsBook(d, f);

    # init player
    player.inventory := newInventory();    

    setPathThroughShapes(keys(REPLACE_SHAPES));

    fadeViewTo(TITLE_X, TITLE_Y);    
}
