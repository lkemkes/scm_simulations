// This do-file defines the program add_treatment_effect.


set more off

// Load dependencies
*do programs/prepare_panel_resembling_ca_data.do


capture program drop add_treatment_effect
program define add_treatment_effect
/* Add a treatment effect to unit 1 from trperiod onwards. The treatment effect 
is a linear function from 0 to treatment_in_percent times the mean of Y.*/
	args n_periods trperiod treatment_in_percent
	
	* Calculate values for treatment effect
	qui sum Y if unit == 1
	local mean_y = r(mean)

	cap drop alpha_it
	gen alpha_it = 0
	replace alpha_it = (period - `trperiod' + 1) / ///
						(`n_periods' - `trperiod' + 1) * ///
						`mean_y' * `treatment_in_percent' / 100 ///
						if period >= `trperiod' & unit == 1
	di "Created treatment effect"
	
	* Add treatment effect to the dependent variable
	replace Y = Y + alpha_it
		
end


prepare_panel_resembling_ca_data 31 20 39
add_treatment_effect 31 20 100
