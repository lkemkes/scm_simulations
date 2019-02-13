// This do-file analyzes the simulations' results.

set more off

local treatment_sizes "0 20 40 60"


foreach treatment_size in `treatment_sizes' {
	di "Max. treatment effect: `treatment_size'% of the dependent variable's mean"
	use "simulations/20190210_treatment=`treatment_size'_n=500.dta", clear
	append using "simulations/20190211_treatment=`treatment_size'_n=500.dta"
	
	di "Number of p-values <= 0.05:"
	count if p_value_rmspe_ratio <= 0.05
	di "Number of p-values <= 0.1:"
	count if p_value_rmspe_ratio <= 0.1
	di "Number of p-values <= 1/39 = .02564103:"
	count if count_rspme_ratio_higher == 0
	di "Number of p-values <= 2/39 = .05128205:"
	count if count_rspme_ratio_higher <= 1
	di "Number of p-values <= 3/39 = .07692308:"
	count if count_rspme_ratio_higher <= 2
	di "Number of p-values <= 4/39 = .1025641:"
	count if count_rspme_ratio_higher <= 3
	sum count_rspme_ratio_higher, d
	di "p-value median:"
	di r(median)
	
	hist count_rspme_ratio_higher, start(0) width(1) discrete percent ///
		title("Distribution of the number of placebo runs") ///
		subtitle("with a higher RMSPE ratio than the treated unit") ///
		xtitle("Number of placebo runs with higher RMSPE ratio than treated unit")
	graph export "graphs/histogram_treatment_`treatment_size'.png", replace
	di "-----------------------"
	di "-----------------------"
}


use "simulations/20190210_treatment=0_n=500.dta", clear
append using "simulations/20190211_treatment=0_n=500.dta"
gen simulation_id = _n
tsset simulation_id
forvalues i = 1/4 {
	di `i'
	gen equal_`i'_39 = 0 
	replace equal_`i'_39 = 1 if count_rspme_ratio_higher <= `i' - 1
	gen cumsum_equal_`i'_39 = sum(equal_`i'_39)
	gen ratio_`i'_39 = cumsum_equal_`i'_39 / simulation_id
}

label variable ratio_1_39   "Share p-values = 1/39" 
label variable ratio_2_39   "Share p-values <= 2/39" 
label variable ratio_3_39   "Share p-values <= 3/39" 
label variable ratio_4_39   "Share p-values <= 4/39"

tsline ratio_1_39 ratio_2_39 ratio_3_39 ratio_4_39, ///
	title("Convergence of p-value distribution") ///
	subtitle("Scenario without treatment effect") ///
	xtitle("Number of simulations")
graph export "graphs/convergence.png", replace
