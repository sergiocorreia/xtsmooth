* ===========================================================================
* Test accuracy of -xtsmooth- using random variables and smoothers
* ===========================================================================
	clear all
	cls
	cap ado uninstall xtsmooth
	net install xtsmooth, from("C:\Git\xtsmooth\src")

// --------------------------------------------------------------------------
// Programs
// --------------------------------------------------------------------------

capture program drop TestRandom
program define TestRandom
	syntax varname(numeric)

	* Pick random smoother
	*loc tokens "3 5 7 R S E H"
	loc tokens "3 5 7 9 R E H" // S does not always works... see example in test_simple.do
	loc tokens "`tokens' `tokens' `tokens'" // Allow up to 3 repetitions
	loc max_size : word count `tokens'
	mata: st_local("smoother", subinstr(invtokens(jumble(tokens("`tokens'")')[1..ceil(runiform(1,1)*`max_size')]'), " ", ""))

	di as text "Var=[`varlist'] Smoother[`smoother']"
	loc cmd `"Check, variable(`varlist') smoother(`smoother')"'
	di as text "`cmd'"
	`cmd'
end


// --------------------------------------------------------------------------
// Load data
// --------------------------------------------------------------------------

	use "fred", clear

	ds t, not
	loc vars `r(varlist)'
	loc k = c(k) - 1
	assert `k' == `: word count `vars''

/*
loc smooth 3R33RSSEH7H // 3R33RSSH // 3R33RSSEH7H
smooth `smooth' CORLAGACBN, gen(y)
xtsmooth CORLAGACBN, gen(x) smooth(`smooth') twice
tssmooth nl exp = CORLAGACBN
tsline CORLAGACBN x y exp if t>=tq(1990q1) , legend(order(1 "Original" 2 "XTSMOOTH" 3 "SMOOTH"))
*/

	forv iter=1/1000 {
		* Pick random variable
		loc i = ceil(runiform() * `k')
		loc var : word `i' of `vars'

		di as text _n "{bf:Random Test `iter'}"
		TestRandom `var'
	}


exit
