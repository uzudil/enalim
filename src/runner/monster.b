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
            #return anchorAndMoveCreatureRandom(c, delta);
            print("ATTACK!");
            # 0.1 is how long the attack sequence takes for 2 frames
            c.monster.attackTime := 0.1; 
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
