// This do-file defines the program calculate_rmspe.

capture program drop calculate_rmspe
program define calculate_rmspe
/* Calculate the Root Mean Squared Prediction Error (RMSPE) for the estimate 
`y_pred' of `y_true', only considering values for which `if_condition' is true. 
*/
	args y_pred y_true if_condition
	
	qui sum `y_pred' `if_condition'
	local n_observations = `r(N)'
	
	tempvar residual residual_squared total_sum_of_squares mspe rmspe_var
	gen `residual' = `y_true' - `y_pred' `if_condition'
	gen `residual_squared' = `residual'^2
	egen `total_sum_of_squares' = total(`residual_squared') 
	gen `mspe' = `total_sum_of_squares' / `n_observations'
	gen `rmspe_var' = sqrt(`mspe')
	local rmspe = `rmspe_var'
	scalar rmspe = `rmspe'
end
