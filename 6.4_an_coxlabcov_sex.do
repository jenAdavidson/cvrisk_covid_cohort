

/*******************************************************************************
#1. Loop through datasets
*******************************************************************************/

local outcome cdeathlabcov iculabcov respsuplabcov hosplabcov macelabcov acslabcov strokelabcov hflabcov arrhylabcov 

use "$datadir/labcovdataset", clear


forvalues x=0/1 {
preserve
keep if sex==`x'

/*******************************************************************************
#3. Number of events
*******************************************************************************/


*rename variables which are too long for local	
rename arrhythmialabcov arrhylabcov  
rename enddate_arrhythmialabcov enddate_arrhylabcov
rename cdeathlabcov28days cdlabcov28  
rename enddate_cdeathlabcov28days enddate_cdlabcov28
rename deathlabcov28days dlabcov28  
rename enddate_deathlabcov28days enddate_dlabcov28
	
foreach cond of local outcome {
	
	*Number of events
	foreach group in qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="qrisk1" unique newid if `cond'==1 & qrisk3==1
		if "`group'"=="qrisk0" unique newid if `cond'==1 & qrisk3==0
		if "`group'"=="hrisk1" unique newid if `cond'==1 & hrisk==1
		if "`group'"=="hrisk0" unique newid if `cond'==1 & hrisk==0
			
		local num`group'`cond'=r(sum) 
	} // end foreach group

	
/*******************************************************************************
#4. Set data for each outcome
*******************************************************************************/		
	*UPDATE ENDDATE TO INCLUDE OUTCOME DATE
	replace enddate_`cond'=enddate_`cond'+1 if enddate_`cond'==exposdate
	stset enddate_`cond', fail(`cond'==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)	

	
/*******************************************************************************
#5. Rates
*******************************************************************************/	

	foreach group in qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="qrisk1" stptime if qrisk3==1, per(1000)
		if "`group'"=="qrisk0" stptime if qrisk3==0, per(1000)
		if "`group'"=="hrisk1" stptime if hrisk==1, per(1000)
		if "`group'"=="hrisk0" stptime if hrisk==0, per(1000)
		
		local es=string(`r(rate)',"%4.1f")
		local lci=string(`r(lb)',"%4.1f")
		local uci=string(`r(ub)',"%4.1f")
	
		*create string for output
		global rate`group'`cond' "`es' (`lci'-`uci')"
	} // end foreach group
	
	
/*******************************************************************************
#7. Crude model
*******************************************************************************/	
	foreach risk in qrisk3 hrisk {		
			stcox i.`risk', base
			local hrcru`risk'`cond'=exp(_b[1.`risk'])
			local ci1cru`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk'])
			local ci2cru`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])

/*******************************************************************************
#8. Adjusted model
*******************************************************************************/		
		
		if "`risk'"=="hrisk" {
		if `sex'==1
			stcox i.`risk' i.ageband i.ethrisk i.townsend2011_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd cons_countpriorb i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.b_ra i.b_sle i.immunosuppression i.b_impotence2, base // model with non-imputed variables
			local hradj`risk'`cond'=exp(_b[1.`risk'])
			local ci1adj`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2adj`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		} // end if
		
		else {
		stcox i.`risk' i.ageband i.ethrisk i.townsend2011_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd cons_countpriorb i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.b_ra i.b_sle i.immunosuppression, base // model with non-imputed variables
			local hradj`risk'`cond'=exp(_b[1.`risk'])
			local ci1adj`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2adj`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		}
		}
	
	
		if "`risk'"=="qrisk3" {
		stcox i.`risk' i.highalcintake cons_countpriorb i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression i.renal_egfr, base // model with egfr
		local hradj`risk'`cond'=exp(_b[1.`risk'])
		local ci1adj`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
		local ci2adj`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		} // end if
		
	} // end foreach risk
	
}/*end foreach var*/
/*******************************************************************************
#9. Output
*******************************************************************************/		

cap file close textfile 
file open textfile using "$outputdir/labcovmaincox_sex`x'.csv", write replace
file write textfile "sep=;" _n
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >10%" ";" (`numqrisk1cdeathlabcov') ";" ("$rateqrisk1cdeathlabcov") ";" %5.2f (`hrcruqrisk3cdeathlabcov') " (" %4.2f (`ci1cruqrisk3cdeathlabcov') "-" %4.2f (`ci2cruqrisk3cdeathlabcov') ")" ";" %5.2f (`hradjqrisk3cdeathlabcov') " (" %4.2f (`ci1adjqrisk3cdeathlabcov') "-" %4.2f (`ci2adjqrisk3cdeathlabcov') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisk0cdeathlabcov') ";" ("$rateqrisk0cdeathlabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1cdeathlabcov') ";" ("$ratehrisk1cdeathlabcov") ";" %5.2f (`hrcruhriskcdeathlabcov') " (" %4.2f (`ci1cruhriskcdeathlabcov') "-" %4.2f (`ci2cruhriskcdeathlabcov') ")" ";" %5.2f (`hradjhriskcdeathlabcov') " (" %4.2f (`ci1adjhriskcdeathlabcov') "-" %4.2f (`ci2adjhriskcdeathlabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0cdeathlabcov') ";" ("$ratehrisk0cdeathlabcov") ";" "ref" ";" "ref" _n
file write textfile "ICU admission†" ";" "QRISK3 >=10%" ";" (`numqrisk1iculabcov') ";" ("$rateqrisk1iculabcov") ";" %5.2f (`hrcruqrisk3iculabcov') " (" %4.2f (`ci1cruqrisk3iculabcov') "-" %4.2f (`ci2cruqrisk3iculabcov') ")" ";" %5.2f (`hradjqrisk3iculabcov') " (" %4.2f (`ci1adjqrisk3iculabcov') "-" %4.2f (`ci2adjqrisk3iculabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0iculabcov') ";" ("$rateqrisk0iculabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1iculabcov') ";" ("$ratehrisk1iculabcov") ";" %5.2f (`hrcruhriskiculabcov') " (" %4.2f (`ci1cruhriskiculabcov') "-" %4.2f (`ci2cruhriskiculabcov') ")" ";" %5.2f (`hradjhriskiculabcov') " (" %4.2f (`ci1adjhriskiculabcov') "-" %4.2f (`ci2adjhriskiculabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0iculabcov') ";" ("$ratehrisk0iculabcov") ";" "ref" ";" "ref" _n
file write textfile "Respiratory support‡" ";" "QRISK3 >=10%" ";" (`numqrisk1respsuplabcov') ";" ("$rateqrisk1respsuplabcov") ";" %5.2f (`hrcruqrisk3respsuplabcov') " (" %4.2f (`ci1cruqrisk3respsuplabcov') "-" %4.2f (`ci2cruqrisk3respsuplabcov') ")" ";" %5.2f (`hradjqrisk3respsuplabcov') " (" %4.2f (`ci1adjqrisk3respsuplabcov') "-" %4.2f (`ci2adjqrisk3respsuplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0respsuplabcov') ";" ("$rateqrisk0respsuplabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1respsuplabcov') ";" ("$ratehrisk1respsuplabcov") ";" %5.2f (`hrcruhriskrespsuplabcov') " (" %4.2f (`ci1cruhriskrespsuplabcov') "-" %4.2f (`ci2cruhriskrespsuplabcov') ")" ";" %5.2f (`hradjhriskrespsuplabcov') " (" %4.2f (`ci1adjhriskrespsuplabcov') "-" %4.2f (`ci2adjhriskrespsuplabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0respsuplabcov') ";" ("$ratehrisk0respsuplabcov") ";" "ref" ";" "ref" _n
file write textfile "Hospitalization$" ";" "QRISK3 >=10%" ";" (`numqrisk1hosplabcov') ";" ("$rateqrisk1hosplabcov") ";" %5.2f (`hrcruqrisk3hosplabcov') " (" %4.2f (`ci1cruqrisk3hosplabcov') "-" %4.2f (`ci2cruqrisk3hosplabcov') ")" ";" %5.2f (`hradjqrisk3hosplabcov') " (" %4.2f (`ci1adjqrisk3hosplabcov') "-" %4.2f (`ci2adjqrisk3hosplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0hosplabcov') ";" ("$rateqrisk0hosplabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1hosplabcov') ";" ("$ratehrisk1hosplabcov") ";" %5.2f (`hrcruhriskhosplabcov') " (" %4.2f (`ci1cruhriskhosplabcov') "-" %4.2f (`ci2cruhriskhosplabcov') ")" ";" %5.2f (`hradjhriskhosplabcov') " (" %4.2f (`ci1adjhriskhosplabcov') "-" %4.2f (`ci2adjhriskhosplabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0hosplabcov') ";" ("$ratehrisk0hosplabcov") ";" "ref" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=10%" ";" (`numqrisk1macelabcov') ";" ("$rateqrisk1macelabcov") ";" %5.2f (`hrcruqrisk3macelabcov') " (" %4.2f (`ci1cruqrisk3macelabcov') "-" %4.2f (`ci2cruqrisk3macelabcov') ")" ";" %5.2f (`hradjqrisk3macelabcov') " (" %4.2f (`ci1adjqrisk3macelabcov') "-" %4.2f (`ci2adjqrisk3macelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0macelabcov') ";" ("$rateqrisk0macelabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1macelabcov') ";" ("$ratehrisk1macelabcov") ";" %5.2f (`hrcruhriskmacelabcov') " (" %4.2f (`ci1cruhriskmacelabcov') "-" %4.2f (`ci2cruhriskmacelabcov') ")" ";" %5.2f (`hradjhriskmacelabcov') " (" %4.2f (`ci1adjhriskmacelabcov') "-" %4.2f (`ci2adjhriskmacelabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0macelabcov') ";" ("$ratehrisk0macelabcov") ";" "ref" ";" "ref" _n
file write textfile "ACS" ";" "QRISK3 >=10%"";" (`numqrisk1acslabcov') ";" ("$rateqrisk1acslabcov") ";" %5.2f (`hrcruqrisk3acslabcov') " (" %4.2f (`ci1cruqrisk3acslabcov') "-" %4.2f (`ci2cruqrisk3acslabcov') ")" ";" %5.2f (`hradjqrisk3acslabcov') " (" %4.2f (`ci1adjqrisk3acslabcov') "-" %4.2f (`ci2adjqrisk3acslabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0acslabcov') ";" ("$rateqrisk0acslabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1acslabcov') ";" ("$ratehrisk1acslabcov") ";" %5.2f (`hrcruhriskacslabcov') " (" %4.2f (`ci1cruhriskacslabcov') "-" %4.2f (`ci2cruhriskacslabcov') ")" ";" %5.2f (`hradjhriskacslabcov') " (" %4.2f (`ci1adjhriskacslabcov') "-" %4.2f (`ci2adjhriskacslabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0acslabcov') ";" ("$ratehrisk0acslabcov") ";" "ref" ";" "ref" ";" _n
file write textfile "Ischaemic stroke" ";" "QRISK3 >=10%" ";" (`numqrisk1strokelabcov') ";" ("$rateqrisk1strokelabcov") ";" %5.2f (`hrcruqrisk3strokelabcov') " (" %4.2f (`ci1cruqrisk3strokelabcov') "-" %4.2f (`ci2cruqrisk3strokelabcov') ")" ";" %5.2f (`hradjqrisk3strokelabcov') " (" %4.2f (`ci1adjqrisk3strokelabcov') "-" %4.2f (`ci2adjqrisk3strokelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0strokelabcov') ";" ("$rateqrisk0strokelabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1strokelabcov') ";" ("$ratehrisk1strokelabcov") ";" %5.2f (`hrcruhriskstrokelabcov') " (" %4.2f (`ci1cruhriskstrokelabcov') "-" %4.2f (`ci2cruhriskstrokelabcov') ")" ";" %5.2f (`hradjhriskstrokelabcov') " (" %4.2f (`ci1adjhriskstrokelabcov') "-" %4.2f (`ci2adjhriskstrokelabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0strokelabcov') ";" ("$ratehrisk0strokelabcov") ";" "ref" ";" "ref" _n
file write textfile "Acute left ventricular failure" ";" "QRISK3 >=10%" ";" (`numqrisk1hflabcov') ";" ("$rateqrisk1hflabcov") ";" %5.2f (`hrcruqrisk3hflabcov') " (" %4.2f (`ci1cruqrisk3hflabcov') "-" %4.2f (`ci2cruqrisk3hflabcov') ")" ";" %5.2f (`hradjqrisk3hflabcov') " (" %4.2f (`ci1adjqrisk3hflabcov') "-" %4.2f (`ci2adjqrisk3hflabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0hflabcov') ";" ("$rateqrisk0hflabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1hflabcov') ";" ("$ratehrisk1hflabcov") ";" %5.2f (`hrcruhriskhflabcov') " (" %4.2f (`ci1cruhriskhflabcov') "-" %4.2f (`ci2cruhriskhflabcov') ")" ";" %5.2f (`hradjhriskhflabcov') " (" %4.2f (`ci1adjhriskhflabcov') "-" %4.2f (`ci2adjhriskhflabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0hflabcov') ";" ("$ratehrisk0hflabcov") ";" "ref" ";" "ref" _n
file write textfile "Major ventricular arrhythmia" ";" "QRISK3 >=10%" ";" (`numqrisk1arrhylabcov') ";" ("$rateqrisk1arrhylabcov") ";" %5.2f (`hrcruqrisk3arrhylabcov') " (" %4.2f (`ci1cruqrisk3arrhylabcov') "-" %4.2f (`ci2cruqrisk3arrhylabcov') ")" ";" %5.2f (`hradjqrisk3arrhylabcov') " (" %4.2f (`ci1adjqrisk3arrhylabcov') "-" %4.2f (`ci2adjqrisk3arrhylabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0arrhylabcov') ";" ("$rateqrisk0arrhylabcov") ";" "ref" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1arrhylabcov') ";" ("$ratehrisk1arrhylabcov") ";" %5.2f (`hrcruhriskarrhylabcov') " (" %4.2f (`ci1cruhriskarrhylabcov') "-" %4.2f (`ci2cruhriskarrhylabcov') ")" ";" %5.2f (`hradjhriskarrhylabcov') " (" %4.2f (`ci1adjhriskarrhylabcov') "-" %4.2f (`ci2adjhriskarrhylabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0arrhylabcov') ";" ("$ratehrisk0arrhylabcov") ";" "ref" ";" "ref"  _n

restore
}