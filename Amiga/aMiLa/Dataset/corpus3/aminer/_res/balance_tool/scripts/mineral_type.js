class MineralType {
	static SILVER = {id: 0, name: 'silver', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: true, reward: 5, isDamaging: false, tileIndex: TileIndex.SILVER_1};
	static GOLD = {id: 1, name: 'gold', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: true, reward: 10, isDamaging: false, tileIndex: TileIndex.GOLD_1};
	static EMERALD = {id: 2, name: 'emerald', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: true, reward: 15, isDamaging: false, tileIndex: TileIndex.EMERALD_1};
	static RUBY = {id: 3, name: 'ruby', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: true, reward: 20, isDamaging: false, tileIndex: TileIndex.RUBY_1};
	static MOONSTONE = {id: 4, name: 'moonstone', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: true, reward: 25, isDamaging: false, tileIndex: TileIndex.MOONSTONE_1};
	static DIRT = {id: 5, name: 'dirt', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: false, reward: 0, isDamaging: false, tileIndex: TileIndex.DIRT_1};
	static AIR = {id: 6, name: 'air', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: false, reward: 0, isDamaging: false, tileIndex: TileIndex.CAVE_BG_1};
	static MAGMA = {id: 7, name: 'magma', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: false, reward: 0, isDamaging: true, tileIndex: TileIndex.MAGMA_1};
	static ROCK = {id: 8, name: 'rock', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: false, reward: 0, isDamaging: false, tileIndex: TileIndex.STONE_1};
	static BONE = {id: 9, name: 'bone', isCapsule: false, isCrate: false, isGate: false, isDino: true, isCollectible: false, reward: 0, isDamaging: false, tileIndex: TileIndex.BONE_1};
	static GATE = {id: 10, name: 'gate', isCapsule: false, isCrate: false, isGate: true, isDino: false, isCollectible: false, reward: 0, isDamaging: false, tileIndex: TileIndex.GATE_1};
	static CRATE = {id: 11, name: 'crate', isCapsule: false, isCrate: true, isGate: false, isDino: false, isCollectible: false, reward: 0, isDamaging: false, tileIndex: TileIndex.CRATE_1};
	static CAPSULE = {id: 11, name: 'capsule', isCapsule: true, isCrate: false, isGate: false, isDino: false, isCollectible: false, reward: 0, isDamaging: false, tileIndex: TileIndex.CAPSULE_1};
	static UNKNOWN = {id: 12, name: 'unknown', isCapsule: false, isCrate: false, isGate: false, isDino: false, isCollectible: false, reward: 0, isDamaging: false, tileIndex: null};

	static all = [
		this.SILVER,
		this.GOLD,
		this.EMERALD,
		this.RUBY,
		this.MOONSTONE,
		this.DIRT,
		this.AIR,
		this.MAGMA,
		this.ROCK,
		this.BONE,
		this.GATE,
		this.CRATE,
		this.UNKNOWN,
	];

	static collectibles = (() => this.all.filter((x) => x.isCollectible))();
	static questables = (() => this.all.filter((x) => x.isGate || x.isDino || x.isCrate))();
	static statables = (() => this.collectibles.concat(this.questables))();
}
