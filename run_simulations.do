// This do-file runs the simulations.
set more off

// Load dependencies:
do programs/prepare_panel_scm.do
do programs/calculate_rmspe.do
do programs/conduct_scm.do
do programs/scm_simulation.do


// Conduct simulations:
local treatment_effects 0 50
foreach a of local treatment_effects {
	
	simulate p_value_rmspe_ratio = e(p_value_rspme_ratio) ///
		 p_value_avg_effect = e(p_value_avg_effect) ///
		 avg_effect_treated_unit = e(avg_effect_treated_unit) ///
		 count_rspme_ratio_higher = e(count_rspme_ratio_higher) ///
		 count_avg_deviation_higher = e(count_avg_deviation_higher), ///
		 reps(2): scm_simulation 21 30 `a' constant
	
	save "simulations/simul_`a'_january", replace
}

count if p_value_rmspe_ratio <= 0.05
