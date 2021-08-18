SECTIONS["24,25"] := {
    "init": this => {
        setBook(4984, 5009, 3, "map", "On ghosts and spirits");
    },
    "teleport": (this, x, y, z) => {
        return null;
    },
    "action": (this, x, y, z) => {
        if(x = 4969 && y = 5001 && z = 1) {
            timedMessage(x, y, z, "Beware of ghosts!");            
            return true;
        }
        return null;
    }
};
