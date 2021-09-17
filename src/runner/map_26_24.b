SECTIONS["26,24"] := {
    "init": this => {
    },
    "teleport": (this, x, y, z) => {
        if(x >= 5396 && x < 5400 && y >= 4908 && y < 4912 && z = 1) {
            return [ 5370, 4909, 1 ];    
        } else if(x = 5368 && y >= 4908 && y < 4912 && z = 1) {
            return [ 5397, 4914, 1 ];
        }
        return null;
    },
    "locked": (this, x, y, z) => {
        return null;
    },
};
