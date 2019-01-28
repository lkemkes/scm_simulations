// Replication of SCM results in Abadie, Diamond & Hainmueller (2010)

set more off

* Install the synth package if not yet installed (uncomment following line)
* ssc install synth

* Load the dataset
* Note: You might first have to navigate to the directory where 
* synth_smoking.dta is stored using the "cd" command.
sysuse synth_smoking, clear

* Create a folder for intermediate results:
mkdir replication_data

* Declare the panelvar and timevar for the panel
tsset state year

* Find ID for the State we are interested in (California)
label list state
* => The ID for California is 3

* Descriptive statistics
xtsum lnincome age15to24 retprice if inrange(year, 1980, 1988) & state != 3
tabstat lnincome age15to24 retprice if inrange(year, 1980, 1988) & state!=3, ///
	s(n min mean p50 max) c(statistics)

xtsum beer if inrange(year, 1984, 1988) & state != 3
xtsum cigsale if year == 1975 & state != 3
xtsum cigsale if year == 1980 & state != 3
xtsum cigsale if year == 1988 & state != 3
bysort year: summarize cigsale if state != 3 & ///
	(year == 1975 | year == 1980 | year == 1988), detail


* Conduct SCM
local explanatory_vars ///
	lnincome(1980(1)1988) beer(1984(1)1988) ///
	age15to24(1980(1)1988) retprice(1980(1)1988) ///
	cigsale(1975) cigsale(1980) cigsale(1988)
	
synth cigsale `explanatory_vars', ///
	trunit(3) trperiod(1989) nested keep(replication) replace fig


* Placebo tests: Run SCM for every State pretending the treatment had
* happened in that State, store results in a separate file per State
tempname rmspemat
forvalues i = 1/39 {
qui synth cigsale `explanatory_vars', ///
	trunit(`i') trperiod(1989) keep("replication_data/state_`i'") replace
di "Treated State `i'."
matrix `rmspemat' = nullmat(`rmspemat') \ e(RMSPE)
local names `"`names' `"`i'"'"'
}

* Create a file with the pre-treatment RMSPE for each State
mat colnames `rmspemat' = "RMSPE"
mat rownames `rmspemat' = `names'
matlist `rmspemat', row("Treated State")
clear
svmat `rmspemat', names("RMSPE")
gen state = _n
rename RMSPE1 RMSPE
save "replication_data/rmspe.dta", replace

* Build panel dataset with true and synthetic cigsale values for all States
use "replication_data/state_1.dta", clear
gen state = 1
keep state _time _Y_treated _Y_synthetic
forvalues i = 2/39 {
	append using "replication_data/state_`i'.dta", ///
		keep(_time _Y_treated _Y_synthetic)
	replace state = `i' if state == .
}
keep if _Y_treated != .
label values state state

* Calculate delta between actual cigsales and cigsales in synthetic State:
gen delta_treatment = _Y_treated - _Y_synthetic
egen total_delta_cigsale = total(delta_treatment) ///
	if inrange(_time, 1990, 2000), by(state) 
gen avg_delta_cigsale = total_delta_cigsale / 11

* Combine with information on the pre-treatment RMSPE for each State
merge m:1 state using "replication_data/rmspe.dta"
gen rmspe_lower_20 = 0
replace rmspe_lower_20 = 1 if RMSPE < 20
gen rmspe_lower_5xca = 0
replace rmspe_lower_5xca = 1 if RMSPE < 5 * 2.0378504

* Show the average change in cigarette packages sold per year for each State:
sort avg_delta_cigsale
list state avg_delta_cigsale RMSPE if _time == 1990 & rmspe_lower_5xca == 1, ///
	sep(10)
