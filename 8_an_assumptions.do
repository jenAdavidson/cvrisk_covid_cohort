*Assumptions

use "$datadir/labcovdataset", clear

preserve
replace enddate_cdeathlabcov=enddate_cdeathlabcov+1 if enddate_cdeathlabcov==exposdate
stset enddate_cdeathlabcov, fail(cdeathlabcov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
estat phtest, detail 
estat phtest, plot(hrisk)
estat phtest, plot(haematological)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3) 
estat phtest, plot(haematological) 
restore

preserve
replace enddate_iculabcov=enddate_iculabcov+1 if enddate_iculabcov==exposdate
stset enddate_iculabcov, fail(iculabcov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
estat phtest, detail
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3) 
restore

preserve
replace enddate_respsuplabcov=enddate_respsuplabcov+1 if enddate_respsuplabcov==exposdate
stset enddate_respsuplabcov, fail(respsuplabcov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
estat phtest, detail
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3) 
restore

preserve
replace enddate_macelabcov=enddate_macelabcov+1 if enddate_macelabcov==exposdate
stset enddate_macelabcov, fail(macelabcov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
estat phtest, detail
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3) 
restore

preserve
replace enddate_acslabcov=enddate_acslabcov+1 if enddate_acslabcov==exposdate
stset enddate_acslabcov, fail(acslabcov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
*renal predicts outcome, can't include in model
estat phtest, detail
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3) 
restore

preserve
replace enddate_strokelabcov=enddate_strokelabcov+1 if enddate_strokelabcov==exposdate
stset enddate_strokelabcov, fail(strokelabcov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
estat phtest, detail
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
**no one with immunosuppression and outcome, can't include in model
estat phtest, detail
estat phtest, plot(qrisk3) 
restore

preserve
replace enddate_hflabcov=enddate_hflabcov+1 if enddate_hflabcov==exposdate
stset enddate_hflabcov, fail(hflabcov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
**too few observation with migraine to include in model
estat phtest, detail
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3) 
restore

preserve
replace enddate_arrhythmialabcov=enddate_arrhythmialabcov+1 if enddate_arrhythmialabcov==exposdate
stset enddate_arrhythmialabcov, fail(arrhythmialabcov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
estat phtest, detail
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3) 
restore



use "$datadir/clincovdataset", clear

preserve
replace enddate_cdeathclincov=enddate_cdeathclincov+1 if enddate_cdeathclincov==exposdate
stset enddate_cdeathclincov, fail(cdeathclincov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
estat phtest, detail 
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3)  
restore

preserve
replace enddate_maceclincov=enddate_maceclincov+1 if enddate_maceclincov==exposdate
stset enddate_maceclincov, fail(maceclincov==1) origin(time exposdate) enter(time exposdate) id(newid) scale(365.25)

quietly stcox hrisk age sex ethrisk townsend2011_5 bmigrp2 rati2 smoke_cat2 highalcintake fh_cvd b_corticosteroids antiplatelets anticoagulants b_migraine diabetes renal liver lung asthmawithocs asthmanoocs smi lidisability nonhaematological haematological immunosuppressed, base 
estat phtest, detail
estat phtest, plot(hrisk)

quietly stcox qrisk3 highalcintake antiplatelets anticoagulants liver lung asthmawithocs asthmanoocs lidisability nonhaematological haematological immunosuppression renal_egfr, base 
estat phtest, detail
estat phtest, plot(qrisk3) 
restore
