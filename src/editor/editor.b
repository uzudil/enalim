const TREES = [ "plant.oak", "plant.red", "plant.pine", "plant.willow", "plant.dead" ];
const MISC_OUTDOOR = [ "rock", "rock.corner", "rock.2", "rock.3" ];
const ROCK_ROOF = [ "roof.mountain.1", "roof.mountain.2", "roof.mountain.3" ];
const RUG_SIZE = 2;

def editorCommand() {
    if(isPressed(KeyL)) {
        drawWater(getPosition());
    }
    if(isPressed(KeyG)) {
        drawGrass(getPosition());
    }
    if(isPressed(KeyT)) {
        pos := getPosition();
        drawTree(pos[0], pos[1], pos[2]);
    }
    if(isPressed(KeyR)) {
        pos := getPosition();
        x := int(pos[0] / 4) * 4;
        y := int(pos[1] / 4) * 4;
        setShape(x, y, 7, choose(ROCK_ROOF));
    }
    if(isPressed(KeyY)) {
        pos := getPosition();
        x := int(pos[0] / 4) * 4;
        y := int(pos[1] / 4) * 4;
        drawDungeon(x, y);
    }    
    if(isPressed(Key0)) {
        setMaxZ(24, null);
    }
    if(isPressed(Key1)) {
        setMaxZ(1, null);
    }
    if(isPressed(Key2)) {
        setMaxZ(7, null);
    }
    if(isPressed(Key3)) {
        setMaxZ(14, null);
    }
    if(isPressed(Key4)) {
        setMaxZ(21, null);
    }    
    if(isPressed(Key6)) {
        startRug("rug.red");
    }
    if(isPressed(Key7)) {
        startRug("rug.blue");
    }    
    if(isPressed(Key8)) {
        startRug("rug.green");
    }        
    if(isPressed(Key9)) {
        startRug("rug.black");
    }        
}

def startRug(rug) {
    pos := getPosition();
    #x := int(pos[0] / RUG_SIZE) * RUG_SIZE;
    #y := int(pos[1] / RUG_SIZE) * RUG_SIZE;
    x := pos[0];
    y := pos[1];
    z := int(pos[2]/7)*7 + 1;
    eraseAllExtras(x, y, z);
    setShapeExtra(x, y, z, rug);
    range(-1, 2, 1, xx => {
        range(-1, 2, 1, yy => {
            drawRugEdge(x + xx * RUG_SIZE, y + yy * RUG_SIZE, z, rug);
        });
    });
}

def drawRugEdge(x, y, z, rug) {
    this := len(array_filter(getShapeExtra(x, y, z), s => startsWith(s, "rug."))) > 0;
    if(this = false) {
        return 1;
    }

    eraseAllExtras(x, y, z);
    setShapeExtra(x, y, z, rug);

    n := len(array_filter(getShapeExtra(x, y - RUG_SIZE, z), s => startsWith(s, "rug."))) > 0;
    s := len(array_filter(getShapeExtra(x, y + RUG_SIZE, z), s => startsWith(s, "rug."))) > 0;
    w := len(array_filter(getShapeExtra(x + RUG_SIZE, y, z), s => startsWith(s, "rug."))) > 0;
    e := len(array_filter(getShapeExtra(x - RUG_SIZE, y, z), s => startsWith(s, "rug."))) > 0;
    if(n && s && e && w) {
        return 1;
    }
    if(n && s && w = false) {
        setShapeExtra(x, y, z, "rug.w");
        return 1;
    }
    if(n && s && e = false) {
        setShapeExtra(x, y, z, "rug.e");
        return 1;
    }    
    if(e && w && n = false) {
        setShapeExtra(x, y, z, "rug.n");
        return 1;
    }    
    if(e && w && s = false) {
        setShapeExtra(x, y, z, "rug.s");
        return 1;
    }    
    if(n && e) {
        setShapeExtra(x, y, z, "rug.sw");
        return 1;
    }
    if(n && w) {
        setShapeExtra(x, y, z, "rug.se");
        return 1;
    }    
    if(s && w) {
        setShapeExtra(x, y, z, "rug.ne");
        return 1;
    }        
    if(s && e) {
        setShapeExtra(x, y, z, "rug.nw");
        return 1;
    }
}

dungeon := {
    "ground.cave": {
        "floor": "ground.cave",
        "corner.black": "cave.earth.corner.2",
        "corner": "cave.earth.corner.1",
        "wall.w": "cave.earth.e3", 
        "wall.e": "cave.earth.w3", 
        "wall.s": "cave.earth.s3", 
        "wall.n": "cave.earth.n3", 
        "wall.w.wide": "cave.earth.e", 
        "wall.e.wide": "cave.earth.w", 
        "wall.s.wide": "cave.earth.s", 
        "wall.n.wide": "cave.earth.n", 
    },
    "ground.cave.2": {
        "floor": "ground.cave.2",
        "corner.black": "cave.rock.corner.2",
        "corner": "cave.rock.corner.1",
        "wall.w": "cave.rock.e3", 
        "wall.e": "cave.rock.w3", 
        "wall.s": "cave.rock.s3", 
        "wall.n": "cave.rock.n3", 
        "wall.w.wide": "cave.rock.e", 
        "wall.e.wide": "cave.rock.w", 
        "wall.s.wide": "cave.rock.s", 
        "wall.n.wide": "cave.rock.n",     
    },
};

def isDungeon(x, y) {
    info := getShape(x, y, 0);
    if(info != null) {
        return dungeon[info[0]];
    }
    return null;
}

def drawDungeon(x, y) {
    d := isDungeon(x, y);
    if(d != null) {
        drawDungeonBlock(x, y, d);
    }
}

def drawDungeonBlock(x, y, d) {
    range(0, 4, 1, xx => {
        range(0, 4, 1, yy => {
            eraseShape(x + xx, y + yy, 1);
        });
    });
    eraseShape(x, y, 7);

    drawDungeonWalls(x, y, d);
    setShape(x, y, 7, choose(ROCK_ROOF));
}

def drawDungeonWalls(x, y, d) {
    n := isDungeon(x, y - 4) = null;
    s := isDungeon(x, y + 4) = null;
    e := isDungeon(x + 4, y) = null;
    w := isDungeon(x - 4, y) = null;
    ne := isDungeon(x + 4, y - 4) = null;
    se := isDungeon(x + 4, y + 4) = null;
    nw := isDungeon(x - 4, y - 4) = null;
    sw := isDungeon(x - 4, y + 4) = null;

    sw_corner := s && w;
    nw_corner := n && w;
    se_corner := s && e;
    ne_corner := n && e;

    if(sw_corner) {
        setShape(x, y + 3, 1, d["corner.black"]);
        setShape(x, y, 1, d["wall.w"]);
        setShape(x + 1, y + 3, 1, d["wall.s"]);
        return 1;
    }
    if(nw_corner) {
        setShape(x, y, 1, d["corner"]);
        setShape(x, y + 1, 1, d["wall.w"]);
        setShape(x + 1, y, 1, d["wall.n"]);
        return 1;
    }
    if(se_corner) {
        setShape(x + 3, y + 3, 1, d["corner.black"]);
        setShape(x + 3, y, 1, d["wall.e"]);
        setShape(x, y + 3, 1, d["wall.s"]);
        return 1;
    }
    if(ne_corner) {
        setShape(x + 3, y, 1, d["corner.black"]);
        setShape(x + 3, y + 1, 1, d["wall.e"]);
        setShape(x, y, 1, d["wall.n"]);
        return 1;
    }    

    if(n) {
        setShape(x, y, 1, d["wall.n.wide"]);
        return 1;
    }
    if(s) {
        setShape(x, y + 3, 1, d["wall.s.wide"]);
        return 1;
    }
    if(w) {
        setShape(x, y, 1, d["wall.w.wide"]);
        return 1;
    }
    if(e) {
        setShape(x + 3, y, 1, d["wall.e.wide"]);
        return 1;
    }

    if(nw) {
        setShape(x, y, 1, d["corner"]); 
    }
    if(ne) {
        setShape(x + 3, y, 1, d["corner"]); 
    }
    if(sw) {
        setShape(x, y + 3, 1, d["corner"]); 
    }
    if(se) {
        setShape(x + 3, y + 3, 1, d["corner.black"]); 
    }
    return 1;

}

const LAND_UNIT = 32;

def isGround(x, y) {
    info := getShape(x, y, 0);
    if(info = null) {
        return false;
    }
    return info[0] != "ground.water";
}

def fillFloor(x, y, w, h, shape) {
    range(x, x + w, 4, xx => {
        range(y, y + h, 4, yy => {
            setShape(xx, yy, 0, shape);
        });
    });    
}

def drawTree(x, y, z) {
    setShape(x, y, z, "plant.trunk");
    setShape(x - 1, y - 1, z + 4, choose(TREES));
}

def drawMisc(x, y, z) {
    setShape(x, y, z, choose(MISC_OUTDOOR));
}

def drawLand(x, y, w, h) {
    p := choose([0.25, 0.5, 0.75]);
    range(x, x + w, 4, xx => {
        range(y, y + h, 4, yy => {
            if(random() < p) {
                mode := random();
                if(mode < 0.9) {
                    drawTree(xx + 1, yy + 1, 1);
                } else {
                    drawMisc(xx, yy, 1);
                }
            }
        });
    });
}

def drawGrass(pos) {
    x := int(pos[0] / LAND_UNIT) * LAND_UNIT;
    y := int(pos[1] / LAND_UNIT) * LAND_UNIT;
    clearArea(x, y, LAND_UNIT, LAND_UNIT);
    fillFloor(x, y, LAND_UNIT, LAND_UNIT, "ground.grass");
    drawLand(x, y, LAND_UNIT/2, LAND_UNIT/2);
    drawLand(x + LAND_UNIT/2, y, LAND_UNIT/2, LAND_UNIT/2);
    drawLand(x + LAND_UNIT/2, y + LAND_UNIT/2, LAND_UNIT/2, LAND_UNIT/2);
    drawLand(x, y + LAND_UNIT/2, LAND_UNIT/2, LAND_UNIT/2);    
}

def drawEdge(fx) {
    range(0, 1 + int(random() * 3), 1, fx);
}

def drawWater(pos) {
    x := int(pos[0] / LAND_UNIT) * LAND_UNIT;
    y := int(pos[1] / LAND_UNIT) * LAND_UNIT;

    n := isGround(x + LAND_UNIT/2, y - 1);
    s := isGround(x + LAND_UNIT/2, y + LAND_UNIT);
    w := isGround(x - 1, y + LAND_UNIT/2);
    e := isGround(x + LAND_UNIT, y + LAND_UNIT/2);

    clearArea(x, y, LAND_UNIT, LAND_UNIT);
    fillFloor(x, y, LAND_UNIT, LAND_UNIT, "ground.water");
    
    # edges
    if(n) {
        print("north edge");
        range(x, x + LAND_UNIT, 4, xx => {
            drawEdge(i => setShapeEditor(xx, y + i * 4, 0, "ground.dirt"));
        });
    }
    if(s) {
        print("south edge");
        range(x, x + LAND_UNIT, 4, xx => {
            drawEdge(i => setShapeEditor(xx, y + LAND_UNIT - 4 - i * 4, 0, "ground.dirt"));
        });
    }
    if(e) {
        print("east edge");
        range(y, y + LAND_UNIT, 4, yy => {
            drawEdge(i => setShapeEditor(x + LAND_UNIT - 4 - i * 4, yy, 0, "ground.dirt"));
        });
    }
    if(w) {
        print("west edge");
        range(y, y + LAND_UNIT, 4, yy => {
            drawEdge(i => setShapeEditor(x + i * 4, yy, 0, "ground.dirt"));
        });
    }
}

# put this last so parse errors make the app panic()
def main() {
}
