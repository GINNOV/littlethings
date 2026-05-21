class GroundLayer {
	constructor(name, pixelStartY, drillDifficulty, colorHex) {
		this.name = name;
		this.pixelStartY = pixelStartY;
		this.drillDifficulty = drillDifficulty;
		this.colorHex = colorHex;
	}

	static getLayerAt(posY) {
		for(let i = 0; i < this.layers.length - 1; ++i) {
			if(this.layers[i + 1].pixelStartY / 32 > posY) {
				return this.layers[i];
			}
		}
		this.layers[this.layers.length - 1];
	}

	static layers = [
		new GroundLayer('A', 0, 2, Utils.rgbToHex(153, 68, 17)),
		new GroundLayer('B', (64 + 1) * 32, 3, Utils.rgbToHex(153, 102, 17)),
		new GroundLayer('C', (64 + 128 + 1) * 32, 4, Utils.rgbToHex(153, 102, 51)),
		new GroundLayer('D', (64 + 128 + 256 + 1) * 32, 5, Utils.rgbToHex(119, 102, 51)),
		new GroundLayer('E', (64 + 128 + 256 + 256 + 1) * 32, 6, Utils.rgbToHex(119, 102, 68)),
		new GroundLayer('X', 65535, 0, Utils.rgbToHex(119, 102, 68)) // unreachable
	]
}
