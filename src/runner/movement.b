def decodeMovement(savedMove, width, height, speed, centerView) {
    move := newMovement(0, 0, 0, width, height, speed, centerView);
    move.decode(savedMove);
    return move;
}

def newMovement(startX, startY, startZ, width, height, speed, centerView) {
    return {
        "x": startX,
        "y": startY,
        "z": startZ,
        "centerView": centerView,
        "scrollOffsetX": 0,
        "scrollOffsetY": 0,
        "dir": DirW,
        "speed": speed,
        "width": width,
        "height": height,
        "encode": (move) => {
            return { "x": move.x, "y": move.y, "z": move.z, "dir": move.dir };
        },
        "decode": (move, saved) => {
            move.set(saved.x, saved.y, saved.z);
            move.dir := saved.dir;
        },
        "moveInDir": (move, dx, dy, delta, interceptMove, onPosChange) => {
            move.dir := getDir(dx, dy);
            moved := true;

            # adjust speed for diagonal movement... maybe this should be computed from iso angles?
            speed := move.speed;
            if(dx != 0 && dy != 0) {
                speed := move.speed * 1.5;
            }
            newXf := move.x + move.scrollOffsetX + (dx * delta / speed);
            newYf := move.y + move.scrollOffsetY + (dy * delta / speed);
            newX := int(newXf + 0.5);
            newY := int(newYf + 0.5);

            if(newX != move.x || newY != move.y) {
                if(interceptMove != null) {
                    if(interceptMove(newX, newY, move.z)) {
                        return true;
                    }
                }

                newZ := move.stepTo(newX, newY);
                if(newZ > -1) {
                    if(move.centerView) {
                        moveViewTo(newX, newY);
                    }
                    moveShape(move.x, move.y, move.z, newX, newY, newZ);
                    move.set(newX, newY, newZ);
                    if(onPosChange != null) {
                        onPosChange(newX, newY, newZ);
                    }
                } else {
                    # player is blocked
                    moved := false;
                }
            }

            if(moved) {
                move.scrollOffsetX := newXf - newX;
                move.scrollOffsetY := newYf - newY;
                if(move.centerView) {
                    #setViewScroll(move.scrollOffsetX, move.scrollOffsetY, move.z - 1);
                    setViewScroll(move.scrollOffsetX, move.scrollOffsetY, int(move.z / 7) * 7);
                }
                setOffset(move.x, move.y, move.z, move.scrollOffsetX, move.scrollOffsetY);
            }
            return moved;
        },
        "stepTo": (move, newX, newY) => {
            # find the new z coord        
            newZ := -1;
            if(fits(newX, newY, move.z, move.x, move.y, move.z)) {
                newZ := move.z;
            } else {
                # step up if you can
                if(fits(newX, newY, move.z + 1, move.x, move.y, move.z)) {
                    newZ := move.z + 1;
                }
            }

            if(newZ > 0 && newZ <= move.z + 1 && inspectUnder(newX, newY, newZ, move.width, move.height)) {
                # drop down
                while(newZ > 0 && standOnShape(newX, newY, newZ, move.width, move.height) = false) {
                    newZ := newZ - 1;
                }
            } else {
                newZ := -1;
            }

            return newZ;
        },
        "set": (move, x, y, z) => {
            move.x := x;
            move.y := y;
            move.z := z;
        },
        "isAt": (move, x, y, z) => x = move.x && y = move.y && z = move.z,
        "setAnimation": (move, animation, anim_speed) => setAnimation(move.x, move.y, move.z, animation, move.dir, anim_speed),
        "erase": move => eraseShape(move.x, move.y, move.z),
        "setShape": (move, shape) => setShape(move.x, move.y, move.z, shape),
        "distanceTo": (move, nx, ny, nz) => distance(move.x, move.y, move.z, nx, ny, nz),
        "distanceXyTo": (move, nx, ny) => distance(move.x, move.y, move.z, nx, ny, move.z),
        "findPath": (move, destX, destY, destZ) => findPath(move.x, move.y, move.z, destX, destY, destZ),
    };
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
