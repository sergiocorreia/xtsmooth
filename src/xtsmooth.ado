*! version 0.1.0 17jan2020

program define xtsmooth
	syntax varname(numeric) [if] [in] , Generate(name) Smoother(string) [Twice]
	marksample touse

	* Validate that the filter is not invalid (warning: this does not flag all problematic cases)
	smooth `smoother' `varlist', gen(`generate') dryrun
	qui gen double `generate' = `varlist' if `touse'
	
	loc smoother = strupper("`smoother'") // letters may be specified in lowercase if preferred.
	loc smoother = subinstr("`smoother'", " ", "", .) // Allow spaces, makes for more readable smoother
	loc smoother = subinstr("`smoother'", "3R", "A", .)
	loc smoother = subinstr("`smoother'", "5R", "B", .)
	loc smoother = subinstr("`smoother'", "7R", "C", .)
	loc smoother = subinstr("`smoother'", "9R", "D", .)
	loc smoother = subinstr("`smoother'", "SR", "F", .)

	Smooth `generate', smoother("`smoother'")
	
	if ("`twice'" != "") {
		tempvar residuals // Recall that data = smooth + rough (i.e. residuals)
		qui gen double `residuals' = `varlist' - `generate' // 1) Calculate "rough"
		Smooth `residuals', smoother("`smoother'") // 2) Smooth the "rough"
		qui replace `generate' = `generate' + `residuals' // 3) Add back the "smoother rough"
	}

	assert inlist(mi(`varlist') + mi(`generate'), 0, 2) // We can't create new MVs, but if X is missing we can't fill it in
end


program define Smooth
	syntax varname(numeric), Smoother(string)
	loc n = strlen("`smoother'")
	forval i = 1/`n' {
		loc token = substr(`"`smoother'"', `i', 1)
		*assert inlist("`token'", "3", "5", "7", "R", "H", "S", "E")
		assert inlist("`token'", "3", "5", "7", "9", "H", "S", "E") | inlist("`token'", "A", "B", "C", "D", "F")
		Run`token' `varlist'
	}
end


program define Run3
	args x
	tempvar y ok
	gen byte `ok' = !mi(L.`x' + `x' + F.`x')
	qui gen double `y' = min( max(L.`x', `x'), max( min(L.`x', `x'), F.`x') )
	qui replace `x' = `y' if `ok'
end


program define Run3Alt
	args x
	tempvar y3 ok3
	gen byte `ok3' = !mi(L.`x' + `x' + F.`x')
	mata: rowmedian("L(1/-1).`x'", "`y3'")
	qui replace `x' = `y3' if `ok3'
end


program define Run5
	args x
	tempvar y5 y3 ok5 ok3

	gen byte `ok5' = !mi(L2.`x' + L.`x' + `x' + F.`x' + F2.`x')
	gen byte `ok3' = !mi(         L.`x' + `x' + F.`x'         ) & !`ok5'

	mata: rowmedian("L(2/-2).`x'", "`y5'")
	mata: rowmedian("L(1/-1).`x'", "`y3'")

	qui replace `x' = `y5' if `ok5'
	qui replace `x' = `y3' if `ok3'
end


program define Run7
	args x
	tempvar y7 y5 y3 ok7 ok5 ok3

	gen byte `ok7' = !mi(L3.`x' + L2.`x' + L.`x' + `x' + F.`x' + F2.`x' + F3.`x')
	gen byte `ok5' = !mi(         L2.`x' + L.`x' + `x' + F.`x' + F2.`x'         ) & !`ok7'
	gen byte `ok3' = !mi(                  L.`x' + `x' + F.`x'                  ) & !`ok7' & !`ok5'

	mata: rowmedian("L(3/-3).`x'", "`y7'")
	mata: rowmedian("L(2/-2).`x'", "`y5'")
	mata: rowmedian("L(1/-1).`x'", "`y3'")

	qui replace `x' = `y7' if `ok7'
	qui replace `x' = `y5' if `ok5'
	qui replace `x' = `y3' if `ok3'
end


program define Run9
	args x
	tempvar y9 y7 y5 y3 ok9 ok7 ok5 ok3

	gen byte `ok9' = !mi(L4.`x' + L3.`x' + L2.`x' + L.`x' + `x' + F.`x' + F2.`x' + F3.`x' + F4.`x')
	gen byte `ok7' = !mi(         L3.`x' + L2.`x' + L.`x' + `x' + F.`x' + F2.`x' + F3.`x'         ) & !`ok9'
	gen byte `ok5' = !mi(                  L2.`x' + L.`x' + `x' + F.`x' + F2.`x'                  ) & !`ok9' & !`ok7'
	gen byte `ok3' = !mi(                           L.`x' + `x' + F.`x'                           ) & !`ok9' & !`ok7' & !`ok5'

	mata: rowmedian("L(4/-4).`x'", "`y9'")
	mata: rowmedian("L(3/-3).`x'", "`y7'")
	mata: rowmedian("L(2/-2).`x'", "`y5'")
	mata: rowmedian("L(1/-1).`x'", "`y3'")

	qui replace `x' = `y9' if `ok9'
	qui replace `x' = `y7' if `ok7'
	qui replace `x' = `y5' if `ok5'
	qui replace `x' = `y3' if `ok3'
end


program define RunA // "A" = Repeat 3 (3R)
	args x
	RunRepeat `x' 3
end


program define RunB // "B" = Repeat 5 (5R)
	args x
	RunRepeat `x' 5
end


program define RunC // "C" = Repeat 7 (7R)
	args x
	RunRepeat `x' 7
end


program define RunD // "C" = Repeat 9 (9R)
	args x
	RunRepeat `x' 9
end


program define RunF // "F" = Repeat S (SR)
	args x
	RunRepeat `x' S
end


program define RunRepeat
	args x i
	assert inlist("`i'", "3", "5", "7", "9", "S")
	tempvar copy
	qui gen double `copy' = .

	while (1) {
		qui replace `copy' = `x'
		Run`i' `x'
		cap assert reldif(`x', `copy') < 1e-7 if !mi(`x')
		if (c(rc) == 0) continue, break
	}
end


program define RunE // Endpoints
	* z_1 = med{ 3*z_2 - 2*z_3, y_1, z_2} ???
	args x
	tempvar y_first y_last is_last is_first

	gen byte `is_last'  = mi(F.`x') & !mi(`x')
	gen byte `is_first' = mi(L.`x') & !mi(`x')

	qui gen double `y_last' = min(max(`x',l.`x'), max(min(`x',l.`x'), (3*l.`x' - 2*l2.`x'))) if `is_last' // median(X, L.X, 3*L.X - 2*L2.X) ; remember that X (but not L.X) is the original value at the endpoint
	qui gen double `y_first' = min(max(`x', f.`x'), max(min(`x', f.`x'), (3*f.`x' - 2*f2.`x'))) if `is_first'

	qui replace `x' = `y_last' if `is_last'
	qui replace `x' = `y_first' if `is_first'
end


program define RunH // Hanning
	args x
	tempvar y
	qui gen double `y' = (L.`x' + 2 * `x' + F.`x') / 4 // Will be missing if one of the three is
	qui replace `x' = `y' if !mi(`y')
end


program define RunS
	* See Tukey (1977) and Velleman (1980) p610
	args x
	tempvar is_flat extrapolated y cancel_flat


	* 1) Split the series (is_flat==1 marks end of one side, ==2 marks beginning of next)
	* Unabbreviated formula would be: (X==F.X) & (X != L.X) & (F.X != F2.X) & ((X > L.X & F.X > F2.X) | (X < L.X & F.X < F2.X))
	gen byte `is_flat' = (reldif(`x', F.`x') < 1e-7) & (sign(S.`x') * sign(F2S.`x') == -1)
	qui replace `is_flat' = 2 if L.`is_flat' == 1

	* Remove consecutive flat regions; else we don't match -smooth-
	**qui gen `cancel_flat' = (`is_flat'==1 & L.`is_flat'==2) | (`is_flat'==2 & L2.`is_flat'==2)
	**qui replace `is_flat' = 0 if `cancel_flat'
	
	**qui replace `is_flat' = 0 if (`is_flat'==1 & L.`is_flat'==2) | (`is_flat'==2 & L2.`is_flat'==2)
	
	*li `x' `is_flat'

	* 2) Apply endpoint rule E
	qui gen double `extrapolated' = .
	qui replace `extrapolated' = 3 * L1.`x' - 2 * L2.`x' if `is_flat' == 1 // 3 * L1.`x' - 2 & L2.`x' = 2 * SL1.`x' + L1.`x'
	qui replace `extrapolated' = 3 * F1.`x' - 2 * F2.`x' if `is_flat' == 2
	
	* 3) Replace series
	mata: rowmedian("L(0/1).`x' `extrapolated'", "`y'")
	qui replace `x' = `y' if !mi(`y') & (`is_flat' == 1)
	drop `y'

	mata: rowmedian("F(0/1).`x' `extrapolated'", "`y'")
	qui replace `x' = `y' if !mi(`y') & (`is_flat' == 2)
	drop `y' `extrapolated'

	* 4) Resmooth through 3R
	RunA `x'
end


mata:
void rowmedian(string vars, string newvar) {
	// Load data
	data = st_data(., vars)
	n = rows(data)
	k = cols(data)
	assert(mod(k, 2)) // assert even
	midpoint = (1 + k) / 2

	// Reshape it long
	data = vec(J(k, 1, 1..n)) , vec(data') // (1::n) # J(k, 1, 1)

	// Sort it
	data = sort(data, (1,2))

	// Keep medians of each group
	index = midpoint :+ (0::n-1) :* k
	data = data[index, 2]

	// Save data
	st_store(., st_addvar("double", newvar), data)
}
end


/*
# Rules include:

- S can only be applied after 3, 3R, or S
- H *should* only be applied after all nonlinear smoothers
- R *should* be used only with odd-span smoothers because even-span smoothers are not guaranteed to converge.

# TODO:

- We need a variant of S that ignores when both obs are zero (e.g. NCOs is full of zeroes)
*/
