clear

import excel "J:\EHR-Working\Jennifer\RaisedCVDRisk_COVID19\analysis\objective2_cohort\outputfiles\dataforforestplot.xlsx", sheet("Sheet1") firstrow

label variable risk " "

metan es lci uci, fixed effect(Fully-adjusted HR) lcols(risk) by(outcome)

metan es lci uci, fixed effect(Fully-adjusted HR) lcols(risk) by(outcome) nowt nobox nosubgroup nooverall astext(60) texts(105) graphregion(color(white)) null(1) xlab(0,1,4,8,12) xsize(10) ysize(8)

graph save "$outputdir\HRs", replace
graph export "$outputdir\HRs", as(tif) width(10000) replace

