
containers := [];

def setContainer(uiImage, x, y, z, location, items) {
    id := "";
    if(location = "map") {
        id := "i." + x + "." + y + "." + z;
    } else {
        id := location + "." + x;
    }
    c := array_find(containers, cc => cc.id = id);
    if(c = null) {
        c := {
            "id": id,
            "uiImage": uiImage,
            "x": x,
            "y": y,
            "z": z,
            "location": location,
            "items": newInventory(),
        };
        array_foreach(items, (i, item) => c.items.add(item, -1, -1));
        containers[len(containers)] := c;
    }
    return c;
}

def updateContainerLocation(c, x, y, z, location) {
    c.x := x;
    c.y := y;
    c.z := z;
    c.location := location;
    print("New container location for id=" + c.id + " " + c.location + ":" + c.x + "," + c.y + "," + c.z);
}

def getContainer(x, y, z, location) {
    # todo: if this is too slow, keep track of creaturePos in a global table
    if(location = "map") {
        return array_find(containers, c => c.x = x && c.y = y && c.z = z);
    }
    return array_find(containers, c => c.x = x && c.location = location);
}

def getContainerById(id) {
    return array_find(containers, c => c.id = id);
}

def pruneContainers(sectionX, sectionY) {
    removes := [];
    array_remove(containers, c => {
        if(c.location = "map") {
            sectionPos := getSectionPos(c.x, c.y);
            b := sectionPos[0] = sectionX && sectionPos[1] = sectionY;
            if(b) {
                removes[len(removes)] := {
                    "id": c.id,
                    "uiImage": c.uiImage,
                    "x": c.x,
                    "y": c.y,
                    "z": c.z,
                    "location": c.location,
                    "items": c.items.encode(),
                    "containers": [],
                };
                print("* Pruning container: " + c.uiImage + " " + c.id);
            }
            return b;
        }
        return false;
    });
    prune_contained(removes);
    return removes;
}

def prune_contained(tests) {
    if(len(tests) = 0) {
        return 1;
    }

    a := [];
    array_foreach(tests, (i, r) => {
        array_remove(containers, c => {
            if(c.location = r.id) {                
                result := {
                    "id": c.id,
                    "uiImage": c.uiImage,
                    "x": c.x,
                    "y": c.y,
                    "z": c.z,
                    "location": c.location,
                    "items": c.items.encode(),
                    "containers": [],
                };
                r.containers[len(r.containers)] := result;
                a[len(a)] := result;
                return true;
            }
            return false;
        });
    });
    prune_contained(a);
}

def restoreContainer(savedContainer) {
    print("* Restoring container " + savedContainer.uiImage + " " + savedContainer.id);
    c := {
        "id": savedContainer.id,
        "uiImage": savedContainer.uiImage,
        "x": savedContainer.x,
        "y": savedContainer.y,
        "z": savedContainer.z,
        "location": savedContainer.location,
        "items": newInventory(),
    };
    c.items.decode(savedContainer.items);
    containers[len(containers)] := c;
    restore_contained(savedContainer.containers);
}

def restore_contained(saved) {
    if(len(saved) = 0) {
        return 1;
    }
    array_foreach(saved, (i, s) => {
        c := {
            "id": s.id,
            "uiImage": s.uiImage,
            "x": s.x,
            "y": s.y,
            "z": s.z,
            "location": s.location,
            "items": newInventory(),
        };
        c.items.decode(s.items);
        containers[len(containers)] := c;
        restore_contained(s.containers);
    });
}

def newInventory() {
    return {
        "items": [],
        "add": (self, shape, xpos, ypos) => {
            if(xpos < 0) {
                xpos := int(50 + random() * 100);
                ypos := int(30 + random() * 60);
            }
            self.items[len(self.items)] := {
                "shape": shape,
                "x": xpos,
                "y": ypos,
            };
            return len(self.items) - 1;
        },
        "remove": (self, index, location) => {
            # adjust the location of containers in this inventory
            i := index + 1;
            while(i < len(self.items)) {
                c := getContainer(i, -1, -1, location);
                if(c != null) {
                    updateContainerLocation(c, i - 1, -1, -1, location);
                }
                i := i + 1;
            }
            # remove the item
            item := self.items[index];
            out := { 
                "shape": item.shape, 
                "x": item.x, 
                "y": item.y, 
            };
            del self.items[index];
            return out;
        },
        "render": self => {
            return array_map(self.items, item => {
                return {
                    "type": "uiImage",
                    "name": item.shape,
                    "x": item.x,
                    "y": item.y,
                };
            });
        },
        "encode": self => {
            return array_map(self.items, i => {
                return {
                    "shape": i.shape,
                    "x": i.x,
                    "y": i.y,
                };
            });
        },
        "decode": (self, saved) => {
            array_foreach(saved, (i, item) => self.add(item.shape, item.x, item.y));
        },
    };
}
