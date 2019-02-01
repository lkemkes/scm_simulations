// This do-file analyzes the simulations' results.

set more off

local treatment_sizes "0 20 40 60"


foreach treatment_size in `treatment_sizes' {
	di "Max. treatment effect: `treatment_size'% of the dependent variable's mean"
	use "simulations/simulations_treatment=`treatment_size'_n=1000.dta", clear
	
	di "Number of p-values <= 0.05:"
	count if p_value_rmspe_ratio <= 0.05
	di "Number of p-values <= 0.1:"
	count if p_value_rmspe_ratio <= 0.1
	di "Number of p-values == 1/39:"
	count if p_value_rmspe_ratio == 1/39
	di "Number of p-values <= 2/39:"
	count if p_value_rmspe_ratio <= 2/39
	di "Number of p-values <= 3/39:"
	count if p_value_rmspe_ratio <= 3/39
	di "Number of p-values <= 4/39:"
	count if p_value_rmspe_ratio <= 4/39
	qui sum count_rspme_ratio_higher, d
	di "p-value median:"
	di r(median)
	
	hist count_rspme_ratio_higher, start(0) width(1) discrete percent ///
		title("Distribution of the test statistic") ///
		xtitle("Number of placebo runs with higher RMSPE ratio than treated unit")
	graph export "graphs/histogram_treatment_`treatment_size'.png", replace
	di "-----------------------"
	di "-----------------------"
}

use "simulations/simulations_treatment=60_n=1000.dta", clear

count if p_value_rmspe_ratio <= 0.05
count if p_value_rmspe_ratio <= 0.1

tab count_rspme_ratio_higher
sum count_rspme_ratio_higher, d

hist count_rspme_ratio_higher, start(0) width(1) discrete percent ///
	title("Distribution of the test statistic") ///
	xtitle("Number of placebo runs with higher RMSPE ratio than treated unit")
graph export "graphs/histogram_treatment_60.png", replace




use "simulations/simulations_treatment=40_n=1000.dta", clear

count if p_value_rmspe_ratio <= 0.05
count if p_value_rmspe_ratio <= 0.1

tab count_rspme_ratio_higher
sum count_rspme_ratio_higher, d

hist count_rspme_ratio_higher, start(0) width(1) discrete percent ///
	title("Distribution of the test statistic") ///
	xtitle("Number of placebo runs with higher RMSPE ratio than treated unit")
graph export "graphs/histogram_treatment_40.png", replace


set more off
use "simulations/simulations_treatment=20_n=1000.dta", clear

count if p_value_rmspe_ratio <= 0.05
count if p_value_rmspe_ratio <= 0.1

tab count_rspme_ratio_higher
sum count_rspme_ratio_higher, d

hist count_rspme_ratio_higher, start(0) width(1) discrete percent ///
	title("Distribution of the test statistic") ///
	xtitle("Number of placebo runs with higher RMSPE ratio than treated unit")
graph export "graphs/histogram_treatment_20.png", replace


********************************************************************************
// With no treatment effect
********************************************************************************
set more off
use "simulations/simulations_treatment=0_n=1000.dta", clear

count if p_value_rmspe_ratio <= 0.05
count if p_value_rmspe_ratio <= 0.1

tab count_rspme_ratio_higher
sum count_rspme_ratio_higher, d

hist count_rspme_ratio_higher, start(0) width(1) discrete percent ///
	title("Distribution of the test statistic") ///
	xtitle("Number of placebo runs with higher RMSPE ratio than treated unit")
graph export "graphs/histogram_no_treatment.png", replace

