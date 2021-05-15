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
        },
        "remove": (self, index) => {
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
    };
}
