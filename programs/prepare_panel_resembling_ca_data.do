// This do-file defines the program prepare_panel_resembling_ca_data.


// Load dependencies
do programs/instantiate_panel.do
do analyze_ca_data.do

capture program drop prepare_panel_resembling_ca_data
program define prepare_panel_resembling_ca_data
/* Prepare a panel dataset with simulated data for using the Synthetic 
Control Method (SCM). The generated data will be based on empirical
characteristics of the California tobacco dataset. */
	args n_periods n_units trperiod treatment_effect treatment_effect_type
	
	instantiate_panel `n_periods' `n_units'
	
	* Generate time-fixed value delta_t
	gen delta_t = 2 * period
	
	* Generate treatment effect variable T
	gen T = 0
	replace T = 1 if unit == 1 & period >= `trperiod'
	
	* Generate covariates Z_i that are constant over time
	forvalues i = 1/`n_units' {
		local Z1 = rnormal(50, 2)
		local Z2 = rnormal(20, 1)
		
		* Generate Z1 and Z2 if they don't exist yet
		capture gen Z1 = `Z1'
		capture gen Z2 = `Z2'
		
		* Replace Z1 and Z2 if they already exist
		if _rc != 0 {
			replace Z1 = `Z1' if unit == `i'
			replace Z2 = `Z2' if unit == `i'
		}
	}
	
	* Generate coefficients theta_i for covariates Z_i
	gen theta1 = 1 if period == 1
	gen theta2 = 3 if period == 1
	forvalues t = 2/`n_periods' {
		local theta1 = rnormal(1, 1)
		local theta2 = rnormal(3, 1)
		replace theta1 = `theta1'
		replace theta2 = `theta2'
	}
	
	* Generate factor loadings
	forvalues i = 1/`n_units' {
		local mu1 = rnormal(10, 2)
		
		capture gen mu1 = `mu1'
		if _rc != 0 {
			replace mu1 = `mu1' if unit == `i'
		}
	}
	
	* Generate unobserved common factors belonging to factor loadings
	gen lambda1 = 0.5 * period
	
	* Generate the true dependent variable
	if "`treatment_effect_type'" == "linear_in_time" {
		gen Y = delta_t + `treatment_effect'*(period - `trperiod')*T + ///
			theta1*Z1 + theta2*Z2 + lambda1*mu1 + rnormal(0, 1)
	}
	else if "`treatment_effect_type'" == "constant" {
		gen Y = delta_t + `treatment_effect'*T + ///
			theta1*Z1 + theta2*Z2 + lambda1*mu1 + rnormal(0, 1)
	}
	
	* TODO: else { raise an error }
	
	tsset unit period
	
end
