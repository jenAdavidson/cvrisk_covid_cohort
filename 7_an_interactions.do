



use "$datadir/labcovdataset", clear

local labcovoutcome cdeathlabcov iculabcov respsuplabcov hosplabcov macelabcov

foreach l_cond of local labcovoutcome {
replace enddate_`l_cond'=enddate_`l_cond'+1 if enddate_`l_cond'==exposdate
	stset enddate_`l_cond', fail(`l_cond'==1) origin(time exposdate) enter(time exposdate) id(patid) scale(365.25)	

stcox i.hrisk i.ageband i.sex i.ethrisk i.townsend2001_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd cons_countpriorb i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.b_ra i.b_sle i.immunosuppression i.b_impotence2, base
est store a

stcox i.hrisk##i.ageband i.sex i.ethrisk i.townsend2001_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd cons_countpriorb i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.b_ra i.b_sle i.immunosuppression i.b_impotence2, base
est store b
lrtest a b

stcox i.hrisk##i.sex i.ageband i.ethrisk i.townsend2001_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd cons_countpriorb i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.b_ra i.b_sle i.immunosuppression i.b_impotence2, base
est store c
lrtest a c

}

use "$datadir/clincovdataset", clear

local clincovoutcome cdeathclincov icuclincov respsupclincov hospclincov maceclincov

foreach c_cond of local clincovoutcome {
replace enddate_`c_cond'=enddate_`c_cond'+1 if enddate_`c_cond'==exposdate
	stset enddate_`c_cond', fail(`c_cond'==1) origin(time exposdate) enter(time exposdate) id(patid) scale(365.25)	

stcox i.hrisk i.ageband i.sex i.ethrisk i.townsend2001_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd cons_countpriorb i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.b_ra i.b_sle i.immunosuppression i.b_impotence2, base
est store a

stcox i.hrisk##i.ageband i.sex i.ethrisk i.townsend2001_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd cons_countpriorb i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.b_ra i.b_sle i.immunosuppression i.b_impotence2, base
est store b
lrtest a b

stcox i.hrisk##i.sex i.ageband i.ethrisk i.townsend2001_5 i.bmigrp2 rati2 i.smoke_cat2 i.highalcintake i.fh_cvd cons_countpriorb i.b_corticosteroids i.antiplatelets i.anticoagulants i.b_AF i.b_migraine i.diabetes i.renal i.liver i.lung i.asthmawithocs i.asthmanoocs i.smi i.dementia i.neuro i.lidisability i.nonhaematological i.haematological i.b_ra i.b_sle i.immunosuppression i.b_impotence2, base
est store c
lrtest a c

}