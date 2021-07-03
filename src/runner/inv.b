
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
    items[len(items)] := c;
}

def pruneItems(sectionX, sectionY) {
    removes := [];
    array_remove(items, c => {
        if(c.location = "map") {
            sectionPos := getSectionPos(c.x, c.y);
            b := sectionPos[0] = sectionX && sectionPos[1] = sectionY;
            if(b) {
                removes[len(removes)] := saveItem(c);
                print("* Pruning item: " + c.uiImage + " " + c.id);
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
        array_remove(items, c => {
            if(c.location = r.id) {
                result := saveItem(c);
                r.containers[len(r.containers)] := result;
                a[len(a)] := result;
                return true;
            }
            return false;
        });
    });
    prune_contained(a);
}

def restoreItem(savedItem) {
    print("* Restoring item " + savedItem.uiImage + " " + savedItem.id);
    c := loadItem(savedItem);
    restore_contained(savedItem.containers);
    print("* Done restoring item");
}

def restore_contained(saved) {
    if(len(saved) = 0) {
        return 1;
    }
    array_foreach(saved, (i, s) => {
        items[len(items)] := loadItem(s);
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
            i := index + 1;
            while(i < len(self.items)) {
                c := getItem(i, -1, -1, location);
                if(c != null) {
                    updateItemLocation(c, i - 1, -1, -1, location);
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
