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
