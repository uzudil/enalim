
const SECTION_SIZE = 200;

activeSections := [];

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
        array_foreach(data.items, (i, c) => restoreItem(c));
        print("+++ Done restoring " + sectionX + "," + sectionY);
    }

    # start section
    section := getSection(sectionX, sectionY);
    if(section != null) {
        if(section["start"] != null) {
            section.start();
        }
    }

    setRoofVisiblity();
    activeSections[len(activeSections)] := [sectionX, sectionY];
}

def beforeSectionSave(sectionX, sectionY) {
    array_remove(activeSections, s => s[0] = sectionX && s[1] = sectionY);
    save_game();
    return { 
        "creatures": pruneCreatures(sectionX, sectionY), 
        "items": pruneItems("map", sectionX, sectionY, true),
    };
}

def restartActiveSections() {
    array_foreach(activeSections, (i, p) => {
        print("Restarting active section: " + p[0] + "," + p[1]);
        section := getSection(p[0], p[1]);
        if(section != null) {
            if(section["start"] != null) {
                section.start();
            }
        }    
    });
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
