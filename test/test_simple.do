* ===========================================================================
* Test accuracy of -xtsmooth-
* ===========================================================================
* See help for mkassert, cscript

	clear all
	cls

	cap ado uninstall xtsmooth
	net install xtsmooth, from("C:\Git\xtsmooth\src")
	pr drop _all

// --------------------------------------------------------------------------
// Programs
// --------------------------------------------------------------------------




// --------------------------------------------------------------------------
// Simple tests
// --------------------------------------------------------------------------

	sysuse auto
	gen int t = _n
	tsset t

	set trace off

	keep t price

	keep in 2/10
	**keep in 2/8

	Check, variable(price) smoother(3)
	Check, variable(price) smoother(5)
	Check, variable(price) smoother(7)
	Check, variable(price) smoother(3R)
	Check, variable(price) smoother(5R)
	Check, variable(price) smoother(7R)
	Check, variable(price) smoother(3H)
	Check, variable(price) smoother(3R5H)
	Check, variable(price) smoother(3RE5H)
	Check, variable(price) smoother(3R5EH)
	Check, variable(price) smoother(3S)
	Check, variable(price) smoother(3S5S)
	Check, variable(price) smoother(3SR)
	Check, variable(price) smoother(3SRR)
	Check, variable(price) smoother(3SR53RSR)
	Check, variable(price) smoother(3RSEH)
	Check, variable(price) smoother(3RSSEH)
	Check, variable(price) smoother(3RSESEH)

	Check, variable(price) smoother(3) twice
	Check, variable(price) smoother(3E) twice
	Check, variable(price) smoother(3R5) twice
	Check, variable(price) smoother(3R5H) twice
	Check, variable(price) smoother(3RSESE) twice
	
	Check, variable(price) smoother(3SH) twice
	Check, variable(price) smoother(3RSESEH) twice


	* tw (line price t, color(black)) (line `x' t, color(red) lwidth(thick) lpattern(dash)) (line `y' t, color(blue))

// --------------------------------------------------------------------------
// Tests on FRED data
// --------------------------------------------------------------------------

	*use "fred", clear
	*keep t CORALOBN
	*replace CORALOBN = round(100 * CORALOBN) - 57
	*compress
	* *keep in 50/59
	*keep in 50/55

	clear
	input byte(x)
		0
		2
		5
		1
		0
		4
	end
	gen byte t = _n
	tsset t
	format %tq t
	compress

/*	smooth 3  x, gen(y3 )
	smooth 3S x, gen(y3S)
	xtsmooth x, s(3S) gen(z3S)
	gen delta = y3S - z3S

	format %12.0f y* z*
	li
*/

	cap noi Check, var(x) s(3S) // BUGBUG
	
	Check, variable(CORLAGACBN) smoother(3R33RSSEH7H) // BUGBUG	

exit
