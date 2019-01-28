// This do-file defines the program conduct_scm.


capture program drop conduct_scm
program define conduct_scm, eclass
/* Conduct the Synthetic Control Method (SCM) and report:
  - RMSPE before the treatment
  - RMSPE after the treatment
  - average deviation of the true observed outcome from the synthetic outcome 
	in the post-treatment periods the average alpha 
*/
	args depvar predictorvars trunit trperiod
	
	tempfile scm_results
	qui synth `depvar' `predictorvars', ///
		trunit(`trunit') trperiod(`trperiod') keep(`scm_results')
	
	preserve
	use `scm_results', clear
	
	* Calculate RMSPE for the periods before the treatment occurred
	calculate_rmspe _Y_synthetic _Y_treated "if _time < `trperiod'"
	ereturn scalar rmspe_pretreatment = rmspe
	
	* Calculate RMSPE for the periods after the treatment occurred
	calculate_rmspe _Y_synthetic _Y_treated "if _time > `trperiod'"
	ereturn scalar rmspe_posttreatment = rmspe
	
	* Calculate the average deviation of the true observed outcome from the 
	* synthetic outcome in the post-treatment periods
	tempvar residual
	gen `residual' = _Y_treated - _Y_synthetic
	qui sum `residual' if _time > `trperiod'
	ereturn scalar avg_deviation_from_sc_post = r(mean)
	
	restore
	
end
