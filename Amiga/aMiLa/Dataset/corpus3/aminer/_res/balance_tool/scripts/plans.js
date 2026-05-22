class PlanInfo {
	constructor(targetSum, mineralsRequired) {
		this.targetSum = targetSum;
		this.mineralsRequired = mineralsRequired; // [mineralId] => count
	}
}

class Plans {
	constructor() {
		this.mineralsCollected = new Array(MineralType.all.length).fill(0); // [mineralId] => count
		this.mineralsUnlocked = [ MineralType.SILVER.id ]; // [mineralId]
		this.index = 0;
		this.isStarted = true;
		this.isExtendedByFavor = false;
		this.isAllFinished = false;

		this.sequence = []; // [planIndex] => [planInfo]

		// First plan
		let mineralsRequired = new Array(MineralType.all.length).fill(0); // [mineralId] => count
		mineralsRequired[MineralType.SILVER.id] = 3;
		let targetSum = mineralsRequired.reduce((sum, amount, id) => sum + MineralType.all[id].reward * amount, 0);
		this.sequence.push(new PlanInfo(targetSum, mineralsRequired));

		// Generate plan based on allowed minerals and target money - no more than dirt tiles in segment
		let planCount = g_defs.maxAccolades * g_defs.maxSubAccolades;
		for(let planIndex = 1; planIndex < planCount; ++planIndex) {
			let remainingStacks = Math.min(planIndex * 5, 40);
			let mineralsAllowed = this.getAllowedMineralIdsForPlan(planIndex); // [index] => mineralId
			mineralsRequired = new Array(MineralType.all.length).fill(0); // [mineralId] => count

			while(remainingStacks > 0) {
				let mineralId = mineralsAllowed[g_rand.next16MinMax(0, mineralsAllowed.length - 1)];
				let count = g_rand.next16MinMax(1, 3);
				// console.log(`adding ${count} of mineral ${MineralType.all[mineralId].name}`)
				mineralsRequired[mineralId] += count;
				--remainingStacks;
			}
			targetSum = mineralsRequired.reduce((sum, amount, id) => sum + MineralType.all[id].reward * amount, 0);
			this.sequence.push(new PlanInfo(targetSum, mineralsRequired));
		}

		this.start();
	}

	getAllowedMineralIdsForPlan(planIndex) {
		let mineralsAllowed = [];
		if(planIndex >= g_defs.planSilver) {
			mineralsAllowed.push(MineralType.SILVER.id);
		}
		if(planIndex >= g_defs.planGold) {
			mineralsAllowed.push(MineralType.GOLD.id);
		}
		if(planIndex >= g_defs.planEmerald) {
			mineralsAllowed.push(MineralType.EMERALD.id);
		}
		if(planIndex >= g_defs.planRuby) {
			mineralsAllowed.push(MineralType.RUBY.id);
		}
		if(planIndex >= g_defs.planMoonstone) {
			mineralsAllowed.push(MineralType.MOONSTONE.id);
		}
		return mineralsAllowed;
	}

	// todo: refactor for new procgen
	reroll() {
		this.mineralsRequired = new Array(MineralType.all.length).fill(0); // [mineralId] => count
		let costRemaining = this.targetSum;
		let i = 0;
		do {
			let collectibleIndex = g_rand.next16MinMax(0, MineralType.collectibles.length - 1);
			let mineralId = MineralType.collectibles[collectibleIndex].id;
			if(this.mineralsUnlocked.indexOf(mineralId) != -1) {
				let reward = MineralType.all[mineralId].reward;
				let count = g_rand.next16Max(Math.floor((costRemaining + reward - 1) / reward));

				this.mineralsRequired[mineralId] += count;
				costRemaining -= count * reward;
				console.log(`reward ${reward}, count ${count}, remaining: ${costRemaining}`);
			}
			if(++i > 100) {
				break;
			}
		} while(costRemaining > 0);
	}

	next() {
		if(this.index < this.sequence.length - 1) {
			++this.index;
			this.start();
		}
		else {
			this.isAllFinished = true;
		}
	}

	start() {
		this.mineralsCollected = new Array(MineralType.all.length).fill(0); // [mineralId] => count
		this.timeRemaining = g_defs.timeInDay * g_defs.daysPerPlan; // Add for nice division into 30 days
		this.wasWarning = false;
	}

	getCurrentPlanInfo() {
		return this.sequence[this.index];
	}

	isCompleted() {
		for(let i = 0; i < MineralType.all.length; ++i) {
			if(this.getCurrentPlanInfo().mineralsRequired[i] != this.mineralsCollected[i]) {
				return false;
			}
		}
		return true;
	}

	tryProceed() {
		if(this.isCompleted() && !this.isAllFinished) {
			this.next();
			return true;
		}
		return false;
	}

	elapseTime(timeDelta) {
		if(this.isAllFinished) {
			return;
		}

		this.timeRemaining -= timeDelta;
		if(this.timeRemaining <= 0) {
			g_vehicle.addRebuke();
			this.timeRemaining = 14 * g_defs.timeInDay;
		}
		else if(this.timeRemaining <= 3 * g_defs.timeInDay && !this.wasWarning) {
			addMessage('Plan due soon', 'warning');
			this.wasWarning = true;
		}
	}

	extendTime(timeDelta) {
		this.timeRemaining += timeDelta;
		if(this.timeRemaining > 3 * g_defs.timeInDay) {
			this.wasWarning = false;
		}
	}
}
