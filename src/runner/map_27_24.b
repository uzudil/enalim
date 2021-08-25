SECTIONS["27,24"] := {
    "init": this => {
    },
    "teleport": (this, x, y, z) => {
        if(y >= 4904 && y <= 4907 && x >= 5588 && x <= 5591 && z = 1) {
            return [5575, 4877, 1];
        }
        if(x = 5572 && y >= 4876 && y <= 4879 && z = 1) {
            return [5588, 4909, 1];
        }
        return null;
    },
    "locked": (this, x, y, z) => {
        return null;
    },
};
