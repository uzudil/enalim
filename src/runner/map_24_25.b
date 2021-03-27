
const MAP_24_25 = {
    "init": this => {
        setNpc(4998, 5001, 1, npcDefs.necromancer);
    },
    "teleport": (this, x, y, z) => {
        return null;
    }
};

const NECROMANCER_CONVO = {
    "": "My trusted assistant, I have a $task for you!",
    "task": "As you know, we're preparing for the coming lunar alignment. I need $three more spell $components and I need you to bring them to me.",
};
