def decodeMovement(savedMove, width, height, depth, shape, speed, centerView, isFlying) {
    move := newMovement(0, 0, 0, width, height, depth, shape, speed, centerView, isFlying);
    move.decode(savedMove);
    return move;
}

def newMovement(startX, startY, startZ, width, height, depth, shape, speed, centerView, isFlying) {
    return {
        "x": startX,
        "y": startY,
        "z": startZ,
        "isFlying": isFlying,
        "centerView": centerView,
        "isPlayer": centerView,
        "scrollOffsetX": 0,
        "scrollOffsetY": 0,
        "dir": DirW,
        "speed": speed,
        "width": width,
        "height": height,
        "depth": depth,
        "shape": shape,
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

                newZ := moveShape(move.x, move.y, move.z, newX, newY, move.isFlying);
                if(newZ > -1) {
                    if(move.centerView) {
                        moveViewTo(newX, newY);
                    }
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
                    setViewScroll(move.scrollOffsetX, move.scrollOffsetY, int(move.z / 7) * 7);
                }
                setOffset(move.x, move.y, move.z, move.scrollOffsetX, move.scrollOffsetY);
            }
            return moved;
        },
        "set": (move, x, y, z) => {
            move.x := x;
            move.y := y;
            move.z := z;
        },
        "isAt": (move, x, y, z) => x = move.x && y = move.y && z = move.z,
        "setAnimation": (move, animation, anim_speed) => setAnimation(move.x, move.y, move.z, animation, move.dir, anim_speed),
        "erase": move => eraseShapeExact(move.x, move.y, move.z),
        "setShape": (move, shape) => setShape(move.x, move.y, move.z, shape),
        "distanceTo": (move, nx, ny, nz) => distance(move.x, move.y, move.z, nx, ny, nz),
        "distanceXyTo": (move, nx, ny) => distance(move.x, move.y, move.z, nx, ny, move.z),
        "findPath": (move, destX, destY, destZ) => findPath(move.x, move.y, move.z, destX, destY, destZ, move.isFlying),
        "findNearby": (move, radius, evalFx, successFx) => {
            found := [false];
            range(-1 * radius, move.width + radius, 1, x => {
                range(-1 * radius, move.height + radius, 1, y => {
                    range(0, move.depth, 1, z => {
                        if(found[0] = false) {
                            e := evalFx(move.x + x, move.y + y, move.z + z);
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
        },
        "findShapeNearby": (move, name, fx) => {
            return move.findNearby(1, (x,y,z) => {
                info := getShape(x, y, z);
                if(info != null) {
                    if(info[0] = name) {
                        return info;
                    }
                }
                return null;
            }, info => fx(info[1], info[2], info[3]));
        },
        "findNpcNearby": (move, fx) => {
            if(move.findNearby(4, getNpc, fx) = false) {
                print("Not near any npc-s.");
            }
        },
        "forBase": (move, fx) => {
            range(0, move.width, 1, x => {
                range(0, move.height, 1, y => {
                    fx(move.x + x, move.y + y);
                });
            });
        },
        "operateDoorNearby": (move) => {
            return array_find(
                keys(REPLACE_SHAPES), 
                shape => move.findShapeNearby(shape, (x, y, z) => move.operateDoor(shape, x, y, z))
            );
        },
        "operateDoorAt": (move, x, y, z) => {
            shape := getShape(x, y, z);
            if(shape != null) {
                if(REPLACE_SHAPES[shape[0]] != null) {
                    move.operateDoor(shape[0], x, y, z);
                    return true;
                }
            }
            return false;
        },
        "operateDoor": (move, shape, x, y, z) => {
            if(unlock_door(x, y, z, move.isPlayer)) {
                print("Door is locked.");
                if(move.isPlayer) {
                    timedMessage(x, y, z, "Locked!");
                }
                return 1;
            }

            dx := 0;
            dy := 0;
            if(endsWith(shape, ".x")) {
                dx := 1;
            } else {
                dy := 1;
            }
            newShape := REPLACE_SHAPES[shape];
            d := 0;
            while(d < 4) {
                if(intersectsShapes(x, y, z, newShape, move.x, move.y, move.z, move.shape) = false) {
                    eraseShape(x, y, z);
                    setShape(x, y, z, newShape);
                    return 1;
                }
                d := d + 1;                        
                if(move.moveInDir(dx, dy, move.speed, null, null) = false) {
                    print("door is blocked!");
                    return 1;
                }
            }
            print("can't open door");
        },
    };
}

