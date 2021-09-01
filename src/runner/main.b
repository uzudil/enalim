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
const MODE_EXIT = "exit";

const PLAYER_SHAPE = "lydell";

const PLAYER_SHAPES = [
    "",
    "-sword",
    "-axe",
    "-bow",
    "-staff",
    "-lance",
    "-dagger",
];

# the global player state
player := {
    "shape": PLAYER_SHAPE,
    "shapeIndex": 0,
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
    "attackTimer": 0,
    "coolTimer": 0,
    "attackTarget": null,
    "lastAttackTarget": null,
    "combatMode": false,
    "gameState": {
        "unlocked": [],
    },
    "cursor": "cursor.nw",
    "mouseDrive": false,
    "mouseOnInteractive": 0,
    "hp": 20,
};    

# the player's shape size
const PLAYER_X = 2;
const PLAYER_Y = 2;
const PLAYER_Z = 4;

const PLAYER_MOVE_SPEED = 0.085;

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
def events(delta, fadeDir, mouseX, mouseY, mouseWorldX, mouseWorldY, mouseWorldZ, mouseButtonDown, mouseOnInteractive) {
    player.mouseX := mouseX;
    player.mouseY := mouseY;
    player.mouseWorldX := mouseWorldX;
    player.mouseWorldY := mouseWorldY;
    player.mouseWorldZ := mouseWorldZ;
    player.mouseButtonDown := mouseButtonDown;
    player.mouseOnInteractive := mouseOnInteractive;
    player.elapsedTime := player.elapsedTime + delta;

    EVENTS_MAP[player.mode](delta, fadeDir);

    if(isPressed(KeyX)) {
        player.move.erase();
        saveGame();
        player.move.setShape(player.shape);
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

        setConvoAnswerIndexAt(player.mouseX, player.mouseY);

        if(didClick()) {
            getClick();
            fireConvoAnswerIndex();
        }

        setCursor("cursor.hand");
        player.move.setAnimation(ANIM_STAND);
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
    if(isPressed(KeySpace) || didClick()) {
        getClick();
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
        o := parseTopic("The story so far: ...");
        array_foreach(o.lines, (index, line) => addMessage(10, 75 + (index * LINE_HEIGHT), line, 0, 128, 128, 128));
        o := parseTopic("And also: ...");
        array_foreach(o.lines, (index, line) => addMessage(10, 200 + (index * LINE_HEIGHT), line, 0, 128, 128, 128));
        addMessage(110, 275, "Press SPACE to continue", 1, 128, 128, 128);
    }
}

def eventsTitle3(delta, fadeDir) {
    if(isPressed(KeySpace) || didClick()) {
        getClick();
        delAllMessages();
        player.mode := MODE_GAME;
        player.move := newMovement(5000, 5015, 1, PLAYER_X, PLAYER_Y, PLAYER_Z, player.shape, PLAYER_MOVE_SPEED, true, false);
        load_game();
        player.move.setShape(player.shape);
        player.move.setAnimation(ANIM_STAND);
        stopCreatures();
        fadeViewTo(player.move.x, player.move.y);
    }
}

def eventsTeleport(delta, fadeDir) {
    if(fadeDir = 1) {
        player.move.erase();
        player.move.set(player.teleportPos[0], player.teleportPos[1], player.teleportPos[2]);
        player.move.setShape(player.shape);
        player.teleportPos := null;
        setRoofVisiblity();
        player.mode := MODE_GAME;
    }
    player.move.setAnimation(ANIM_STAND);
    stopCreatures();
}

def eventsGameplay(delta, fadeDir) {
    if(fadeDir = 1) {
        setRoofVisiblity();
    }

    cursorDir := setCursorAndGetDir();
    animationType := ANIM_STAND;
    if(player.attackTimer > 0) {
        player.attackTimer := player.attackTimer - delta;
        animationType := ANIM_ATTACK;
    } else {
        if(player.coolTimer > 0) {
            if(player.attackTarget != null) {
                attackDamage();
            }
            player.coolTimer := player.coolTimer - delta;
        } else {
            if(player.combatMode) {
                continueCombat();
            }
            if(player.mouseDrive) {
                if(player.mouseButtonDown = 1) {
                    dx := cursorDir[0];
                    dy := cursorDir[1];
                    if(dx != 0 || dy != 0) {
                        animationType := ANIM_MOVE;
                        playerMove(dx, dy, delta);
                    }
                } else {
                    player.mouseDrive := false;
                    # eat this click
                    if(didClick()) {
                        getClick();
                    }
                }
            } else {
                if(didClick()) {
                    handleGameClick();
                } else {
                    if(isPressed(KeyL)) {
                        player.shapeIndex := player.shapeIndex + 1;
                        if(player.shapeIndex >= len(PLAYER_SHAPES)) {
                            player.shapeIndex := 0;
                        }
                        player.move.erase();
                        player.move.setShape(player.shape + PLAYER_SHAPES[player.shapeIndex]);
                    }

                    if(player.mouseButtonDown = 1 && player.mouseOnInteractive = 0 && player.dragShape = null) {
                        player.mouseDrive := true;
                    }

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
                        if(closeTopPanel() != true) {
                            startExitMode();
                        }
                    }                
                }
            }
        }
    }

    player.move.setAnimation(animationType);
    moveCreatures(delta);
}

def handleGameClick() {
    pos := getClick();
    dragging := pos[3];
    isDragStart := pos[4];
    dragAction := pos[5];
    dragIndex := pos[6];
    print("click: pos=" + pos[0] + "," + pos[1] + "," + pos[2] + " dragging=" + dragging + " dragAction=" + dragAction + " dragIndex=" + dragIndex + " isDragStart=" + isDragStart);
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
                print("Click on panel: " + panel[0]);
                # raise clicked panel
                if(panel[0] = "inventory") {
                    openInventory();
                } else {
                    c := getItemById(panel[0]);
                    raisePanel(c.id, c.uiImage);
                }
            } else {
                shape := getShape(pos[0], pos[1], pos[2]);
                print("click on no shape");
                if(shape = null) {
                    return 1;
                }
                print("shape:" + shape + " at " + pos[0] + "," + pos[1] + "," + pos[2]);

                creature := getCreature(pos[0], pos[1], pos[2]);
                if(creature != null) {
                    if(creature.template.movement = "hunt") {
                        startAttack(creature);
                        return 1;
                    }
                }

                d := player.move.distanceTo(pos[0], pos[1], pos[2]);
                # print("SHAPE CLICK: " + d);
                if(d > 8) {
                    # too far
                    setCursorTmp("cursor.no");
                    return 1;
                }

                if(player.move.operateDoorAt(pos[0], pos[1], pos[2])) {
                    return 1;
                }

                if(operateWindowAt(shape[0], pos[0], pos[1], pos[2])) {
                    return 1;
                }

                if(shape[0] = "clock.y") {
                    timedMessage(pos[0], pos[1], pos[2], getTime(), false);
                    return 1;
                }

                if(scriptedAction(pos[0], pos[1], pos[2])) {
                    return 1;
                }

                if(openContainer(shape[1], shape[2], shape[3], "map")) {
                    return 1;
                }

                if(shape[0] = player.shape + PLAYER_SHAPES[player.shapeIndex]) {
                    openInventory();
                    return 1;
                }

                if(creature != null) {
                    if(creature.npc != null) {
                        startConvo(creature.npc);
                        return 1;
                    }
                }

                if(player.mouseOnInteractive = 1) {
                    timedMessage(shape[1], shape[2], shape[3], getShapeDescription(shape[0]), false);
                }
            }
        } else {
            if(openContainer(dragIndex, -1, -1, dragAction)) {
                return 1;
            }
            
            desc := getShapeDescription(getContainedShape(dragAction, dragIndex));
            timedMessageXY(player.mouseX, player.mouseY, desc);
        }
    }
}

def getContainedShape(location, index) {
    if(location = "inventory") {
        return player.inventory.items[index].shape;
    } else {
        c := getItemById(location);
        return c.items.items[index].shape;
    }
}

def startExitMode() {
    raisePanel("exit", "marble");
    updatePanel("exit", [{
        "type": "uiText",
        "text": "Exit game?",
        "x": 75,
        "y": 35,
        "fontIndex": 0,
    },{
        "type": "uiText",
        "text": "Press SPACE to quit.",
        "x": 70,
        "y": 100,
        "fontIndex": 1,
    }]);
    centerPanel("exit");
    player.mode := MODE_EXIT;
}

def setCursorAndGetDir() {
    if(player.dragShape != null) {
        setCursor("cursor.hand");
        return [0,0];
    }
    if(player.mouseDrive = false && player.mouseOnInteractive = 1) {
        setCursor("cursor.hand");
        return [0,0];
    }
    dir := getDirScreen(player.mouseX, player.mouseY);
    dx := 0;
    dy := 0;
    cursor := "";
    if(dir = DIR_W) {
        dx := 1; dy := -1;
        cursor := "cursor.w";
    }
    if(dir = DIR_E) {
        dx := -1; dy := 1;
        cursor := "cursor.e";
    }
    if(dir = DIR_N) {
        dx := -1; dy := -1;
        cursor := "cursor.n";
    }
    if(dir = DIR_S) {
        dx := 1; dy := 1;
        cursor := "cursor.s";
    }
    if(dir = DIR_NE) {
        dx := -1;
        cursor := "cursor.ne";
    }
    if(dir = DIR_SE) {
        dy := 1;
        cursor := "cursor.se";
    }
    if(dir = DIR_NW) {
        dy := -1;
        cursor := "cursor.nw";
    }
    if(dir = DIR_SW) {
        dx := 1;
        cursor := "cursor.sw";
    }
    setCursor(cursor);
    return [dx, dy];
}

def eventsExit(delta, fadeDir) {
    if(isPressed(KeyEscape)) {
        closeTopPanel();
        setCalendarPaused(false);
        player.mode := MODE_GAME;
    }

    if(isPressed(KeySpace)) {
        exitEvent();
        exit();
    }
}

# called by golang on exit
def exitEvent() {
    print("+++ exitEvent start");
    saveGame();
    print("+++ exitEvent done");
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

    if(didClick()) {
        getClick();
        if(player.mouseX < SCREEN_WIDTH/2) {
            turnBookPage(-1);
        } else {
            turnBookPage(1);
        }
    }
    setCursor("cursor.hand");
}

def openInventory() {
    raisePanel("inventory", "inventory");
    updateInventoryUi();
}

def updateInventoryUi() {
    updatePanel("inventory", player.inventory.render());
}

def getItemName(x, y, z, location) {
    return "unknown";
}

def openContainer(x, y, z, location) {
    c := getItem(x, y, z, location);
    if(c = null) {
        if(location != "map") {
            print("No item at " + x + " in " + location + ":");
            array_foreach(items, (i, c) => {
                if(c.location = location) {
                    print("\t" + c.x + " " + c.uiImage);
                }
            });
        }
        return false;
    }
    print("openContainer: c=" + c + " type=" + c.type);
    if(c.type = CONTAINER_TYPE) {
        raisePanel(c.id, c.uiImage);
        updateContainerUi(c);
        return true;
    }
    if(c.type = BOOK_TYPE) {
        raisePanel(c.id, c.uiImage);
        centerPanel(c.id);
        lockPanel(c.id);
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
            "draggedContainer": item.item,
        };
        debugInventory();
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
                "draggedContainer": item.item,
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

def debugInventory() {
    print("------------------------------");
    print("inventory:");
    array_foreach(player.inventory.items, (i, c) => {
        print("\t" + i + ": " + c.shape);
    });
    print("items:");
    array_foreach(items, (i, c) => {
        if(c.location = "inventory") {
            print("\t" + c.x + " " + c.uiImage);
        }
    });
    print("------------------------------");
}

def endDrag(pos) {
    if(player.dragShape != null) {
        handled := false;
        if(pos[2] > 0) {
            info := getShape(pos[0], pos[1], pos[2] - 1);
            if(info != null) {
                if(info[0] = player.shape + PLAYER_SHAPES[player.shapeIndex]) {
                    # drop over character
                    index := player.inventory.add(player.dragShape.shape, -1, -1);
                    updateInventoryUi();
                    if(player.dragShape.draggedContainer != null) {
                        updateItemLocation(player.dragShape.draggedContainer, index, -1, -1, "inventory");
                    }
                    debugInventory();
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
                debugInventory();
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
        debugInventory();
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
        # erase player or else it stays on map sometimes...
        player.move.erase();
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

def operateWindowAt(shape, x, y, z) {
    winX := [0, 0, 0];
    winY := [0, 0, 0];
    if(shape = "window.x") {
        winX[0] := x;
        winX[1] := y;
        winX[2] := z;
    }
    if(shape = "window.y") {
        winY[0] := x;
        winY[1] := y;
        winY[2] := z;
    }

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

def operateWindow() {
    return player.move.findNearby(1, (x,y,z) => {
        info := getShape(x, y, z);
        if(info != null) {
            if(info[0] = "window.x" || info[0] = "window.y") {
                return info;
            }
        }
        return null;
    }, info => operateWindowAt(info[0], info[1], info[2], info[3]));
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

def unlock_door(x, y, z, isPlayer) {
    # check if this door is unlocked
    locked := array_find(player.gameState.unlocked, u => u.x = x && u.y = y && u.z = z) = null;
    if(locked) {
        key := null;

        # is there a key for this door?
        sectionPos := getSectionPos(x, y);
        section := getSection(sectionPos[0], sectionPos[1]);
        if(section != null) {
            if(section["locked"] != null) {
                key := section.locked(x, y, z);                        
            }
        }

        if(key = null) {
            # if there is no key, the door is open
            locked := false;
        } else {
            # does the player have the key?
            if(locked && isPlayer && array_find(player.inventory.items, item => item.shape = key) != null) {
                locked := false;
                player.gameState.unlocked[len(player.gameState.unlocked)] := { "x": x, "y": y, "z": z };
                print("Player unlocks the door with " + key);
                timedMessage(x, y, z, "Door is unlocked!", false);
            }
        }
    }
    return locked;
}

def timedMessage(x, y, z, message, rise) {
    showMessageAt(x, y, z, message, 2, MESSAGE_R, MESSAGE_G, MESSAGE_B, rise);
}

def timedMessageXY(x, y, message, rise) {
    showMessageAtXY(x, y, message, 2, MESSAGE_R, MESSAGE_G, MESSAGE_B, rise);
}

def save_game() {
    if(player.move != null) {
        saveMap("savegame.json", {
            "calendar": getCalendarRaw(),
            "gameState": player.gameState,
            "items": pruneItems("inventory", 0, 0, false),
            "inventory": player.inventory.encode(),
            "move": player.move.encode(),
            "hp": player.hp,
        });
    }
}

def load_game() {
    saved := loadMap("savegame.json");
    if(saved != null) {
        setCalendarRaw(saved.calendar);
        player.hp := saved.hp;
        player.gameState := saved.gameState;
        array_foreach(saved.items, (i, c) => restoreItem(c));
        player.inventory.decode(saved.inventory);
        player.move.decode(saved.move);
        return true;
    }
    return false;
}

def distanceAndDirToCreature(creature) {
    cx := creature.move.x + creature.template.baseWidth/2;
    cy := creature.move.y + creature.template.baseHeight/2;
    px := player.move.x + 1;
    py := player.move.y + 1;
    dx := (cx - px);
    if(dx != 0) {
        dx := dx / abs(dx);
    }
    dy := (cy - py);
    if(dy != 0) {
        dy := dy / abs(dy);
    }
    dir := getDir(dx, dy);
    d := distance(
        cx, cy, creature.move.z, 
        px, py, player.move.z);
    return [d, dir];
}

def startAttack(creature) {
    if(player.coolTimer <= 0) {
        distAndDir := distanceAndDirToCreature(creature);
        player.move.dir := distAndDir[1];
        if(int(distAndDir[0]) <= creature.template.baseWidth/2 + 1) {
            # attack
            if(random() >= 0.75) {
                timedMessage(
                    player.move.x + (random() * 4),
                    player.move.y + (random() * 2) - 6,
                    player.move.z,
                    choose(COMBAT_MESSAGES), 
                    false
                );
            }
            player.attackTimer := ANIMATION_SPEED * 2;
            player.coolTimer := 0.5;
            player.attackTarget := creature;
            player.combatMode := true;
        } else {
            # move nearer to the enemy
        }
    }
}

def continueCombat() {
    if(player.lastAttackTarget != null) {
        if(player.lastAttackTarget.hp > 0) {
            startAttack(player.lastAttackTarget);
            return 1;
        }
    }
    c := findNearestMonster();
    if(c != null) {
        startAttack(c);
    }
}

def findNearestMonster() {
    targets := array_filter(creatures, c => {
        d := player.move.distanceTo(c.move.x, c.move.y, c.move.z);
        return d <= 10;
    });
    if(len(targets) > 0) {
        return choose(targets);
    } else {
        return null;
    }
}

def attackDamage() {
    dam := int(random() * 5);
    takeDamage(player.attackTarget, dam, c => {
        c.move.erase();
        array_remove(creatures, cc => {
            return cc.id = c.id;
        });
        player.combatMode := findNearestMonster() != null;
    });
    player.lastAttackTarget := player.attackTarget;
    player.attackTarget := null;
}

def playerTakeDamage(enemy) {
    # todo:...
    player.combatMode := true;
}

def main() {
    # register npc-s
    array_foreach(npcReg, (i, npc) => registerNpc(npc));

    EVENTS_MAP[MODE_INIT] := (s, d,f) => eventsInit(d, f);
    EVENTS_MAP[MODE_TELEPORT] := (s, d,f) => eventsTeleport(d, f);
    EVENTS_MAP[MODE_CONVO] := (s, d,f) => eventsConvo(d, f);
    EVENTS_MAP[MODE_TITLE] := (s, d,f) => eventsTitle(d, f);
    EVENTS_MAP[MODE_TITLE2] := (s, d,f) => eventsTitle2(d, f);
    EVENTS_MAP[MODE_TITLE3] := (s, d,f) => eventsTitle3(d, f);
    EVENTS_MAP[MODE_GAME] := (s, d,f) => eventsGameplay(d, f);
    EVENTS_MAP[MODE_BOOK] := (s, d,f) => eventsBook(d, f);
    EVENTS_MAP[MODE_EXIT] := (s, d,f) => eventsExit(d, f);

    # init player
    player.inventory := newInventory();    

    setPathThroughShapes(keys(REPLACE_SHAPES));

    fadeViewTo(TITLE_X, TITLE_Y);    
}
