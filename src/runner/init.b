# this file is compiled first (before calling main())
const SCREEN_WIDTH = 400;
const SCREEN_HEIGHT = 300;

const LINE_HEIGHT = 24;
const LINE_HEIGHT_SMALL = 16;

const ANIM_STAND = "stand";
const ANIM_MOVE = "move";

const MESSAGE_R = 255;
const MESSAGE_G = 220;
const MESSAGE_B = 30;

const VIEW_SIZE = 64;

const SECTIONS = {};

const npcReg = [];

def addNpcDef(npc) {
    npcReg[len(npcReg)] := npc;
}

const npcDefs = {};
