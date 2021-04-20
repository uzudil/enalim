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

                newZ := moveShape(move.x, move.y, move.z, newX, newY);
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
        "erase": move => eraseShape(move.x, move.y, move.z),
        "setShape": (move, shape) => setShape(move.x, move.y, move.z, shape),
        "distanceTo": (move, nx, ny, nz) => distance(move.x, move.y, move.z, nx, ny, nz),
        "distanceXyTo": (move, nx, ny) => distance(move.x, move.y, move.z, nx, ny, move.z),
        "findPath": (move, destX, destY, destZ) => findPath(move.x, move.y, move.z, destX, destY, destZ),
    };
}

