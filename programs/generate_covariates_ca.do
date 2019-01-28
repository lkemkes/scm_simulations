// This do-file defines the program generate_covariates_ca.


do analyze_ca_data.do


cap program drop generate_covariates_ca
program define generate_covariates_ca
/* Generate covariates for n_units that follow the same multivariate normal 
distribution as the covariates in the California tobacco dataset. */

	args n_units
	
	drawnorm Z1 Z2 Z3 Z4 Z5, n(`n_units') cov(capital_sigma) means(M) clear
	
	gen unit = _n

end

generate_covariates_ca
