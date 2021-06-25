
const SECTION_SIZE = 200;

def getSectionPos(x, y) {
    return [ int(x / SECTION_SIZE), int(y / SECTION_SIZE) ];
}

def getSection(sectionX, sectionY) {
    return SECTIONS["" + sectionX + "," + sectionY];
}

def onSectionLoad(sectionX, sectionY, data) {
    if(len(keys(data)) = 0) {
        # initialize a section
        print("+++ Initial load " + sectionX + "," + sectionY);
        section := getSection(sectionX, sectionY);
        if(section != null) {
            section.init();
        }
        print("+++ Init done " + sectionX + "," + sectionY);
    } else {
        # restore a section from saved data
        print("+++ Restore load " + sectionX + "," + sectionY);
        array_foreach(data.creatures, (i, c) => restoreCreature(c));
        array_foreach(data.items, (i, c) => restoreItems(c));
        print("+++ Done restoring " + sectionX + "," + sectionY);
    }
}

def beforeSectionSave(sectionX, sectionY) {
    if(player.mode = MODE_GAME || player.mode = MODE_TELEPORT) {
        player.move.erase();
    }
    return { 
        "creatures": pruneCreatures(sectionX, sectionY), 
        "items": pruneItems(sectionX, sectionY),
    };
}

def teleport(x, y, z) {
    sectionPos := getSectionPos(x, y);
    section := getSection(sectionPos[0], sectionPos[1]);
    if(section != null) {
        return section.teleport(x, y, z);
    }
    return null;
}

def scriptedAction(x, y, z) {
    sectionPos := getSectionPos(x, y);
    section := getSection(sectionPos[0], sectionPos[1]);
    if(section != null) {
        if(section["action"] != null) {
            return section.action(x, y, z);
        }
    }
    return null;
}

def staticInitSections() {
    array_foreach(keys(SECTIONS), (i, k) => {
        section := SECTIONS[k];
        if(section["staticInit"] != null) {
            section.staticInit();
        }
    });
}
