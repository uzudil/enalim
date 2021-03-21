const TREES = [ "plant.oak", "plant.red", "plant.pine", "plant.willow", "plant.dead" ];
const ROCK_ROOF = [ "roof.mountain.1", "roof.mountain.2", "roof.mountain.3" ];

def choose(a) {
    return a[int(random() * len(a))];
}

def editorCommand() {
    if(isPressed(KeyT)) {
        pos := getPosition();
        setShape(pos[0], pos[1], pos[2], "plant.trunk");
        setShape(pos[0] - 1, pos[1] - 1, pos[2] + 4, choose(TREES));
    }
    if(isPressed(KeyR)) {
        pos := getPosition();
        x := int(pos[0] / 4) * 4;
        y := int(pos[1] / 4) * 4;
        setShape(x, y, 7, choose(ROCK_ROOF));
    }
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
}

def main() {
    #fadeViewTo(5000, 5000);
}
