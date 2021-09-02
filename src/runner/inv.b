
const CONTAINER_TYPE = "container";
const BOOK_TYPE = "book";

items := [];

def setBook(x, y, z, location, book) {
    c := setItem("book", x, y, z, location, BOOK_TYPE);
    c["book"] := book;
    return c;
}

def setContainer(uiImage, x, y, z, location, invItems) {
    c := setItem(uiImage, x, y, z, location, CONTAINER_TYPE);
    if(c["items"] = null) {
        c["items"] := newInventory();
        array_foreach(invItems, (i, item) => {
            if(typeof(item) = "map") {
                c.items.add(item.shape, -1, -1);
                if(item["book"] != null) {
                    setBook(len(c.items.items) - 1, 0, 0, c.id, item.book);
                }
            } else {
                c.items.add(item, -1, -1);
            }
        });
    }
    return c;
}

def setItem(uiImage, x, y, z, location, type) {
    id := "";
    if(location = "map") {
        id := "i." + x + "." + y + "." + z;
    } else {
        id := location + "." + x;
    }
    c := array_find(items, cc => cc.id = id);
    if(c = null) {
        c := {
            "id": id,
            "type": type,
            "uiImage": uiImage,
            "x": x,
            "y": y,
            "z": z,
            "location": location,
        };
        print("*** Adding item of type: " + c.type);
        items[len(items)] := c;
    }
    return c;
}

def updateItemLocation(c, x, y, z, location) {
    c.x := x;
    c.y := y;
    c.z := z;
    c.location := location;
    print("New item location for id=" + c.id + " " + c.location + ":" + c.x + "," + c.y + "," + c.z);
}

def getItem(x, y, z, location) {
    # todo: linear search
    if(location = "map") {
        return array_find(items, c => c.x = x && c.y = y && c.z = z);
    }
    return array_find(items, c => c.x = x && c.location = location);
}

def getItemById(id) {
    return array_find(items, c => c.id = id);
}

def saveItem(item) {
    saved := {
        "id": item.id,
        "uiImage": item.uiImage,
        "type": item.type,
        "x": item.x,
        "y": item.y,
        "z": item.z,
        "location": item.location,
        "containers": [],
    };
    if(item["items"] != null) {
        saved["items"] := item.items.encode();
    }
    if(item["book"] != null) {
        saved["book"] := item["book"];
    }
    return saved;
}

def loadItem(savedItem) {
    c := {
        "id": savedItem.id,
        "uiImage": savedItem.uiImage,
        "type": savedItem.type,
        "x": savedItem.x,
        "y": savedItem.y,
        "z": savedItem.z,
        "location": savedItem.location,
    };
    if(savedItem["items"] != null) {
        c["items"] := newInventory();
        c.items.decode(savedItem.items);
    }
    if(savedItem["book"] != null) {
        c["book"] := savedItem["book"];
    }
    return c;
}

def pruneItems(location, sectionX, sectionY, doRemove) {
    saves := array_reduce(items, [], (a, c) => {
        b := c.location = location;
        if(location = "map") {
            sectionPos := getSectionPos(c.x, c.y);
            b := sectionPos[0] = sectionX && sectionPos[1] = sectionY;
        }
        if(b) {
            a[len(a)] := saveItem(c);
        }
        return a;
    });
    if(doRemove && len(saves) > 0) {
        array_remove(items, c => array_find(saves, s => s.id = c.id) != null);
    }
    prune_contained(saves, doRemove);
    return saves;
}

def prune_contained(tests, doRemove) {
    if(len(tests) = 0) {
        return 1;
    }
    saves := array_reduce(tests, [], (a, r) => {
        array_foreach(items, (t, c) => {
            if(c.location = r.id) {
                result := saveItem(c);
                r.containers[len(r.containers)] := result;
                a[len(a)] := result;
            }
        });
        return a;
    });
    if(doRemove && len(saves) > 0) {
        array_remove(items, c => array_find(saves, s => s.id = c.id) != null);
    }
    prune_contained(saves, doRemove);
}

def restoreItem(savedItem) {
    print("* Restoring item " + savedItem.uiImage + " " + savedItem.id + " saved=" + savedItem);
    c := loadItem(savedItem);
    items[len(items)] := c;
    restore_contained(savedItem.containers);
    print("* Done restoring item");
}

def restore_contained(saved) {
    array_foreach(saved, (i, s) => {
        c := loadItem(s);
        items[len(items)] := c;
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
        "findIndex": (self, name) => array_find_index(self.items, item => item.shape = name),
        "remove": (self, index, location) => {
            # adjust the location of items in this inventory
            item := getItem(index, -1, -1, location);
            i := index + 1;
            while(i < len(self.items)) {
                c := getItem(i, -1, -1, location);
                if(c != null) {
                    updateItemLocation(c, i - 1, -1, -1, location);
                }
                i := i + 1;
            }
            # remove the item
            invItem := self.items[index];
            out := { 
                "shape": invItem.shape, 
                "x": invItem.x, 
                "y": invItem.y, 
                "item": item,
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

def newEquipment() {
    return {
        "equipment": DEFAULT_EQUIPMENT,
        "render": self => {
            uis := [];
            array_foreach(self.equipment, (slot, shape) => {
                if(shape != null) {
                    pos := SLOT_POS[slot];
                    uis[len(uis)] := {
                        "type": "uiImage",
                        "name": shape,
                        "x": pos[0],
                        "y": pos[1],
                    };
                }
            });
            return uis;
        },
        "encode": self => self.equipment,
        "decode": (self, saved) => {
            if(saved = null) {
                self.equipment := DEFAULT_EQUIPMENT;
            } else {
                self.equipment := saved;
            }
        },
    };
}
