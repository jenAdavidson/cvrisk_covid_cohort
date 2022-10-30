
/*******************************************************************************
#Adjusted model
*******************************************************************************/

use "$datadir/labcovdataset", clear
local outcome cdeathlabcov iculabcov respsuplabcov hosplabcov macelabcov
foreach cond of local outcome {
	
*UPDATE ENDDATE TO INCLUDE OUTCOME DATE
replace enddate_`cond'=enddate_`cond'+1 if enddate_`cond'==exposdate
stset enddate_`cond', fail(`cond'==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)	


stcox i.qrisk3 age i.highalcintake i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression i.renal_egfr, base 
local hradjqrisk3`cond'=exp(_b[1.qrisk3])
local ci1adjqrisk3`cond'=exp(_b[1.qrisk3]-1.96*_se[1.qrisk3]) 
local ci2adjqrisk3`cond'=exp(_b[1.qrisk3]+1.96*_se[1.qrisk3])

}/*end foreach var*/

cap file close textfile 
file open textfile using "$outputdir/qriskageadjustedlab.csv", write replace
file write textfile "sep=;" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >10%" ";" %5.2f (`hradjqrisk3cdeathlabcov') " (" %4.2f (`ci1adjqrisk3cdeathlabcov') "-" %4.2f (`ci2adjqrisk3cdeathlabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "ICU admission" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3iculabcov') " (" %4.2f (`ci1adjqrisk3iculabcov') "-" %4.2f (`ci2adjqrisk3iculabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Respiratory support" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3respsuplabcov') " (" %4.2f (`ci1adjqrisk3respsuplabcov') "-" %4.2f (`ci2adjqrisk3respsuplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Hospitalization" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3hosplabcov') " (" %4.2f (`ci1adjqrisk3hosplabcov') "-" %4.2f (`ci2adjqrisk3hosplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3macelabcov') " (" %4.2f (`ci1adjqrisk3macelabcov') "-" %4.2f (`ci2adjqrisk3macelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";"  "ref" _n


use "$datadir/clincovdataset", clear
local outcome cdeathclincov hospclincov maceclincov
foreach cond of local outcome {
	
*UPDATE ENDDATE TO INCLUDE OUTCOME DATE
replace enddate_`cond'=enddate_`cond'+1 if enddate_`cond'==exposdate
stset enddate_`cond', fail(`cond'==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)	


stcox i.qrisk3 age i.highalcintake i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression i.renal_egfr, base 
local hradjqrisk3`cond'=exp(_b[1.qrisk3])
local ci1adjqrisk3`cond'=exp(_b[1.qrisk3]-1.96*_se[1.qrisk3]) 
local ci2adjqrisk3`cond'=exp(_b[1.qrisk3]+1.96*_se[1.qrisk3])

}/*end foreach var*/

cap file close textfile 
file open textfile using "$outputdir/qriskageadjustedclin.csv", write replace
file write textfile "sep=;" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >10%" ";" %5.2f (`hradjqrisk3cdeathclincov') " (" %4.2f (`ci1adjqrisk3cdeathclincov') "-" %4.2f (`ci2adjqrisk3cdeathclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Hospitalization" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3hospclincov') " (" %4.2f (`ci1adjqrisk3hospclincov') "-" %4.2f (`ci2adjqrisk3hospclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3maceclincov') " (" %4.2f (`ci1adjqrisk3maceclincov') "-" %4.2f (`ci2adjqrisk3maceclincov') ")" _n
file write textfile ";" "QRISK3 <10%" ";"  "ref" _n


/*******************************************************************************
#<65s
*******************************************************************************/

use "$datadir/labcovdataset", clear
drop if age>64
local outcome cdeathlabcov iculabcov respsuplabcov hosplabcov macelabcov
foreach cond of local outcome {
	
*UPDATE ENDDATE TO INCLUDE OUTCOME DATE
replace enddate_`cond'=enddate_`cond'+1 if enddate_`cond'==exposdate
stset enddate_`cond', fail(`cond'==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)	


stcox i.qrisk3 i.highalcintake i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression i.renal_egfr, base 
local hradjqrisk3`cond'=exp(_b[1.qrisk3])
local ci1adjqrisk3`cond'=exp(_b[1.qrisk3]-1.96*_se[1.qrisk3]) 
local ci2adjqrisk3`cond'=exp(_b[1.qrisk3]+1.96*_se[1.qrisk3])

}/*end foreach var*/

cap file close textfile 
file open textfile using "$outputdir/qriskless65lab.csv", write replace
file write textfile "sep=;" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >10%" ";" %5.2f (`hradjqrisk3cdeathlabcov') " (" %4.2f (`ci1adjqrisk3cdeathlabcov') "-" %4.2f (`ci2adjqrisk3cdeathlabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "ICU admission" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3iculabcov') " (" %4.2f (`ci1adjqrisk3iculabcov') "-" %4.2f (`ci2adjqrisk3iculabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Respiratory support" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3respsuplabcov') " (" %4.2f (`ci1adjqrisk3respsuplabcov') "-" %4.2f (`ci2adjqrisk3respsuplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Hospitalization" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3hosplabcov') " (" %4.2f (`ci1adjqrisk3hosplabcov') "-" %4.2f (`ci2adjqrisk3hosplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3macelabcov') " (" %4.2f (`ci1adjqrisk3macelabcov') "-" %4.2f (`ci2adjqrisk3macelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";"  "ref" _n

/*******************************************************************************
#<75s
*******************************************************************************/

use "$datadir/labcovdataset", clear
drop if age>74
local outcome cdeathlabcov iculabcov respsuplabcov hosplabcov macelabcov
foreach cond of local outcome {
	
*UPDATE ENDDATE TO INCLUDE OUTCOME DATE
replace enddate_`cond'=enddate_`cond'+1 if enddate_`cond'==exposdate
stset enddate_`cond', fail(`cond'==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)	


stcox i.qrisk3 i.highalcintake i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression i.renal_egfr, base 
local hradjqrisk3`cond'=exp(_b[1.qrisk3])
local ci1adjqrisk3`cond'=exp(_b[1.qrisk3]-1.96*_se[1.qrisk3]) 
local ci2adjqrisk3`cond'=exp(_b[1.qrisk3]+1.96*_se[1.qrisk3])

}/*end foreach var*/

cap file close textfile 
file open textfile using "$outputdir/qriskless75lab.csv", write replace
file write textfile "sep=;" _n
file write textfile "COVID-19 death*" ";" "QRISK3 >10%" ";" %5.2f (`hradjqrisk3cdeathlabcov') " (" %4.2f (`ci1adjqrisk3cdeathlabcov') "-" %4.2f (`ci2adjqrisk3cdeathlabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "ICU admission" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3iculabcov') " (" %4.2f (`ci1adjqrisk3iculabcov') "-" %4.2f (`ci2adjqrisk3iculabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Respiratory support" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3respsuplabcov') " (" %4.2f (`ci1adjqrisk3respsuplabcov') "-" %4.2f (`ci2adjqrisk3respsuplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Hospitalization" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3hosplabcov') " (" %4.2f (`ci1adjqrisk3hosplabcov') "-" %4.2f (`ci2adjqrisk3hosplabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3macelabcov') " (" %4.2f (`ci1adjqrisk3macelabcov') "-" %4.2f (`ci2adjqrisk3macelabcov') ")" _n
file write textfile ";" "QRISK3 <10%" ";"  "ref" _n

/*******************************************************************************
#Age stratified
*******************************************************************************/

use "$datadir/labcovdataset", clear
local outcome cdeathlabcov iculabcov respsuplabcov hosplabcov macelabcov
foreach cond of local outcome {
	
*UPDATE ENDDATE TO INCLUDE OUTCOME DATE
replace enddate_`cond'=enddate_`cond'+1 if enddate_`cond'==exposdate
stset enddate_`cond', fail(`cond'==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)	

levelsof ageband, local(levels)
foreach i of local levels {
stcox i.qrisk3 i.highalcintake i.antiplatelets i.anticoagulants i.liver i.lung i.asthmawithocs i.asthmanoocs i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.immunosuppression i.renal_egfr if ageband==`i', base 
local hradjqrisk3`cond'`i'=exp(_b[1.qrisk3])
local ci1adjqrisk3`cond'`i'=exp(_b[1.qrisk3]-1.96*_se[1.qrisk3]) 
local ci2adjqrisk3`cond'`i'=exp(_b[1.qrisk3]+1.96*_se[1.qrisk3])
}
}/*end foreach var*/

cap file close textfile 
file open textfile using "$outputdir/qriskagestratlab.csv", write replace
file write textfile "sep=;" _n
levelsof ageband, local(levels)
foreach i of local levels {
file write textfile "`: label (ageband) `i''" _n 
file write textfile "COVID-19 death" ";" "QRISK3 >10%" ";" %5.2f (`hradjqrisk3cdeathlabcov`i'') " (" %4.2f (`ci1adjqrisk3cdeathlabcov`i'') "-" %4.2f (`ci2adjqrisk3cdeathlabcov`i'') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "ICU admission" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3iculabcov`i'') " (" %4.2f (`ci1adjqrisk3iculabcov`i'') "-" %4.2f (`ci2adjqrisk3iculabcov`i'') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Respiratory support" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3respsuplabcov`i'') " (" %4.2f (`ci1adjqrisk3respsuplabcov`i'') "-" %4.2f (`ci2adjqrisk3respsuplabcov`i'') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "Hospitalization" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3hosplabcov`i'') " (" %4.2f (`ci1adjqrisk3hosplabcov`i'') "-" %4.2f (`ci2adjqrisk3hosplabcov`i'') ")" _n
file write textfile ";" "QRISK3 <10%" ";" "ref" _n
file write textfile "MACE" ";" "QRISK3 >=10%" ";" %5.2f (`hradjqrisk3macelabcov`i'') " (" %4.2f (`ci1adjqrisk3macelabcov`i'') "-" %4.2f (`ci2adjqrisk3macelabcov`i'') ")" _n
file write textfile ";" "QRISK3 <10%" ";"  "ref" _n
}

cap file close textfile 
