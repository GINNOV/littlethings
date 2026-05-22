let g_defs = null;
let g_rand = null;
let g_tileMap = null;
let g_vehicle = null;
let g_plans = null;

function reloadGame() {
	clearMessages();
	g_defs = new Defs();
	g_rand = new rand(g_defs.seed1, g_defs.seed2);
	g_plans = new Plans();
	g_tileMap = new TileMap(11, 1024);
	g_vehicle = new Vehicle();

	drawTiles(g_tileMap);
	updateVehicleStats();
	updateMineralStats();
	updateTotalMoneyStats();
	updateOfficeStats();
	updateWarehouse();
	generateBlackMarketTable();

	addMessage('Started new game', 'success');
}

function onCellTryExcavate(evt) {
	evt.preventDefault();
	if(!(evt.buttons & 1) || g_vehicle.isGameOver()) {
		return;
	}

	let cell = evt.target;
	let posX = parseInt(cell.dataset.posX);
	let posY = parseInt(cell.dataset.posY);

	if(g_vehicle.tryExcavate(posX, posY)) {
		console.log(`excavated at ${posX},${posY}`);

		// Update view
		cell.setAttribute('class', '');
		cell.classList.add('tile_bg');
		cell.textContent = '';

		updateVehicleStats();
		updateMineralStats();
		updateOfficeStats();
	}
}

function updateVehicleStats() {
	document.querySelector('#vehicle_hull_mk').textContent = g_vehicle.hullMk + 1;
	document.querySelector('#vehicle_hull_curr').textContent = g_vehicle.hullCurr;
	document.querySelector('#vehicle_hull_max').textContent = g_vehicle.hullMax;
	document.querySelector('#vehicle_upgrade_hull_cost').textContent = g_vehicle.hullMk < g_defs.upgradeCosts.length ? g_defs.upgradeCosts[g_vehicle.hullMk] : 0;

	document.querySelector('#vehicle_cargo_mk').textContent = g_vehicle.cargoMk + 1;
	document.querySelector('#vehicle_cargo_curr').textContent = g_vehicle.cargoCurr;
	document.querySelector('#vehicle_cargo_max').textContent = g_vehicle.cargoMax;
	document.querySelector('#vehicle_upgrade_cargo_cost').textContent = g_vehicle.cargoMk < g_defs.upgradeCosts.length ? g_defs.upgradeCosts[g_vehicle.cargoMk] : 0;

	document.querySelector('#vehicle_drill_mk').textContent = g_vehicle.drillMk + 1;
	document.querySelector('#vehicle_drill_curr').textContent = g_vehicle.drillCurr;
	document.querySelector('#vehicle_drill_max').textContent = g_vehicle.drillMax;
	document.querySelector('#vehicle_upgrade_drill_cost').textContent = g_vehicle.drillMk < g_defs.upgradeCosts.length ? g_defs.upgradeCosts[g_vehicle.drillMk] : 0;

	document.querySelector('#vehicle_money').textContent = g_vehicle.money;
	document.querySelector('#vehicle_money_spent_on_restock').textContent = g_vehicle.moneySpentOnRestock;
}

function setMineCellEvents(cell) {
	cell.addEventListener('mousedown', onCellTryExcavate);
	cell.addEventListener('mousemove', onCellTryExcavate);
}

function updateWarehouse() {
	for(let mineralType of MineralType.collectibles) {
		let name = mineralType.name;
		document.querySelector(`#stock_${name}`).textContent = g_vehicle.stock[mineralType.id];
		document.querySelector(`#sold_${name}`).textContent = g_vehicle.sold[mineralType.id];
		document.querySelector(`#plan_${name}_spent`).textContent = g_plans.mineralsCollected[mineralType.id];
		document.querySelector(`#plan_${name}_required`).textContent = g_plans.getCurrentPlanInfo().mineralsRequired[mineralType.id];
	}
}

function generateBlackMarketTable() {
	let table = document.querySelector('#black_market_goods');
	table.innerHTML = '';

	let tr = document.createElement('tr');
	let cell = document.createElement('th');
	cell.textContent = 'buy\\sell';
	tr.appendChild(cell);
	for(let mineralType of MineralType.collectibles) {
		cell = document.createElement('th');
		cell.textContent = mineralType.name;
		tr.appendChild(cell);
	}
	table.appendChild(tr);

	let mineralBuyIndex = 0;
	for(let mineralTypeBuy of MineralType.collectibles) {
		tr = document.createElement('tr');
		cell = document.createElement('th');
		cell.textContent = mineralTypeBuy.name;
		tr.appendChild(cell);

		let mineralSellIndex = 0;
		for(let mineralTypeSell of MineralType.collectibles) {
			cell = document.createElement('td');
			if(mineralSellIndex == mineralBuyIndex) {
				cell.innerHTML = '-';
			}
			else {
				let button = document.createElement('button');
				let delta = mineralBuyIndex - mineralSellIndex;
				let sellAmount = delta > 0 ? 4 * (delta) : 1;
				let buyAmount = 1;
				button.innerHTML = `${buyAmount} for ${sellAmount}`;
				button.dataset.mineralSellId = mineralTypeSell.id;
				button.dataset.mineralBuyId = mineralTypeBuy.id;
				button.dataset.sellAmount = sellAmount;
				button.dataset.buyAmount = buyAmount;
				button.addEventListener('click', onBlackMarketBuyClicked);
				cell.appendChild(button);
			}
			tr.appendChild(cell);
			++mineralSellIndex;
		}

		table.appendChild(tr);
		++mineralBuyIndex;
	}
}

function drawTiles(tileMap) {
	let table = document.querySelector('#mine_preview');
	table.innerHTML = '';

	let sizeX = tileMap.tiles.length;
	let sizeY = tileMap.tiles[0].length;

	for(let y = 0; y < sizeY; ++y) {
		let tr = document.createElement('tr');
		for(let x = 1; x < sizeX; ++x) { // skip dummy column on the left
			let td = document.createElement('td');
			if(tileMap.tiles[x][y].mineralType == MineralType.DIRT) {
				td.classList.add('tile_dirt');
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.SILVER) {
				td.classList.add('tile_silver');
				td.textContent = 'S' + tileMap.tiles[x][y].mineralAmount;
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.GOLD) {
				td.classList.add('tile_gold');
				td.textContent = 'G' + tileMap.tiles[x][y].mineralAmount;
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.EMERALD) {
				td.classList.add('tile_emerald');
				td.textContent = 'E' + tileMap.tiles[x][y].mineralAmount;
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.RUBY) {
				td.classList.add('tile_ruby');
				td.textContent = 'R' + tileMap.tiles[x][y].mineralAmount;
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.MOONSTONE) {
				td.classList.add('tile_moonstone');
				td.textContent = 'M' + tileMap.tiles[x][y].mineralAmount;
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.AIR) {
				td.classList.add('tile_bg');
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.MAGMA) {
				td.classList.add('tile_magma');
				td.textContent = '🔥';
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.ROCK) {
				td.classList.add('tile_stone');
				td.textContent = 'R';
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.BONE) {
				td.classList.add('tile_bone');
				td.textContent = 'B';
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.GATE) {
				td.classList.add('tile_gate');
				td.textContent = 'G';
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.CRATE) {
				td.classList.add('tile_crate');
				td.textContent = 'C';
			}
			else if(tileMap.tiles[x][y].mineralType == MineralType.CAPSULE) {
				td.classList.add('tile_capsule');
				td.textContent = 'J';
			}
			else {
				td.textContent = tileMap.tiles[x][y].index;
			}
			if(tileMap.isSolid(x, y)) {
				let colorHex = GroundLayer.getLayerAt(y).colorHex;
				td.style = `background-color: ${colorHex};`;
			}

			td.dataset.posX = x;
			td.dataset.posY = y;
			setMineCellEvents(td);

			tr.appendChild(td);
		}

		let tdRowIndex = document.createElement('td');
		tdRowIndex.textContent = y;
		tdRowIndex.classList.add('row_index');
		tr.appendChild(tdRowIndex);

		let tdLayerName = document.createElement('td');
		tdLayerName.textContent = GroundLayer.getLayerAt(y).name;
		tdLayerName.classList.add('row_index');
		tr.appendChild(tdLayerName);

		let tdPlanIndex = document.createElement('td');
		tdPlanIndex.textContent = tileMap.rowPlans[y];
		tdPlanIndex.classList.add('row_index');
		tr.appendChild(tdPlanIndex);

		table.appendChild(tr);
	}
}

function onGameReloadClicked() {
	reloadGame();
}

function onBlackMarketBuyClicked(evt) {
	let button = evt.target;
	let mineralSellId = parseInt(button.dataset.mineralSellId);
	let mineralBuyId = parseInt(button.dataset.mineralBuyId);
	let sellAmount = parseInt(button.dataset.sellAmount);
	let buyAmount = parseInt(button.dataset.buyAmount);

	let mineralSellType = MineralType.all[mineralSellId];
	let mineralBuyType = MineralType.all[mineralBuyId];

	g_vehicle.tryBlackMarketExchange(mineralSellType, sellAmount, mineralBuyType, buyAmount);
	updateWarehouse();
}

function onSellClicked(mineralType, amount) {
	if(g_vehicle.isGameOver()) {
		return;
	}

	g_vehicle.trySell(mineralType, amount);
	updateVehicleStats();
	updateWarehouse();
}

function onResetEndingClicked() {
	g_vehicle.ending = Ending.NONE;
	updateOfficeStats();
}

function onSellAllClicked() {
	if(g_vehicle.isGameOver()) {
		return;
	}

	for(let mineralType of MineralType.all) {
		g_vehicle.trySell(mineralType, 1000000);
	}
	updateVehicleStats();
	updateWarehouse();
}

function onPlanFillClicked(mineralType, amount) {
	if(g_vehicle.isGameOver()) {
		return;
	}

	g_vehicle.tryFillPlan(mineralType, amount);
	updateVehicleStats();
	updateWarehouse();
	updateOfficeStats();
}

function onFillAllPlanClicked() {
	if(g_vehicle.isGameOver()) {
		return;
	}

	for(let mineralType of MineralType.all) {
		let isPlanCompleted = g_vehicle.tryFillPlan(mineralType, 1000000);
		if(isPlanCompleted) {
			break;
		}
	}
	updateVehicleStats();
	updateWarehouse();
	updateOfficeStats();
}

function onRestockClicked(evt) {
	if(g_vehicle.isGameOver()) {
		return;
	}

	g_vehicle.restock();

	if(g_vehicle.isGateQuestioningPending) {
		let isReporting = confirm(`Report found gate elements?\nIf yes, reduces heat by ${g_defs.heatFromGate}.\nIf not and caught on lie, commissar will know + rebuke`);
		g_vehicle.answerGateQuestioning(isReporting);
	}
	if(g_vehicle.minerIsCrateQuestioningPending) {
		let isReporting = confirm(`Report found crates?\nIf yes, reduces heat by ${g_defs.heatFromCrateQuestioning} and commissar confiscates crates.\nIf not and caught on lie, commissar will confiscate crates`);
		g_vehicle.answerCrateQuestioning(isReporting);
	}

	updateVehicleStats();
	updateOfficeStats();
	updateWarehouse();
}

function onAccountingClicked() {
	if(g_vehicle.isGameOver()) {
		return;
	}

	g_vehicle.doAccounting();
	updateVehicleStats();
	updateWarehouse();
	updateOfficeStats();
}

function onBribeClicked() {
	if(g_vehicle.isGameOver()) {
		return;
	}

	g_vehicle.doBribe();
	updateVehicleStats();
	updateWarehouse();
	updateOfficeStats();
}

function onReportAgentClicked() {
	g_vehicle.tryReportAgent();
	updateOfficeStats();
}

function onSellCrateClicked() {
	g_vehicle.trySellCrate();
	updateOfficeStats();
	updateVehicleStats();
}

function onEscapeWestClicked() {
	g_vehicle.tryEscapeWest();
	updateOfficeStats();
}

function onOpenCapsuleClicked() {
	g_vehicle.tryOpenCapsule();
	updateOfficeStats();
}

function onTeleportWestClicked() {
	g_vehicle.tryTeleportWest();
	updateOfficeStats();
}

function onReportBaseClicked() {
	g_vehicle.tryReportBase();
	updateOfficeStats();
}

function updateTotalMoneyStats() {
	let planCosts = g_plans.sequence.map((planInfo) => planInfo.targetSum);
	let totalPlanCost = planCosts.reduce((sum, planCost) => sum + planCost, 0);
	let totalMineralsInPlans = new Array(MineralType.all.length).fill(0); // [mineralId] => count
	g_plans.sequence.forEach(planInfo => {
		planInfo.mineralsRequired.forEach((mineralCount, mineralId) => {
			totalMineralsInPlans[mineralId] += mineralCount;
		});
	});

	document.querySelector('#upgrade_cost_total').textContent = g_defs.upgradeCosts.reduce((sum, value) => sum + value, 0) * 3;
	document.querySelector('#plan_cost_total').textContent = totalPlanCost;
	document.querySelector('#separate_plan_costs').textContent = planCosts.join(', ');
	for (const mineralType of MineralType.collectibles) {
		document.querySelector(`#plan_total_${mineralType.name}`).textContent = totalMineralsInPlans[mineralType.id];
		document.querySelector(`#plan_margin_${mineralType.name}`).textContent = g_tileMap.totalMineralCounts[mineralType.id] - totalMineralsInPlans[mineralType.id];
	}
}

function updateMineralStats() {
	for(let mineralType of MineralType.statables) {
		let name = mineralType.name;
		document.querySelector(`#minerals_${name}_total`).textContent = g_tileMap.totalMineralCounts[mineralType.id];
		document.querySelector(`#minerals_${name}`).textContent = g_tileMap.currentMineralCounts[mineralType.id];
	}
	document.querySelector('#minerals_money').textContent = g_tileMap.currentMoney;
	document.querySelector('#minerals_money_total').textContent = g_tileMap.totalMoney;
}

function updateOfficeStats() {
	document.querySelector('#office_ending').textContent = g_vehicle.ending.description;
	document.querySelector('#office_ending').className = g_vehicle.ending.className;

	document.querySelector('#office_dino_quest_state').textContent = g_vehicle.dinoQuestState.description;
	document.querySelector('#office_dino_quest_state').className = g_vehicle.dinoQuestState.className;
	document.querySelector('#office_dino_found_bones').textContent = g_vehicle.foundBones;

	document.querySelector('#office_gate_quest_state').textContent = g_vehicle.gateQuestState.description;
	document.querySelector('#office_gate_quest_state').className = g_vehicle.gateQuestState.className;
	document.querySelector('#office_gate_reported').textContent = g_vehicle.isGateReported ? '✓' : '✗';
	document.querySelector('#office_gate_found_gates').textContent = g_vehicle.foundGates;

	document.querySelector('#office_miner_held_crates').textContent = g_vehicle.minerHeldCrates;
	document.querySelector('#office_miner_spent_crates').textContent = g_vehicle.minerSpentCrates;
	document.querySelector('#office_miner_sold_crates').textContent = g_vehicle.minerSoldCrates;
	document.querySelector('#office_miner_is_base_reported').textContent = g_vehicle.minerIsBaseReported ? '✓' : '✗';
	document.querySelector('#office_miner_is_agent_reported').textContent = g_vehicle.minerIsAgentReported ? '✓' : '✗';
	document.querySelector('#office_miner_is_jay_found').textContent = g_vehicle.minerIsJayFound ? '✓' : '✗';

	document.querySelector('#plan_index').textContent = g_plans.index + 1;
	document.querySelector('#plan_started').textContent = g_plans.isStarted ? '✓' : '✗';
	document.querySelector('#plan_extended').textContent = g_plans.isExtendedByFavor ? '✓' : '✗';
	document.querySelector('#plan_time_remaining').textContent = g_plans.timeRemaining;
	document.querySelector('#plan_time_remaining_days').textContent = (g_plans.timeRemaining / g_defs.timeInDay).toFixed(2);
	document.querySelector('#plan_unlocked_minerals').textContent = g_plans.mineralsUnlocked.map((x) => MineralType.all[x].name).join(', ');
	document.querySelector('#office_rebukes_curr').textContent = g_vehicle.rebukes;
	document.querySelector('#office_rebukes_max').textContent = g_defs.maxRebukes;
	document.querySelector('#office_accolades_curr').textContent = g_vehicle.accolades;
	document.querySelector('#office_accolades_max').textContent = g_defs.maxAccolades;
	document.querySelector('#office_accolades_progress_curr').textContent = g_vehicle.subAccolades;
	document.querySelector('#office_accolades_progress_max').textContent = g_defs.maxSubAccolades;
	document.querySelector('#office_heat').textContent = g_vehicle.heat;
	document.querySelector('#office_bribe_cost').textContent = g_vehicle.getBribeCost();
}

function onUpgradeClicked(part) {
	g_vehicle.tryUpgradePart(part);
	updateVehicleStats();
}

function clearMessages() {
	document.querySelector('#messages_container').innerHTML = '';
}

function onMessageCloseClicked() {
	let msgDiv = this.parentNode;
	let container = msgDiv.parentNode;
	container.removeChild(msgDiv);
}

function addMessage(text, className) {
	let msgDiv = document.createElement('div');
	msgDiv.classList.add('message');
	msgDiv.classList.add(className);
	msgDiv.textContent = 'Incoming message: ' + text;
	let msgBtn = document.createElement('button');
	msgBtn.textContent = 'Dismiss';
	msgBtn.className = 'btn_large';
	msgBtn.addEventListener('click', onMessageCloseClicked);
	msgDiv.appendChild(msgBtn);
	document.querySelector('#messages_container').appendChild(msgDiv);
}

window.addEventListener('load', function() {
	document.querySelector('#btn_vehicle_restock').addEventListener('click', onRestockClicked);

	document.querySelector('#btn_accounting').addEventListener('click', function() {onAccountingClicked(); });
	document.querySelector('#btn_bribe').addEventListener('click', function() {onBribeClicked(); });
	for(let mineralType of MineralType.collectibles) {
		let name = mineralType.name;
		document.querySelector(`#${name}_price`).textContent = mineralType.reward;
		document.querySelector(`#btn_${name}_sell_1`).addEventListener('click', function() {onSellClicked(mineralType, 1); });
		document.querySelector(`#btn_${name}_sell_10`).addEventListener('click', function() {onSellClicked(mineralType, 10); });
		document.querySelector(`#btn_${name}_plan_1`).addEventListener('click', function() {onPlanFillClicked(mineralType, 1); });
		document.querySelector(`#btn_${name}_plan_fill`).addEventListener('click', function() {onPlanFillClicked(mineralType, 1000000); });
	}
	document.querySelector('#btn_sell_all').addEventListener('click', function() {onSellAllClicked(); });
	document.querySelector('#btn_fill_plan').addEventListener('click', function() {onFillAllPlanClicked(); });
	document.querySelector('#btn_game_reload').addEventListener('click', function() {onGameReloadClicked(); });
	document.querySelector('#vehicle_upgrade_hull').addEventListener('click', function() { onUpgradeClicked('hull'); })
	document.querySelector('#vehicle_upgrade_drill').addEventListener('click', function() { onUpgradeClicked('drill'); })
	document.querySelector('#vehicle_upgrade_cargo').addEventListener('click', function() { onUpgradeClicked('cargo'); })
	document.querySelector('#ending_reset').addEventListener('click', function() { onResetEndingClicked(); })

	document.querySelector('#btn_sell_crate').addEventListener('click', function() { onSellCrateClicked(); })
	document.querySelector('#btn_escape_west').addEventListener('click', function() { onEscapeWestClicked(); })
	document.querySelector('#btn_report_agent').addEventListener('click', function() { onReportAgentClicked(); })
	document.querySelector('#btn_open_capsule').addEventListener('click', function() { onOpenCapsuleClicked(); })
	document.querySelector('#btn_teleport_west').addEventListener('click', function() { onTeleportWestClicked(); })
	document.querySelector('#btn_report_base').addEventListener('click', function() { onReportBaseClicked(); })

	reloadGame();
});
