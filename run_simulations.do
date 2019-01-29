// This do-file runs the simulations.
set more off


// Define parameters:
local n_reps 1000
local n_units 39
local n_periods 31
local trperiod 20
local seed 42


// Load dependencies:
do programs/scm_simulation.do
do programs/calculate_rmspe.do


// Conduct simulations:
local treatment "yes no"
foreach treat of local treatment {

	simulate p_value_rmspe_ratio = e(p_value_rspme_ratio) ///
		 p_value_avg_effect = e(p_value_avg_effect) ///
		 avg_effect_treated_unit = e(avg_effect_treated_unit) ///
		 count_rspme_ratio_higher = e(count_rspme_ratio_higher) ///
		 count_avg_deviation_higher = e(count_avg_deviation_higher), ///
		 seed(`seed') ///
		 reps(`n_reps'): scm_simulation `n_periods' `trperiod' `n_units' `treat'
		 
	save "simulations/simulations_treat=`treat'", replace

}

count if p_value_rmspe_ratio <= 0.05
