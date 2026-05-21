class TileMap {
	constructor(width, height) {
		this.tiles = new Array(width).fill(0).map(() => new Array(height).fill(0));
		this.width = width;
		this.height = height;
		this.rowPlans = new Array(height).fill('');

		let tileRowBaseDirt = 8;

		for(let x = 1; x < width; ++x) {
			for(let y = tileRowBaseDirt + 2; y < height; ++y) {
				// 2000 is max
				let what = Math.floor((g_rand.next16() * 1000) / 65535);
				let chanceAir = 50;
				let chanceRock, chanceMagma;
				chanceRock = Utils.clamp(y * 500 / 2000, 0, 500);
				chanceMagma = Utils.chanceTrapezoid(y, 50, 900, 1000, 1100, 0, 75);

				let chance = 0;
				if(what < (chance = chanceRock)) {
					this.tiles[x][y] = new Tile(g_rand.next16MinMax(TileIndex.STONE_1, TileIndex.STONE_4));
				}
				else if(what < (chance += chanceMagma)) {
					this.tiles[x][y] = new Tile(g_rand.next16MinMax(TileIndex.MAGMA_1, TileIndex.MAGMA_2));
				}
				else if(
					what < (chance += chanceAir) &&
					this.isSolid(x - 1, y) && this.isSolid(x, y - 1)
				) {
					this.tiles[x][y] = new Tile(TileIndex.CAVE_BG_1+15);
				}
				else {
					this.tiles[x][y] = new Tile(TileIndex.DIRT_1 + ((x & 1) ^ (y & 1)));
				}
			}
		}

		// Draw bases
		for(let baseIndex = 0; baseIndex < TileMap.bases.length; ++baseIndex) {
			let base = TileMap.bases[baseIndex];
			for(let y = 0; y < base.pattern.length; ++y) {
				for(let x = 1; x < width; ++x) {
					this.tiles[x][base.level + y] = new Tile(base.pattern[y][x - 1]);
				}
			}
		}

		// Fill left invisible col with rocks
		for(let y = 0; y < height; ++y) {
			this.tiles[0][y] = new Tile(TileIndex.STONE_1);
		}

		// Rock bottom
		for(let x = 1; x < width; ++x) {
			this.tiles[x][height - 1] = new Tile(TileIndex.BASE_GROUND_1);
		}

		// Quest items
		for(let depth of g_defs.dinoDepths) {
			this.tiles[g_rand.next16MinMax(1, width - 1)][depth] = new Tile(TileIndex.BONE_1);
		}
		for(let depth of g_defs.gateDepths) {
			this.tiles[g_rand.next16MinMax(1, width - 1)][depth] = new Tile(TileIndex.GATE_1);
		}
		for(let depth of g_defs.crateDepths) {
			this.tiles[g_rand.next16MinMax(1, width - 1)][depth] = new Tile(TileIndex.CRATE_1);
		}
		this.tiles[g_rand.next16MinMax(1, width - 1)][g_defs.crateCapsuleDepth] = new Tile(TileIndex.CAPSULE_1);

		// Rows per plan
		let plannableRows = 0;
		let baseIndex = 0;
		for(let y = 0; y < height - 1; ++y) {
			if(baseIndex >= TileMap.bases.length || y < TileMap.bases[baseIndex].level) {
				++plannableRows;
			}
			else if(y >= TileMap.bases[baseIndex].level + TileMap.bases[baseIndex].pattern.length - 1) {
				++baseIndex;
			}
		}
		let planCount = g_defs.maxAccolades * g_defs.maxSubAccolades;
		let plannedRows = plannableRows * g_defs.minePercentForPlans;
		console.log(`plannable rows: ${plannableRows}, planned: ${plannedRows}, rows per plan: ${plannedRows / planCount}`);
		let rowsPerPlan = Math.ceil(plannedRows / planCount);

		// Pattern for filling minerals
		let fillPosPattern = []; // [idx] => {x,y}, unordered
		for(let x = 1; x < width; ++x) {
			for(let y = 0; y < rowsPerPlan; ++y) {
				fillPosPattern.push({x: x, y: y});
			}
		}
		Utils.shuffleArray(fillPosPattern, g_rand);

		baseIndex = 0;
		let currentRow = 0;
		let nextPatternPos = 0;
		let currentPlannableRow = 0;
		for(let planIndex = 0; planIndex < planCount; ++planIndex) {
			// Get mine rows for plan
			let planLastPlannableRow  = Math.floor((plannedRows * (planIndex + 1)) / planCount);
			let planSegmentRows = [];
			while(currentPlannableRow <= planLastPlannableRow) {
				if(baseIndex < TileMap.bases.length && currentRow >= TileMap.bases[baseIndex].level) {
					currentRow = TileMap.bases[baseIndex].level + TileMap.bases[baseIndex].pattern.length;
					++baseIndex;
				}
				this.rowPlans[currentRow] = `P${planIndex + 1}`;
				planSegmentRows.push(currentRow++);
				++currentPlannableRow;
			}

			let planInfo = g_plans.sequence[planIndex];
			console.log(`plan ${planIndex} rows ${planSegmentRows[0]}..${planSegmentRows[planSegmentRows.length - 1]} minerals required: ${planInfo.mineralsRequired}`);

			// Fill mine segment with minerals required for plan, merging some in the process
			let placedMoney = 0;
			let totalMinerals = planInfo.mineralsRequired.reduce((sum, value) => sum + value, 0);
			let mineralsRemaining = planInfo.mineralsRequired.map((x) => x);
			let allowedMineralIds = g_plans.getAllowedMineralIdsForPlan(planIndex);
			let placedStacks = 0;
			while(totalMinerals > 0) {
				// pick mineral
				let placedMineralId = allowedMineralIds[g_rand.next16MinMax(0, allowedMineralIds.length - 1)];
				if(mineralsRemaining[placedMineralId] > 0) {
					let startPatternPos = nextPatternPos;
					let isPlaced = false;
					do {
						// pick next position from pattern
						let placePosition = fillPosPattern[nextPatternPos];
						nextPatternPos = (nextPatternPos + 1) % fillPosPattern.length;
						if(placePosition.y >= planSegmentRows.length) {
							continue;
						}

						// fill position with mineral
						let existingTile = this.tiles[placePosition.x][planSegmentRows[placePosition.y]];
						if(existingTile.mineralType == MineralType.DIRT) {
							let placedAmount = g_rand.next16MinMax(1, Math.min(mineralsRemaining[placedMineralId], 3));
							let mineralTileIndex = MineralType.all[placedMineralId].tileIndex;
							this.tiles[placePosition.x][planSegmentRows[placePosition.y]] = new Tile(mineralTileIndex + placedAmount - 1);
							totalMinerals -= placedAmount;
							mineralsRemaining[placedMineralId] -= placedAmount;
							isPlaced = true;
							++placedStacks;
							placedMoney += MineralType.all[placedMineralId].reward * placedAmount;
							break;
						}
						else if (
							mineralsRemaining[existingTile.mineralType.id] > 0 &&
							existingTile.mineralAmount < 3
						) {
							let delta = Math.min(3 - existingTile.mineralAmount, mineralsRemaining[existingTile.mineralType.id]);
							existingTile.mineralAmount += delta;
							mineralsRemaining[existingTile.mineralType.id] -= delta;
							totalMinerals -= delta;
							isPlaced = true;
							placedMoney += existingTile.mineralType.reward * delta;
							break;
						}
					} while(nextPatternPos != startPatternPos);
					if(!isPlaced) {
						addMessage(`Can't place all minerals on plan ${planIndex}`, 'error');
						break;
					}
				}
			}
			console.log(`placed money: ${placedMoney}/${planInfo.targetSum}, stacks: ${placedStacks}`);

			let extraMineralMoney = g_defs.extraPlanMoney;
			while(extraMineralMoney > 0) {
				// pick mineral
				let placedMineralId = allowedMineralIds[g_rand.next16MinMax(0, allowedMineralIds.length - 1)];
				let startPatternPos = nextPatternPos;
				let isPlaced = false;
				do {
					// pick next position from pattern
					let placePosition = fillPosPattern[nextPatternPos];
					nextPatternPos = (nextPatternPos + 1) % fillPosPattern.length;
					if(placePosition.y >= planSegmentRows.length) {
						continue;
					}

					// fill position with mineral
					if(this.tiles[placePosition.x][planSegmentRows[placePosition.y]].mineralType == MineralType.DIRT) {
						let mineralReward = MineralType.all[placedMineralId].reward;
						let maxAmount = Math.min(Math.floor((extraMineralMoney + mineralReward - 1) / mineralReward), 3);
						let placedAmount = g_rand.next16MinMax(1, maxAmount);
						extraMineralMoney -= placedAmount * mineralReward;
						let mineralTileIndex = MineralType.all[placedMineralId].tileIndex;
						this.tiles[placePosition.x][planSegmentRows[placePosition.y]] = new Tile(mineralTileIndex + placedAmount - 1);
						isPlaced = true;
						break;
					}
				} while(nextPatternPos != startPatternPos);
				if(!isPlaced) {
					addMessage(`Couldn't place all extra minerals on plan ${planIndex}`, 'error');
					break;
				}
			}
		}

		// Extra minerals after all plans
		let totalMineralsInPlans = new Array(MineralType.all.length).fill(0); // [mineralId] => count
		g_plans.sequence.forEach(planInfo => {
			planInfo.mineralsRequired.forEach((mineralCount, mineralId) => {
				totalMineralsInPlans[mineralId] += mineralCount;
			});
		});

		let unplannedRows = plannableRows - plannedRows;
		if(unplannedRows > 0) {
			let fauxPlanCount = Math.floor(unplannedRows / rowsPerPlan);
			let fauxPlanMinerals = totalMineralsInPlans.map((x) => Math.ceil((x * g_defs.trailingMineralCountMultiplier) / fauxPlanCount));
			console.log(`faux plan minerals: ${fauxPlanMinerals}`);
			for(let fauxPlanIndex = 0; fauxPlanIndex < fauxPlanCount; ++fauxPlanIndex) {
				// Get mine rows for faux-plan
				let planLastFauxPlanRow  = Math.floor(plannedRows + (unplannedRows * (fauxPlanIndex + 1)) / fauxPlanCount);
				let planSegmentRows = [];
				while(currentPlannableRow <= planLastFauxPlanRow) {
					if(baseIndex < TileMap.bases.length && currentRow >= TileMap.bases[baseIndex].level) {
						currentRow = TileMap.bases[baseIndex].level + TileMap.bases[baseIndex].pattern.length;
						++baseIndex;
					}
					this.rowPlans[currentRow] = `F${fauxPlanIndex + 1}`;
					planSegmentRows.push(currentRow++);
					++currentPlannableRow;
				}

				console.log(`faux plan ${fauxPlanIndex} rows ${planSegmentRows[0]}..${planSegmentRows[planSegmentRows.length - 1]} minerals required: ${fauxPlanMinerals}`);

				// Fill mine segment with minerals required for faux-plan, merging some in the process
				let totalMinerals = fauxPlanMinerals.reduce((sum, value) => sum + value, 0);
				let mineralsRemaining = fauxPlanMinerals.map((x) => x);
				let allowedMineralIds = MineralType.collectibles.map((mineralType) => mineralType.id);
				while(totalMinerals > 0) {
					// pick mineral and count
					let placedMineralId = allowedMineralIds[g_rand.next16MinMax(0, allowedMineralIds.length - 1)];
					if(mineralsRemaining[placedMineralId] > 0) {
						let startPatternPos = nextPatternPos;
						let isPlaced = false;
						do {
							// pick next position from pattern
							let placePosition = fillPosPattern[nextPatternPos];
							nextPatternPos = (nextPatternPos + 1) % fillPosPattern.length;
							if(placePosition.y >= planSegmentRows.length) {
								continue;
							}

							// fill position with mineral
							let existingTile = this.tiles[placePosition.x][planSegmentRows[placePosition.y]];
							if(existingTile.mineralType == MineralType.DIRT) {
								let placedAmount = g_rand.next16MinMax(1, Math.min(mineralsRemaining[placedMineralId], 3));
								let mineralTileIndex = MineralType.all[placedMineralId].tileIndex;
								this.tiles[placePosition.x][planSegmentRows[placePosition.y]] = new Tile(mineralTileIndex + placedAmount - 1);
								totalMinerals -= placedAmount;
								mineralsRemaining[placedMineralId] -= placedAmount;
								isPlaced = true;
								break;
							}
							else if (
								mineralsRemaining[existingTile.mineralType.id] > 0 &&
								existingTile.mineralAmount < 3
							) {
								let delta = Math.min(3 - existingTile.mineralAmount, mineralsRemaining[existingTile.mineralType.id]);
								existingTile.mineralAmount += delta;
								mineralsRemaining[existingTile.mineralType.id] -= delta;
								totalMinerals -= delta;
								isPlaced = true;
								break;
							}
						} while(nextPatternPos != startPatternPos);
						if(!isPlaced) {
							addMessage(`Can't place all minerals on faux plan ${fauxPlanIndex}`, 'warning');
							break;
						}
					}
				}
			}
		}

		// Count minerals
		this.totalMineralCounts = {};
		this.totalMoney = 0;
		for(let mineralType of MineralType.all) {
			this.totalMineralCounts[mineralType.id] = 0;
		}
		for(let x = 1; x < width; ++x) {
			for(let y = 0; y < height; ++y) {
				let tile = this.tiles[x][y];
				if(tile.mineralType.isGate || tile.mineralType.isDino || tile.mineralType.isCrate) {
					this.totalMineralCounts[tile.mineralType.id] += 1;
				}
				else {
					this.totalMineralCounts[tile.mineralType.id] += tile.mineralAmount;
				}
				this.totalMoney += tile.mineralAmount * tile.mineralType.reward;
			}
		}

		this.currentMineralCounts = {};
		for(let mineralType of MineralType.all) {
			this.currentMineralCounts[mineralType.id] = this.totalMineralCounts[mineralType.id];
		}
		this.currentMoney = this.totalMoney;
	}


	isSolid(x, y) {
		return this.tiles[x][y].index >= TileIndex.DIRT_1;
	}

	static bases = [
		{
			level: 0,
			pattern: [
				[ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
				[ 1,  1,  1,  1,  1,  1,  1,  1,  1,  1],
				[ 2,  2,  2,  2,  2,  2,  2,  2,  2,  2],
				[ 3,  3,  3,  3,  3,  3,  3,  3,  3,  3],
				[ 4,  4,  4,  4,  4,  4,  4,  4,  4,  5],
				[ 6,  6,  7,  6,  6,  8,  9, 10, 11, 12],
				[13, 14, 15, 16, 17, 18, 19, 20, 21, 22],
				[23, 24, 25, 26, 27, 28, 29, 30, 31, 32],
				[34, 33, 35, 36, 37, 38, 39, 40, 41, 42],
				[63, 57, 63, 64, 63, 64, 63, 64, 63, 64],
			]
		},
		{
			level: 100,
			pattern: [
				[44, 44, 44, 44, 44, 44, 44, 44, 44, 44],
				[ 0, 43, 43, 43, 43,  1, 43,  0, 43, 43],
				[43,  1, 43, 43, 43, 43, 43, 43, 43,  2],
				[43, 43, 43, 43, 43,  3,  1, 43, 43,  1],
				[43, 43, 43, 43,  3, 43, 43, 43,  0, 43],
				[43,  1, 43, 43, 43, 43, 43, 43, 43,  2],
				[13, 14, 15, 16, 17, 18, 19, 20, 21, 22],
				[23, 24, 25, 26, 27, 28, 29, 30, 31, 32],
				[34, 35, 36, 37, 38, 33, 39, 40, 41, 42],
				[63, 64, 63, 64, 63, 57, 63, 64, 63, 64],
			]
		},
		{
			level: 209, // teleport
			pattern: [
				[44, 44, 44, 44, 44, 44, 44, 44, 44, 44],
				[ 0, 43, 43, 43, 43,  1, 43,  0, 43, 43],
				[43,  1, 43, 43, 43, 43, 43, 43, 43,  2],
				[43, 43, 43, 43, 43,  3,  1, 43, 43,  1],
				[ 4,  5, 43, 43,  6,  5, 43, 43,  0, 43],
				[ 7,  8,  1, 43,  9, 10,  2, 11, 43, 43],
				[12, 13, 43, 43, 14, 15, 16, 17, 18, 19],
				[20, 21, 22, 23, 24, 25, 26, 27, 28, 29],
				[34, 35, 36, 37, 38, 33, 39, 40, 41, 42],
				[63, 64, 63, 64, 63, 57, 63, 64, 63, 64],
			]
		},
		{
			level: 500, // gate
			pattern: [
				[44, 44, 44, 44, 44, 44, 44, 44, 44, 44],
				[ 0, 43, 43, 43, 43,  1, 43,  0, 43, 43],
				[43,  1, 43, 43, 43, 43, 43, 43, 43,  2],
				[43, 43, 43, 43, 43,  3,  1, 43, 43,  1],
				[ 4,  5, 43, 43,  6,  5, 43, 43,  0, 43],
				[ 7,  8,  1, 43,  9, 10,  2, 11, 43, 43],
				[12, 13, 43, 43, 14, 15, 16, 17, 18, 19],
				[20, 21, 22, 23, 24, 25, 26, 27, 28, 29],
				[34, 35, 36, 37, 38, 33, 39, 40, 41, 42],
				[63, 64, 63, 64, 63, 57, 63, 64, 63, 64],
			]
		},
	];

}
