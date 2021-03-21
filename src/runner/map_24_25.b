const MAP_24_25 = {
    "init": this => {
    },
    "teleport": (this, x, y, z) => {
        #if(x > 4994 && x <= 4998 && y = 5045 && z = 1) {
        #    return [4988, 5005, 1];
        #}
        #if(x = 4984 && y <= 5007 && y >= 5004 && z = 1) {
        #    return [4997, 5049, 1];
        #}
        return null;
    }
};
