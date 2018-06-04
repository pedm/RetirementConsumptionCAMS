/*
This code seeks to reproduce table 1 from Hurd and Rohwedder's paper on 
Heterogeneity in spending change at retirement. Table 1 shows the means
and medians of total real spending before and after retirement and the 
median of the change in spending calculated over households where 
retirement occurred between CAMS waves.

Written by Lan Luo, Yale University
Herb Scarf RA for Cormac O'Dea @Yale Economics Department
lan.luo@yale.edu

First version: 5/30/18
*/
clear

//Set up directories:
***** Lan ***** 
global tpPath "C:\Users\ericluo04\Dropbox\MoranOConnellODea\data"
global folder "C:\Users\ericluo04\Documents\GitHub\RetirementConsumptionCAMS"
***** Cormac ***** 
//global tpPath

use $tpPath\randhrs1992_2014v2_STATA\randhrs1992_2014v2.dta
merge 1:1 hhidpn using $tpPath\randcams_2001_2015v2\randcams_2001_2015v2.dta, keep(2 3)
drop _merge
save $tpPath\CAMSHRSpanelmerge1.dta, replace

use $tpPath\CAMSHRSpanelmerge1.dta, clear
keep hhidpn *agey_b *cwgtr *lbrf *sayret *retemp *lbrfh *lbrfy *inlbrf *cmstat *ctots *cdurs *cndur *ctranss *chouss *cautoall *ccarpay *cmort *cmortint *ctotc *cdurc *ctransc *chousc *chmeqf

//renaming variables to prepare for reshaping (example: h5cndurf -> h_cndurf5)
foreach var of varlist *agey_b *cwgtr *lbrf *sayret *retemp *lbrfh *lbrfy *cmstat *ctots *cdurs *cndur *ctranss *chouss *cautoall *ccarpay *cmort *cmortint *ctotc *cdurc *ctransc *chousc *chmeqf {
	//if wave value is less than 10
	if !(substr("`var'", 3, 1) == "0" | substr("`var'", 3, 1) == "1" | substr("`var'", 3, 1) == "2" | substr("`var'", 3, 1) == "3") {
		local newvarname = substr("`var'", 1, 1) + "_" + substr("`var'", 3, .) + substr("`var'", 2, 1) 
		rename `var' `newvarname'
	}
	//if wave value is greater than or equal to 10
	if (substr("`var'", 3, 1) == "0" | substr("`var'", 3, 1) == "1" | substr("`var'", 3, 1) == "2" | substr("`var'", 3, 1) == "3") {
		local newvarname = substr("`var'", 1, 1) + "_" + substr("`var'", 4, .) + substr("`var'", 2, 2) 
		rename `var' `newvarname'
	}
}

//reshape from wide to long panel data
reshape long s_agey_b r_agey_b h_cwgtr s_lbrf r_lbrf s_inlbrf r_inlbrf  s_sayret r_sayret s_retemp r_retemp s_lbrfh r_lbrfh s_lbrfy r_lbrfy h_cmstat h_ctots h_cdurs h_cndur h_ctranss h_chouss h_cautoall h_ccarpay h_cmort h_cmortint h_ctotc h_cdurc h_ctransc h_chousc h_chmeqf, i(hhidpn) j(wave)

//sort and declare data set as panel data
//NOTE: wave refers to HRS waves not CAMS waves
sort hhidpn wave
xtset hhidpn wave 
rename hhidpn id
rename s_agey_b s_age
rename r_agey_b r_age
rename h_cwgtr weight

//saves raw, basic panel data
save $tpPath\CAMSHRSpanelraw.dta, replace

//import CPI to make monetary values real
clear
import excel "$folder/Data/Raw/CPI_2015.xls", sheet("Sheet1")  firstrow
rename Year wave
replace wave = 1 if wave == 1992
replace wave = 2 if wave == 1994
replace wave = 3 if wave == 1996
replace wave = 4 if wave == 1998
replace wave = 5 if wave == 2000
replace wave = 6 if wave == 2002
replace wave = 7 if wave == 2004
replace wave = 8 if wave == 2006
replace wave = 9 if wave == 2008
replace wave = 10 if wave == 2010
replace wave = 11 if wave == 2012
replace wave = 12 if wave == 2014
drop if wave > 12
keep wave CPI_base_2003
save "$folder/Data/Intermediate/CPI.dta", replace

merge 1:m wave using $tpPath\CAMSHRSpanelraw.dta
tab wave if _merge == 2
tab wave if _merge == 3
drop _merge

//create real variables for spending values
foreach var of varlist *ctots *cdurs *cndur *ctranss *chouss *cautoall *ccarpay *cmort *cmortint *ctotc *cdurc *ctransc *chousc *chmeqf {
	local realvar = "`var'" + "_real"
	gen `realvar' = 100 * `var' / CPI_base_2003
}

//saves raw, basic panel data
save $tpPath\CAMSHRSpanelraw.dta, replace

use $tpPath\CAMSHRSpanelraw.dta, clear
sum h_cdurs h_cndur h_ctots
drop if wave < 5 // because expenditure data begins in wave 5
drop if wave > 8
sort id wave

* todo later: perhaps do this for F2 F3 etc
gen ret_transition = (r_sayret == 1 | r_sayret == 2) & L.r_sayret == 0 & ((F.r_sayret == 1 | F.r_sayret == 2) | F.r_sayret == . ) 
replace ret_transition = 0 if s_age < 50 | s_age > 70
replace ret_transition = 0 if r_age < 50 | r_age > 70
tab ret_transition if h_cndur != .

gen time = "immediately_before_ret" if F.ret_transition == 1
replace time = "immediately_after_ret" if ret_transition == 1

//drop if missing either the before or after observation
by id, sort: egen n = count(h_cndur) if time != ""
drop if n < 2
save $tpPath\CAMSHRStable1.dta, replace


use $tpPath\CAMSHRStable1.dta, clear
gen dif = (h_cndur - L.h_cndur) / L.h_cndur
//(sem) se_nondur = h_cndur se_expend = h_ctots
//collapse (mean) nondur = h_cndur dur = h_cdurs expend = h_ctots (median) med_nondur = h_cndur med_dur = h_cdurs med_expend = h_ctots hhchange = dif (count) n = h_cndur [pw = weight], by(time)
collapse (mean) nondur = h_cndur dur = h_cdurs expend = h_ctots (median) med_nondur = h_cndur med_dur = h_cdurs med_expend = h_ctots hhchange = dif (count) n = h_cndur, by(time)

list
