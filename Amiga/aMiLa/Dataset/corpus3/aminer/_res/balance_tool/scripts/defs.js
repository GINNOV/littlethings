class Defs {
	constructor() {
		this.timeInDay = 140;
		this.minePercentForPlans = parseInt(document.querySelector('[name=defs_mine_percent_for_plans]').value) / 100;
		this.daysPerPlan = parseInt(document.querySelector('[name=defs_days_per_plan]').value);
		this.maxRebukes = parseInt(document.querySelector('[name=defs_rebukes]').value);
		this.maxSubAccolades = parseInt(document.querySelector('[name=defs_plans_per_accoldade]').value);
		this.maxAccolades = parseInt(document.querySelector('[name=defs_accolades]').value);
		this.extraPlanMoney = parseInt(document.querySelector('[name=extra_plan_money]').value);
		this.hullPrice = parseInt(document.querySelector('[name=defs_hull_price]').value);
		this.drillUnitPrice = parseInt(document.querySelector('[name=defs_drill_unit_price]').value);
		this.dillInUnit = parseInt(document.querySelector('[name=defs_drill_amount_in_unit]').value);
		this.trailingMineralCountMultiplier = parseFloat(document.querySelector('[name=trailing_mineral_count_multiplier]').value);
		this.seed1 = parseInt(document.querySelector('[name=defs_seed1]').value);
		this.seed2 = parseInt(document.querySelector('[name=defs_seed2]').value);
		this.upgradeCosts = document.querySelector('[name=defs_upgrade_costs]').value.split(',').map((x) => parseInt(x));
		this.hullBase = 50;
		this.hullAddPerLevel = 20;
		this.drillBase = 1000;
		this.drillAddPerLevel = 250;
		this.cargoBase = 20;
		this.cargoAddPerLevel = 10;
		this.damageAfterRestock = 10;

		this.bribeBaseCost = parseInt(document.querySelector('[name=defs_bribe_base_cost]').value);
		this.bribeCostMultiplier = parseFloat(document.querySelector('[name=defs_bribe_cost_multiplier]').value);
		this.heatAddPerAccounting = parseInt(document.querySelector('[name=defs_heat_add_accounting]').value);
		this.heatRemovedByPlan = parseInt(document.querySelector('[name=defs_heat_remove_plan]').value);

		this.planSilver = 0;
		this.planGold = 10;
		this.planEmerald = 30;
		this.planRuby = 40;
		this.planMoonstone = 20;

		this.dinoDepths = document.querySelector('[name=defs_dino_depths]').value.split(',').map((x) => parseInt(x));

		this.gateDepths = document.querySelector('[name=defs_gate_depths]').value.split(',').map((x) => parseInt(x));
		this.heatFromGate = parseInt(document.querySelector('[name=defs_heat_from_gate]').value);

		this.crateDepths = document.querySelector('[name=defs_crate_depths]').value.split(',').map((x) => parseInt(x));
		this.crateCapsuleDepth = parseInt(document.querySelector('[name=defs_crate_capsule_depth]').value);
		this.crateTeleportCost = parseInt(document.querySelector('[name=defs_crate_teleport_cost]').value);
		this.crateCapsuleCost = parseInt(document.querySelector('[name=defs_crate_capsule_cost]').value);
		this.crateSellReward = parseInt(document.querySelector('[name=defs_crate_sell_reward]').value);
		this.crateSellBeforeEscape = parseInt(document.querySelector('[name=defs_crate_sell_before_escape]').value);
		this.escapeHeat = parseInt(document.querySelector('[name=defs_escape_heat]').value);
		this.crateCountForInterrogation = parseInt(document.querySelector('[name=defs_crate_count_for_interrogation]').value);
		this.heatFromCrateQuestioning = parseInt(document.querySelector('[name=defs_heat_from_crate_questioning]').value);
	}
}
