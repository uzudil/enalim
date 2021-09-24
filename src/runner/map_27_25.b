SECTIONS["27,25"] := {
    "init": this => {
    },
    "teleport": (this, x, y, z) => {
        if(y = 5015 && x <= 5483 && x >= 5480 && z = 1) {
            return [5405, 4969, 1];
        } else if(x = 5506 && y >= 5067 && y < 5071 && z = 1) {
            return [ 5297, 4986, 1 ];
        }
        return null;
    },
    "locked": (this, x, y, z) => {
        return null;
    },
    "action": (this, x, y, z) => {
        return null;
    }
};
