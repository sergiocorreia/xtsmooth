* ===========================================================================
* Create FRED test data
* ===========================================================================
	
	import fred CORALACBN CORALOBN CORCACBN CORFLACBN CORFLOBN CORLFRACBN CORLAGACBN NDCOALLL NCOALLACB NCOALLOB NCOALLSREACB NCOALLCACB NCOALLAGACB NCOCMC1 WYTNC NCOTOT3, clear
	
	gen long t = qofd(daten) , before(datestr)
	format %tq t
	tsset t
	drop date*
	recast double _all
	compress

	saveold "fred", replace

exit
