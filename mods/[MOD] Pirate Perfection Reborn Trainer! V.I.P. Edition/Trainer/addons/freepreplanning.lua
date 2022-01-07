--Free and unlimited preplanning by baldwin
--Purpose: preplanning elements are now free and also you no longer need favors to purchase them

backuper:backup('MoneyManager.get_preplanning_type_cost')
function
	MoneyManager.get_preplanning_type_cost()
	return 0
end

backuper:backup('MoneyManager.can_afford_preplanning_type')
function
	MoneyManager.can_afford_preplanning_type()
	return true
end

backuper:backup('MoneyManager.get_preplanning_votes_cost')
function MoneyManager.get_preplanning_votes_cost()
	return 0
end

backuper:backup('PrePlanningManager.get_type_budget_cost')
function PrePlanningManager.get_type_budget_cost()
	return 0
end

backuper:backup('PrePlanningManager.can_reserve_mission_element')
function PrePlanningManager.can_reserve_mission_element()
	return true
end

backuper:backup('PrePlanningManager.can_vote_on_plan')
function PrePlanningManager.can_vote_on_plan()
	return true
end