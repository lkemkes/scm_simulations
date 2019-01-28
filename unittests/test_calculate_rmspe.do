// This do-file defines unittests for the program calculate_rmspe.


// Load dependencies
do programs/calculate_rmspe.do


capture program drop test_calculate_rmspe
program define test_calculate_rmspe
/* Unit-tests for calculate_rmspe. */
	drop _all
	set obs 2
	gen A = 1
	gen B = 0
	
	calculate_rmspe A B ""
	assert rmspe == 1
	
	replace A = 2
	calculate_rmspe A B ""
	assert rmspe == 2
	
	drop _all
	set obs 4
	gen A = 2
	gen B = 0
	replace A = 5 if _n > 2
	calculate_rmspe A B ""
	assert rmspe > 2
	calculate_rmspe A B "if _n < 3"
	assert rmspe == 2
	
	drop _all
	set obs 5
	gen A = 0
	gen B = 0
	replace A = 4 if _n == 1
	replace A = 3 if _n == 2
	calculate_rmspe A B ""
	assert rmspe - sqrt(5) < 0.001
	
	di "Passed all unit-tests for calculate_rmspe."
	
	/* TODO: Replace variable names A and B by y_true and y_pred. */
	
end
