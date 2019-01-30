// This do-file defines the program scm_simulation.

set more off

// Load dependencies
do programs/add_treatment_effect.do
do programs/conduct_scm.do

capture program drop scm_simulation
program define scm_simulation, eclass
	
	args n_periods trperiod n_units treatment_percent
	
	di "Treatment Period:"
	di `trperiod'
	
	prepare_panel_resembling_ca_data `n_periods' `trperiod' `n_units'
	add_treatment_effect `n_periods' `trperiod' "`treatment_percent'"
	
	* SCM
	di "Starting SCM now..."
	conduct_scm "Y" "Z1 Z2 Z3 Z4 Z5" 1 `trperiod'
	di "Finished SCM."
	local ratio_1 = e(rmspe_posttreatment) / e(rmspe_pretreatment)
	local avg_deviation_1 = e(avg_deviation_from_sc_post)
	
	* Placebos
	local count_rspme_ratio_higher = 0
	forvalues i = 2/`n_units' {
		conduct_scm "Y" "Z1 Z2 Z3 Z4 Z5" `i' `trperiod'
		if e(rmspe_posttreatment) / e(rmspe_pretreatment) > `ratio_1' {
			local count_rspme_ratio_higher = `count_rspme_ratio_higher' + 1
		}
	}
		
	ereturn scalar p_value_rspme_ratio = ///
		(1 + `count_rspme_ratio_higher') / `n_units'
	ereturn scalar avg_effect_treated_unit = `avg_deviation_1'
	ereturn scalar count_rspme_ratio_higher = `count_rspme_ratio_higher'

	
end
