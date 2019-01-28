// This do-file runs the simulations.
set more off


// Define parameters:
local n_reps 1
local n_units 39
local n_periods 20
local seed 42

// Load dependencies:
do programs/scm_simulation.do


// Conduct simulations:
local treatment_effects 0 50
foreach a of local treatment_effects {
	
	simulate p_value_rmspe_ratio = e(p_value_rspme_ratio) ///
		 p_value_avg_effect = e(p_value_avg_effect) ///
		 avg_effect_treated_unit = e(avg_effect_treated_unit) ///
		 count_rspme_ratio_higher = e(count_rspme_ratio_higher) ///
		 count_avg_deviation_higher = e(count_avg_deviation_higher), ///
		 seed(`seed') ///
		 reps(`n_reps'): scm_simulation `n_periods' `n_units' `a' constant
		 
	save "simulations/simul_`a'_january", replace
}

count if p_value_rmspe_ratio <= 0.05
