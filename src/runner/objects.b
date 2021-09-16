const SLOT_HEAD = 0;
const SLOT_CLOAK = 1;
const SLOT_AMULET = 2;
const SLOT_ARMOR = 3;
const SLOT_RIGHT_HAND = 4;
const SLOT_LEFT_HAND = 5;
const SLOT_BELT = 6;
const SLOT_FEET = 7;
const SLOT_RING_1 = 8;
const SLOT_RING_2 = 9;

const SLOT_POS = [
    [80, 32],
    [24, 56],
    [136, 56],
    [80, 80],
    [24, 112],
    [136, 112],
    [80, 144],
    [80, 208],
    [24, 176],
    [136, 176],
];

const DEFAULT_EQUIPMENT = [ null, null, null, null, null, null, null, null, null, null ];

const OBJECTS = [
    { name: "Broadsword", slot: SLOT_RIGHT_HAND, variation: "sword", shape: "item.sword", cat: CAT_WEAPON, price: 150 },
    { name: "Dagger", slot: SLOT_RIGHT_HAND, variation: "dagger", shape: "item.dagger", cat: CAT_WEAPON, price: 50 },
    { name: "Leather Helm", slot: SLOT_HEAD, shape: "item.helm.leather", cat: CAT_ARMOR, price: 80 },
];

const OBJECTS_BY_SHAPE = {};

def initObjects() {
    array_foreach(OBJECTS, (i, e) => {
        OBJECTS_BY_SHAPE[e.shape] := e;
    });
}
