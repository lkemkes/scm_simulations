// This do-file runs unittests for the defined programs, i.e. the programs are
// tested with example values and it is checked that the actual outputs match 
// the expected output.

set more off

// Load dependencies:
do unittests/test_calculate_rmspe.do


// Run unittests:
test_calculate_rmspe
