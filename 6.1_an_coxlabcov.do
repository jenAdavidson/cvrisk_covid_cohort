
log using "$logdir/labcov.log", replace
/*******************************************************************************
#1. Loop through datasets
*******************************************************************************/

local outcome cdeathlabcov cdlabcov28 dlabcov28 iculabcov respsuplabcov hosplabcov macelabcov acslabcov strokelabcov hflabcov arrhylabcov // need to check which death variable is the main one

use "$datadir/labcovdataset", clear


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
	foreach group in qrisk1 qrisk0 hrisk1 hrisk0 qrisksens2 qrisksens1 qrisksens0 qrisk2_1 qrisk2_0 {
		if "`group'"=="qrisk1" unique newid if `cond'==1 & qrisk3==1
		if "`group'"=="qrisk0" unique newid if `cond'==1 & qrisk3==0
		if "`group'"=="hrisk1" unique newid if `cond'==1 & hrisk==1
		if "`group'"=="hrisk0" unique newid if `cond'==1 & hrisk==0
		
		if "`group'"=="qrisksens2" unique newid if `cond'==1 & qrisk3_sens==2
		if "`group'"=="qrisksens1" unique newid if `cond'==1 & qrisk3_sens==1
		if "`group'"=="qrisksens0" unique newid if `cond'==1 & qrisk3_sens==0
		if "`group'"=="qrisk2_1" unique newid if `cond'==1 & qrisk2==1
		if "`group'"=="qrisk2_0" unique newid if `cond'==1 & qrisk2==0
			
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

	foreach group in qrisk1 qrisk0 hrisk1 hrisk0 qrisksens2 qrisksens1 qrisksens0 qrisk2_1 qrisk2_0 {
		if "`group'"=="qrisk1" stptime if qrisk3==1, per(1000)
		if "`group'"=="qrisk0" stptime if qrisk3==0, per(1000)
		if "`group'"=="hrisk1" stptime if hrisk==1, per(1000)
		if "`group'"=="hrisk0" stptime if hrisk==0, per(1000)
		
		if "`group'"=="qrisksens2" stptime if qrisk3_sens==2, per(1000)
		if "`group'"=="qrisksens1" stptime if qrisk3_sens==1, per(1000)
		if "`group'"=="qrisksens0" stptime if qrisk3_sens==0, per(1000)
		if "`group'"=="qrisk2_1" stptime if qrisk2==1, per(1000)
		if "`group'"=="qrisk2_0" stptime if qrisk2==0, per(1000)

		local es=string(`r(rate)',"%4.1f")
		local lci=string(`r(lb)',"%4.1f")
		local uci=string(`r(ub)',"%4.1f")
	
		*create string for output
		global rate`group'`cond' "`es' (`lci'-`uci')"
	} // end foreach group
	
/*******************************************************************************
#6. Kaplien Meier curve
*******************************************************************************/		
	
	foreach risk in qrisk3 hrisk /*qrisk3_sens qrisk2*/ {
		sts graph, by(`risk') legend(label(1 "Low risk") label(2 "Raised risk")) graphregion(color(white))
		graph save "$outputdir/km_`cond'`risk'", replace 
	
/*******************************************************************************
#7. Crude model
*******************************************************************************/	
				
		if "`risk'"=="qrisk3_sens" {
			stcox i.`risk', base 
			local hrcru2`risk'`cond'=exp(_b[2.`risk'])
			local ci1cru2`risk'`cond'=exp(_b[2.`risk']-1.96*_se[2.`risk']) 
			local ci2cru2`risk'`cond'=exp(_b[2.`risk']+1.96*_se[2.`risk'])
			local hrcru1`risk'`cond'=exp(_b[1.`risk'])
			local ci1cru1`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2cru1`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		} // end if	
		
		else {
			stcox i.`risk', base
			local hrcru`risk'`cond'=exp(_b[1.`risk'])
			local ci1cru`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk'])
			local ci2cru`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		} // end else

/*******************************************************************************
#8. Adjusted model
*******************************************************************************/		
		
		if "`risk'"=="hrisk" {	
			stcox i.`risk' age i.sex, base 
			local hrsex`risk'`cond'=exp(_b[1.`risk'])
			local ci1sex`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2sex`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		
			stcox i.`risk' age i.sex i.ethrisk i.townsend2011_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd /*cons_countpriorb*/ i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppressed /*i.b_impotence2*/, base // model with non-imputed variables
			local hradj`risk'`cond'=exp(_b[1.`risk'])
			local ci1adj`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2adj`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		
			stcox i.`risk' age i.sex i.ethrisk i.townsend2011_5 i.bmigrp rati i.smoke_cat i.highalcintake i.fh_cvd /*cons_countpriorb*/ i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppressed /*i.b_impotence2*/, base // model with imputed variables
			local hradjimp`risk'`cond'=exp(_b[1.`risk'])
			local ci1adjimp`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2adjimp`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		} // end if
	
		if "`risk'"=="qrisk2" {
			stcox i.`risk' i.highalcintake /*cons_countpriorb*/ i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_migraine i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological /*i.b_sle*/ i.immunosuppression /*i.b_impotence2*/, base // model with non-imputed variables
			local hradj`risk'`cond'=exp(_b[1.`risk'])
			local ci1adj`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2adj`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		} // end if
	
		if "`risk'"=="qrisk3" {
		stcox i.`risk' i.highalcintake /*cons_countpriorb*/ i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression i.renal_egfr, base // model with egfr
		local hradj`risk'`cond'=exp(_b[1.`risk'])
		local ci1adj`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
		local ci2adj`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		
		stcox i.`risk' i.highalcintake /*cons_countpriorb*/ i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression, base // model without egfr	
		local hradjnoegfr`risk'`cond'=exp(_b[1.`risk'])
		local ci1adjnoegfr`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
		local ci2adjnoegfr`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		} // end if
		
		if "`risk'"=="qrisk3_sens" {
		stcox i.`risk' i.highalcintake /*cons_countpriorb*/ i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression i.renal_egfr, base // model with egfr
		local hradj2`risk'`cond'=exp(_b[2.`risk'])
		local ci1adj2`risk'`cond'=exp(_b[2.`risk']-1.96*_se[2.`risk']) 
		local ci2adj2`risk'`cond'=exp(_b[2.`risk']+1.96*_se[2.`risk'])
		local hradj1`risk'`cond'=exp(_b[1.`risk'])
		local ci1adj1`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
		local ci2adj1`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		} // end if
		
	} // end foreach risk

}/*end foreach var*/
log close

/*******************************************************************************
#9. Output
*******************************************************************************/		

cap file close textfile 
file open textfile using "$outputdir/labcovmaincox.csv", write replace
file write textfile "sep=;" _n
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Age- and sex-adjusted HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >10%" ";" (`numqrisk1cdeathlabcov') ";" ("$rateqrisk1cdeathlabcov") ";" %5.2f (`hrcruqrisk3cdeathlabcov') " (" %4.2f (`ci1cruqrisk3cdeathlabcov') "-" %4.2f (`ci2cruqrisk3cdeathlabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3cdeathlabcov') " (" %4.2f (`ci1adjqrisk3cdeathlabcov') "-" %4.2f (`ci2adjqrisk3cdeathlabcov') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisk0cdeathlabcov') ";" ("$rateqrisk0cdeathlabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1cdeathlabcov') ";" ("$ratehrisk1cdeathlabcov") ";" %5.2f (`hrcruhriskcdeathlabcov') " (" %4.2f (`ci1cruhriskcdeathlabcov') "-" %4.2f (`ci2cruhriskcdeathlabcov') ")" ";" %5.2f (`hrsexhriskcdeathlabcov') " (" %4.2f (`ci1sexhriskcdeathlabcov') "-" %4.2f (`ci2sexhriskcdeathlabcov') ")" ";" %5.2f (`hradjhriskcdeathlabcov') " (" %4.2f (`ci1adjhriskcdeathlabcov') "-" %4.2f (`ci2adjhriskcdeathlabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0cdeathlabcov') ";" ("$ratehrisk0cdeathlabcov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "ICU admission†" ";" "QRISK3 >=10%" ";" (`numqrisk1iculabcov') ";" ("$rateqrisk1iculabcov") ";" %5.2f (`hrcruqrisk3iculabcov') " (" %4.2f (`ci1cruqrisk3iculabcov') "-" %4.2f (`ci2cruqrisk3iculabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3iculabcov') " (" %4.2f (`ci1adjqrisk3iculabcov') "-" %4.2f (`ci2adjqrisk3iculabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0iculabcov') ";" ("$rateqrisk0iculabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1iculabcov') ";" ("$ratehrisk1iculabcov") ";" %5.2f (`hrcruhriskiculabcov') " (" %4.2f (`ci1cruhriskiculabcov') "-" %4.2f (`ci2cruhriskiculabcov') ")" ";" %5.2f (`hrsexhriskiculabcov') " (" %4.2f (`ci1sexhriskiculabcov') "-" %4.2f (`ci2sexhriskiculabcov') ")" ";" %5.2f (`hradjhriskiculabcov') " (" %4.2f (`ci1adjhriskiculabcov') "-" %4.2f (`ci2adjhriskiculabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0iculabcov') ";" ("$ratehrisk0iculabcov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Respiratory support‡" ";" "QRISK3 >=10%" ";" (`numqrisk1respsuplabcov') ";" ("$rateqrisk1respsuplabcov") ";" %5.2f (`hrcruqrisk3respsuplabcov') " (" %4.2f (`ci1cruqrisk3respsuplabcov') "-" %4.2f (`ci2cruqrisk3respsuplabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3respsuplabcov') " (" %4.2f (`ci1adjqrisk3respsuplabcov') "-" %4.2f (`ci2adjqrisk3respsuplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0respsuplabcov') ";" ("$rateqrisk0respsuplabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1respsuplabcov') ";" ("$ratehrisk1respsuplabcov") ";" %5.2f (`hrcruhriskrespsuplabcov') " (" %4.2f (`ci1cruhriskrespsuplabcov') "-" %4.2f (`ci2cruhriskrespsuplabcov') ")" ";" %5.2f (`hrsexhriskrespsuplabcov') " (" %4.2f (`ci1sexhriskrespsuplabcov') "-" %4.2f (`ci2sexhriskrespsuplabcov') ")" ";" %5.2f (`hradjhriskrespsuplabcov') " (" %4.2f (`ci1adjhriskrespsuplabcov') "-" %4.2f (`ci2adjhriskrespsuplabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0respsuplabcov') ";" ("$ratehrisk0respsuplabcov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Hospitalization$" ";" "QRISK3 >=10%" ";" (`numqrisk1hosplabcov') ";" ("$rateqrisk1hosplabcov") ";" %5.2f (`hrcruqrisk3hosplabcov') " (" %4.2f (`ci1cruqrisk3hosplabcov') "-" %4.2f (`ci2cruqrisk3hosplabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3hosplabcov') " (" %4.2f (`ci1adjqrisk3hosplabcov') "-" %4.2f (`ci2adjqrisk3hosplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0hosplabcov') ";" ("$rateqrisk0hosplabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1hosplabcov') ";" ("$ratehrisk1hosplabcov") ";" %5.2f (`hrcruhriskhosplabcov') " (" %4.2f (`ci1cruhriskhosplabcov') "-" %4.2f (`ci2cruhriskhosplabcov') ")" ";" %5.2f (`hrsexhriskhosplabcov') " (" %4.2f (`ci1sexhriskhosplabcov') "-" %4.2f (`ci2sexhriskhosplabcov') ")" ";" %5.2f (`hradjhriskhosplabcov') " (" %4.2f (`ci1adjhriskhosplabcov') "-" %4.2f (`ci2adjhriskhosplabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0hosplabcov') ";" ("$ratehrisk0hosplabcov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=10%" ";" (`numqrisk1macelabcov') ";" ("$rateqrisk1macelabcov") ";" %5.2f (`hrcruqrisk3macelabcov') " (" %4.2f (`ci1cruqrisk3macelabcov') "-" %4.2f (`ci2cruqrisk3macelabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3macelabcov') " (" %4.2f (`ci1adjqrisk3macelabcov') "-" %4.2f (`ci2adjqrisk3macelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0macelabcov') ";" ("$rateqrisk0macelabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1macelabcov') ";" ("$ratehrisk1macelabcov") ";" %5.2f (`hrcruhriskmacelabcov') " (" %4.2f (`ci1cruhriskmacelabcov') "-" %4.2f (`ci2cruhriskmacelabcov') ")" ";" %5.2f (`hrsexhriskmacelabcov') " (" %4.2f (`ci1sexhriskmacelabcov') "-" %4.2f (`ci2sexhriskmacelabcov') ")" ";" %5.2f (`hradjhriskmacelabcov') " (" %4.2f (`ci1adjhriskmacelabcov') "-" %4.2f (`ci2adjhriskmacelabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0macelabcov') ";" ("$ratehrisk0macelabcov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "ACS" ";" "QRISK3 >=10%"";" (`numqrisk1acslabcov') ";" ("$rateqrisk1acslabcov") ";" %5.2f (`hrcruqrisk3acslabcov') " (" %4.2f (`ci1cruqrisk3acslabcov') "-" %4.2f (`ci2cruqrisk3acslabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3acslabcov') " (" %4.2f (`ci1adjqrisk3acslabcov') "-" %4.2f (`ci2adjqrisk3acslabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0acslabcov') ";" ("$rateqrisk0acslabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1acslabcov') ";" ("$ratehrisk1acslabcov") ";" %5.2f (`hrcruhriskacslabcov') " (" %4.2f (`ci1cruhriskacslabcov') "-" %4.2f (`ci2cruhriskacslabcov') ")" ";" %5.2f (`hrsexhriskacslabcov') " (" %4.2f (`ci1sexhriskacslabcov') "-" %4.2f (`ci2sexhriskacslabcov') ")" ";" %5.2f (`hradjhriskacslabcov') " (" %4.2f (`ci1adjhriskacslabcov') "-" %4.2f (`ci2adjhriskacslabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0acslabcov') ";" ("$ratehrisk0acslabcov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Ischaemic stroke" ";" "QRISK3 >=10%" ";" (`numqrisk1strokelabcov') ";" ("$rateqrisk1strokelabcov") ";" %5.2f (`hrcruqrisk3strokelabcov') " (" %4.2f (`ci1cruqrisk3strokelabcov') "-" %4.2f (`ci2cruqrisk3strokelabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3strokelabcov') " (" %4.2f (`ci1adjqrisk3strokelabcov') "-" %4.2f (`ci2adjqrisk3strokelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0strokelabcov') ";" ("$rateqrisk0strokelabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1strokelabcov') ";" ("$ratehrisk1strokelabcov") ";" %5.2f (`hrcruhriskstrokelabcov') " (" %4.2f (`ci1cruhriskstrokelabcov') "-" %4.2f (`ci2cruhriskstrokelabcov') ")" ";" %5.2f (`hrsexhriskstrokelabcov') " (" %4.2f (`ci1sexhriskstrokelabcov') "-" %4.2f (`ci2sexhriskstrokelabcov') ")" ";" %5.2f (`hradjhriskstrokelabcov') " (" %4.2f (`ci1adjhriskstrokelabcov') "-" %4.2f (`ci2adjhriskstrokelabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0strokelabcov') ";" ("$ratehrisk0strokelabcov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Acute left ventricular failure" ";" "QRISK3 >=10%" ";" (`numqrisk1hflabcov') ";" ("$rateqrisk1hflabcov") ";" %5.2f (`hrcruqrisk3hflabcov') " (" %4.2f (`ci1cruqrisk3hflabcov') "-" %4.2f (`ci2cruqrisk3hflabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3hflabcov') " (" %4.2f (`ci1adjqrisk3hflabcov') "-" %4.2f (`ci2adjqrisk3hflabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0hflabcov') ";" ("$rateqrisk0hflabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1hflabcov') ";" ("$ratehrisk1hflabcov") ";" %5.2f (`hrcruhriskhflabcov') " (" %4.2f (`ci1cruhriskhflabcov') "-" %4.2f (`ci2cruhriskhflabcov') ")" ";" %5.2f (`hrsexhriskhflabcov') " (" %4.2f (`ci1sexhriskhflabcov') "-" %4.2f (`ci2sexhriskhflabcov') ")" ";" %5.2f (`hradjhriskhflabcov') " (" %4.2f (`ci1adjhriskhflabcov') "-" %4.2f (`ci2adjhriskhflabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0hflabcov') ";" ("$ratehrisk0hflabcov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Major ventricular arrhythmia" ";" "QRISK3 >=10%" ";" (`numqrisk1arrhylabcov') ";" ("$rateqrisk1arrhylabcov") ";" %5.2f (`hrcruqrisk3arrhylabcov') " (" %4.2f (`ci1cruqrisk3arrhylabcov') "-" %4.2f (`ci2cruqrisk3arrhylabcov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3arrhylabcov') " (" %4.2f (`ci1adjqrisk3arrhylabcov') "-" %4.2f (`ci2adjqrisk3arrhylabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0arrhylabcov') ";" ("$rateqrisk0arrhylabcov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1arrhylabcov') ";" ("$ratehrisk1arrhylabcov") ";" %5.2f (`hrcruhriskarrhylabcov') " (" %4.2f (`ci1cruhriskarrhylabcov') "-" %4.2f (`ci2cruhriskarrhylabcov') ")" ";" %5.2f (`hrsexhriskarrhylabcov') " (" %4.2f (`ci1sexhriskarrhylabcov') "-" %4.2f (`ci2sexhriskarrhylabcov') ")" ";" %5.2f (`hradjhriskarrhylabcov') " (" %4.2f (`ci1adjhriskarrhylabcov') "-" %4.2f (`ci2adjhriskarrhylabcov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0arrhylabcov') ";" ("$ratehrisk0arrhylabcov") ";" "ref" ";" "ref" ";" "ref" _n
	
cap file close textfile 
file open textfile using "$outputdir/labcovsensqrisk3cox.csv", write replace
file write textfile "sep=;" _n
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >=20%" ";" (`numqrisksens2cdeathlabcov') ";" ("$rateqrisksens2cdeathlabcov") ";" %5.2f (`hrcru2qrisk3_senscdeathlabcov') " (" %4.2f (`ci1cru2qrisk3_senscdeathlabcov') "-" %4.2f (`ci2cru2qrisk3_senscdeathlabcov') ")" ";" %5.2f (`hradj2qrisk3_senscdeathlabcov') " (" %4.2f (`ci1adj2qrisk3_senscdeathlabcov') "-" %4.2f (`ci2adj2qrisk3_senscdeathlabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1cdeathlabcov') ";" ("$rateqrisksens1cdeathlabcov") ";" %5.2f (`hrcru1qrisk3_senscdeathlabcov') " (" %4.2f (`ci1cru1qrisk3_senscdeathlabcov') "-" %4.2f (`ci2cru1qrisk3_senscdeathlabcov') ")" ";" %5.2f (`hradj1qrisk3_senscdeathlabcov') " (" %4.2f (`ci1adj1qrisk3_senscdeathlabcov') "-" %4.2f (`ci2adj1qrisk3_senscdeathlabcov') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisksens0cdeathlabcov') ";" ("$rateqrisksens0cdeathlabcov") ";" "ref" ";" "ref" _n
file write textfile "ICU admission†" ";" "QRISK3 >=20%" ";" (`numqrisksens2iculabcov') ";" ("$rateqrisksens2iculabcov") ";" %5.2f (`hrcru2qrisk3_sensiculabcov') " (" %4.2f (`ci1cru2qrisk3_sensiculabcov') "-" %4.2f (`ci2cru2qrisk3_sensiculabcov') ")" ";" %5.2f (`hradj2qrisk3_sensiculabcov') " (" %4.2f (`ci1adj2qrisk3_sensiculabcov') "-" %4.2f (`ci2adj2qrisk3_sensiculabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1iculabcov') ";" ("$rateqrisksens1iculabcov") ";" %5.2f (`hrcru1qrisk3_sensiculabcov') " (" %4.2f (`ci1cru1qrisk3_sensiculabcov') "-" %4.2f (`ci2cru1qrisk3_sensiculabcov') ")" ";" %5.2f (`hradj1qrisk3_sensiculabcov') " (" %4.2f (`ci1adj1qrisk3_sensiculabcov') "-" %4.2f (`ci2adj1qrisk3_sensiculabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0iculabcov') ";" ("$rateqrisksens0iculabcov") ";" "ref" ";" "ref" _n
file write textfile "Respiratory support‡" ";" "QRISK3 >=20%" ";" (`numqrisksens2respsuplabcov') ";" ("$rateqrisksens2respsuplabcov") ";" %5.2f (`hrcru2qrisk3_sensrespsuplabcov') " (" %4.2f (`ci1cru2qrisk3_sensrespsuplabcov') "-" %4.2f (`ci2cru2qrisk3_sensrespsuplabcov') ")" ";" %5.2f (`hradj2qrisk3_sensrespsuplabcov') " (" %4.2f (`ci1adj2qrisk3_sensrespsuplabcov') "-" %4.2f (`ci2adj2qrisk3_sensrespsuplabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1respsuplabcov') ";" ("$rateqrisksens1respsuplabcov") ";" %5.2f (`hrcru1qrisk3_sensrespsuplabcov') " (" %4.2f (`ci1cru1qrisk3_sensrespsuplabcov') "-" %4.2f (`ci2cru1qrisk3_sensrespsuplabcov') ")" ";" %5.2f (`hradj1qrisk3_sensrespsuplabcov') " (" %4.2f (`ci1adj1qrisk3_sensrespsuplabcov') "-" %4.2f (`ci2adj1qrisk3_sensrespsuplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0respsuplabcov') ";" ("$rateqrisksens0respsuplabcov") ";" "ref" ";" "ref" _n
file write textfile "Hospitalization$" ";" "QRISK3 >=20%" ";" (`numqrisksens2hosplabcov') ";" ("$rateqrisksens2hosplabcov") ";" %5.2f (`hrcru2qrisk3_senshosplabcov') " (" %4.2f (`ci1cru2qrisk3_senshosplabcov') "-" %4.2f (`ci2cru2qrisk3_senshosplabcov') ")" ";" %5.2f (`hradj2qrisk3_senshosplabcov') " (" %4.2f (`ci1adj2qrisk3_senshosplabcov') "-" %4.2f (`ci2adj2qrisk3_senshosplabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1hosplabcov') ";" ("$rateqrisksens1hosplabcov") ";" %5.2f (`hrcru1qrisk3_senshosplabcov') " (" %4.2f (`ci1cru1qrisk3_senshosplabcov') "-" %4.2f (`ci2cru1qrisk3_senshosplabcov') ")" ";" %5.2f (`hradj1qrisk3_senshosplabcov') " (" %4.2f (`ci1adj1qrisk3_senshosplabcov') "-" %4.2f (`ci2adj1qrisk3_senshosplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0hosplabcov') ";" ("$rateqrisksens0hosplabcov") ";" "ref" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=20%" ";" (`numqrisksens2macelabcov') ";" ("$rateqrisksens2macelabcov") ";" %5.2f (`hrcru2qrisk3_sensmacelabcov') " (" %4.2f (`ci1cru2qrisk3_sensmacelabcov') "-" %4.2f (`ci2cru2qrisk3_sensmacelabcov') ")" ";" %5.2f (`hradj2qrisk3_sensmacelabcov') " (" %4.2f (`ci1adj2qrisk3_sensmacelabcov') "-" %4.2f (`ci2adj2qrisk3_sensmacelabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1macelabcov') ";" ("$rateqrisksens1macelabcov") ";" %5.2f (`hrcru1qrisk3_sensmacelabcov') " (" %4.2f (`ci1cru1qrisk3_sensmacelabcov') "-" %4.2f (`ci2cru1qrisk3_sensmacelabcov') ")" ";" %5.2f (`hradj1qrisk3_sensmacelabcov') " (" %4.2f (`ci1adj1qrisk3_sensmacelabcov') "-" %4.2f (`ci2adj1qrisk3_sensmacelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0macelabcov') ";" ("$rateqrisksens0macelabcov") ";" "ref" ";" "ref" _n
file write textfile "ACS" ";" "QRISK3 >=20%" ";" (`numqrisksens2acslabcov') ";" ("$rateqrisksens2acslabcov") ";" %5.2f (`hrcru2qrisk3_sensacslabcov') " (" %4.2f (`ci1cru2qrisk3_sensacslabcov') "-" %4.2f (`ci2cru2qrisk3_sensacslabcov') ")" ";" %5.2f (`hradj2qrisk3_sensacslabcov') " (" %4.2f (`ci1adj2qrisk3_sensacslabcov') "-" %4.2f (`ci2adj2qrisk3_sensacslabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1acslabcov') ";" ("$rateqrisksens1acslabcov") ";" %5.2f (`hrcru1qrisk3_sensacslabcov') " (" %4.2f (`ci1cru1qrisk3_sensacslabcov') "-" %4.2f (`ci2cru1qrisk3_sensacslabcov') ")" ";" %5.2f (`hradj1qrisk3_sensacslabcov') " (" %4.2f (`ci1adj1qrisk3_sensacslabcov') "-" %4.2f (`ci2adj1qrisk3_sensacslabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0acslabcov') ";" ("$rateqrisksens0acslabcov") ";" "ref" ";" "ref" _n
file write textfile "Ischaemic stroke" ";" "QRISK3 >=20%" ";" (`numqrisksens2strokelabcov') ";" ("$rateqrisksens2strokelabcov") ";" %5.2f (`hrcru2qrisk3_sensstrokelabcov') " (" %4.2f (`ci1cru2qrisk3_sensstrokelabcov') "-" %4.2f (`ci2cru2qrisk3_sensstrokelabcov') ")" ";" %5.2f (`hradj2qrisk3_sensstrokelabcov') " (" %4.2f (`ci1adj2qrisk3_sensstrokelabcov') "-" %4.2f (`ci2adj2qrisk3_sensstrokelabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1strokelabcov') ";" ("$rateqrisksens1strokelabcov") ";" %5.2f (`hrcru1qrisk3_sensstrokelabcov') " (" %4.2f (`ci1cru1qrisk3_sensstrokelabcov') "-" %4.2f (`ci2cru1qrisk3_sensstrokelabcov') ")" ";" %5.2f (`hradj1qrisk3_sensstrokelabcov') " (" %4.2f (`ci1adj1qrisk3_sensstrokelabcov') "-" %4.2f (`ci2adj1qrisk3_sensstrokelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0strokelabcov') ";" ("$rateqrisksens0strokelabcov") ";" "ref" ";" "ref" _n
file write textfile "Acute left ventricular failure" ";" "QRISK3 >=20%" ";" (`numqrisksens2hflabcov') ";" ("$rateqrisksens2hflabcov") ";" %5.2f (`hrcru2qrisk3_senshflabcov') " (" %4.2f (`ci1cru2qrisk3_senshflabcov') "-" %4.2f (`ci2cru2qrisk3_senshflabcov') ")" ";" %5.2f (`hradj2qrisk3_senshflabcov') " (" %4.2f (`ci1adj2qrisk3_senshflabcov') "-" %4.2f (`ci2adj2qrisk3_senshflabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1hflabcov') ";" ("$rateqrisksens1hflabcov") ";" %5.2f (`hrcru1qrisk3_senshflabcov') " (" %4.2f (`ci1cru1qrisk3_senshflabcov') "-" %4.2f (`ci2cru1qrisk3_senshflabcov') ")" ";" %5.2f (`hradj1qrisk3_senshflabcov') " (" %4.2f (`ci1adj1qrisk3_senshflabcov') "-" %4.2f (`ci2adj1qrisk3_senshflabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0hflabcov') ";" ("$rateqrisksens0hflabcov") ";" "ref" ";" "ref" _n
file write textfile "Major ventricular arrhythmia" ";" "QRISK3 >=20%" ";" (`numqrisksens2arrhylabcov') ";" ("$rateqrisksens2arrhylabcov") ";" %5.2f (`hrcru2qrisk3_sensarrhylabcov') " (" %4.2f (`ci1cru2qrisk3_sensarrhylabcov') "-" %4.2f (`ci2cru2qrisk3_sensarrhylabcov') ")" ";" %5.2f (`hradj2qrisk3_sensarrhylabcov') " (" %4.2f (`ci1adj2qrisk3_sensarrhylabcov') "-" %4.2f (`ci2adj2qrisk3_sensarrhylabcov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1arrhylabcov') ";" ("$rateqrisksens1arrhylabcov") ";" %5.2f (`hrcru1qrisk3_sensarrhylabcov') " (" %4.2f (`ci1cru1qrisk3_sensarrhylabcov') "-" %4.2f (`ci2cru1qrisk3_sensarrhylabcov') ")" ";" %5.2f (`hradj1qrisk3_sensarrhylabcov') " (" %4.2f (`ci1adj1qrisk3_sensarrhylabcov') "-" %4.2f (`ci2adj1qrisk3_sensarrhylabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0arrhylabcov') ";" ("$rateqrisksens0arrhylabcov") ";" "ref" ";" "ref" _n
	
cap file close textfile 
file open textfile using "$outputdir/labcovqrisk2cox.csv", write replace
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death*" ";" "QRISK2 >=10%" ";" (`numqrisk2_1cdeathlabcov') ";" ("$rateqrisk2_1cdeathlabcov") ";" %5.2f (`hrcruqrisk2cdeathlabcov') " (" %4.2f (`ci1cruqrisk2cdeathlabcov') "-" %4.2f (`ci2cruqrisk2cdeathlabcov') ")" ";" %5.2f (`hradjqrisk2cdeathlabcov') " (" %4.2f (`ci1adjqrisk2cdeathlabcov') "-" %4.2f (`ci2adjqrisk2cdeathlabcov') ")" _n
file write textfile ";" "QRISK2 <10%"  ";" (`numqrisk2_0cdeathlabcov') ";" ("$rateqrisk2_0cdeathlabcov") ";" "ref" ";" "ref" _n
file write textfile "ICU admission†" ";" "QRISK2 >=10%" ";" (`numqrisk2_1iculabcov') ";" ("$rateqrisk2_1iculabcov") ";" %5.2f (`hrcruqrisk2iculabcov') " (" %4.2f (`ci1cruqrisk2iculabcov') "-" %4.2f (`ci2cruqrisk2iculabcov') ")" ";" %5.2f (`hradjqrisk2iculabcov') " (" %4.2f (`ci1adjqrisk2iculabcov') "-" %4.2f (`ci2adjqrisk2iculabcov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0iculabcov') ";" ("$rateqrisk2_0iculabcov") ";" "ref" ";" "ref" _n
file write textfile "Respiratory support‡" ";" "QRISK2 >=10%" ";" (`numqrisk2_1respsuplabcov') ";" ("$rateqrisk2_1respsuplabcov") ";" %5.2f (`hrcruqrisk2respsuplabcov') " (" %4.2f (`ci1cruqrisk2respsuplabcov') "-" %4.2f (`ci2cruqrisk2respsuplabcov') ")" ";" %5.2f (`hradjqrisk2respsuplabcov') " (" %4.2f (`ci1adjqrisk2respsuplabcov') "-" %4.2f (`ci2adjqrisk2respsuplabcov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0respsuplabcov') ";" ("$rateqrisk2_0respsuplabcov") ";" "ref" ";" "ref" _n
file write textfile "Hospitalization$" ";" "QRISK2 >=10%" ";" (`numqrisk2_1hosplabcov') ";" ("$rateqrisk2_1hosplabcov") ";" %5.2f (`hrcruqrisk2hosplabcov') " (" %4.2f (`ci1cruqrisk2hosplabcov') "-" %4.2f (`ci2cruqrisk2hosplabcov') ")" ";" %5.2f (`hradjqrisk2hosplabcov') " (" %4.2f (`ci1adjqrisk2hosplabcov') "-" %4.2f (`ci2adjqrisk2hosplabcov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0hosplabcov') ";" ("$rateqrisk2_0hosplabcov") ";" "ref" ";" "ref" _n
file write textfile "MACE" ";" "QRISK2 >=10%" ";" (`numqrisk2_1macelabcov') ";" ("$rateqrisk2_1macelabcov") ";" %5.2f (`hrcruqrisk2macelabcov') " (" %4.2f (`ci1cruqrisk2macelabcov') "-" %4.2f (`ci2cruqrisk2macelabcov') ")" ";" %5.2f (`hradjqrisk2macelabcov') " (" %4.2f (`ci1adjqrisk2macelabcov') "-" %4.2f (`ci2adjqrisk2macelabcov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0macelabcov') ";" ("$rateqrisk2_0macelabcov") ";" "ref" ";" "ref" _n
file write textfile "ACS" ";" "QRISK3 >=10%"";" (`numqrisk2_1acslabcov') ";" ("$rateqrisk2_1acslabcov") ";" %5.2f (`hrcruqrisk2acslabcov') " (" %4.2f (`ci1cruqrisk2acslabcov') "-" %4.2f (`ci2cruqrisk2acslabcov') ")" ";" %5.2f (`hradjqrisk2acslabcov') " (" %4.2f (`ci1adjqrisk2acslabcov') "-" %4.2f (`ci2adjqrisk2acslabcov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0acslabcov') ";" ("$rateqrisk2_0acslabcov") ";" "ref" ";" "ref" _n
file write textfile "Ischaemic stroke" ";" "QRISK2 >=10%" ";" (`numqrisk2_1strokelabcov') ";" ("$rateqrisk2_1strokelabcov") ";" %5.2f (`hrcruqrisk2strokelabcov') " (" %4.2f (`ci1cruqrisk2strokelabcov') "-" %4.2f (`ci2cruqrisk2strokelabcov') ")" ";" %5.2f (`hradjqrisk2strokelabcov') " (" %4.2f (`ci1adjqrisk2strokelabcov') "-" %4.2f (`ci2adjqrisk2strokelabcov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0strokelabcov') ";" ("$rateqrisk2_0strokelabcov") ";" "ref" ";" "ref" _n
file write textfile "Acute left ventricular failure" ";" "QRISK2 >=10%" ";" (`numqrisk2_1hflabcov') ";" ("$rateqrisk2_1hflabcov") ";" %5.2f (`hrcruqrisk2hflabcov') " (" %4.2f (`ci1cruqrisk2hflabcov') "-" %4.2f (`ci2cruqrisk2hflabcov') ")" ";" %5.2f (`hradjqrisk2hflabcov') " (" %4.2f (`ci1adjqrisk2hflabcov') "-" %4.2f (`ci2adjqrisk2hflabcov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0hflabcov') ";" ("$rateqrisk2_0hflabcov") ";" "ref" ";" "ref" _n
file write textfile "Major ventricular arrhythmia" ";" "QRISK2 >=10%" ";" (`numqrisk2_1arrhylabcov') ";" ("$rateqrisk2_1arrhylabcov") ";" %5.2f (`hrcruqrisk2arrhylabcov') " (" %4.2f (`ci1cruqrisk2arrhylabcov') "-" %4.2f (`ci2cruqrisk2arrhylabcov') ")" ";" %5.2f (`hradjqrisk2arrhylabcov') " (" %4.2f (`ci1adjqrisk2arrhylabcov') "-" %4.2f (`ci2adjqrisk2arrhylabcov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0arrhylabcov') ";" ("$rateqrisk2_0arrhylabcov") ";" "ref" ";" "ref" _n

cap file close textfile 
file open textfile using "$outputdir/labcovdeathsenscox.csv", write replace
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Sex-adjusted HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death within 28 days*" ";" "QRISK3 >10%" ";" (`numqrisk1cdlabcov28') ";" ("$rateqrisk1cdlabcov28") ";" %5.2f (`hrcruqrisk3cdlabcov28') " (" %4.2f (`ci1cruqrisk3cdlabcov28') "-" %4.2f (`ci2cruqrisk3cdlabcov28') ")" ";" "NA" ";" %5.2f (`hradjqrisk3cdlabcov28') " (" %4.2f (`ci1adjqrisk3cdlabcov28') "-" %4.2f (`ci2adjqrisk3cdlabcov28') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisk0cdlabcov28') ";" ("$rateqrisk0cdlabcov28") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1cdlabcov28') ";" ("$ratehrisk1cdlabcov28") ";" %5.2f (`hrcruhriskcdlabcov28') " (" %4.2f (`ci1cruhriskcdlabcov28') "-" %4.2f (`ci2cruhriskcdlabcov28') ")" ";" %5.2f (`hrsexhriskcdlabcov28') " (" %4.2f (`ci1sexhriskcdlabcov28') "-" %4.2f (`ci2sexhriskcdlabcov28') ")" ";" %5.2f (`hradjhriskcdlabcov28') " (" %4.2f (`ci1adjhriskcdlabcov28') "-" %4.2f (`ci2adjhriskcdlabcov28') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0cdlabcov28') ";" ("$ratehrisk0cdlabcov28") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "All-cause death within 28 days" ";" "QRISK3 >10%" ";" (`numqrisk1dlabcov28') ";" ("$rateqrisk1dlabcov28days") ";" %5.2f (`hrcruqrisk3dlabcov28') " (" %4.2f (`ci1cruqrisk3dlabcov28') "-" %4.2f (`ci2cruqrisk3dlabcov28') ")" ";" "NA" ";" %5.2f (`hradjqrisk3dlabcov28') " (" %4.2f (`ci1adjqrisk3dlabcov28') "-" %4.2f (`ci2adjqrisk3dlabcov28') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisk0dlabcov28') ";" ("$rateqrisk0dlabcov28") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1dlabcov28') ";" ("$ratehrisk1dlabcov28") ";" %5.2f (`hrcruhriskdlabcov28') " (" %4.2f (`ci1cruhriskdlabcov28') "-" %4.2f (`ci2cruhriskdlabcov28') ")" ";" %5.2f (`hrsexhriskdlabcov28') " (" %4.2f (`ci1sexhriskdlabcov28') "-" %4.2f (`ci2sexhriskdlabcov28') ")" ";" %5.2f (`hradjhriskdlabcov28') " (" %4.2f (`ci1adjhriskdlabcov28') "-" %4.2f (`ci2adjhriskdlabcov28') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0dlabcov28') ";" ("$ratehrisk0dlabcov28") ";" "ref" ";" "ref" ";" "ref" _n
cap file close textfile 


graph combine "$outputdir\km_cdeathlabcovqrisk3" "$outputdir\km_cdeathlabcovhrisk", col(2) 
graph save "Graph" "$outputdir\km_cdeathlabcov.gph"
graph export "$outputdir\km_cdeathlabcov.tif", as(tif) name("Graph")

graph combine "$outputdir\km_iculabcovqrisk3" "$outputdir\km_iculabcovhrisk", col(2)
graph save "Graph" "$outputdir\km_iculabcov.gph"
graph export "$outputdir\km_iculabcov.tif", as(tif) name("Graph")
 
graph combine "$outputdir\km_respsuplabcovqrisk3" "$outputdir\km_respsuplabcovhrisk", col(2)
graph save "Graph" "$outputdir\km_respsuplabcov.gph"
graph export "$outputdir\km_respsuplabcov.tif", as(tif) name("Graph")

graph combine "$outputdir\km_hosplabcovqrisk3" "$outputdir\km_hosplabcovhrisk", col(2)
graph save "Graph" "$outputdir\km_hosplabcov.gph"
graph export "$outputdir\km_hosplabcov.tif", as(tif) name("Graph")

graph combine "$outputdir\km_macelabcovqrisk3" "$outputdir\km_macelabcovhrisk", col(2)
graph save "Graph" "$outputdir\km_macelabcov.gph"
graph export "$outputdir\km_macelabcov.tif", as(tif) name("Graph")