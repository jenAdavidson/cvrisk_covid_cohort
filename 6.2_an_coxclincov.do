
log using "$logdir/clincov.log", replace	
/*******************************************************************************
#1. Loop through datasets
*******************************************************************************/

local outcome cdeathclincov cdclincov28 dclincov28 hospclincov maceclincov acsclincov strokeclincov hfclincov arrhyclincov 

use "$datadir/clincovdataset", clear


/*******************************************************************************
#3. Number of events
*******************************************************************************/
	
	
*rename variables which are too long for local	
rename arrhythmiaclincov arrhyclincov 
rename enddate_arrhythmiaclincov enddate_arrhyclincov
rename cdeathclincov28days cdclincov28  
rename enddate_cdeathclincov28days enddate_cdclincov28
rename deathclincov28days dclincov28  
rename enddate_deathclincov28days enddate_dclincov28
	
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
	
	foreach risk in qrisk3 hrisk qrisk3_sens qrisk2 {
		/*sts graph, by(`risk')
		graph save "$outputdir/km_clincov`cond'", replace*/
	
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
			stcox i.`risk' i.ageband i.sex, base 
			local hrsex`risk'`cond'=exp(_b[1.`risk'])
			local ci1sex`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2sex`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		
			stcox i.`risk' i.age i.sex i.ethrisk i.townsend2011_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd /*cons_countpriorb*/ i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppressed i.b_impotence2, base // model with non-imputed variables
			local hradj`risk'`cond'=exp(_b[1.`risk'])
			local ci1adj`risk'`cond'=exp(_b[1.`risk']-1.96*_se[1.`risk']) 
			local ci2adj`risk'`cond'=exp(_b[1.`risk']+1.96*_se[1.`risk'])
		
			stcox i.`risk' i.age i.sex i.ethrisk i.townsend2011_5 i.bmigrp rati i.smoke_cat i.highalcintake i.fh_cvd /*cons_countpriorb*/ i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppressed /*i.b_impotence2*/, base // model with imputed variables
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
file open textfile using "$outputdir/clincovmaincox.csv", write replace
file write textfile "sep=;" _n
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Age- and sex-adjusted HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >=10%" ";" (`numqrisk1cdeathclincov') ";" ("$rateqrisk1cdeathclincov") ";" %5.2f (`hrcruqrisk3cdeathclincov') " (" %4.2f (`ci1cruqrisk3cdeathclincov') "-" %4.2f (`ci2cruqrisk3cdeathclincov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3cdeathclincov') " (" %4.2f (`ci1adjqrisk3cdeathclincov') "-" %4.2f (`ci2adjqrisk3cdeathclincov') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisk0cdeathclincov') ";" ("$rateqrisk0cdeathclincov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1cdeathclincov') ";" ("$ratehrisk1cdeathclincov") ";" %5.2f (`hrcruhriskcdeathclincov') " (" %4.2f (`ci1cruhriskcdeathclincov') "-" %4.2f (`ci2cruhriskcdeathclincov') ")" ";" %5.2f (`hrsexhriskcdeathclincov') " (" %4.2f (`ci1sexhriskcdeathclincov') "-" %4.2f (`ci2sexhriskcdeathclincov') ")" ";" %5.2f (`hradjhriskcdeathclincov') " (" %4.2f (`ci1adjhriskcdeathclincov') "-" %4.2f (`ci2adjhriskcdeathclincov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0cdeathclincov') ";" ("$ratehrisk0cdeathclincov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Hospitalization$" ";" "QRISK3 >=10%" ";" (`numqrisk1hospclincov') ";" ("$rateqrisk1hospclincov") ";" %5.2f (`hrcruqrisk3hospclincov') " (" %4.2f (`ci1cruqrisk3hospclincov') "-" %4.2f (`ci2cruqrisk3hospclincov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3hospclincov') " (" %4.2f (`ci1adjqrisk3hospclincov') "-" %4.2f (`ci2adjqrisk3hospclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0hospclincov') ";" ("$rateqrisk0hospclincov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1hospclincov') ";" ("$ratehrisk1hospclincov") ";" %5.2f (`hrcruhriskhospclincov') " (" %4.2f (`ci1cruhriskhospclincov') "-" %4.2f (`ci2cruhriskhospclincov') ")" ";" %5.2f (`hrsexhriskhospclincov') " (" %4.2f (`ci1sexhriskhospclincov') "-" %4.2f (`ci2sexhriskhospclincov') ")" ";" %5.2f (`hradjhriskhospclincov') " (" %4.2f (`ci1adjhriskhospclincov') "-" %4.2f (`ci2adjhriskhospclincov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0hospclincov') ";" ("$ratehrisk0hospclincov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=10%" ";" (`numqrisk1maceclincov') ";" ("$rateqrisk1maceclincov") ";" %5.2f (`hrcruqrisk3maceclincov') " (" %4.2f (`ci1cruqrisk3maceclincov') "-" %4.2f (`ci2cruqrisk3maceclincov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3maceclincov') " (" %4.2f (`ci1adjqrisk3maceclincov') "-" %4.2f (`ci2adjqrisk3maceclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0maceclincov') ";" ("$rateqrisk0maceclincov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1maceclincov') ";" ("$ratehrisk1maceclincov") ";" %5.2f (`hrcruhriskmaceclincov') " (" %4.2f (`ci1cruhriskmaceclincov') "-" %4.2f (`ci2cruhriskmaceclincov') ")" ";" %5.2f (`hrsexhriskmaceclincov') " (" %4.2f (`ci1sexhriskmaceclincov') "-" %4.2f (`ci2sexhriskmaceclincov') ")" ";" %5.2f (`hradjhriskmaceclincov') " (" %4.2f (`ci1adjhriskmaceclincov') "-" %4.2f (`ci2adjhriskmaceclincov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0maceclincov') ";" ("$ratehrisk0maceclincov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "ACS" ";" "QRISK3 >=10%"";" (`numqrisk1acsclincov') ";" ("$rateqrisk1acsclincov") ";" %5.2f (`hrcruqrisk3acsclincov') " (" %4.2f (`ci1cruqrisk3acsclincov') "-" %4.2f (`ci2cruqrisk3acsclincov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3acsclincov') " (" %4.2f (`ci1adjqrisk3acsclincov') "-" %4.2f (`ci2adjqrisk3acsclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0acsclincov') ";" ("$rateqrisk0acsclincov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1acsclincov') ";" ("$ratehrisk1acsclincov") ";" %5.2f (`hrcruhriskacsclincov') " (" %4.2f (`ci1cruhriskacsclincov') "-" %4.2f (`ci2cruhriskacsclincov') ")" ";" %5.2f (`hrsexhriskacsclincov') " (" %4.2f (`ci1sexhriskacsclincov') "-" %4.2f (`ci2sexhriskacsclincov') ")" ";" %5.2f (`hradjhriskacsclincov') " (" %4.2f (`ci1adjhriskacsclincov') "-" %4.2f (`ci2adjhriskacsclincov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0acsclincov') ";" ("$ratehrisk0acsclincov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Ischaemic stroke" ";" "QRISK3 >=10%" ";" (`numqrisk1strokeclincov') ";" ("$rateqrisk1strokeclincov") ";" %5.2f (`hrcruqrisk3strokeclincov') " (" %4.2f (`ci1cruqrisk3strokeclincov') "-" %4.2f (`ci2cruqrisk3strokeclincov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3strokeclincov') " (" %4.2f (`ci1adjqrisk3strokeclincov') "-" %4.2f (`ci2adjqrisk3strokeclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0strokeclincov') ";" ("$rateqrisk0strokeclincov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1strokeclincov') ";" ("$ratehrisk1strokeclincov") ";" %5.2f (`hrcruhriskstrokeclincov') " (" %4.2f (`ci1cruhriskstrokeclincov') "-" %4.2f (`ci2cruhriskstrokeclincov') ")" ";" %5.2f (`hrsexhriskstrokeclincov') " (" %4.2f (`ci1sexhriskstrokeclincov') "-" %4.2f (`ci2sexhriskstrokeclincov') ")" ";" %5.2f (`hradjhriskstrokeclincov') " (" %4.2f (`ci1adjhriskstrokeclincov') "-" %4.2f (`ci2adjhriskstrokeclincov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0strokeclincov') ";" ("$ratehrisk0strokeclincov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Acute left ventricular failure" ";" "QRISK3 >=10%" ";" (`numqrisk1hfclincov') ";" ("$rateqrisk1hfclincov") ";" %5.2f (`hrcruqrisk3hfclincov') " (" %4.2f (`ci1cruqrisk3hfclincov') "-" %4.2f (`ci2cruqrisk3hfclincov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3hfclincov') " (" %4.2f (`ci1adjqrisk3hfclincov') "-" %4.2f (`ci2adjqrisk3hfclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0hfclincov') ";" ("$rateqrisk0hfclincov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1hfclincov') ";" ("$ratehrisk1hfclincov") ";" %5.2f (`hrcruhriskhfclincov') " (" %4.2f (`ci1cruhriskhfclincov') "-" %4.2f (`ci2cruhriskhfclincov') ")" ";" %5.2f (`hrsexhriskhfclincov') " (" %4.2f (`ci1sexhriskhfclincov') "-" %4.2f (`ci2sexhriskhfclincov') ")" ";" %5.2f (`hradjhriskhfclincov') " (" %4.2f (`ci1adjhriskhfclincov') "-" %4.2f (`ci2adjhriskhfclincov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0hfclincov') ";" ("$ratehrisk0hfclincov") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "Major ventricular arrhythmia" ";" "QRISK3 >=10%" ";" (`numqrisk1arrhyclincov') ";" ("$rateqrisk1arrhyclincov") ";" %5.2f (`hrcruqrisk3arrhyclincov') " (" %4.2f (`ci1cruqrisk3arrhyclincov') "-" %4.2f (`ci2cruqrisk3arrhyclincov') ")" ";" "NA" ";" %5.2f (`hradjqrisk3arrhyclincov') " (" %4.2f (`ci1adjqrisk3arrhyclincov') "-" %4.2f (`ci2adjqrisk3arrhyclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisk0arrhyclincov') ";" ("$rateqrisk0arrhyclincov") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1arrhyclincov') ";" ("$ratehrisk1arrhyclincov") ";" %5.2f (`hrcruhriskarrhyclincov') " (" %4.2f (`ci1cruhriskarrhyclincov') "-" %4.2f (`ci2cruhriskarrhyclincov') ")" ";" %5.2f (`hrsexhriskarrhyclincov') " (" %4.2f (`ci1sexhriskarrhyclincov') "-" %4.2f (`ci2sexhriskarrhyclincov') ")" ";" %5.2f (`hradjhriskarrhyclincov') " (" %4.2f (`ci1adjhriskarrhyclincov') "-" %4.2f (`ci2adjhriskarrhyclincov') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0arrhyclincov') ";" ("$ratehrisk0arrhyclincov") ";" "ref" ";" "ref" ";" "ref" _n
	
cap file close textfile 
file open textfile using "$outputdir/clincovsensqrisk3cox.csv", write replace
file write textfile "sep=;" _n
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >=20%" ";" (`numqrisksens2cdeathclincov') ";" ("$rateqrisksens2cdeathclincov") ";" %5.2f (`hrcru2qrisk3_senscdeathclincov') " (" %4.2f (`ci1cru2qrisk3_senscdeathclincov') "-" %4.2f (`ci2cru2qrisk3_senscdeathclincov') ")" ";" %5.2f (`hradj2qrisk3_senscdeathclincov') " (" %4.2f (`ci1adj2qrisk3_senscdeathclincov') "-" %4.2f (`ci2adj2qrisk3_senscdeathclincov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1cdeathclincov') ";" ("$rateqrisksens1cdeathclincov") ";" %5.2f (`hrcru1qrisk3_senscdeathclincov') " (" %4.2f (`ci1cru1qrisk3_senscdeathclincov') "-" %4.2f (`ci2cru1qrisk3_senscdeathclincov') ")" ";" %5.2f (`hradj1qrisk3_senscdeathclincov') " (" %4.2f (`ci1adj1qrisk3_senscdeathclincov') "-" %4.2f (`ci2adj1qrisk3_senscdeathclincov') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisksens0cdeathclincov') ";" ("$rateqrisksens0cdeathclincov") ";" "ref" ";" "ref" _n
file write textfile "Hospitalization$" ";" "QRISK3 >=20%" ";" (`numqrisksens2hospclincov') ";" ("$rateqrisksens2hospclincov") ";" %5.2f (`hrcru2qrisk3_senshospclincov') " (" %4.2f (`ci1cru2qrisk3_senshospclincov') "-" %4.2f (`ci2cru2qrisk3_senshospclincov') ")" ";" %5.2f (`hradj2qrisk3_senshospclincov') " (" %4.2f (`ci1adj2qrisk3_senshospclincov') "-" %4.2f (`ci2adj2qrisk3_senshospclincov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1hospclincov') ";" ("$rateqrisksens1hospclincov") ";" %5.2f (`hrcru1qrisk3_senshospclincov') " (" %4.2f (`ci1cru1qrisk3_senshospclincov') "-" %4.2f (`ci2cru1qrisk3_senshospclincov') ")" ";" %5.2f (`hradj1qrisk3_senshospclincov') " (" %4.2f (`ci1adj1qrisk3_senshospclincov') "-" %4.2f (`ci2adj1qrisk3_senshospclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0hospclincov') ";" ("$rateqrisksens0hospclincov") ";" "ref" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=20%" ";" (`numqrisksens2maceclincov') ";" ("$rateqrisksens2maceclincov") ";" %5.2f (`hrcru2qrisk3_sensmaceclincov') " (" %4.2f (`ci1cru2qrisk3_sensmaceclincov') "-" %4.2f (`ci2cru2qrisk3_sensmaceclincov') ")" ";" %5.2f (`hradj2qrisk3_sensmaceclincov') " (" %4.2f (`ci1adj2qrisk3_sensmaceclincov') "-" %4.2f (`ci2adj2qrisk3_sensmaceclincov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1maceclincov') ";" ("$rateqrisksens1maceclincov") ";" %5.2f (`hrcru1qrisk3_sensmaceclincov') " (" %4.2f (`ci1cru1qrisk3_sensmaceclincov') "-" %4.2f (`ci2cru1qrisk3_sensmaceclincov') ")" ";" %5.2f (`hradj1qrisk3_sensmaceclincov') " (" %4.2f (`ci1adj1qrisk3_sensmaceclincov') "-" %4.2f (`ci2adj1qrisk3_sensmaceclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0maceclincov') ";" ("$rateqrisksens0maceclincov") ";" "ref" ";" "ref" _n
file write textfile "ACS" ";" "QRISK3 >=20%" ";" (`numqrisksens2acsclincov') ";" ("$rateqrisksens2acsclincov") ";" %5.2f (`hrcru2qrisk3_sensacsclincov') " (" %4.2f (`ci1cru2qrisk3_sensacsclincov') "-" %4.2f (`ci2cru2qrisk3_sensacsclincov') ")" ";" %5.2f (`hradj2qrisk3_sensacsclincov') " (" %4.2f (`ci1adj2qrisk3_sensacsclincov') "-" %4.2f (`ci2adj2qrisk3_sensacsclincov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1acsclincov') ";" ("$rateqrisksens1acsclincov") ";" %5.2f (`hrcru1qrisk3_sensacsclincov') " (" %4.2f (`ci1cru1qrisk3_sensacsclincov') "-" %4.2f (`ci2cru1qrisk3_sensacsclincov') ")" ";" %5.2f (`hradj1qrisk3_sensacsclincov') " (" %4.2f (`ci1adj1qrisk3_sensacsclincov') "-" %4.2f (`ci2adj1qrisk3_sensacsclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0acsclincov') ";" ("$rateqrisksens0acsclincov") ";" "ref" ";" "ref" _n
file write textfile "Ischaemic stroke" ";" "QRISK3 >=20%" ";" (`numqrisksens2strokeclincov') ";" ("$rateqrisksens2strokeclincov") ";" %5.2f (`hrcru2qrisk3_sensstrokeclincov') " (" %4.2f (`ci1cru2qrisk3_sensstrokeclincov') "-" %4.2f (`ci2cru2qrisk3_sensstrokeclincov') ")" ";" %5.2f (`hradj2qrisk3_sensstrokeclincov') " (" %4.2f (`ci1adj2qrisk3_sensstrokeclincov') "-" %4.2f (`ci2adj2qrisk3_sensstrokeclincov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1strokeclincov') ";" ("$rateqrisksens1strokeclincov") ";" %5.2f (`hrcru1qrisk3_sensstrokeclincov') " (" %4.2f (`ci1cru1qrisk3_sensstrokeclincov') "-" %4.2f (`ci2cru1qrisk3_sensstrokeclincov') ")" ";" %5.2f (`hradj1qrisk3_sensstrokeclincov') " (" %4.2f (`ci1adj1qrisk3_sensstrokeclincov') "-" %4.2f (`ci2adj1qrisk3_sensstrokeclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0strokeclincov') ";" ("$rateqrisksens0strokeclincov") ";" "ref" ";" "ref" _n
file write textfile "Acute left ventricular failure" ";" "QRISK3 >=20%" ";" (`numqrisksens2hfclincov') ";" ("$rateqrisksens2hfclincov") ";" %5.2f (`hrcru2qrisk3_senshfclincov') " (" %4.2f (`ci1cru2qrisk3_senshfclincov') "-" %4.2f (`ci2cru2qrisk3_senshfclincov') ")" ";" %5.2f (`hradj2qrisk3_senshfclincov') " (" %4.2f (`ci1adj2qrisk3_senshfclincov') "-" %4.2f (`ci2adj2qrisk3_senshfclincov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1hfclincov') ";" ("$rateqrisksens1hfclincov") ";" %5.2f (`hrcru1qrisk3_senshfclincov') " (" %4.2f (`ci1cru1qrisk3_senshfclincov') "-" %4.2f (`ci2cru1qrisk3_senshfclincov') ")" ";" %5.2f (`hradj1qrisk3_senshfclincov') " (" %4.2f (`ci1adj1qrisk3_senshfclincov') "-" %4.2f (`ci2adj1qrisk3_senshfclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0hfclincov') ";" ("$rateqrisksens0hfclincov") ";" "ref" ";" "ref" _n
file write textfile "Major ventricular arrhythmia" ";" "QRISK3 >=20%" ";" (`numqrisksens2arrhyclincov') ";" ("$rateqrisksens2arrhyclincov") ";" %5.2f (`hrcru2qrisk3_sensarrhyclincov') " (" %4.2f (`ci1cru2qrisk3_sensarrhyclincov') "-" %4.2f (`ci2cru2qrisk3_sensarrhyclincov') ")" ";" %5.2f (`hradj2qrisk3_sensarrhyclincov') " (" %4.2f (`ci1adj2qrisk3_sensarrhyclincov') "-" %4.2f (`ci2adj2qrisk3_sensarrhyclincov') ")" _n
file write textfile ";" "QRISK3 10-19%" ";" (`numqrisksens1arrhyclincov') ";" ("$rateqrisksens1arrhyclincov") ";" %5.2f (`hrcru1qrisk3_sensarrhyclincov') " (" %4.2f (`ci1cru1qrisk3_sensarrhyclincov') "-" %4.2f (`ci2cru1qrisk3_sensarrhyclincov') ")" ";" %5.2f (`hradj1qrisk3_sensarrhyclincov') " (" %4.2f (`ci1adj1qrisk3_sensarrhyclincov') "-" %4.2f (`ci2adj1qrisk3_sensarrhyclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" (`numqrisksens0arrhyclincov') ";" ("$rateqrisksens0arrhyclincov") ";" "ref" ";" "ref" _n
	
cap file close textfile 
file open textfile using "$outputdir/clincovqrisk2cox.csv", write replace
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death*" ";" "QRISK2 >=10%" ";" (`numqrisk2_1cdeathclincov') ";" ("$rateqrisk2_1cdeathclincov") ";" %5.2f (`hrcruqrisk2cdeathclincov') " (" %4.2f (`ci1cruqrisk2cdeathclincov') "-" %4.2f (`ci2cruqrisk2cdeathclincov') ")" ";" %5.2f (`hradjqrisk2cdeathclincov') " (" %4.2f (`ci1adjqrisk2cdeathclincov') "-" %4.2f (`ci2adjqrisk2cdeathclincov') ")" _n
file write textfile ";" "QRISK2 <10%"  ";" (`numqrisk2_0cdeathclincov') ";" ("$rateqrisk2_0cdeathclincov") ";" "ref" ";" "ref" _n
file write textfile "Hospitalization$" ";" "QRISK2 >=10%" ";" (`numqrisk2_1hospclincov') ";" ("$rateqrisk2_1hospclincov") ";" %5.2f (`hrcruqrisk2hospclincov') " (" %4.2f (`ci1cruqrisk2hospclincov') "-" %4.2f (`ci2cruqrisk2hospclincov') ")" ";" %5.2f (`hradjqrisk2hospclincov') " (" %4.2f (`ci1adjqrisk2hospclincov') "-" %4.2f (`ci2adjqrisk2hospclincov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0hospclincov') ";" ("$rateqrisk2_0hospclincov") ";" "ref" ";" "ref" _n
file write textfile "MACE" ";" "QRISK2 >=10%" ";" (`numqrisk2_1maceclincov') ";" ("$rateqrisk2_1maceclincov") ";" %5.2f (`hrcruqrisk2maceclincov') " (" %4.2f (`ci1cruqrisk2maceclincov') "-" %4.2f (`ci2cruqrisk2maceclincov') ")" ";" %5.2f (`hradjqrisk2maceclincov') " (" %4.2f (`ci1adjqrisk2maceclincov') "-" %4.2f (`ci2adjqrisk2maceclincov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0maceclincov') ";" ("$rateqrisk2_0maceclincov") ";" "ref" ";" "ref" _n
file write textfile "ACS" ";" "QRISK3 >=10%"";" (`numqrisk2_1acsclincov') ";" ("$rateqrisk2_1acsclincov") ";" %5.2f (`hrcruqrisk2acsclincov') " (" %4.2f (`ci1cruqrisk2acsclincov') "-" %4.2f (`ci2cruqrisk2acsclincov') ")" ";" %5.2f (`hradjqrisk2acsclincov') " (" %4.2f (`ci1adjqrisk2acsclincov') "-" %4.2f (`ci2adjqrisk2acsclincov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0acsclincov') ";" ("$rateqrisk2_0acsclincov") ";" "ref" ";" "ref" _n
file write textfile "Ischaemic stroke" ";" "QRISK2 >=10%" ";" (`numqrisk2_1strokeclincov') ";" ("$rateqrisk2_1strokeclincov") ";" %5.2f (`hrcruqrisk2strokeclincov') " (" %4.2f (`ci1cruqrisk2strokeclincov') "-" %4.2f (`ci2cruqrisk2strokeclincov') ")" ";" %5.2f (`hradjqrisk2strokeclincov') " (" %4.2f (`ci1adjqrisk2strokeclincov') "-" %4.2f (`ci2adjqrisk2strokeclincov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0strokeclincov') ";" ("$rateqrisk2_0strokeclincov") ";" "ref" ";" "ref" _n
file write textfile "Acute left ventricular failure" ";" "QRISK2 >=10%" ";" (`numqrisk2_1hfclincov') ";" ("$rateqrisk2_1hfclincov") ";" %5.2f (`hrcruqrisk2hfclincov') " (" %4.2f (`ci1cruqrisk2hfclincov') "-" %4.2f (`ci2cruqrisk2hfclincov') ")" ";" %5.2f (`hradjqrisk2hfclincov') " (" %4.2f (`ci1adjqrisk2hfclincov') "-" %4.2f (`ci2adjqrisk2hfclincov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0hfclincov') ";" ("$rateqrisk2_0hfclincov") ";" "ref" ";" "ref" _n
file write textfile "Major ventricular arrhythmia" ";" "QRISK2 >=10%" ";" (`numqrisk2_1arrhyclincov') ";" ("$rateqrisk2_1arrhyclincov") ";" %5.2f (`hrcruqrisk2arrhyclincov') " (" %4.2f (`ci1cruqrisk2arrhyclincov') "-" %4.2f (`ci2cruqrisk2arrhyclincov') ")" ";" %5.2f (`hradjqrisk2arrhyclincov') " (" %4.2f (`ci1adjqrisk2arrhyclincov') "-" %4.2f (`ci2adjqrisk2arrhyclincov') ")" _n
file write textfile ";" "QRISK2 <10%" ";" (`numqrisk2_0arrhyclincov') ";" ("$rateqrisk2_0arrhyclincov") ";" "ref" ";" "ref" _n

cap file close textfile 
file open textfile using "$outputdir/clincovdeathsenscox.csv", write replace
file write textfile "Outcome" ";" ";" "No. of events" ";" "Rate per 1,000 person-years (95% CI)" ";" "Crude HR (95% CI)" ";" "Sex-adjusted HR (95% CI)" ";" "Fully-adjusted* HR (95% CI)" _n
file write textfile "COVID-19 death within 28 days*" ";" "QRISK3 >10%" ";" (`numqrisk1cdclincov28') ";" ("$rateqrisk1cdclincov28") ";" %5.2f (`hrcruqrisk3cdclincov28') " (" %4.2f (`ci1cruqrisk3cdclincov28') "-" %4.2f (`ci2cruqrisk3cdclincov28') ")" ";" "NA" ";" %5.2f (`hradjqrisk3cdclincov28') " (" %4.2f (`ci1adjqrisk3cdclincov28') "-" %4.2f (`ci2adjqrisk3cdclincov28') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisk0cdclincov28') ";" ("$rateqrisk0cdclincov28") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1cdclincov28') ";" ("$ratehrisk1cdclincov28") ";" %5.2f (`hrcruhriskcdclincov28') " (" %4.2f (`ci1cruhriskcdclincov28') "-" %4.2f (`ci2cruhriskcdclincov28') ")" ";" %5.2f (`hrsexhriskcdclincov28') " (" %4.2f (`ci1sexhriskcdclincov28') "-" %4.2f (`ci2sexhriskcdclincov28') ")" ";" %5.2f (`hradjhriskcdclincov28') " (" %4.2f (`ci1adjhriskcdclincov28') "-" %4.2f (`ci2adjhriskcdclincov28') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0cdclincov28') ";" ("$ratehrisk0cdclincov28") ";" "ref" ";" "ref" ";" "ref" _n
file write textfile "All-cause death within 28 days" ";" "QRISK3 >10%" ";" (`numqrisk1dclincov28') ";" ("$rateqrisk1dclincov28") ";" %5.2f (`hrcruqrisk3dclincov28') " (" %4.2f (`ci1cruqrisk3dclincov28') "-" %4.2f (`ci2cruqrisk3dclincov28') ")" ";" "NA" ";" %5.2f (`hradjqrisk3dclincov28') " (" %4.2f (`ci1adjqrisk3dclincov28') "-" %4.2f (`ci2adjqrisk3dclincov28') ")" _n
file write textfile ";" "QRISK3 <10%"  ";" (`numqrisk0dclincov28') ";" ("$rateqrisk0dclincov28") ";" "ref" ";" "NA" ";" "ref" _n
file write textfile ";" "Hypertension" ";" (`numhrisk1dclincov28') ";" ("$ratehrisk1dclincov28") ";" %5.2f (`hrcruhriskdclincov28') " (" %4.2f (`ci1cruhriskdclincov28') "-" %4.2f (`ci2cruhriskdclincov28') ")" ";" %5.2f (`hrsexhriskdclincov28') " (" %4.2f (`ci1sexhriskdclincov28') "-" %4.2f (`ci2sexhriskdclincov28') ")" ";" %5.2f (`hradjhriskdclincov28') " (" %4.2f (`ci1adjhriskdclincov28') "-" %4.2f (`ci2adjhriskdclincov28') ")" _n
file write textfile ";" "No hypertension" ";" (`numhrisk0dclincov28') ";" ("$ratehrisk0dclincov28") ";" "ref" ";" "ref" ";" "ref" _n
cap file close textfile 