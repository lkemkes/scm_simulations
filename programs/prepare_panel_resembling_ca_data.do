// This do-file defines the program prepare_panel_resembling_ca_data.


set more off

// Load dependencies
do programs/generate_covariates_ca.do
do programs/instantiate_panel.do


capture program drop prepare_panel_resembling_ca_data
program define prepare_panel_resembling_ca_data
/* Prepare a panel dataset with simulated data for using the Synthetic 
Control Method (SCM). The generated data will be based on empirical
characteristics of the California tobacco dataset. It does not contain any
treatment effect yet. */
	args n_periods trperiod n_units
	
	* Create an empty panel dataset
	instantiate_panel `n_periods' `n_units'
	tsset unit period
	
	* Generate covariates
	preserve
	tempfile ca_covariates_sim
	generate_covariates_ca `n_units'	
	save `ca_covariates_sim'
	restore
	
	* Merge covariates into empty panel dataset
	merge m:1 unit using `ca_covariates_sim.dta'
		
	* Generate time-fixed value delta_t
	gen delta_t = 25 * (period - 1)
	
	* Generate treatment dummy T
	gen T = 0
	replace T = 1 if unit == 1 & period >= `trperiod'
			
	* Generate coefficients theta_i for covariates Z_i
	gen theta1 = -20 - 2.5 * (period - 1)
	gen theta2 = 1.5 - 0.1 * (period - 1)
	local theta3 = rnormal(8.337215, 107.9198)
	local theta4 = rnormal(.0009622, 0.1545717)
	local theta5 = rnormal(-0.0062764 , 0.0519627)
	gen theta3 = `theta3'
	gen theta4 = `theta4'
	gen theta5 = `theta5'
	forvalues period = 2/`n_periods' {
		local theta3 = `theta3' + rnormal(0, 107.9198)
		local theta4 = `theta4' + rnormal(0, 0.1545717)
		local theta5 = `theta5' + rnormal(0, 0.0519627)
		replace theta3 = `theta3' if period == `period'
		replace theta4 = `theta4' if period == `period'
		replace theta5 = `theta5' if period == `period'
	}
		
	* Generate factor loadings
	local mu1 = runiform(-10, 22)
	gen mu1 = `mu1'
	forvalues i = 2/`n_units' {
		local mu1 = runiform(-10, 22)
		replace mu1 = `mu1' if unit == `i'
	}
	
	* Generate unobserved common factors belonging to factor loadings
	gen lambda1 = 1
		
	* Generate noise
	gen epsilon = rnormal(0, 8)
	
	* Generate the dependent variable without treatment
	gen Y = delta_t + ///
			theta1*Z1 + theta2*Z2 + theta3*Z3 + theta4*Z4 + theta5*Z5 + ///
			lambda1*mu1 + epsilon
			
end

set more off
prepare_panel_resembling_ca_data 31 20 39
histogram Y, ///
	title("Distribution of dependent variable in random sample") ///
	subtitle("from the defined data generation process")
graph export "graphs/histogram_sample.png", replace


*xtline Y

