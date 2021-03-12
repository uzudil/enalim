def onSectionLoad(sectionX, sectionY) {
    if(sectionX = 25 && sectionY = 25) {
        # todo: load creature pos (and other mutables) from another file?
        setCreature(5040, 5075, 1, creaturesTemplates.cow);
        setCreature(5032, 5061, 1, creaturesTemplates.cow);
    }
}

def beforeSectionSave(sectionX, sectionY) {
    print("About to save section: " + name);
    pruneCreatures(sectionX, sectionY);
    # save creatures, etc. in another file?
}
