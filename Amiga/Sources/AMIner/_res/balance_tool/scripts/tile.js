class Tile {
	constructor(tileIndex) {
		this.index = tileIndex;

		if(
			TileIndex.CAVE_BG_1 <= tileIndex && tileIndex <= TileIndex.CAVE_BG_16 ||
			TileIndex.BASE_BG_FIRST <= tileIndex  && tileIndex <= TileIndex.BASE_SHAFT
		) {
			this.mineralType = MineralType.AIR;
			this.mineralAmount = 0
		}
		else if(TileIndex.SILVER_1 <= tileIndex && tileIndex <= TileIndex.SILVER_3) {
			this.mineralType = MineralType.SILVER;
			this.mineralAmount = tileIndex - TileIndex.SILVER_1 + 1;
		}
		else if(TileIndex.GOLD_1 <= tileIndex && tileIndex <= TileIndex.GOLD_3) {
			this.mineralType = MineralType.GOLD;
			this.mineralAmount = tileIndex - TileIndex.GOLD_1 + 1;
		}
		else if(TileIndex.EMERALD_1 <= tileIndex && tileIndex <= TileIndex.EMERALD_3) {
			this.mineralType = MineralType.EMERALD;
			this.mineralAmount = tileIndex - TileIndex.EMERALD_1 + 1;
		}
		else if(TileIndex.RUBY_1 <= tileIndex && tileIndex <= TileIndex.RUBY_3) {
			this.mineralType = MineralType.RUBY;
			this.mineralAmount = tileIndex - TileIndex.RUBY_1 + 1;
		}
		else if(TileIndex.MOONSTONE_1 <= tileIndex && tileIndex <= TileIndex.MOONSTONE_3) {
			this.mineralType = MineralType.MOONSTONE;
			this.mineralAmount = tileIndex - TileIndex.MOONSTONE_1 + 1;
		}
		else if(TileIndex.MAGMA_1 <= tileIndex && tileIndex <= TileIndex.MAGMA_2) {
			this.mineralType = MineralType.MAGMA;
			this.mineralAmount = 0;
		}
		else if(TileIndex.STONE_1 <= tileIndex && tileIndex <= TileIndex.STONE_4) {
			this.mineralType = MineralType.ROCK;
			this.mineralAmount = 0;
		}
		else if(TileIndex.BASE_GROUND_1 <= tileIndex && tileIndex <= TileIndex.BASE_GROUND_9) {
			// TODO: unbreakable
			this.mineralType = MineralType.ROCK;
			this.mineralAmount = 0;
		}
		else if(TileIndex.BONE_HEAD <= tileIndex && tileIndex <= TileIndex.BONE_1) {
			this.mineralType = MineralType.BONE;
			this.mineralAmount = 0;
		}
		else if(TileIndex.GATE_1 <= tileIndex && tileIndex <= TileIndex.GATE_1) {
			this.mineralType = MineralType.GATE;
			this.mineralAmount = 0;
		}
		else if(TileIndex.CRATE_1 <= tileIndex && tileIndex <= TileIndex.CRATE_1) {
			this.mineralType = MineralType.CRATE;
			this.mineralAmount = 0;
		}
		else if(TileIndex.CAPSULE_1 <= tileIndex && tileIndex <= TileIndex.CAPSULE_1) {
			this.mineralType = MineralType.CAPSULE;
			this.mineralAmount = 0;
		}
		else {
			this.mineralType = MineralType.DIRT;
			this.mineralAmount = 0;
		}
	}

	isHardToDrill() {
		return this.index >= TileIndex.STONE_1;
	}
}
