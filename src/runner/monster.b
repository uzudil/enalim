
def initMonster(c) {
    return {
        "name": "MONSTER " + c.template.shape,
        "nextCheck": 0,
        "pathFail": 0,
        "path": null,
        "step": 0,
    };
}

def moveMonster(c, delta) {
    if(c["monster"] = null) {
        c["monster"] := initMonster(c);
    }

    player_distance := c.move.distanceTo(player.move.x, player.move.y, player.move.z);
    # print(c.template.shape + " distance to player:" + player_distance);

    # already there?
    if(player_distance <= 2) {
        print(c.monster.name + " move done - will attack!");
        # todo: combat!
        return monsterMoveRandom(c, delta);
    }

    # are we on a path?
    if(c.monster.path != null) {
        if(c.monster.step >= len(c.monster.path)/3) {
            # finished path?
            c.monster.path := null;
            c.monster.step := 0;
            print(c.monster.name + " path done, will try new path");
        } else {
            return takeMonsterPathStep(c, delta);
        }
    }

    # are we too far?
    if(player_distance > 10) {
        return monsterMoveRandom(c, delta);
    }

    # can't call findPath yet
    if(c.monster.nextCheck > 0) {
        c.monster.nextCheck := c.monster.nextCheck - delta;
        return monsterMoveRandom(c, delta);
    }
    
    # try to get there via astar            
    print("+++ " + c.monster.name + " calling findPath!");
    path := c.move.findPath(player.move.x, player.move.y, player.move.z);
    print("+++ " + c.monster.name + " path finder: " + path);
    if(path != null) {
        c.monster.path := path;
        c.monster.step := 0;
        c.monster.pathFail := 0;
        c.monster.nextCheck := 0;
        return takeMonsterPathStep(c, delta);
    }

    # can't find path: try again later
    c.monster.pathFail := c.monster.pathFail + 1;
    if(c.monster.pathFail >= 3) {
        # failed too many times: take a longer break
        c.monster.pathFail := 0;
        c.monster.nextCheck := 3 + random() * 2;
    } else {
        c.monster.nextCheck := 0.5 + random();
    }
    return monsterMoveRandom(c, delta);
}

def monsterMoveRandom(c, delta) {
    # re-anchor at current location
    c.anchor := [ c.move.x, c.move.y, c.move.z ];
    return moveCreatureRandom(c, delta);
}

def takeMonsterPathStep(c, delta) {
    # waiting for the path to unblock?
    if(c.monster.nextCheck > 0) {
        c.monster.nextCheck := c.monster.nextCheck - delta;
        return ANIM_STAND;
    }

    # take a step on path
    nextX := c.monster.path[c.monster.step * 3];
    nextY := c.monster.path[(c.monster.step * 3) + 1];
    deltaX := nextX - c.move.x;
    deltaY := nextY - c.move.y;
    moved := c.move.moveInDir(deltaX, deltaY, delta, null, (newX, newY, newZ) => {
        c.monster.step := c.monster.step + 1;
    });
    if(moved) {
        return ANIM_MOVE;
    }
    if(c.move.operateDoorNearby() != null) {
        # a door opened: recalc path
        c.monster["path"] := null;
    } else {
        print(c.template.shape + " failed to move on path. From: " + c.move.x + "," + c.move.y + " To:" + nextX + "," + nextY);
        
        # after 3 fails, give up on this path
        c.monster.pathFail := c.monster.pathFail + 1;
        if(c.monster.pathFail >= 3) {
            c.monster.path := null;
            c.monster.step := 0;
        } else {
            c.monster.nextCheck := 0.5 + random();
        }
    }
    return ANIM_STAND;
}
