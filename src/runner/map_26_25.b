SECTIONS["26,25"] := {
    "init": this => {
    },
    "teleport": (this, x, y, z) => {
        return null;
    },
    "locked": (this, x, y, z) => {
        if(x = 5208 && y = 5017 && z = 1) {
            return "key.ourdlen2";
        }
        return null;
    },
};
