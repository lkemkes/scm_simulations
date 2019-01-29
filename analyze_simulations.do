// This do-file analyzes the simulations' results.


********************************************************************************
// With treatment effect
********************************************************************************
use "simulations/simulations_treat=yes.dta", clear

count if p_value_rmspe_ratio <= 0.05
count if p_value_rmspe_ratio <= 0.1

tab count_rspme_ratio_higher


********************************************************************************
// With no treatment effect
********************************************************************************
use "simulations/simulations_treat=no.dta", clear

count if p_value_rmspe_ratio <= 0.05
count if p_value_rmspe_ratio <= 0.1

tab count_rspme_ratio_higher

