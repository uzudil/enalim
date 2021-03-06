const TREES = [ "plant.oak", "plant.red", "plant.pine", "plant.willow", "plant.dead", "plant.pine2" ];
const ROCK_ROOF = [ "roof.mountain.1", "roof.mountain.2", "roof.mountain.3" ];
const RUG_SIZE = 2;

const MODE_SECTION = "section";
const MODE_INSERT = "insert";

editor := {
    roofMode: false,
    mode: "",
    lastX: 0,
    lastY: 0,
    dirX: 0,
    dirY: 0,
};

def editorSectionCommand() {
    if(isPressed(Key1)) {
        drawWater(getPosition(), true);
    }
    if(isPressed(Key2)) {
        drawWater(getPosition(), false);
    }
    if(isPressed(Key3)) {
        drawGrass(getPosition(), 
            null,
            ["rock", "rock.corner", "rock.2", "rock.3", "rock.4", "rock.5", "trunk.y", "plant.bush"],
            [ "plant.flower.green.large", "plant.flower.yellow.large", "plant.flower.red.large" ]
        );
    }
    if(isPressed(Key4)) {
        drawGrass(getPosition(), 
            null,
            null,
            null
        );
    }
    if(isPressed(Key5)) {
        drawGrass(getPosition(), 
            array_flatten([
                array_times("plant.oak", 6), 
                array_times("plant.willow", 2), 
                array_times("plant.red", 2),
                "plant.dead"
            ]), 
            ["rock", "rock.corner", "rock.2", "rock.3", "rock.4", "rock.5", "trunk.y", "plant.bush"],
            [ "plant.flower.green.large", "plant.flower.yellow.large", "plant.flower.red.large" ]
        );
    }
    if(isPressed(Key6)) {
        drawGrass(getPosition(), 
            array_flatten([
                array_times("plant.pine", 10), 
                array_times("plant.dead", 1)
            ]),
            [ "rock", "rock.corner", "rock.2", "rock.3", "rock.4", "rock.5", "trunk.y" ],
            [ "plant.flower.green.large", "plant.flower.yellow.large" ]
        );
    }
    if(isPressed(Key7)) {
        drawGrass(getPosition(), 
            array_flatten([
                array_times("plant.pine2", 10), 
                array_times("plant.dead", 1)
            ]),
            [ "rock", "rock.corner", "rock.2", "rock.3", "rock.4", "rock.5", "trunk.y" ],
            [ "plant.flower.green.large" ]
        );
    }
}

def editorInsertCommand() {
    step := 0;
    if(isPressed(Key1)) {
        pos := getPosition();
        drawTree(pos[0], pos[1], pos[2]);
        step := 4;
    }
    if(isPressed(Key2)) {
        pos := getPosition();
        x := int(pos[0] / 4) * 4;
        y := int(pos[1] / 4) * 4;
        if(drawDungeon(x, y, 0)) {
            step := 4;
        }
    }
    if(isPressed(Key3)) {
        pos := getPosition();
        x := int(pos[0] / 4) * 4;
        y := int(pos[1] / 4) * 4;
        if(drawDungeon(x, y, 1)) {
            step := 4;
        }
    }
    if(isPressed(Key4)) {
        pos := getPosition();
        x := int(pos[0] / 4) * 4;
        y := int(pos[1] / 4) * 4;
        if(drawDungeon(x, y, 2)) {
            step := 4;
        }
    }
    if(isPressed(Key5)) {
        drawRiver(getPosition());
        step := 4;
    }
    if(isPressed(Key6)) {
        drawMountain(getPosition());
        step := 4;
    }
    
    if(step != 0 && (editor.dirX != 0 || editor.dirY != 0)) {
        moveViewTo(editor.lastX + editor.dirX * step, editor.lastY + editor.dirY * step);
    }
}

def editorDefaultCommand() {
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

def editorCommand() {
    pos := getPosition();
    if(editor.lastX != pos[0] || editor.lastY != pos[1]) {
        editor.dirX := normalize(pos[0] - editor.lastX);
        editor.dirY := normalize(pos[1] - editor.lastY);
        editor.lastX := pos[0];
        editor.lastY := pos[1];
    }

    if(isPressed(KeyTab)) {
        if(editor.roofMode) {
            print("to NO roof");
            setMaxZ(24, null);
            editor.roofMode := false;
        } else {
            print("to roof");
            setMaxZ(7, "roof.mountain.1");
            editor.roofMode := true;
        }
    }

    # switch mode
    if(isPressed(KeyS)) {
        editor.mode := MODE_SECTION;
        setEditorLabel(editor.mode);
    } else if(isPressed(KeyI)) {
        editor.mode := MODE_INSERT;
        setEditorLabel(editor.mode);
    } else if(isPressed(KeyEscape)) {
        editor.mode := "";
        setEditorLabel(editor.mode);
    }

    # mode details
    if(editor.mode = MODE_SECTION) {
        editorSectionCommand();
    } else if(editor.mode = MODE_INSERT) {
        editorInsertCommand();
    } else {
        editorDefaultCommand();
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

dungeon := [
    {
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
        "corner.se": "cave.dirt.corner.sw",
        "corner.ne": "cave.dirt.corner.nw",
        "corner.sw": "cave.dirt.corner.se",
        "corner.nw": "cave.dirt.corner.ne",
    },
    {
        "floor": "ground.cave.2",
        "corner.black": "cave.earth.corner.2",
        "corner": "cave.rock.corner.1",
        "wall.w": "cave.rock.e3", 
        "wall.e": "cave.earth.w3", 
        "wall.s": "cave.earth.s3", 
        "wall.n": "cave.rock.n3", 
        "wall.w.wide": "cave.rock.e", 
        "wall.e.wide": "cave.earth.w", 
        "wall.s.wide": "cave.earth.s", 
        "wall.n.wide": "cave.rock.n",     
        "corner.se": "cave.rock.corner.sw",
        "corner.ne": "cave.rock.corner.nw",
        "corner.sw": "cave.rock.corner.se",
        "corner.nw": "cave.rock.corner.ne",
    },
    {
        "floor": "ground.cave.2",
        "corner.black": "cave.earth.corner.2",
        "corner": "dungeon.stone.corner",
        "wall.w": "dungeon.stone.e3", 
        "wall.e": "dungeon.stone.w3", 
        "wall.s": "dungeon.stone.s3", 
        "wall.n": "dungeon.stone.n3", 
        "wall.w.wide": "dungeon.stone.e", 
        "wall.e.wide": "dungeon.stone.w", 
        "wall.s.wide": "dungeon.stone.s", 
        "wall.n.wide": "dungeon.stone.n",     
        "corner.se": "dungeon.stone.corner",
        "corner.ne": "dungeon.stone.corner",
        "corner.sw": "dungeon.stone.corner",
        "corner.nw": "dungeon.stone.corner",
    },
];

def isDungeonFloor(x, y) {
    info := getShape(x, y, 0);
    if(info != null) {
        return info[0] = "ground.cave" || info[0] = "ground.cave.2";
    }
    return false;
}

def isUnderMountain(x, y) {
    info := getShape(x, y, 7);
    if(info != null) {
        return array_find(ROCK_ROOF, e => e = info[0]) != null;
    }
    return false;
}

def drawDungeon(x, y, dungeonType) {
    if(isUnderMountain(x, y)) {
        drawDungeonBlock(x, y, dungeon[dungeonType]);
        return true;
    }
    return false;
}

def drawDungeonBlock(x, y, d) {
    eraseShape(x, y, 0);
    setShape(x, y, 0, d.floor);
    range(0, 4, 1, xx => {
        range(0, 4, 1, yy => {
            eraseShape(x + xx, y + yy, 1);
        });
    });
    drawDungeonWalls(x, y, d);
}

def drawDungeonWalls(x, y, d) {
    n := isDungeonFloor(x, y - 4) = false;
    s := isDungeonFloor(x, y + 4) = false;
    e := isDungeonFloor(x + 4, y) = false;
    w := isDungeonFloor(x - 4, y) = false;
    ne := isDungeonFloor(x + 4, y - 4) = false;
    se := isDungeonFloor(x + 4, y + 4) = false;
    nw := isDungeonFloor(x - 4, y - 4) = false;
    sw := isDungeonFloor(x - 4, y + 4) = false;

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
        setShape(x, y, 1, d["corner.black"]);
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
        setShape(x, y, 1, d["corner.nw"]); 
    }
    if(ne) {
        setShape(x + 3, y, 1, d["corner.ne"]); 
    }
    if(sw) {
        setShape(x, y + 3, 1, d["corner.sw"]); 
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

def highest_frequency(m) {
    mm := null;
    ii := 0;
    a := keys(m);
    while(ii < len(a)) {
        k := a[ii];
        if(mm = null) {
            mm := k;
        } else {
            if(m[k] > m[mm]) {
                mm := k;
            }
        }
        ii := ii + 1;
    }
    return [mm, m[mm]];
}

def fillFloor(x, y, w, h, shape, shape2) {
    range(x, x + w, 4, xx => {
        range(y, y + h, 4, yy => {
            if(xx > x && yy > y && xx < x + w - 4 && yy < y + h - 4 && random() < 0.5 && shape2 != null) {
                setShapeEditor(xx, yy, 0, choose(shape2));
            } else {
                setShapeEditor(xx, yy, 0, shape);
            }
        });
    });    
}

def drawTree(x, y, z) {
    setShape(x, y, z, "plant.trunk");
    setShape(x - 1, y - 1, z + 4, choose(TREES));
}

def cellularExtra(x, y, z, w, h, dx, dy) {
    range(x + dx, x + w - dx, dx, xx => {
        range(y + dy, y + h - dy, dy, yy => {
            a := [];
            range(-1, 2, 1, xxx => {
                range(-1, 2, 1, yyy => {
                    o := getShapeExtra(xx + xxx * dx, yy + yyy * dy, z);
                    if(len(o) > 0) {
                        a[len(a)] := o[0];
                    }
                });
            });
            oo := getShapeExtra(xx, yy, z);
            if(len(a) > 0) {                    
                m := array_reduce(a, {}, (d, e) => {
                    if(d[e] = null) {
                        d[e] := 1;
                    } else {
                        d[e] := d[e] + 1;
                    }
                    return d;
                });
                if(len(oo) > 0) {
                    c := m[oo[0]];
                    if(c = null) {
                        eraseAllExtras(xx, yy, z);
                    } else {
                        if(c < 3) {
                            eraseAllExtras(xx, yy, z);
                        }
                    }
                } else {
                    fr := highest_frequency(m);
                    if(fr[1] > 3) {
                        setShapeExtra(xx, yy, z, fr[0]);
                    }
                }
            }
        });
    });
}

def drawLandExtras(x, y, w, h, extras) {
    range(x, x + w, 2, xx => {
        range(y, y + h, 2, yy => {
            if(random() < 0.15 * len(extras)) {
                setShapeExtra(xx, yy, 1, choose(extras));
            }
        });
    });
    range(0, 5, 1, i => {    
        cellularExtra(x, y, 1, w, h, 2, 2);
    });
    small := {
        "plant.flower.green.large": "plant.flower.green.small", 
        "plant.flower.yellow.large": "plant.flower.yellow.small", 
        "plant.flower.red.large": "plant.flower.red.small"
    };
    range(x, x + w, 2, xx => {
        range(y, y + h, 2, yy => {
            o := getShapeExtra(xx, yy, 1);
            if(len(o) > 0 && random() < 0.25) {
                if(small[o[0]] != null) {
                    eraseAllExtras(xx, yy, 1);
                    setShapeExtra(xx, yy, 1, small[o[0]]);
                }
            }
        });
    });    
}

def drawLand(x, y, w, h, trees, objects, extras) {
    if(extras != null) {
        drawLandExtras(x, y, w, h, extras);
    }
    pos := [];
    range(x, x + w, 4, xx => {
        range(y, y + h, 4, yy => {
            pos[len(pos)] := [xx, yy];
        });
    });
    n := len(pos);
    if(trees != null) {
        range(0, int(n*0.5), 1, i => {
            i := int(random() * len(pos));
            p := pos[i];
            setShape(p[0] + 1, p[1] + 1, 1, "plant.trunk");
            setShape(p[0], p[1], 5, choose(trees));
            del pos[i];
        });
    }
    if(objects != null) {
        range(0, int(n*0.15), 1, i => {
            i := int(random() * len(pos));
            p := pos[i];
            setShape(p[0], p[1], 1, choose(objects));
            del pos[i];
        });
    }
}

def drawGrass(pos, trees, objects, extras) {
    x := int(pos[0] / LAND_UNIT) * LAND_UNIT;
    y := int(pos[1] / LAND_UNIT) * LAND_UNIT;
    clearArea(x, y, LAND_UNIT, LAND_UNIT);
    shape2 := null;
    if(objects != null) {
        shape2 := choose([
            ["ground.grass.2"], 
            ["ground.marsh", "ground.marsh.2"], 
            ["ground.grass.3"]
        ]);
    }
    fillFloor(x, y, LAND_UNIT, LAND_UNIT, "ground.grass", shape2);
    drawLand(x, y, LAND_UNIT, LAND_UNIT, trees, objects, extras);
}

def drawEdge(fx) {
    range(0, 1 + int(random() * 3), 1, fx);
}

def drawRiver(pos) {
    x := int(pos[0] / 4) * 4;
    y := int(pos[1] / 4) * 4;
    clearArea(x, y, 4, 4);
    setShapeEditor(x, y, 0, "ground.water");

    range(-1, 2, 1, dx => {
        range(-1, 2, 1, dy => {
            if(dx != 0 || dy != 0) {
                xx := x + dx * 4;
                yy := y + dy * 4;
                
                shape := null;
                info := getShape(xx, yy, 0);
                if(info = null) {
                    shape := "ground.dirt";
                } else {
                    if(info[0] != "ground.water" && info[0] != "ground.dirt") {
                        shape := "ground.dirt";
                    }
                }
                if(shape != null) {
                    clearArea(xx, yy, 4, 4);
                    setShapeEditor(xx, yy, 0, shape);
                }
            }
        });
    });
}

def drawMountain(pos) {
    x := int(pos[0] / 4) * 4;
    y := int(pos[1] / 4) * 4;
    if(isCave(x, y) = false) {
        clearArea(x, y, 4, 4);
        setShape(x, y, 7, choose(ROCK_ROOF));
        drawMountainEdge(x, y);

        range(-1, 2, 1, dx => {
            range(-1, 2, 1, dy => {
                if(dx != 0 || dy != 0) {
                    drawMountainEdge(x + dx * 4, y + dy * 4);
                }
            });
        });
    }
}

def drawMountainEdge(x, y) {
    if(isCave(x, y)) {
        return 0;
    }

    n := isCave(x, y - 4);
    s := isCave(x, y + 4);
    w := isCave(x + 4, y);
    e := isCave(x - 4, y);
    ne := isCave(x - 4, y - 4);
    nw := isCave(x + 4, y - 4);
    se := isCave(x - 4, y + 4);
    sw := isCave(x + 4, y + 4);
    shape := getMountainShape(n, s, w, e, nw, ne, sw, se);

    #debug := [
    #    ["n", n], ["s", s], ["e", e], ["w", w],
    #    ["ne", ne], ["se", se], ["nw", nw], ["sw", sw],
    #];
    #debug := array_filter(debug, e => e[1]);
    #debug_str := array_reduce(debug, "", (s, e) => {
    #    if(len(s) > 0) {
    #        s := s + ", ";
    #    }
    #    s := s + e[0];
    #    return s;
    #});
    #print("pos=" + x + "," + y + " " + debug_str + " shape=" + shape);

    if(shape != null) {
        floor := getShape(x, y, 0);
        clearArea(x, y, 4, 4);
        if(floor != null) {
            if(floor[0] != "ground.dirt" && floor[0] != "ground.grass" && floor[0] != "ground.water") {
                floor[0] := "ground.grass";
            }
            setShape(x, y, 0, floor[0]);
        }
        setShape(x, y, 1, shape);
    }
}

def getMountainShape(n, s, w, e, nw, ne, sw, se) {
    if(n && ne && e) {
        return "mountain.sw.2";
    }
    if(e && se && s) {
        return "mountain.nw.2";
    }
    if(s && sw && w) {
        return "mountain.ne.2";
    }
    if(w && nw && n) {
        return "mountain.se.2";
    }
    if(n) {
        return "mountain.s";
    }
    if(s) {
        return "mountain.n";
    }
    if(e) {
        return "mountain.w";
    }
    if(w) {
        return "mountain.e";
    }
    if(se) {
        return "mountain.nw";
    }
    if(sw) {
        return "mountain.ne";
    }
    if(ne) {
        return "mountain.sw";
    }
    if(nw) {
        return "mountain.se";
    }
}

def isCave(x, y) {
    #info := getShape(x, y, 0);
    #if(info = null) {
    #    return false;
    #}
    #return startsWith(info[0], "ground.cave");
    return isUnderMountain(x, y);
}

def isMountain(x, y) {
    info := getShape(x, y, 1);
    if(info = null) {
        return false;
    }
    return startsWith(info[0], "mountain.");
}

def getMountain(x, y) {
    info := getShape(x, y, 1);
    if(info = null) {
        return null;
    }
    return info[0];
}

def drawWater(pos, drawBeach) {
    x := int(pos[0] / LAND_UNIT) * LAND_UNIT;
    y := int(pos[1] / LAND_UNIT) * LAND_UNIT;

    n := isGround(x + LAND_UNIT/2, y - 1);
    s := isGround(x + LAND_UNIT/2, y + LAND_UNIT);
    w := isGround(x - 1, y + LAND_UNIT/2);
    e := isGround(x + LAND_UNIT, y + LAND_UNIT/2);

    clearArea(x, y, LAND_UNIT, LAND_UNIT);
    fillFloor(x, y, LAND_UNIT, LAND_UNIT, "ground.water", null);
    
    if(drawBeach) {
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
}

# put this last so parse errors make the app panic()
def main() {
}

