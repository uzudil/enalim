SECTIONS["24,24"] := {
    "init": this => {
        setBook(4997, 4992, 10, "map", "Raising the dead");
    },
    "teleport": (this, x, y, z) => {
        if(x >= 4996 && x <= 4999 && y = 4986 && z = 1) {
            return [5002, 5037, 1];
        }
        return null;
    }
};
