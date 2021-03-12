const TREES = [ "plant.oak", "plant.red", "plant.pine", "plant.willow", "plant.dead" ];

def choose(a) {
    return a[int(random() * len(a))];
}

def editorCommand() {
    if(isPressed(KeyT)) {
        pos := getPosition();
        setShape(pos[0], pos[1], pos[2], "plant.trunk");
        setShape(pos[0] - 1, pos[1] - 1, pos[2] + 4, choose(TREES));
    }
    if(isPressed(Key0)) {
        setMaxZ(24);
    }
    if(isPressed(Key1)) {
        setMaxZ(7);
    }
    if(isPressed(Key2)) {
        setMaxZ(14);
    }
    if(isPressed(Key3)) {
        setMaxZ(21);
    }    
}

def main() {
    # this is never called
}
