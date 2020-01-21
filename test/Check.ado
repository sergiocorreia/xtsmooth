capture program drop Check
program define Check
	syntax, Smoother(string) Variable(varname numeric) [Twice]
	tempvar x y	delta ok
	loc comma_twice = cond("`twice'" == "", "", ",twice")

	di as text "Testing smoother {res}`smoother'`comma_twice'{txt} {col 30} (variable={res}`variable'{txt})"
	
	loc cmd `"smooth `smoother'`comma_twice' `variable', gen(`x')"'
	di as text `"    `cmd'"'
	cap noi `cmd'
	loc rc1 = c(rc)

	loc cmd `"xtsmooth `variable', gen(`y') smooth(`smoother') `twice'"'
	di as text `"    `cmd'"'
	cap noi `cmd'
	loc rc2 = c(rc)

	if (`rc1' != `rc2') {
		di as error "Error codes are not the same `rc1'!=`rc2'"
		error 1235
	}

	if (`rc1') exit
	
	*gen double `delta' = reldif(`x', `y')
	qui gen double `delta' = `x' - `y'
	qui gen byte `ok' = (`delta' <= 1e-7) | (mi(`x') & mi(`y'))
	qui cou if !`ok'

	if (r(N)) {
		rename `x' smooth
		rename `y' xtsmooth
		rename `delta' delta
		rename `ok' ok
		*format %12.2fc smooth xtsmooth
		*	li `variable' smooth xtsmooth delta if (delta > 1e-7) | (F.delta > 1e-7 & F.delta<.) | (L.delta > 1e-7)
		cou if !ok
		li `variable' smooth xtsmooth delta if _n <= 10
		*tw (line price t, color(black)) (line smooth t, color(red) lwidth(thick) lpattern(dash)) (line xtsmooth t, color(blue))
		error 1234
	}
	assert `ok'
end
