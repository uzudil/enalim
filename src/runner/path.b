def initPath(c, name) {
    return {
        "name": name,
        "nextCheck": 0,
        "pathFail": 0,
        "path": null,
        "step": 0,
    };
}

def pathMove(c, delta, opts) {
    if(c["pathMove"] = null) {
        c["pathMove"] := initPath(c, opts.name);
    }

    #destDistance := c.move.distanceTo(opts.dest.x, opts.dest.y, opts.dest.z);
    destDistance := distance(
        c.move.x + c.template.baseWidth/2, c.move.y + c.template.baseHeight/2, c.move.z, 
        opts.dest.x + opts.nearDistance/2, opts.dest.y + opts.nearDistance/2, opts.dest.z);

    minDist := (c.template.baseWidth + opts.nearDistance) / 2;

    # already there?
    if(int(destDistance) <= minDist) {
        #print(c.pathMove.name + " move done - will act!");
        return opts.onSuccess();
    }

    # are we on a path?
    if(c.pathMove.path != null) {
        if(c.pathMove.step >= len(c.pathMove.path)/3) {
            # finished path?
            c.pathMove.path := null;
            c.pathMove.step := 0;
            print(c.pathMove.name + " path done, will try new path");
        } else {
            return takePathMoveStep(c, delta, destDistance, minDist);
        }
    }

    # are we too far?
    if(opts.farDistance > 0 && destDistance > opts.farDistance) {
        return anchorAndMoveCreatureRandom(c, delta);
    }

    #print(c.template.shape + " distance to player:" + destDistance + " vs + " + opts.nearDistance);

    # can't call findPath yet
    if(c.pathMove.nextCheck > 0) {
        c.pathMove.nextCheck := c.pathMove.nextCheck - delta;
        return anchorAndMoveCreatureRandom(c, delta);
    }
    
    # try to get there via astar            
    #print("+++ " + c.pathMove.name + " calling findPath!");
    path := c.move.findPath(opts.dest.x, opts.dest.y, opts.dest.z, c.template.baseWidth, opts.nearDistance);
    #print("+++ " + c.pathMove.name + " path finder: " + path);
    if(path != null) {
        print("+++ " + c.pathMove.name + " has path!");
        c.pathMove.path := path;
        c.pathMove.step := 0;
        c.pathMove.pathFail := 0;
        c.pathMove.nextCheck := 0;
        return takePathMoveStep(c, delta, destDistance, minDist);
    } else {
        print("+++ " + c.pathMove.name + " no path found!");
    }

    # can't find path: try again later
    c.pathMove.pathFail := c.pathMove.pathFail + 1;
    if(c.pathMove.pathFail >= 3) {
        # failed too many times: take a longer break
        c.pathMove.pathFail := 0;
        c.pathMove.nextCheck := 3 + random() * 2;
    } else {
        c.pathMove.nextCheck := 0.5 + random();
    }
    return anchorAndMoveCreatureRandom(c, delta);
}

def takePathMoveStep(c, delta, destDistance, minDist) {
    # waiting for the path to unblock?
    if(c.pathMove.nextCheck > 0) {
        c.pathMove.nextCheck := c.pathMove.nextCheck - delta;
        return ANIM_STAND;
    }

    # take a step on path
    nextX := c.pathMove.path[c.pathMove.step * 3];
    nextY := c.pathMove.path[(c.pathMove.step * 3) + 1];
    deltaX := nextX - c.move.x;
    deltaY := nextY - c.move.y;
    moved := c.move.moveInDir(deltaX, deltaY, delta, null, (newX, newY, newZ) => {
        c.pathMove.step := c.pathMove.step + 1;
    });
    if(moved) {
        return ANIM_MOVE;
    }
    if(c.move.operateDoorNearby() != null) {
        # a door opened: recalc path
        c.pathMove["path"] := null;
    } else {
        print(c.template.shape + " failed to move on path. dist=" + destDistance + " vs " + minDist);
        
        # after 3 fails, give up on this path
        c.pathMove.pathFail := c.pathMove.pathFail + 1;
        if(c.pathMove.pathFail >= 3) {
            c.pathMove.path := null;
            c.pathMove.step := 0;
        } else {
            c.pathMove.nextCheck := 0.5 + random();
        }
    }
    return ANIM_STAND;
}
