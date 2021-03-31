# this file is compiled last
const SCREEN_WIDTH = 400;
const SCREEN_HEIGHT = 300;

const LINE_HEIGHT = 24;

const ANIM_STAND = "stand";
const ANIM_MOVE = "move";

const MESSAGE_R = 255;
const MESSAGE_G = 220;
const MESSAGE_B = 30;

const SECTIONS = {
    "25,25": MAP_25_25,
    "24,25": MAP_24_25,
    "24,24": MAP_24_24,
    "25,24": MAP_25_24,
};

const npcDefs = {
    "necromancer": {
        "name": "The Necromancer",
        "creature": creaturesTemplates["monk-blue"],
        "convo": NECROMANCER_CONVO,
    },
};
