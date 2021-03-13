def onSectionLoad(sectionX, sectionY, data) {
    if(len(keys(data)) = 0) {
        # initialize a section
        print("+++ Initial load: " + sectionX + "," + sectionY);
        if(sectionX = 25 && sectionY = 25) {
            setCreature(5040, 5075, 1, creaturesTemplates.cow);
            setCreature(5032, 5061, 1, creaturesTemplates.cow);
        }
    } else {
        # restore a section from saved data
        print("Restore load: " + sectionX + "," + sectionY);
        array_foreach(data.creatures, (i, c) => restoreCreature(c));
        print("Done restoring.");
    }
}

def beforeSectionSave(sectionX, sectionY) {
    sectionCreatures := pruneCreatures(sectionX, sectionY);
    return { "creatures": sectionCreatures };
}
