// This do-file analyzes the simulations' results.

set more off

********************************************************************************
// With treatment effect
********************************************************************************
use "simulations/simulations_treatment=40_n=1000.dta", clear

count if p_value_rmspe_ratio <= 0.05
count if p_value_rmspe_ratio <= 0.1

tab count_rspme_ratio_higher


********************************************************************************
// With no treatment effect
********************************************************************************
use "simulations/simulations_treatment=0_n=1000.dta", clear

count if p_value_rmspe_ratio <= 0.05
count if p_value_rmspe_ratio <= 0.1

tab count_rspme_ratio_higher
