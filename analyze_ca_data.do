// This do-file calculates several summary statistics and estimates for the 
// California tobacco data.


set more off

* Install the synth package if not yet installed (uncomment following line)
* ssc install synth


********************************************************************************
//  Get mean vector and variance-covariance matrix of the covariates
********************************************************************************

* Load the California dataset
sysuse synth_smoking, clear

* Declare the panelvar and timevar for the panel
tsset state year

* Build variables Z_i (which are averages over several years)
egen Z_lnincome = total(lnincome) if inrange(year, 1980, 1988), by(state)
replace Z_lnincome = Z_lnincome / 9
egen Z_beer = total(beer) if inrange(year, 1984, 1988), by(state)
replace Z_beer = Z_beer / 5
egen Z_age15to24 = total(age15to24) if inrange(year, 1980, 1988), by(state)
replace Z_age15to24 = Z_age15to24 / 9
egen Z_retprice = total(retprice) if inrange(year, 1980, 1988), by(state)
replace Z_retprice = Z_retprice / 9
egen Z_cigsale = total(cigsale) if inlist(year, 1975, 1980, 1988), by(state)
replace Z_cigsale = Z_cigsale / 3

* Remove data not corresponding to the year 1988 (since we look at averages, we
* only need data for one year)
tsset, clear
keep if year == 1988

* Remove unnecessary variables
keep state Z_lnincome Z_beer Z_age15to24 Z_retprice Z_cigsale

* Store the variance-covariance matrix in the matrix capital_sigma
correlate Z_lnincome Z_beer Z_age15to24 Z_retprice Z_cigsale, covariance
matrix capital_sigma = r(C)
matrix list capital_sigma

* Store the means of the different variables in the locals mean_1 - mean_5:
sum Z_lnincome
local mean_1 `r(mean)'
sum Z_beer
local mean_2 `r(mean)'
sum Z_age15to24
local mean_3 `r(mean)'
sum Z_retprice
local mean_4 `r(mean)'
sum Z_cigsale
local mean_5 `r(mean)'
matrix M = `mean_1', `mean_2', `mean_3', `mean_4', `mean_5'


********************************************************************************
//  Get estimates for the treatment effects alpha_it
********************************************************************************

* Re-load California data
sysuse synth_smoking, clear
tsset state year

* Conduct SCM
local explanatory_vars ///
	lnincome(1980(1)1988) beer(1984(1)1988) ///
	age15to24(1980(1)1988) retprice(1980(1)1988) ///
	cigsale(1975) cigsale(1980) cigsale(1988)	
synth cigsale `explanatory_vars', ///
	trunit(3) trperiod(1989) nested keep(replication) replace fig

use "replication.dta", clear
gen period = _time - 1970 + 1
gen alpha_it = _Y_treated - _Y_synthetic
keep period alpha_it
drop if alpha_it == .
save "alpha_it.dta", replace
	
