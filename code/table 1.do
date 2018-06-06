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

ssc install zipsave

//Set up directories:
***** Lan ***** 
global folder "C:\Users\ericluo04\Documents\GitHub\RetirementConsumptionCAMS\Data"
***** Cormac ***** 
//global folder

use $folder\Raw\randhrs1992_2014v2_STATA\randhrs1992_2014v2.dta, clear
//reduce size of rand HRS data to fit CAMS range of years
drop s1* r1* h1* s2* r2* h2* s3* r3* h3* s4* r4* h4*
save $folder\Raw\randhrs2000_2014v2.dta, replace

use $folder\Raw\randhrs2000_2014v2.dta, clear
merge 1:1 hhidpn using $folder\Raw\randcams_2001_2015v2\randcams_2001_2015v2.dta, keep(2 3)
drop _merge

keep hhidpn *agey_b *cwgthh *lbrf *sayret *retemp *lbrfh *lbrfy *inlbrf *cmstat *ctots *cdurs *cndur *ctranss *chouss *cautoall *ccarpay *cmort *cmortint *ctotc *cdurc *ctransc *chousc *chmeqf

//renaming variables to prepare for reshaping (example: h5cndurf -> h_cndurf5)
foreach var of varlist *agey_b *cwgthh *lbrf *sayret *retemp *lbrfh *lbrfy *cmstat *ctots *cdurs *cndur *ctranss *chouss *cautoall *ccarpay *cmort *cmortint *ctotc *cdurc *ctransc *chousc *chmeqf {
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
reshape long s_agey_b r_agey_b h_cwgthh s_lbrf r_lbrf s_inlbrf r_inlbrf  s_sayret r_sayret s_retemp r_retemp s_lbrfh r_lbrfh s_lbrfy r_lbrfy h_cmstat h_ctots h_cdurs h_cndur h_ctranss h_chouss h_cautoall h_ccarpay h_cmort h_cmortint h_ctotc h_cdurc h_ctransc h_chousc h_chmeqf, i(hhidpn) j(wave)

//sort and declare data set as panel data
//NOTE: wave refers to HRS waves not CAMS waves
sort hhidpn wave
xtset hhidpn wave 
rename hhidpn id
rename s_agey_b s_age
rename r_agey_b r_age
rename h_cwgthh weight

//saves raw, basic panel data
save $folder\Intermediate\CAMSHRSpanelraw.dta, replace

use $folder\Intermediate\CAMSHRSpanelraw.dta, clear
forvalues year = 1(2)15{
	local wave = `year' / 2 + 4.5
	if `year' < 10{
		local year_string "0`year'"
		local wave_string "0`wave'"
	}
	else{
		local year_string "`year'"
		local wave_string "`wave'"
	}
	
	preserve
		use "$folder\Raw\cams20`year_string'\CAMS`year_string'_R.dta", clear
		destring HHID, replace
		destring PN, replace
		gen double id = HHID*1000 + PN
		gen wave = `wave'
		
		//drop if respondent didn't respond to any of part B of the CAMS survey
		egen number_nonmiss = rownonmiss(B*)
		drop if number_nonmiss == 0
		drop number_nonmiss

		//rename to maintain cross-wave consistency
		if `year' == 1{
			//purchase/lease auto
			rename B1A_4_`year_string' B1a4
			rename B1B_4_`year_string' B1b4
			rename B1C_4_`year_string' B1c4
			//measure of retired
			rename B38_`year_string' retired
			rename B38A_`year_string' recollect
			rename B38B_`year_string' recollectPerc
			rename B38D_`year_string' expect
			rename B38E_`year_string' expectPerc
			
			keep id wave B1a4 B1b4 B1c4 retired recollect recollectPerc expect expectPerc
		} 
		if `year' == 3{
			//purchase/lease auto
			rename B1A4_`year_string' B1a4
			rename B1B4_`year_string' B1b4
			rename B1C4_`year_string' B1c4
			//measure of retired
			rename B44_`year_string' retired
			rename B44A_`year_string' recollect
			rename B44B_`year_string' recollectPerc
			rename B44D_`year_string' expect
			rename B44E_`year_string' expectPerc
			//housekeeping services
			rename B21_`year_string' housekeeping
			//gardening/yard services
			rename B23_`year_string' gardenyard
			//personal care
			rename B27_`year_string' perscare
			
			keep id wave B1a4 B1b4 B1c4 retired recollect recollectPerc expect expectPerc housekeeping gardenyard perscare
		}
		if `year' == 5 | `year' == 7 | `year' == 9 | `year' == 11 | `year' == 13 | `year' == 15{
			//purchase/lease auto
			rename B1a4_`year_string' B1a4
			rename B1b4_`year_string' B1b4
			rename B1c4_`year_string' B1c4	
			//measure of retired
			rename B45_`year_string' retired
			rename B45a_`year_string' recollect
			rename B45b_`year_string' recollectPerc
			rename B45d_`year_string' expect
			rename B45e_`year_string' expectPerc
			//housekeeping services
			rename B26_`year_string' housekeeping
			//gardening/yard services
			rename B28_`year_string' gardenyard
			//personal care
			rename B30_`year_string' perscare
			//household furnishings
			rename B15_`year_string' furnish
			
			keep id wave B1a4 B1b4 B1c4 retired recollect recollectPerc expect expectPerc housekeeping gardenyard perscare furnish
		}
		tempfile ready_to_merge
		save `ready_to_merge', replace
	restore
	
	//4 participants were ommitted from various waves (reference page 6-7 of the
	//RAND_CAMS_2015V2 Documentation file in: Merging to the HRS
	merge 1:1 id wave using `ready_to_merge', update gen(merge`wave_string')
	drop if merge`wave_string' == 2
	save $folder\Intermediate\CAMSHRSpanelrawmerge.dta, replace
}

//import CPI to make monetary values real
clear
import excel "$folder/Raw/CPI_2015.xls", sheet("Sheet1")  firstrow
rename Year wave
replace wave = 5 if wave == 2001
replace wave = 6 if wave == 2003
replace wave = 7 if wave == 2005
replace wave = 8 if wave == 2007
replace wave = 9 if wave == 2009
replace wave = 10 if wave == 2011
replace wave = 11 if wave == 2013
replace wave = 12 if wave == 2015
drop if wave > 12
keep wave CPI_base_2003
save "$folder/Intermediate/CPI.dta", replace

merge 1:m wave using $folder\Intermediate\CAMSHRSpanelrawmerge.dta
tab wave if _merge == 2
tab wave if _merge == 3
drop _merge

//create real variables for spending values
foreach var of varlist B1* housekeeping gardenyard perscare furnish *ctots *cdurs *cndur *ctranss *chouss *cautoall *ccarpay *cmort *cmortint *ctotc *cdurc *ctransc *chousc *chmeqf {
	local realvar = "`var'" + "_real"
	gen `realvar' = 100 * `var' / CPI_base_2003
}

//saves raw, basic panel data
save $folder\Intermediate\CAMSHRSpanelrawmerge.dta, replace

use $folder\Intermediate\CAMSHRSpanelrawmerge.dta, clear
drop if wave < 5 // because expenditure data begins in wave 5
drop if wave > 8
//drop if recollect == . & retired == 1
//drop if recollect == . & retired == 1
sort id wave

//generate nondurable definition across waves based on first six categories of CAMS
replace B1a4 = . if B1a4 == 99999 | B1a4 == 999999
replace B1b4 = . if B1b4 == 99999 | B1b4 == 999999
replace B1c4 = . if B1c4 == 99999 | B1c4 == 999999
egen B1 = rowtotal(B1a4 B1b4 B1c4)
egen newmeasures1 = rowtotal(housekeeping gardenyard perscare)
egen newmeasures2 = rowtotal(housekeeping gardenyard perscare furnish)
gen nondur = h_ctots - h_cdurs - B1
replace nondur = h_ctots - h_cdurs - B1 - newmeasures1 if wave == 6
replace nondur = h_ctots - h_cdurs - B1 - newmeasures2 if wave == 7 | wave == 8 | wave == 9 | wave == 10 | wave == 11 | wave == 12
//consistent total expenditure definition across waves
replace h_ctots = h_ctots - newmeasures1 if wave == 6
replace h_ctots = h_ctots - newmeasures2 if wave == 7 | wave == 8 | wave == 9 | wave == 10 | wave == 11 | wave == 12

* todo later: perhaps do this for F2 F3 etc
gen ret_transition = retired == 1 & L.retired == 5 & (F.retired == 1 | F.retired == . | F.retired == 9 ) 
replace ret_transition = 0 if r_age < 50 | r_age > 70
tab ret_transition if nondur != .

gen time = "immediately_before_ret" if F.ret_transition == 1
replace time = "immediately_after_ret" if ret_transition == 1
// drop if time == ""

//drop if missing either the before or after observation
by id, sort: egen n = count(nondur) if time != ""
drop if n < 2
tab time
save $folder\Final\CAMSHRStable1.dta, replace

//nondurables mean
use $folder\Final\CAMSHRStable1.dta, clear
gen dif = (nondur - L.nondur) / L.nondur

preserve
	collapse (mean) nondur h_ctots h_cdurs B1 B1a4 B1b4 B1c4, by(wave)
	list 
restore

collapse (mean) nondur total = h_ctots h_cdurs B1 (count) n = nondur [pw = weight], by(time)
//collapse (mean) nondur total = h_ctots (median) nondur_med = nondur total_med = h_ctots hhchange = dif (count) n = nondur, by(time)
list
