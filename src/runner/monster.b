def moveMonster(c, delta) {
    if(c["monster"] = null) {
        c["monster"] := initMonster(c);
    }

    if(c.monster.attackTime > 0) {
        c.monster.attackTime := c.monster.attackTime - delta;        
        return ANIM_ATTACK;
    }

    if(c.monster.coolTime > 0) {
        c.monster.coolTime := c.monster.coolTime - delta;
        return ANIM_STAND;
    }

    return pathMove(c, delta, {
        "name": "MONSTER " + c.template.shape, 
        "dest": player.move, 
        "nearDistance": 2,
        "farDistance": 20,
        "onSuccess": self => {
            # todo: combat!
            c.monster.attackTime := ANIMATION_SPEED * c.template.attackSteps; 
            c.monster.coolTime := 0.5;
            return ANIM_ATTACK;
        },
    });
}

def initMonster(c) {
    return {
        "attackTime": 0,
        "coolTime": 0,
    };
}
