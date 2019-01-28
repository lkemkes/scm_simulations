// This do-file defines the program prepare_panel_resembling_ca_data.
set more off

// Load dependencies
do programs/instantiate_panel.do
do programs/generate_covariates_ca.do


capture program drop prepare_panel_resembling_ca_data
program define prepare_panel_resembling_ca_data
/* Prepare a panel dataset with simulated data for using the Synthetic 
Control Method (SCM). The generated data will be based on empirical
characteristics of the California tobacco dataset. */
	args n_periods n_units trperiod
	
	* Create an empty panel dataset
	instantiate_panel `n_periods' `n_units'
	
	* Generate covariates
	preserve
	tempfile ca_covariates_sim
	generate_covariates_ca `n_units'	
	save `ca_covariates_sim'
	restore
	
	* Merge covariates into empty panel dataset
	merge m:1 unit using `ca_covariates_sim.dta'
	
	* Generate time-fixed value delta_t
	gen delta_t = 2 * period
	
	* Generate treatment effect variable T
	gen T = 0
	replace T = 1 if unit == 1 & period >= `trperiod'
	
	* Generate coefficients theta_i for covariates Z_i
	gen theta1 = 1 if period == 1
	gen theta2 = 1 if period == 1
	gen theta3 = 1 if period == 1
	gen theta4 = 1 if period == 1
	gen theta5 = 1 if period == 1
	forvalues t = 2/`n_periods' {
		local theta1 = rnormal(1, 1)
		local theta2 = rnormal(1, 1)
		local theta3 = rnormal(1, 1)
		local theta4 = rnormal(1, 1)
		local theta5 = rnormal(1, 1)
		replace theta1 = `theta1'
		replace theta2 = `theta2'
		replace theta3 = `theta3'
		replace theta4 = `theta4'
		replace theta5 = `theta5'
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
	
	* Generate the treatment effect alpha_it
	merge m:1 period using "alpha_it.dta", nogen
	replace alpha_it = 0 if unit != 1
	replace alpha_it = 0 if period < 20
	
	* Generate the true dependent variable
	gen Y = delta_t + alpha_it*T + ///
			theta1*Z1 + theta2*Z2 + theta3*Z3 + theta4*Z4 + theta5*Z5 + ///
			lambda1*mu1 + rnormal(0, 1)
	
	tsset unit period
	
end

prepare_panel_resembling_ca_data 31 39 20
