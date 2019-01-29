// This do-file calculates several summary statistics and estimates for the 
// California tobacco data.


set more off

* Install the synth package if not yet installed (uncomment following line)
* ssc install synth


********************************************************************************
// Get estimates for the treatment effects alpha_it
********************************************************************************
/*
* Load the California dataset
sysuse synth_smoking, clear

* Declare the panelvar and timevar for the panel
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

*/
********************************************************************************
// Get mean vector and variance-covariance matrix of the covariates
********************************************************************************

* Re-load California data
sysuse synth_smoking, clear
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

tempfile covariates_averages
save `covariates_averages'


********************************************************************************
// Get estimates for time- and state-fixed effects, theta_t, and the variance
// of epsilon_it
********************************************************************************
* Re-load California data
sysuse synth_smoking, clear
merge m:1 state using `covariates_averages'
tsset state year
keep state year cigsale Z_lnincome Z_beer Z_age15to24 Z_retprice Z_cigsale
rename cigsale Y
rename Z_lnincome Z1
rename Z_beer Z2
rename Z_age15to24 Z3
rename Z_retprice Z4
rename Z_cigsale Z5

* Calculate Y_N
gen period = year - 1970 + 1
merge m:1 period using "alpha_it.dta"
replace alpha_it = 0 if state != 3
replace alpha_it = 0 if year < 1989
gen Y_N = Y - alpha_it

xi: reg Y_N i.year i.year|Z1 i.year|Z2 i.year|Z3 i.year|Z4 i.year|Z5 i.state, noconstant
mat b = e(b)

* Residuals epsilon_it
predict Y_N_hat
gen residual = Y_N - Y_N_hat
sum residual
global residuals_std = r(sd)
di "$residuals_std"
histogram residual
graph save "graphs/regression_residuals.png", replace

gen state_fixed_effect = 0
forvalues state = 2/39 {
	local wherestatefecol = colnumb(b,"_Istate_`state'")
	local state_fixed_effect = b[1,`wherestatefecol']
	replace state_fixed_effect = `state_fixed_effect' if state == `state'
}
histogram state_fixed_effect if year == 1970, bin(15)
graph save "graphs/state_fixed_effects.png", replace


gen time_fixed_effect = 0
forvalues year = 1971/2000 {
	local whereyearfecol = colnumb(b,"_Iyear_`year'")
	local year_fixed_effect = b[1,`whereyearfecol']
	replace time_fixed_effect = `year_fixed_effect' if year == `year'
}
tsline time_fixed_effect if state == 1
graph save "graphs/time_fixed_effects.png", replace


forvalues i = 1/5 {
	local wherezicol = colnumb(b,"Z`i'")
	local theta_i0 = b[1,`wherezicol']
	gen theta_`i' = `theta_i0'
	forvalues year = 1971/2000 {
		local wherezicol = colnumb(b,"_IyeaXZ`i'_`year'")
		local theta_it = b[1,`wherezicol']
		replace theta_`i' = theta_`i' + `theta_it' if year == `year'
	}
}

tsline theta_1 if state == 1
tsline theta_2 if state == 1
tsline theta_3 if state == 1
tsline theta_4 if state == 1
tsline theta_5 if state == 1
sort state year
regress theta_3 L.theta_3 if state == 1
sum theta_3 theta_4 theta_5





*mlexp ( lnnormalden(residual, ({b2}^2*{b3} + {b4}^2*{b1})/({b2}^2 + {b4}^2), 1/(1/{b2}^2 + 1/{b4}^2) ))

