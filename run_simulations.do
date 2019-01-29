// This do-file runs the simulations.
set more off


// Define parameters:
local n_reps 1
local n_units 39
local n_periods 31
local trperiod 20
local seed 42


// Load dependencies:
do programs/scm_simulation.do
do programs/calculate_rmspe.do


// Conduct simulations:
local treatment_in_percent 0 10 50 100
foreach treat of local treatment_in_percent {

	simulate p_value_rmspe_ratio = e(p_value_rspme_ratio) ///
		 avg_effect_treated_unit = e(avg_effect_treated_unit) ///
		 count_rspme_ratio_higher = e(count_rspme_ratio_higher), ///
		 seed(`seed') ///
		 reps(`n_reps'): scm_simulation `n_periods' `trperiod' `n_units' `treat'
		 
	save "simulations/simulations_treatment=`treat'", replace

}
