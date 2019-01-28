// This do-file defines the program instantiate_panel.


capture program drop instantiate_panel
program define instantiate_panel
/* Instantiate a panel with `n_periods' periods and `n_units' units. */ 
	
	args n_periods n_units
	
	* Define the number of observations needed for the panel
	local n_obs = `n_periods' * `n_units'
	
	* Delete existing variables
	drop _all

	* Instantiate empty observations
	set obs `n_obs'
	
	* Generate unit variable, which runs `n_periods' times from 1 to `n_units'
	gen unit = mod(_n, `n_units')
	replace unit = `n_units' if unit == 0
	
	* Generate period variable, which equals 1 for the first `n_units', 2 for 
	* the next `n_units, etc.
	gen period = int(_n/`n_units') + 1
	replace period = period - 1 if unit == `n_units'

end
