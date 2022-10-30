/*==============================================================================

AUTHOR:					Jennifer Davidson
DATE:					05/10/2021

STUDY:					Effect of CV risk on MACE after COVID-19

PURPOSE:				create baseline char table in excel

DATASETS USED:			obj1_analysis_dataset
							
DATASETS CREATED:		excel output

NEXT STEPS:				8.1_an_incidencerates.do

==============================================================================*/

/*******************************************************************************
#1. Open dataset and set up column headers in output file
*******************************************************************************/

foreach source in labcov clincov {

use "$datadir/`source'dataset", clear 


* create excel file
putexcel set "$outputdir/`source'baselinecharwave.xlsx", sheet("table") modify

* set row count variable
local rowcount=1

* Table title
putexcel A`rowcount'="Table x. Baseline characteristics of the study population by cardiovascular risk and COVID-19 waves in 2020" 
local ++rowcount // increment row counter variable

* set up column headers
putexcel A`rowcount'="", border(top, thin, black)
putexcel B`rowcount':F`rowcount'="Wave 1", bold border(top, thin, black) vcenter hcenter merge
putexcel G`rowcount':K`rowcount'="Wave 2", bold border(top, thin, black) vcenter hcenter merge
local ++rowcount 
putexcel A`rowcount'="", border(top, thin, black)
putexcel B`rowcount'="All", bold border(top, thin, black) vcenter hcenter
putexcel C`rowcount':D`rowcount'="QRISK3 score", bold border(top, thin, black) vcenter hcenter merge
putexcel E`rowcount':F`rowcount'="Hypertension", bold border(top, thin, black) vcenter hcenter merge
putexcel G`rowcount'="All", bold border(top, thin, black) vcenter hcenter
putexcel H`rowcount':I`rowcount'="QRISK3 score", bold border(top, thin, black) vcenter hcenter merge
putexcel J`rowcount':K`rowcount'="Hypertension", bold border(top, thin, black) vcenter hcenter merge
local ++rowcount

putexcel C`rowcount'="Raised risk", bold border(top, thin, black) vcenter hcenter
putexcel D`rowcount'="Low risk", bold border(top, thin, black) vcenter hcenter
putexcel E`rowcount'="Raised risk", bold border(top, thin, black) vcenter hcenter
putexcel F`rowcount'="Low risk", bold border(top, thin, black) vcenter hcenter
putexcel H`rowcount'="Raised risk", bold border(top, thin, black) vcenter hcenter
putexcel I`rowcount'="Low risk", bold border(top, thin, black) vcenter hcenter
putexcel J`rowcount'="Raised risk", bold border(top, thin, black) vcenter hcenter
putexcel K`rowcount'="Low risk", bold border(top, thin, black) vcenter hcenter
local ++rowcount

/*******************************************************************************
#2. ADD Ns FOR EACH CV RISK GROUP
*******************************************************************************/

**Whole cohort by cardiovascular risk category

*All
unique newid if wave==0
global nall0=r(sum) // for percentage calc later
local N = string(`r(sum)',"%12.0gc")
putexcel B`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if wave==0 & sex==1
global nall0_men=r(sum)
unique newid if wave==1
global nall1=r(sum) 
local N = string(`r(sum)',"%12.0gc")
putexcel G`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if wave==1 & sex==1
global nall1_men=r(sum)
*QRISK3 >=10%
unique newid if qrisk3==1 & wave==0
global nqrisk10=r(sum)
local N = string(`r(sum)',"%12.0gc")
putexcel C`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if qrisk3==1 & wave==0 & sex==1
global nqrisk10_men=r(sum)
unique newid if qrisk3==1 & wave==1
global nqrisk11=r(sum)
local N = string(`r(sum)',"%12.0gc")
putexcel H`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if qrisk3==1 & wave==1 & sex==1
global nqrisk11_men=r(sum)
*QRISK3 <10%
unique newid if qrisk3==0 & wave==0
global nqrisk00=r(sum)
local N = string(`r(sum)',"%12.0gc")
putexcel D`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if qrisk3==0 & wave==0 & sex==1
global nqrisk00_men=r(sum)
unique newid if qrisk3==0 & wave==1
global nqrisk01=r(sum)
local N = string(`r(sum)',"%12.0gc")
putexcel I`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if qrisk3==0 & wave==0 & sex==1
global nqrisk01_men=r(sum)
*Hypertension
unique newid if hrisk==1 & wave==0
global nhrisk10=r(sum)
local N = string(`r(sum)',"%12.0gc")
putexcel E`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if hrisk==1 & wave==0 & sex==1
global nhrisk10_men=r(sum)
unique newid if hrisk==1 & wave==1
global nhrisk11=r(sum)
local N = string(`r(sum)',"%12.0gc")
putexcel J`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if hrisk==1 & wave==1 & sex==1
global nhrisk11_men=r(sum)
*No hypertension
unique newid if hrisk==0 & wave==0
global nhrisk00=r(sum)
local N = string(`r(sum)',"%12.0gc")
putexcel F`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if hrisk==0 & wave==0 & sex==1
global nhrisk00_men=r(sum)
unique newid if hrisk==0 & wave==1
global nhrisk01=r(sum)
local N = string(`r(sum)',"%12.0gc")
putexcel K`rowcount'="N=`N'", border(top, thin, black) hcenter
unique newid if hrisk==0 & wave==1 & sex==1
global nhrisk01_men=r(sum)

local ++rowcount


/*******************************************************************************
#3. Age
*******************************************************************************/

putexcel A`rowcount'="Age (years), Mean (SD)*", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
	
	*wave 1
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	preserve
	if "`group'"=="qrisk1" keep if qrisk3==1
	if "`group'"=="qrisk0" keep if qrisk3==0
	if "`group'"=="hrisk1" keep if hrisk==1
	if "`group'"=="hrisk0" keep if hrisk==0

	summ age if wave==0
	local meanage=string(`r(mean)', "%4.1f")
	local sdage=string(`r(sd)', "%4.1f")
	global `group'_w1_meanage "`meanage' (`sdage')"
	restore

	if "`group'"=="all" local col "B"
	if "`group'"=="qrisk1" local col "C"
	if "`group'"=="qrisk0" local col "D"
	if "`group'"=="hrisk1" local col "E"
	if "`group'"=="hrisk0" local col "F"

	local mean "${`group'_w1_meanage}"
	putexcel `col'`rowcount'="`mean'", hcenter
} /*end foreach group for mean and SD age*/


	*wave 2
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	preserve
	if "`group'"=="qrisk1" keep if qrisk3==1
	if "`group'"=="qrisk0" keep if qrisk3==0
	if "`group'"=="hrisk1" keep if hrisk==1
	if "`group'"=="hrisk0" keep if hrisk==0

	summ age if wave==1
	local meanage=string(`r(mean)', "%4.1f")
	local sdage=string(`r(sd)', "%4.1f")
	global `group'_w2_meanage "`meanage' (`sdage')"
	restore

	if "`group'"=="all" local col "G"
	if "`group'"=="qrisk1" local col "H"
	if "`group'"=="qrisk0" local col "I"
	if "`group'"=="hrisk1" local col "J"
	if "`group'"=="hrisk0" local col "K"

	local mean "${`group'_w2_meanage}"
	putexcel `col'`rowcount'="`mean'", hcenter
} /*end foreach group for mean and SD age*/

local ++rowcount


* loop through each ageband
* so that we end up with the ageband covariates in vars: age_`group'_`ageband'
* where group is: all, qrisk3=1, qrisk3=0, hrisk=1, hrisk=0
* and where ageband is 40-54, 55-64 65-74, 75-84
levelsof ageband, local(levels)
foreach i of local levels {
forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if ageband==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if ageband==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if ageband==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if ageband==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if ageband==`i' & hrisk==0 & wave==`x'
		
		* use returned results
		local n=string(`r(sum)',"%12.0gc") 
		local percent=string((`r(sum)' / ${n`group'`x'}) * 100, "%4.1f")
		
		* create string for output
		global age_`group'_`i'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
	
	putexcel A`rowcount'="`: label (ageband) `i''" // use variable label for row caption
	putexcel B`rowcount'="${age_all_`i'_0}",  hcenter
	putexcel C`rowcount'="${age_qrisk1_`i'_0}",  hcenter
	putexcel D`rowcount'="${age_qrisk0_`i'_0}",  hcenter
	putexcel E`rowcount'="${age_hrisk1_`i'_0}",  hcenter
	putexcel F`rowcount'="${age_hrisk0_`i'_0}",  hcenter
	putexcel G`rowcount'="${age_all_`i'_1}",  hcenter
	putexcel H`rowcount'="${age_qrisk1_`i'_1}",  hcenter
	putexcel I`rowcount'="${age_qrisk0_`i'_1}",  hcenter
	putexcel J`rowcount'="${age_hrisk1_`i'_1}",  hcenter
	putexcel K`rowcount'="${age_hrisk0_`i'_1}",  hcenter
	
	local ++rowcount // increment row counter so that next iteration of loop put on next row
} /*end foreach i of local levels*/


/*******************************************************************************
#4. Sex
*******************************************************************************/

replace sex=2 if sex==.

putexcel A`rowcount'="Sex*", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount

forvalues i=0/2 {
forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if sex==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if sex==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if sex==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if sex==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if sex==`i' & hrisk==0 & wave==`x'

	local n=string(`r(sum)',"%12.0gc") 
	local percent=string((`r(sum)' / ${n`group'`x'}) * 100, "%4.1f")
	
	global sex_`group'_`i'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
		
	putexcel A`rowcount'="`: label (sex) `i''" // use variable label for row caption
	putexcel B`rowcount'="${sex_all_`i'_0}",  hcenter
	putexcel C`rowcount'="${sex_qrisk1_`i'_0}",  hcenter
	putexcel D`rowcount'="${sex_qrisk0_`i'_0}",  hcenter
	putexcel E`rowcount'="${sex_hrisk1_`i'_0}",  hcenter
	putexcel F`rowcount'="${sex_hrisk0_`i'_0}",  hcenter
	putexcel G`rowcount'="${sex_all_`i'_1}",  hcenter
	putexcel H`rowcount'="${sex_qrisk1_`i'_1}",  hcenter
	putexcel I`rowcount'="${sex_qrisk0_`i'_1}",  hcenter
	putexcel J`rowcount'="${sex_hrisk1_`i'_1}",  hcenter
	putexcel K`rowcount'="${sex_hrisk0_`i'_1}",  hcenter
	
	local ++rowcount // increment row counter so that next iteration of loop put on next row
} /*end foreach i of sex*/


/*******************************************************************************
#5. Ethnicity
*******************************************************************************/
replace ethrisk5=4 if ethrisk2==.

putexcel A`rowcount'="Ethnicity*", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount
/*
forvalues x=0/1 {
*All
unique newid if ethrisk5!=. & wave==`x'
global nalleth`x'=r(sum)
*QRISK3 >=10%
unique newid if qrisk3==1 & ethrisk5!=. & wave==`x'
global nqrisk1eth`x'=r(sum) 
*QRISK3 <10%
unique newid if qrisk3==0 & ethrisk5!=. & wave==`x'
global nqrisk0eth`x'=r(sum)
*Hypertension
unique newid if hrisk==1 & ethrisk5!=. & wave==`x'
global nhrisk1eth`x'=r(sum)
*No hypertension
unique newid if hrisk==0 & ethrisk5!=. & wave==`x'
global nhrisk0eth`x'=r(sum)
}
*/
levelsof ethrisk5, local(levels)
foreach i of local levels {
forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if ethrisk5==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if ethrisk5==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if ethrisk5==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if ethrisk5==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if ethrisk5==`i' & hrisk==0 & wave==`x'

	local n=string(`r(sum)',"%12.0gc") 
	local percent=string((`r(sum)' / ${n`group'`x'}) * 100, "%4.1f")
	
	global ethrisk5_`group'_`i'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
		
	putexcel A`rowcount'="`: label (ethrisk5) `i''" // use variable label for row caption
	putexcel B`rowcount'="${ethrisk5_all_`i'_0}", hcenter
	putexcel C`rowcount'="${ethrisk5_qrisk1_`i'_0}", hcenter
	putexcel D`rowcount'="${ethrisk5_qrisk0_`i'_0}", hcenter
	putexcel E`rowcount'="${ethrisk5_hrisk1_`i'_0}", hcenter
	putexcel F`rowcount'="${ethrisk5_hrisk0_`i'_0}", hcenter
	putexcel G`rowcount'="${ethrisk5_all_`i'_1}", hcenter
	putexcel H`rowcount'="${ethrisk5_qrisk1_`i'_1}", hcenter
	putexcel I`rowcount'="${ethrisk5_qrisk0_`i'_1}", hcenter
	putexcel J`rowcount'="${ethrisk5_hrisk1_`i'_1}", hcenter
	putexcel K`rowcount'="${ethrisk5_hrisk0_`i'_1}", hcenter
	
	local ++rowcount // increment row counter so that next iteration of loop put on next row
} /*end foreach i of eth5*/


/*******************************************************************************
#6. Deprivation
*******************************************************************************/

replace townsend2011_5=6 if townsend2011_5==.

putexcel A`rowcount'="Townsend quintile*", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount
/*
forvalues x=0/1 {
*All
unique newid if townsend2011_5!=. & wave==`x'
global nalltown`x'=r(sum)
*QRISK3 >=10%
unique newid if qrisk3==1 & townsend2011_5!=. & wave==`x'
global nqrisk1town`x'=r(sum)
*QRISK3 <10%
unique newid if qrisk3==0 & townsend2011_5!=. & wave==`x'
global nqrisk0town`x'=r(sum)
*Hypertension
unique newid if hrisk==1& townsend2011_5!=. & wave==`x'
global nhrisk1town`x'=r(sum)
*No hypertension
unique newid if hrisk==0 & townsend2011_5!=. & wave==`x'
global nhrisk0town`x'=r(sum)
}
*/
levelsof townsend2011_5, local(levels)
foreach i of local levels {
forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if townsend2011_5==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if townsend2011_5==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if townsend2011_5==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if townsend2011_5==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if townsend2011_5==`i' & hrisk==0 & wave==`x'

	local n=string(`r(sum)',"%12.0gc") 
	local percent=string((`r(sum)' / ${n`group'`x'}) * 100, "%4.1f")
	
	global townsend2011_5_`group'_`i'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
		
	putexcel A`rowcount'="`: label (townsend2011_5) `i''" // use variable label for row caption
	putexcel B`rowcount'="${townsend2011_5_all_`i'_0}",  hcenter
	putexcel C`rowcount'="${townsend2011_5_qrisk1_`i'_0}",  hcenter
	putexcel D`rowcount'="${townsend2011_5_qrisk0_`i'_0}",  hcenter
	putexcel E`rowcount'="${townsend2011_5_hrisk1_`i'_0}",  hcenter
	putexcel F`rowcount'="${townsend2011_5_hrisk0_`i'_0}",  hcenter
	putexcel G`rowcount'="${townsend2011_5_all_`i'_1}",  hcenter
	putexcel H`rowcount'="${townsend2011_5_qrisk1_`i'_1}",  hcenter
	putexcel I`rowcount'="${townsend2011_5_qrisk0_`i'_1}",  hcenter
	putexcel J`rowcount'="${townsend2011_5_hrisk1_`i'_1}",  hcenter
	putexcel K`rowcount'="${townsend2011_5_hrisk0_`i'_1}",  hcenter
	
	local ++rowcount // increment row counter so that next iteration of loop put on next row
} /*end foreach i of townsend2001_5*/


/*******************************************************************************
#7. Region
*******************************************************************************/

replace region=11 if region==.

putexcel A`rowcount'="Region of residence", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount

levelsof region, local(levels)
foreach i of local levels {
forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if region==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if region==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if region==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if region==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if region==`i' & hrisk==0 & wave==`x'

	local n=string(`r(sum)',"%12.0gc") 
	local percent=string((`r(sum)' / ${n`group'}) * 100, "%4.1f")
	
	global region_`group'_`i'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
		
	putexcel A`rowcount'="`: label (region) `i''" // use variable label for row caption
	putexcel B`rowcount'="${region_all_`i'_0}", hcenter
	putexcel C`rowcount'="${region_qrisk1_`i'_0}", hcenter
	putexcel D`rowcount'="${region_qrisk0_`i'_0}", hcenter
	putexcel E`rowcount'="${region_hrisk1_`i'_0}", hcenter
	putexcel F`rowcount'="${region_hrisk0_`i'_0}", hcenter
	putexcel G`rowcount'="${region_all_`i'_1}", hcenter
	putexcel H`rowcount'="${region_qrisk1_`i'_1}", hcenter
	putexcel I`rowcount'="${region_qrisk0_`i'_1}", hcenter
	putexcel J`rowcount'="${region_hrisk1_`i'_1}", hcenter
	putexcel K`rowcount'="${region_hrisk0_`i'_1}", hcenter
	
	local ++rowcount // increment row counter so that next iteration of loop put on next row
} /*end foreach i of townsend2001_5*/


/*******************************************************************************
#8. BMI
*******************************************************************************/

replace bmigrp2=5 if bmigrp2==.

putexcel A`rowcount'="BMI category*†", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount
/*
forvalues x=0/1 {
*All
unique newid if bmigrp2!=. & wave==`x'
global nallbmi`x'=r(sum)
*QRISK3 >=10%
unique newid if qrisk3==1 & bmigrp2!=. & wave==`x'
global nqrisk1bmi`x'=r(sum)
*QRISK3 <10%
unique newid if qrisk3==0 & bmigrp2!=. & wave==`x'
global nqrisk0bmi`x'=r(sum)
*Hypertension
unique newid if hrisk==1 & bmigrp2!=. & wave==`x'
global nhrisk1bmi`x'=r(sum)
*No hypertension
unique newid if hrisk==0 &bmigrp2!=. & wave==`x'
global nhrisk0bmi`x'=r(sum)
}
*/
levelsof bmigrp2, local(levels) // non-imputed version from QRISK
foreach i of local levels {
forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if bmigrp2==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if bmigrp2==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if bmigrp2==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if bmigrp2==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if bmigrp2==`i' & hrisk==0 & wave==`x'

	local n=string(`r(sum)',"%12.0gc") 
	local percent=string((`r(sum)' / ${n`group'`x'}) * 100, "%4.1f")
	
	global bmigrp2_`group'_`i'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
		
	putexcel A`rowcount'="`: label (bmigrp2) `i''" // use variable label for row caption
	putexcel B`rowcount'="${bmigrp2_all_`i'_0}", hcenter
	putexcel C`rowcount'="${bmigrp2_qrisk1_`i'_0}", hcenter
	putexcel D`rowcount'="${bmigrp2_qrisk0_`i'_0}", hcenter
	putexcel E`rowcount'="${bmigrp2_hrisk1_`i'_0}", hcenter
	putexcel F`rowcount'="${bmigrp2_hrisk0_`i'_0}", hcenter
	putexcel G`rowcount'="${bmigrp2_all_`i'_1}", hcenter
	putexcel H`rowcount'="${bmigrp2_qrisk1_`i'_1}", hcenter
	putexcel I`rowcount'="${bmigrp2_qrisk0_`i'_1}", hcenter
	putexcel J`rowcount'="${bmigrp2_hrisk1_`i'_1}", hcenter
	putexcel K`rowcount'="${bmigrp2_hrisk0_`i'_1}", hcenter
	
	local ++rowcount // increment row counter so that next iteration of loop put on next row
} /*end foreach i of bmigrp*/

/*******************************************************************************
#9. Cholesterol:HDL
*******************************************************************************/

putexcel A`rowcount'="Cholesterol:HDL, Mean (SD)*†", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}

*wave 1
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	preserve
	if "`group'"=="qrisk1" keep if qrisk3==1
	if "`group'"=="qrisk0" keep if qrisk3==0
	if "`group'"=="hrisk1" keep if hrisk==1
	if "`group'"=="hrisk0" keep if hrisk==0

	summ rati2 if rati2!=. & wave==0
	local meanr2=string(`r(mean)', "%4.1f")
	local sdr2=string(`r(sd)', "%4.1f")
	global `group'_w1_meanr2 "`meanr2' (`sdr2')"
	restore

	if "`group'"=="all" local col "B"
	if "`group'"=="qrisk1" local col "C"
	if "`group'"=="qrisk0" local col "D"
	if "`group'"=="hrisk1" local col "E"
	if "`group'"=="hrisk0" local col "F"

	local mean "${`group'_w1_meanr2}"
	putexcel `col'`rowcount'="`mean'", hcenter
} /*end foreach group for mean and SD ratio*/


*wave 2
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	preserve
	if "`group'"=="qrisk1" keep if qrisk3==1
	if "`group'"=="qrisk0" keep if qrisk3==0
	if "`group'"=="hrisk1" keep if hrisk==1
	if "`group'"=="hrisk0" keep if hrisk==0

	summ rati2 if rati2!=. & wave==1
	local meanr2=string(`r(mean)', "%4.1f")
	local sdr2=string(`r(sd)', "%4.1f")
	global `group'_w2_meanr2 "`meanr2' (`sdr2')"
	restore

	if "`group'"=="all" local col "G"
	if "`group'"=="qrisk1" local col "H"
	if "`group'"=="qrisk0" local col "I"
	if "`group'"=="hrisk1" local col "J"
	if "`group'"=="hrisk0" local col "K"

	local mean "${`group'_w2_meanr2}"
	putexcel `col'`rowcount'="`mean'", hcenter
} /*end foreach group for mean and SD*/

	local ++rowcount // increment row counter so that next iteration of loop put on next row

	
/*******************************************************************************
#10. Blood pressure
*******************************************************************************/

putexcel A`rowcount'="Systolic blood pressure, Mean (SD)*†‡", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}

*wave 1
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	preserve
	if "`group'"=="qrisk1" keep if qrisk3==1
	if "`group'"=="qrisk0" keep if qrisk3==0
	if "`group'"=="hrisk1" keep if hrisk==1
	if "`group'"=="hrisk0" keep if hrisk==0

	summ sbp2 if sbp2!=. & wave==0
	local meansbp2=string(`r(mean)', "%4.1f")
	local sdsbp2=string(`r(sd)', "%4.1f")
	global `group'_w1_meansbp2 "`meansbp2' (`sdsbp2')"
	restore

	if "`group'"=="all" local col "B"
	if "`group'"=="qrisk1" local col "C"
	if "`group'"=="qrisk0" local col "D"
	if "`group'"=="hrisk1" local col "E"
	if "`group'"=="hrisk0" local col "F"

	local mean "${`group'_w1_meansbp2}"
	putexcel `col'`rowcount'="`mean'", hcenter
	} /*end foreach group for mean and SD ratio*/
	
*wave 2
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	preserve
	if "`group'"=="qrisk1" keep if qrisk3==1 & wave==1
	if "`group'"=="qrisk0" keep if qrisk3==0 & wave==1
	if "`group'"=="hrisk1" keep if hrisk==1 & wave==1
	if "`group'"=="hrisk0" keep if hrisk==0 & wave==1

	summ sbp2 if sbp2!=. & wave==1
	local meansbp2=string(`r(mean)', "%4.1f")
	local sdsbp2=string(`r(sd)', "%4.1f")
	global `group'_w2_meansbp2 "`meansbp2' (`sdsbp2')"
	restore

	if "`group'"=="all" local col "G"
	if "`group'"=="qrisk1" local col "H"
	if "`group'"=="qrisk0" local col "I"
	if "`group'"=="hrisk1" local col "J"
	if "`group'"=="hrisk0" local col "K"

	local mean "${`group'_w2_meansbp2}"
	putexcel `col'`rowcount'="`mean'", hcenter
} /*end foreach group for mean and SD age*/
	
	
local ++rowcount


/*******************************************************************************
#11. Smoking status
*******************************************************************************/

replace smoke_cat2=3 if smoke_cat2==.

putexcel A`rowcount'="Smoking status*†", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount
/*
forvalues x=0/1 {
*All
unique newid if smoke_cat2!=. & wave==`x'
global nallsmok`x'=r(sum)
*QRISK3 >=10%
unique newid if qrisk3==1 & smoke_cat2!=. & wave==`x'
global nqrisk1smok`x'=r(sum)
*QRISK3 <10%
unique newid if qrisk3==0 & smoke_cat2!=. & wave==`x'
global nqrisk0smok`x'=r(sum)
*Hypertension
unique newid if hrisk==1 & smoke_cat2!=. & wave==`x'
global nhrisk1smok`x'=r(sum)
*No hypertension
unique newid if hrisk==0 & smoke_cat2!=. & wave==`x'
global nhrisk0smok`x'=r(sum)
}
*/
levelsof smoke_cat2, local(levels) // use here the non-imputed version of the QRISK variable
foreach i of local levels {
forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if smoke_cat2==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if smoke_cat2==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if smoke_cat2==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if smoke_cat2==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if smoke_cat2==`i' & hrisk==0 & wave==`x'

	local n=string(`r(sum)',"%12.0gc") 
	local percent=string((`r(sum)' / ${n`group'`x'}) * 100, "%4.1f")
	
	global smoke_cat2_`group'_`i'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
		
	putexcel A`rowcount'="`: label (smoke_cat2) `i''" // use variable label for row caption
	putexcel B`rowcount'="${smoke_cat2_all_`i'_0}", hcenter
	putexcel C`rowcount'="${smoke_cat2_qrisk1_`i'_0}", hcenter
	putexcel D`rowcount'="${smoke_cat2_qrisk0_`i'_0}", hcenter
	putexcel E`rowcount'="${smoke_cat2_hrisk1_`i'_0}", hcenter
	putexcel F`rowcount'="${smoke_cat2_hrisk0_`i'_0}", hcenter
	putexcel G`rowcount'="${smoke_cat2_hrisk0_`i'_1}", hcenter
	putexcel H`rowcount'="${smoke_cat2_hrisk0_`i'_1}", hcenter
	putexcel I`rowcount'="${smoke_cat2_hrisk0_`i'_1}", hcenter
	putexcel J`rowcount'="${smoke_cat2_hrisk0_`i'_1}", hcenter
	putexcel K`rowcount'="${smoke_cat2_hrisk0_`i'_1}", hcenter
	
	local ++rowcount // increment row counter so that next iteration of loop put on next row
} /*end foreach i of smoke_cat*/


/*******************************************************************************
#12. Alcohol intake
*******************************************************************************/

replace highalcintake=2 if highalcintake==.

putexcel A`rowcount'="Alcohol consumption†", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount
/*
forvalues x=0/1 {
*All
unique newid if highalcintake!=. & wave==`x'
global nallalc`x'=r(sum)
*QRISK3 >=10%
unique newid if qrisk3==1 & highalcintake!=. & wave==`x'
global nqrisk1alc`x'=r(sum)
*QRISK3 <10%
unique newid if qrisk3==0 & highalcintake!=. & wave==`x'
global nqrisk0alc`x'=r(sum)
*Hypertension
unique newid if hrisk==1 & highalcintake!=. & wave==`x'
global nhrisk1alc`x'=r(sum)
*No hypertension
unique newid if hrisk==0 & highalcintake!=. & wave==`x'
global nhrisk0alc`x'=r(sum)
}
*/
levelsof highalcintake, local(levels)
foreach i of local levels {
forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if highalcintake==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if highalcintake==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if highalcintake==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if highalcintake==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if highalcintake==`i' & hrisk==0 & wave==`x'
 
	local n=string(`r(sum)',"%12.0gc") 
	local percent=string((`r(sum)' / ${n`group'`x'}) * 100, "%4.1f")
	
	global highalcintake_`group'_`i'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
		
	putexcel A`rowcount'="`: label (highalcintake) `i''" // use variable label for row caption
	putexcel B`rowcount'="${highalcintake_all_`i'_0}",  hcenter
	putexcel C`rowcount'="${highalcintake_qrisk1_`i'_0}",  hcenter
	putexcel D`rowcount'="${highalcintake_qrisk0_`i'_0}",  hcenter
	putexcel E`rowcount'="${highalcintake_hrisk1_`i'_0}",  hcenter
	putexcel F`rowcount'="${highalcintake_hrisk0_`i'_0}",  hcenter
	putexcel G`rowcount'="${highalcintake_hrisk0_`i'_1}", hcenter
	putexcel H`rowcount'="${highalcintake_hrisk0_`i'_1}", hcenter
	putexcel I`rowcount'="${highalcintake_hrisk0_`i'_1}", hcenter
	putexcel J`rowcount'="${highalcintake_hrisk0_`i'_1}", hcenter
	putexcel K`rowcount'="${highalcintake_hrisk0_`i'_1}", hcenter
	
	local ++rowcount // increment row counter so that next iteration of loop put on next row
} /*end foreach i of alcintake*/


/*******************************************************************************
#13. FAMILY HISTORY OF CHD
*******************************************************************************/

putexcel A`rowcount'="Family history of CHD*", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}

forvalues x=0/1 {
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	if "`group'"=="all" unique newid if fh_cvd==1 & wave==`x'
	if "`group'"=="qrisk1" unique newid if fh_cvd==1 & qrisk3==1 & wave==`x'
	if "`group'"=="qrisk0" unique newid if fh_cvd==1 & qrisk3==0 & wave==`x'
	if "`group'"=="hrisk1" unique newid if fh_cvd==1 & hrisk==1 & wave==`x'
	if "`group'"=="hrisk0" unique newid if fh_cvd==1 & hrisk==0 & wave==`x'

	local n=string(`r(sum)',"%12.0gc") 
	local percent=string((`r(sum)' / ${n`group'}) * 100, "%4.1f")
	
	global fh_cvd_`group'_`x' "`n' (`percent'%)"	
	} /*end foreach group */
	}
		
putexcel B`rowcount'="${fh_cvd_all_0}", hcenter
putexcel C`rowcount'="${fh_cvd_qrisk1_0}", hcenter
putexcel D`rowcount'="${fh_cvd_qrisk0_0}", hcenter
putexcel E`rowcount'="${fh_cvd_hrisk1_0}", hcenter
putexcel F`rowcount'="${fh_cvd_hrisk0_0}", hcenter
putexcel G`rowcount'="${fh_cvd_all_1}", hcenter
putexcel H`rowcount'="${fh_cvd_qrisk1_1}", hcenter
putexcel I`rowcount'="${fh_cvd_qrisk0_1}", hcenter
putexcel J`rowcount'="${fh_cvd_hrisk1_1}", hcenter
putexcel K`rowcount'="${fh_cvd_hrisk0}_1", hcenter
	
local ++rowcount 

/*******************************************************************************
#14. CONSULTATION FREQUENCY IN THE YEAR PRIOR TO BASELINE
*******************************************************************************/

putexcel A`rowcount'="Consultation frequency in prior 12 months, Median (IQR)", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}

*wave 1
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	preserve
	if "`group'"=="qrisk1" keep if qrisk3==1
	if "`group'"=="qrisk0" keep if qrisk3==0
	if "`group'"=="hrisk1" keep if hrisk==1
	if "`group'"=="hrisk0" keep if hrisk==0

	summ cons_countpriorb if wave==0, detail
	local p50cons=string(`r(p50)', "%4.0f")
	local p25cons=string(`r(p25)', "%4.0f")
	local p75cons=string(`r(p75)', "%4.0f")
	global `group'_w1_median "`p50cons' (`p25cons'-`p75cons')"
	restore

	if "`group'"=="all" local col "B"
	if "`group'"=="qrisk1" local col "C"
	if "`group'"=="qrisk0" local col "D"
	if "`group'"=="hrisk1" local col "E"
	if "`group'"=="hrisk0" local col "F"

	local median "${`group'_w1_median}"
	putexcel `col'`rowcount'="`median'", hcenter
} /*end foreach group for mean and SD*/

*wave 2
foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
	preserve
	if "`group'"=="qrisk1" keep if qrisk3==1
	if "`group'"=="qrisk0" keep if qrisk3==0
	if "`group'"=="hrisk1" keep if hrisk==1
	if "`group'"=="hrisk0" keep if hrisk==0

	summ cons_countpriorb if wave==1, detail
	local p50cons=string(`r(p50)', "%4.0f")
	local p25cons=string(`r(p25)', "%4.0f")
	local p75cons=string(`r(p75)', "%4.0f")
	global `group'_w2_median "`p50cons' (`p25cons'-`p75cons')"
	restore

	if "`group'"=="all" local col "G"
	if "`group'"=="qrisk1" local col "H"
	if "`group'"=="qrisk0" local col "I"
	if "`group'"=="hrisk1" local col "J"
	if "`group'"=="hrisk0" local col "K"

	local median "${`group'_w2_median}"
	putexcel `col'`rowcount'="`median'", hcenter
} /*end foreach group for mean and SD*/

local ++rowcount

/*******************************************************************************
#15. MEDICATIONS
*******************************************************************************/

putexcel A`rowcount'="Medication use$", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount

local drug b_corticosteroids antihypertensives statins antiplatelets anticoagulants 

foreach med of local drug {
forvalues x=0/1 {
		foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if `med'==1 & wave==`x'
		if "`group'"=="qrisk1" unique newid if `med'==1 & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if `med'==1 & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if `med'==1 & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if `med'==1 & hrisk==0 & wave==`x'
		
		* use returned results
		local n=string(`r(sum)',"%12.0gc") 
		local percent=string((`r(sum)' / ${n`group'}) * 100, "%4.1f")
		
		* create string for output
		global `med'_`group'_`x' "`n' (`percent'%)"	
		} /*end foreach group */
		}
		
	if "`med'"=="b_corticosteroids" putexcel A`rowcount'="Regular corticosteroids*"
	if "`med'"=="antihypertensives" putexcel A`rowcount'="Antihypertensives*"
	if "`med'"=="statins" putexcel A`rowcount'="Statins"
	if "`med'"=="antiplatelets" putexcel A`rowcount'="Antiplatelets"
	if "`med'"=="anticoagulants" putexcel A`rowcount'="Anticoagulants"

	putexcel B`rowcount'="${`med'_all_0}", hcenter
	putexcel C`rowcount'="${`med'_qrisk1_0}", hcenter
	putexcel D`rowcount'="${`med'_qrisk0_0}", hcenter
	putexcel E`rowcount'="${`med'_hrisk1_0}", hcenter
	putexcel F`rowcount'="${`med'_hrisk0_0}", hcenter
	putexcel G`rowcount'="${`med'_all_1}", hcenter
	putexcel H`rowcount'="${`med'_qrisk1_1}", hcenter
	putexcel I`rowcount'="${`med'_qrisk0_1}", hcenter
	putexcel J`rowcount'="${`med'_hrisk1_1}", hcenter
	putexcel K`rowcount'="${`med'_hrisk0_1}", hcenter
	local ++rowcount
}/*end foreach medication*/


/*******************************************************************************
#16. COMORBIDITIES
*******************************************************************************/

putexcel A`rowcount'="Comorbid condition", border(top, thin, black)
local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
local ++rowcount

local condition b_AF b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi dementia neuro lidisability nonhaematological haematological b_ra b_sle b_hiv immunosuppression b_impotence2 

foreach med of local condition {
	if "`med'"=="nonhaematological" | "`med'"=="haematological" {

	if "`med'"=="nonhaematological" putexcel A`rowcount'="Non-haematological cancer"
	if "`med'"=="haematological" putexcel A`rowcount'="Haematological malignancy"
	local ++rowcount
	
	levelsof time`med', local(levels)
	foreach i of local levels {	
	forvalues x=0/1 {
		foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if `med'==1 & time`med'==`i' & wave==`x'
		if "`group'"=="qrisk1" unique newid if `med'==1 & time`med'==`i' & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if `med'==1 & time`med'==`i' & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if `med'==1 & time`med'==`i' & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if `med'==1 & time`med'==`i' & hrisk==0 & wave==`x'
		
		* use returned results
		local n=string(`r(sum)',"%12.0gc") 
		local percent=string((`r(sum)' / ${n`group'}) * 100, "%4.1f")
		
		* create string for output
		global `med'_`group'_`i'_`x' "`n' (`percent'%)"	
		} /*end foreach group */
		}
		
	putexcel A`rowcount'="  `: label (time`med') `i''" // use variable label for row caption
	putexcel B`rowcount'="${`med'_all_`i'_0}", hcenter
	putexcel C`rowcount'="${`med'_qrisk1_`i'_0}", hcenter
	putexcel D`rowcount'="${`med'_qrisk0_`i'_0}", hcenter
	putexcel E`rowcount'="${`med'_hrisk1_`i'_0}", hcenter
	putexcel F`rowcount'="${`med'_hrisk0_`i'_0}", hcenter
	putexcel G`rowcount'="${`med'_all_`i'_1}", hcenter
	putexcel H`rowcount'="${`med'_qrisk1_`i'_1}", hcenter
	putexcel I`rowcount'="${`med'_qrisk0_`i'_1}", hcenter
	putexcel J`rowcount'="${`med'_hrisk1_`i'_1}", hcenter
	putexcel K`rowcount'="${`med'_hrisk0_`i'_1}", hcenter
	local ++rowcount
	} /*end foreach i of med*/
	}/*end if loop*/
	
	
	else {
	
	forvalues x=0/1 {
	foreach group in all qrisk1 qrisk0 hrisk1 hrisk0 {
		if "`group'"=="all" unique newid if `med'==1 & wave==`x' 
		if "`group'"=="qrisk1" unique newid if `med'==1 & qrisk3==1 & wave==`x'
		if "`group'"=="qrisk0" unique newid if `med'==1 & qrisk3==0 & wave==`x'
		if "`group'"=="hrisk1" unique newid if `med'==1 & hrisk==1 & wave==`x'
		if "`group'"=="hrisk0" unique newid if `med'==1 & hrisk==0 & wave==`x'
		
		* use returned results
		local n=string(`r(sum)',"%12.0gc") 
		local percent=string((`r(sum)' / ${n`group'}) * 100, "%4.1f")
		
		* create string for output
		global `med'_`group'_`x' "`n' (`percent'%)"	
		} /*end foreach group */
		}
		
	if "`med'"=="b_AF" putexcel A`rowcount'="Atrial fibrillation*"
	if "`med'"=="b_migraine" putexcel A`rowcount'="Migraines*"
	if "`med'"=="diabetes" putexcel A`rowcount'="Diabetes*"
	if "`med'"=="renal" putexcel A`rowcount'="CKD stage 3-5*"
	if "`med'"=="liver" putexcel A`rowcount'="Chronic liver disease"
	if "`med'"=="lung" putexcel A`rowcount'="Chronic respiratory disease (not asthma)"
	if "`med'"=="asthmawithocs" putexcel A`rowcount'="Asthma with recent OCS use$"
	if "`med'"=="asthmanoocs" putexcel A`rowcount'="Asthma with no recent OCS use"
	if "`med'"=="smi" putexcel A`rowcount'="Severe mental illness / antipsychotic use*"
	if "`med'"=="dementia" putexcel A`rowcount'="Dementia"
	if "`med'"=="neuro" putexcel A`rowcount'="Chronic neurological disease"
	if "`med'"=="lidisability" putexcel A`rowcount'="Learning / intellectual disability"
	if "`med'"=="b_ra" putexcel A`rowcount'="Rheumatoid arthritis*"
	if "`med'"=="b_sle" putexcel A`rowcount'="Systemic lupus erythematosus*"
	if "`med'"=="b_hiv" putexcel A`rowcount'="HIV*"
	if "`med'"=="immunosuppression" putexcel A`rowcount'="Immunosuppression#"
	if "`med'"=="b_impotence2" putexcel A`rowcount'="Erectile dysfunction*"

	putexcel B`rowcount'="${`med'_all_0}", hcenter
	putexcel C`rowcount'="${`med'_qrisk1_0}", hcenter
	putexcel D`rowcount'="${`med'_qrisk0_0}", hcenter
	putexcel E`rowcount'="${`med'_hrisk1_0}", hcenter
	putexcel F`rowcount'="${`med'_hrisk0_0}", hcenter
	putexcel G`rowcount'="${`med'_all_1}", hcenter
	putexcel H`rowcount'="${`med'_qrisk1_1}", hcenter
	putexcel I`rowcount'="${`med'_qrisk0_1}", hcenter
	putexcel J`rowcount'="${`med'_hrisk1_1}", hcenter
	putexcel K`rowcount'="${`med'_hrisk0_1}", hcenter
	local ++rowcount
	
	}/*end else loop*/
	
}/*end foreach medication*/


/*******************************************************************************
#17. FOOTNOTES
*******************************************************************************/

local row B C D E F G H I J K
foreach letter of local row {
	putexcel `letter'`rowcount'="", border(top, thin, black)
	}
	
local ++rowcount
local ++rowcount

*footnotes
putexcel A`rowcount'="*In QRISK3 algorithm, but non-imputed version included here (for smoking status, cholesterol:HDL ratio, systolic BP and BMI)"
local ++rowcount
putexcel A`rowcount'="†most recent measure before baseline"
local ++rowcount
putexcel A`rowcount'="‡Used on hypertension definition"
local ++rowcount
putexcel A`rowcount'="$at least 1 prescription in the 12 months before to baseline. Other than corticosteroids which was defined as at least 2 prescriptions prior to baseline with the most recent ≤28 days before baseline"
local ++rowcount
putexcel A`rowcount'="#ever history of solid organ transplant or permanent cellular immune deficiency; history in the 24 months before baseline of aplastic anaemia, bone marrow or stem cell transplant; history in the 12 months before baseline of biologics or other immunosuppressant therapy (excluding corticosteroids), other or unspecified cellular immune deficiency"


}