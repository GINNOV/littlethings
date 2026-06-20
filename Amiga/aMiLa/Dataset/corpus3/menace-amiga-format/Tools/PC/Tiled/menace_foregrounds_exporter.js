// menace_foregrounds_exporter.js
//
// This file is for use in the "Tiled" editor
// see https://www.mapeditor.org/

// This is designed to take a Meance foreground map data and export back into the
// format that the game currently understands. i.e. the "map" file

// The file format is:
// - 1 byte per tile, each byte is the index to the tile in the tile set
// - 2 x 0xFF delimiters at the end of the map data, used to signify the end of the map. 
//      - Tile index 0xFF therefore can't be used in the actual layer

tiled.log("menaceforegroundsexporter.js loaded");

tiled.registerMapFormat("menaceforegroundsexporter", {
    name: "MenaceForegroundsExporter",
    extension: "vmap",

    write: function(map, fileName) {
        tiled.log("Starting MenaceForegroundsExporter v1.00");

        let layer = map.layerAt(0);
        if (!layer || !layer.isTileLayer) {
            tiled.log("First layer is not a tile layer");
            return;
        }

        let width = layer.width;
        let height = layer.height;

        tiled.log(`Map size: ${width}x${height}`);

        let NumDelimiters = 2;
        let bytes = new Uint8Array((width * height) + NumDelimiters);
        let idx = 0;

        // write the data is vertical strips
        for (let x = 0; x < width; x++) {
            for (let y = 0; y < height; y++) {
                let tile = layer.tileAt(x, y);
                bytes[idx++] = tile ? (tile.id & 0xFF) : 0;
            }
        }

        // Menace had 2 x 0xFF delimeters on the end of the file
        bytes[idx++] = 0xFF;
        bytes[idx++] = 0xFF;

        tiled.log(`Total bytes to write (including 0xFF): ${bytes.length}`);

        let file = new BinaryFile(fileName, BinaryFile.WriteOnly);
        file.write(bytes.buffer);
        file.commit();

        tiled.log("Export complete");
    }

});
