// This do-file calculates the mean and the variance-covariance matrix in the
// covariates of the California tobacco dataset.

set more off

* Install the synth package if not yet installed (uncomment following line)
* ssc install synth

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
