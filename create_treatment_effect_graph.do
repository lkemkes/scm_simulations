// This do-file creates a graph showing the different treatment effects.


do "programs/instantiate_panel.do"

instantiate_panel 31 4


gen treatment = 0



replace treatment = (period - 20 + 1) / 12 * 20 if period >= 20 & unit == 2
replace treatment = (period - 20 + 1) / 12 * 40 if period >= 20 & unit == 3
replace treatment = (period - 20 + 1) / 12 * 60 if period >= 20 & unit == 4

label variable treatment 􏰀"Max. treatment effect in % of the dependent variable's mean"

label define treatmentlabel 1 "0%" 2 "20%" 3 "40%" 4 "60%"
label values unit treatmentlabel

tsset unit period

xtline treatment, overlay ///
	title("Modelization of the treatment effect") ///
	ytitle("Treatment effect in %") ///
	legend(subtitle("Max. treatment effect in % of dependent variable's mean"))
graph export "graphs/treatment_alpha.png", replace




