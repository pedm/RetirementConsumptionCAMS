/*
This code seeks to reproduce table 2 from Hurd and Rohwedder's paper on 
Heterogeneity in spending change at retirement. Table 2 shows spending levels, 
both mean and median, by wealth quartile before and after retirement, percent 
changes in them, and the median of the change at the household level.

This table describes nondurable spending done in social security income tertiles. 

Written by Lan Luo, Yale University
Herb Scarf RA for Cormac O'Dea @Yale Economics Department
lan.luo@yale.edu

First version: 7/1/18
*/

//Set up directories:
***** Lan ***** 
global folder "C:\Users\ericluo04\Documents\GitHub\RetirementConsumptionCAMS\Data"
***** Cormac ***** 
//global folder

/////////////////////////////// SS Tertiles ///////////////////////////////

//already dropped if wave not between 5 and 8 / if age not between 50 and 70 / (if recollect/expect == . & retired == 1)
use $folder\Intermediate\pretable1.dta, clear

* todo later: perhaps do this for F2 F3 etc
gen ret_transition = retired == 1 & L.retired == 5 & (F.retired == 1 | F.retired == . | F.retired == 9 ) 
tab ret_transition if nondur != .

gen time = "Pre-retirement" if F.ret_transition == 1
replace time = "Post-retirement" if ret_transition == 1
drop if time == ""

//drop if missing either the before or after observation
tab r_age if time == "Pre-retirement"
by id, sort: egen n = count(nondurables) if time != ""
drop if n < 2
tab time

//create wealth quartiles
xtile ssquart = r_isret, nquantiles(3)
//Median Percent Change
gen difnondurables = (nondurables - L.nondurables) / L.nondurables

count if time == "Pre-retirement"
local count = r(N)
di `count'
	
preserve 
	collapse (mean) nondurables, by(time ssquart)
	reshape wide nondurables, i(time) j(ssquart)
	
	set obs 4
	replace time = "Means:" in 3
	gen order = 2 if time == "Pre-retirement"
	replace order = 3 if time == "Post-retirement"
	replace order = 1 if time == "Means:"
	sort order
	drop order
	
	replace time = "Percent Change in Means" in 4	
		replace nondurables1 = (nondurables1[3] - nondurables1[2])/ nondurables1[2] * 100 in 4
		replace nondurables2 = (nondurables2[3] - nondurables2[2])/ nondurables1[2] * 100 in 4
		replace nondurables3 = (nondurables3[3] - nondurables3[2])/ nondurables1[2] * 100 in 4
		
	save $folder\Intermediate\table2quartilesmeans, replace
restore

preserve 
	collapse (median) nondurables, by(time ssquart)
	reshape wide nondurables, i(time) j(ssquart)
	
	set obs 4
	replace time = "Medians:" in 3
	gen order = 2 if time == "Pre-retirement"
	replace order = 3 if time == "Post-retirement"
	replace order = 1 if time == "Medians:"
	sort order
	drop order
	
	replace time = "Percent Change in Medians" in 4	
		replace nondurables1 = (nondurables1[3] - nondurables1[2])/ nondurables1[2] * 100 in 4
		replace nondurables2 = (nondurables2[3] - nondurables2[2])/ nondurables1[2] * 100 in 4
		replace nondurables3 = (nondurables3[3] - nondurables3[2])/ nondurables1[2] * 100 in 4
	
	save $folder\Intermediate\table2quartilesmedians, replace
restore

preserve 
	collapse (p10) difnondurables, by(time ssquart)
	reshape wide difnondurables, i(time) j(ssquart)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p10)*" in 1
	rename difnondurables1 nondurables1
	rename difnondurables2 nondurables2
	rename difnondurables3 nondurables3

	save $folder\Intermediate\table2quartilesmedians21, replace
restore

preserve 
	collapse (p25) difnondurables, by(time ssquart)
	reshape wide difnondurables, i(time) j(ssquart)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p25)*" in 1
	rename difnondurables1 nondurables1
	rename difnondurables2 nondurables2
	rename difnondurables3 nondurables3

	save $folder\Intermediate\table2quartilesmedians22, replace
restore

preserve 
	collapse (median) difnondurables, by(time ssquart)
	reshape wide difnondurables, i(time) j(ssquart)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p50)" in 1
	rename difnondurables1 nondurables1
	rename difnondurables2 nondurables2
	rename difnondurables3 nondurables3

	save $folder\Intermediate\table2quartilesmedians23, replace
restore

preserve 
	collapse (p75) difnondurables, by(time ssquart)
	reshape wide difnondurables, i(time) j(ssquart)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p75)*" in 1
	rename difnondurables1 nondurables1
	rename difnondurables2 nondurables2
	rename difnondurables3 nondurables3

	save $folder\Intermediate\table2quartilesmedians24, replace
restore

preserve 
	collapse (p90) difnondurables, by(time ssquart)
	reshape wide difnondurables, i(time) j(ssquart)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p90)*" in 1
	rename difnondurables1 nondurables1
	rename difnondurables2 nondurables2
	rename difnondurables3 nondurables3

	save $folder\Intermediate\table2quartilesmedians25, replace
restore

use $folder\Intermediate\table2quartilesmeans, clear
append using $folder\Intermediate\table2quartilesmedians
append using $folder\Intermediate\table2quartilesmedians21
append using $folder\Intermediate\table2quartilesmedians22
append using $folder\Intermediate\table2quartilesmedians23
append using $folder\Intermediate\table2quartilesmedians24
append using $folder\Intermediate\table2quartilesmedians25
gen combine = _n
save $folder\Intermediate\table2quartiles, replace

//////////////////////////////////// Total ////////////////////////////////////

//already dropped if wave not between 5 and 8 / if age not between 50 and 70 / (if recollect/expect == . & retired == 1)
use $folder\Intermediate\pretable1.dta, clear

* todo later: perhaps do this for F2 F3 etc
gen ret_transition = retired == 1 & L.retired == 5 & (F.retired == 1 | F.retired == . | F.retired == 9 ) 
tab ret_transition if nondur != .

gen time = "Pre-retirement" if F.ret_transition == 1
replace time = "Post-retirement" if ret_transition == 1
drop if time == ""

//drop if missing either the before or after observation
tab r_age if time == "Pre-retirement"
by id, sort: egen n = count(nondurables) if time != ""
drop if n < 2
tab time

//create wealth quartiles
xtile ssquart = h_atotb, nquantiles(4)
//Median Percent Change
gen difnondurables = (nondurables - L.nondurables) / L.nondurables

preserve 
	collapse (mean) nondurables, by(time)
	
	set obs 4
	replace time = "Means:" in 3
	gen order = 2 if time == "Pre-retirement"
	replace order = 3 if time == "Post-retirement"
	replace order = 1 if time == "Means:"
	sort order
	drop order
	
	replace time = "Percent Change in Means" in 4	
		replace nondurables = (nondurables[3] - nondurables[2])/ nondurables[2] * 100 in 4

	save $folder\Intermediate\table2totalmeans, replace
restore

preserve 
	collapse (median) nondurables, by(time)
	
	set obs 4
	replace time = "Medians:" in 3
	gen order = 2 if time == "Pre-retirement"
	replace order = 3 if time == "Post-retirement"
	replace order = 1 if time == "Medians:"
	sort order
	drop order
	
	replace time = "Percent Change in Medians" in 4	
		replace nondurables = (nondurables[3] - nondurables[2])/ nondurables[2] * 100 in 4
		
	save $folder\Intermediate\table2totalmedians, replace
restore

preserve 
	collapse (p10) difnondurables, by(time)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p10)*" in 1
	rename difnondurables nondurables

	save $folder\Intermediate\table2totalmedians21, replace
restore

preserve 
	collapse (p25) difnondurables, by(time)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p25)*" in 1
	rename difnondurables nondurables

	save $folder\Intermediate\table2totalmedians22, replace
restore

preserve 
	collapse (median) difnondurables, by(time)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p50)" in 1
	rename difnondurables nondurables

	save $folder\Intermediate\table2totalmedians23, replace
restore

preserve 
	collapse (p75) difnondurables, by(time)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p75)*" in 1
	rename difnondurables nondurables

	save $folder\Intermediate\table2totalmedians24, replace
restore

preserve 
	collapse (p90) difnondurables, by(time)
	
	drop if time == "Pre-retirement"
	set obs 1

	replace time = "Median Percent Change (p90)*" in 1
	rename difnondurables nondurables

	save $folder\Intermediate\table2totalmedians25, replace
restore

use $folder\Intermediate\table2totalmeans, clear
append using $folder\Intermediate\table2totalmedians
append using $folder\Intermediate\table2totalmedians21
append using $folder\Intermediate\table2totalmedians22
append using $folder\Intermediate\table2totalmedians23
append using $folder\Intermediate\table2totalmedians24
append using $folder\Intermediate\table2totalmedians25
gen combine = _n
save $folder\Intermediate\table2total, replace

use $folder\Intermediate\table2quartiles, clear
merge 1:1 combine using $folder\Intermediate\table2total
drop combine _merge
rename time SocialSecurity_Quartiles
rename nondurables1 First
rename nondurables2 Second
rename nondurables3 Third
rename nondurables All

replace First = round(First) if SocialSecurity_Quartiles == "Pre-retirement" | SocialSecurity_Quartiles == "Post-retirement"
replace Second = round(Second) if SocialSecurity_Quartiles == "Pre-retirement" | SocialSecurity_Quartiles == "Post-retirement"
replace Third = round(Third) if SocialSecurity_Quartiles == "Pre-retirement" | SocialSecurity_Quartiles == "Post-retirement"
replace All = round(All) if SocialSecurity_Quartiles == "Pre-retirement" | SocialSecurity_Quartiles == "Post-retirement"
replace First = round(First, .1) if SocialSecurity_Quartiles != "Pre-retirement" | SocialSecurity_Quartiles != "Post-retirement"
replace Second = round(Second, .1) if SocialSecurity_Quartiles != "Pre-retirement" | SocialSecurity_Quartiles != "Post-retirement"
replace Third = round(Third, .1) if SocialSecurity_Quartiles != "Pre-retirement" | SocialSecurity_Quartiles != "Post-retirement"
replace All = round(All, .1) if SocialSecurity_Quartiles != "Pre-retirement" | SocialSecurity_Quartiles != "Post-retirement"

tostring First Second Third All, replace force format(%9.1f)
replace First = substr(First, 1, 2) + "," + substr(First, 3, 3) if SocialSecurity_Quartiles == "Pre-retirement" | SocialSecurity_Quartiles == "Post-retirement"
replace Second = substr(Second, 1, 2) + "," + substr(Second, 3, 3) if SocialSecurity_Quartiles == "Pre-retirement" | SocialSecurity_Quartiles == "Post-retirement"
replace Third = substr(Third, 1, 2) + "," + substr(Third, 3, 3) if SocialSecurity_Quartiles == "Pre-retirement" | SocialSecurity_Quartiles == "Post-retirement"
replace All = substr(All, 1, 2) + "," + substr(All, 3, 3) if SocialSecurity_Quartiles == "Pre-retirement" | SocialSecurity_Quartiles == "Post-retirement"

replace First = "" if SocialSecurity_Quartiles == "Means:" | SocialSecurity_Quartiles == "Medians:"
replace Second = "" if SocialSecurity_Quartiles == "Means:" | SocialSecurity_Quartiles == "Medians:"
replace Third = "" if SocialSecurity_Quartiles == "Means:" | SocialSecurity_Quartiles == "Medians:"
replace All = "" if SocialSecurity_Quartiles == "Means:" | SocialSecurity_Quartiles == "Medians:"
list

texsave SocialSecurity_Quartiles First Second Third All using $folder\Final\table2raw.tex, frag title("Real nondurable spending before and after retirement.") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
save $folder\Intermediate\table2data.dta, replace
