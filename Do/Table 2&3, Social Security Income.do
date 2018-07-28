/*
This code seeks to reproduce table 2/3 from Hurd and Rohwedder's paper on 
Heterogeneity in spending change at retirement. Table 2 shows spending levels, 
both mean and median, by wealth quartile before and after retirement, percent 
changes in them, and the median of the change at the household level.
Table 3 shows household income before and after retirement as measured in the 
HRS core data.

This table describes spending in social security income tertiles. The spending 
categories are: nondurables, durables, totals; food at home, food away from home, 
transportation, health, education (no spending variable in CAMS or HRS), housing, 
recreation, and clothing - household income is then included for table 3. 

Written by Lan Luo, Yale University
Herb Scarf RA for Cormac O'Dea @Yale Economics Department
lan.luo@yale.edu

First version: 7/3/18
*/

//Set up directories:
***** Lan ***** 
global folder "C:\Users\ericluo04\Documents\GitHub\RetirementConsumptionCAMS\Data"
***** Cormac ***** 
//global folder

//already dropped (if wave not between 5 and 8) / if age not between 50 and 70 / (if recollect/expect == . & retired == 1)
use $folder\Intermediate\pretable1.dta, clear
	
foreach var of varlist total durables nondurables food foodhome foodaway transport health housing recreation clothes h_itot_real {
	use $folder\Intermediate\pretable1.dta, clear
	
	* todo later: perhaps do this for F2 F3 etc
	gen ret_transition = retired == 1 & L.retired == 5 & (F.retired == 1 | F.retired == . | F.retired == 9 ) 
	tab ret_transition if nondur != .

	gen time = "Pre-retirement" if F.ret_transition == 1
	replace time = "Post-retirement" if ret_transition == 1
	drop if time == ""

	//create social security tertiles
	//impute with years of education
	xtile tertile = max_ssinc_head, nquantiles(3)
	tab raedyrs
	replace tertile = 1 if max_ssinc_head == 0 & raedyrs < 12
    replace tertile = 2 if max_ssinc_head == 0 & raedyrs >= 12 & raedyrs < 16
    replace tertile = 3 if max_ssinc_head == 0 & raedyrs >= 16
	
	/////////////////////////////// SS Tertiles ///////////////////////////////
	
	//drop if missing either the before or after observation
	tab r_age if time == "Pre-retirement"
	by id, sort: egen n = count(`var') if time != ""
	drop if n < 2
	tab time

	//Median Percent Change
	gen dif`var' = (`var' - L.`var') / L.`var' * 100

	count if time == "Pre-retirement"
	local count = r(N)
	di `count'
		
	preserve 
		collapse (mean) `var', by(time tertile)
		reshape wide `var', i(time) j(tertile)
		
		set obs 4
		replace time = "Means:" in 3
		gen order = 2 if time == "Pre-retirement"
		replace order = 3 if time == "Post-retirement"
		replace order = 1 if time == "Means:"
		sort order
		drop order
		
		replace time = "Percent Change in Means" in 4	
			replace `var'1 = (`var'1[3] - `var'1[2])/ `var'1[2] * 100 in 4
			replace `var'2 = (`var'2[3] - `var'2[2])/ `var'1[2] * 100 in 4
			replace `var'3 = (`var'3[3] - `var'3[2])/ `var'1[2] * 100 in 4
			
		save $folder\Intermediate\table2.5tertilesmeans, replace
	restore

	preserve 
		collapse (median) `var', by(time tertile)
		reshape wide `var', i(time) j(tertile)
		
		set obs 4
		replace time = "Medians:" in 3
		gen order = 2 if time == "Pre-retirement"
		replace order = 3 if time == "Post-retirement"
		replace order = 1 if time == "Medians:"
		sort order
		drop order
		
		replace time = "Percent Change in Medians" in 4	
			replace `var'1 = (`var'1[3] - `var'1[2])/ `var'1[2] * 100 in 4
			replace `var'2 = (`var'2[3] - `var'2[2])/ `var'2[2] * 100 in 4
			replace `var'3 = (`var'3[3] - `var'3[2])/ `var'3[2] * 100 in 4
		
		save $folder\Intermediate\table2.5tertilesmedians, replace
	restore

	preserve 
		collapse (p10) dif`var', by(time tertile)
		reshape wide dif`var', i(time) j(tertile)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p10)*" in 1
		rename dif`var'1 `var'1
		rename dif`var'2 `var'2
		rename dif`var'3 `var'3

		save $folder\Intermediate\table2.5tertilesmedians21, replace
	restore

	preserve 
		collapse (p25) dif`var', by(time tertile)
		reshape wide dif`var', i(time) j(tertile)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p25)*" in 1
		rename dif`var'1 `var'1
		rename dif`var'2 `var'2
		rename dif`var'3 `var'3

		save $folder\Intermediate\table2.5tertilesmedians22, replace
	restore

	preserve 
		collapse (median) dif`var', by(time tertile)
		reshape wide dif`var', i(time) j(tertile)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p50)" in 1
		rename dif`var'1 `var'1
		rename dif`var'2 `var'2
		rename dif`var'3 `var'3

		save $folder\Intermediate\table2.5tertilesmedians23, replace
	restore

	preserve 
		collapse (p75) dif`var', by(time tertile)
		reshape wide dif`var', i(time) j(tertile)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p75)*" in 1
		rename dif`var'1 `var'1
		rename dif`var'2 `var'2
		rename dif`var'3 `var'3

		save $folder\Intermediate\table2.5tertilesmedians24, replace
	restore

	preserve 
		collapse (p90) dif`var', by(time tertile)
		reshape wide dif`var', i(time) j(tertile)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p90)*" in 1
		rename dif`var'1 `var'1
		rename dif`var'2 `var'2
		rename dif`var'3 `var'3

		save $folder\Intermediate\table2.5tertilesmedians25, replace
	restore

	use $folder\Intermediate\table2.5tertilesmeans, clear
	append using $folder\Intermediate\table2.5tertilesmedians
	append using $folder\Intermediate\table2.5tertilesmedians21
	append using $folder\Intermediate\table2.5tertilesmedians22
	append using $folder\Intermediate\table2.5tertilesmedians23
	append using $folder\Intermediate\table2.5tertilesmedians24
	append using $folder\Intermediate\table2.5tertilesmedians25
	gen combine = _n
	save $folder\Intermediate\table2.5tertiles, replace

	//////////////////////////////////// Total ////////////////////////////////////

	//already dropped (if wave not between 5 and 8) / if age not between 50 and 70 / (if recollect/expect == . & retired == 1)
	use $folder\Intermediate\pretable1.dta, clear

	* todo later: perhaps do this for F2 F3 etc
	gen ret_transition = retired == 1 & L.retired == 5 & (F.retired == 1 | F.retired == . | F.retired == 9 ) 
	tab ret_transition if nondur != .

	gen time = "Pre-retirement" if F.ret_transition == 1
	replace time = "Post-retirement" if ret_transition == 1
	drop if time == ""

	//drop if missing either the before or after observation
	tab r_age if time == "Pre-retirement"
	by id, sort: egen n = count(`var') if time != ""
	drop if n < 2
	tab time

	//Median Percent Change
	gen dif`var' = (`var' - L.`var') / L.`var' * 100

	preserve 
		collapse (mean) `var', by(time)
		
		set obs 4
		replace time = "Means:" in 3
		gen order = 2 if time == "Pre-retirement"
		replace order = 3 if time == "Post-retirement"
		replace order = 1 if time == "Means:"
		sort order
		drop order
		
		replace time = "Percent Change in Means" in 4	
			replace `var' = (`var'[3] - `var'[2])/ `var'[2] * 100 in 4

		save $folder\Intermediate\table2.5totalmeans, replace
	restore

	preserve 
		collapse (median) `var', by(time)
		
		set obs 4
		replace time = "Medians:" in 3
		gen order = 2 if time == "Pre-retirement"
		replace order = 3 if time == "Post-retirement"
		replace order = 1 if time == "Medians:"
		sort order
		drop order
		
		replace time = "Percent Change in Medians" in 4	
			replace `var' = (`var'[3] - `var'[2])/ `var'[2] * 100 in 4
			
		save $folder\Intermediate\table2.5totalmedians, replace
	restore

	preserve 
		collapse (p10) dif`var', by(time)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p10)*" in 1
		rename dif`var' `var'

		save $folder\Intermediate\table2.5totalmedians21, replace
	restore

	preserve 
		collapse (p25) dif`var', by(time)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p25)*" in 1
		rename dif`var' `var'

		save $folder\Intermediate\table2.5totalmedians22, replace
	restore

	preserve 
		collapse (median) dif`var', by(time)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p50)" in 1
		rename dif`var' `var'

		save $folder\Intermediate\table2.5totalmedians23, replace
	restore

	preserve 
		collapse (p75) dif`var', by(time)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p75)*" in 1
		rename dif`var' `var'

		save $folder\Intermediate\table2.5totalmedians24, replace
	restore

	preserve 
		collapse (p90) dif`var', by(time)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Median Percent Change (p90)*" in 1
		rename dif`var' `var'

		save $folder\Intermediate\table2.5totalmedians25, replace
	restore

	use $folder\Intermediate\table2.5totalmeans, clear
	append using $folder\Intermediate\table2.5totalmedians
	append using $folder\Intermediate\table2.5totalmedians21
	append using $folder\Intermediate\table2.5totalmedians22
	append using $folder\Intermediate\table2.5totalmedians23
	append using $folder\Intermediate\table2.5totalmedians24
	append using $folder\Intermediate\table2.5totalmedians25
	gen combine = _n
	save $folder\Intermediate\table2.5total, replace

	use $folder\Intermediate\table2.5tertiles, clear
	merge 1:1 combine using $folder\Intermediate\table2.5total
	drop combine _merge
	rename time SS_Tertiles
	rename `var'1 First
	rename `var'2 Second
	rename `var'3 Third
	rename `var' All
	
	//appropriate rounding (to the 0 for spending, to the .1 for percents)
	replace First = round(First) if SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement"
	replace Second = round(Second) if SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement"
	replace Third = round(Third) if SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement"
	replace All = round(All) if SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement"
	replace First = round(First, .1) if SS_Tertiles != "Pre-retirement" | SS_Tertiles != "Post-retirement"
	replace Second = round(Second, .1) if SS_Tertiles != "Pre-retirement" | SS_Tertiles != "Post-retirement"
	replace Third = round(Third, .1) if SS_Tertiles != "Pre-retirement" | SS_Tertiles != "Post-retirement"
	replace All = round(All, .1) if SS_Tertiles != "Pre-retirement" | SS_Tertiles != "Post-retirement" 
	
	tostring First Second Third All, replace force format(%9.1f)
	//appropriate comma placement for spending
	replace First = substr(First, 1, 2) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(First) == 4
	replace Second = substr(Second, 1, 2) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Second) == 4
	replace Third = substr(Third, 1, 2) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Third) == 4
	replace All = substr(All, 1, 2) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(All) == 4
	replace First = substr(First, 1, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(First) == 5
	replace Second = substr(Second, 1, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Second) == 5
	replace Third = substr(Third, 1, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Third) == 5
	replace All = substr(All, 1, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(All) == 5
	replace First = substr(First, 1, 1) + "," + substr(First, 2, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(First) == 6
	replace Second = substr(Second, 1, 1) + "," + substr(Second, 2, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Second) == 6
	replace Third = substr(Third, 1, 1) + "," + substr(Third, 2, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Third) == 6
	replace All = substr(All, 1, 1) + "," + substr(All, 2, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(All) == 6
	replace First = substr(First, 1, 2) + "," + substr(First, 3, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(First) == 7
	replace Second = substr(Second, 1, 2) + "," + substr(Second, 3, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Second) == 7
	replace Third = substr(Third, 1, 2) + "," + substr(Third, 3, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Third) == 7
	replace All = substr(All, 1, 2) + "," + substr(All, 3, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(All) == 7
	replace First = substr(First, 1, 3) + "," + substr(First, 4, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(First) == 8
	replace Second = substr(Second, 1, 3) + "," + substr(Second, 4, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Second) == 8
	replace Third = substr(Third, 1, 3) + "," + substr(Third, 4, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(Third) == 8
	replace All = substr(All, 1, 3) + "," + substr(All, 4, 3) if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & strlen(All) == 8
	replace First = "0" if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & First == "0.0"
	replace Second = "0" if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & Second == "0.0"
	replace Third = "0" if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & Third == "0.0"
	replace All = "0" if (SS_Tertiles == "Pre-retirement" | SS_Tertiles == "Post-retirement") & All == "0.0"
	
	//clean up table with empty space
	replace First = "" if SS_Tertiles == "Means:" | SS_Tertiles == "Medians:"
	replace Second = "" if SS_Tertiles == "Means:" | SS_Tertiles == "Medians:"
	replace Third = "" if SS_Tertiles == "Means:" | SS_Tertiles == "Medians:"
	replace All = "" if SS_Tertiles == "Means:" | SS_Tertiles == "Medians:"
	list

	if "`var'" == "total" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5totalraw.tex, frag title("Real total spending before and after retirement by social security income tertiles (RAND category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table2.5totaldata.dta, replace
	}
	if "`var'" == "durables" {		
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5durablesraw.tex, frag title("Real durables spending before and after retirement by social security income tertiles (RAND category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table2.5durablesdata.dta, replace
	}
	if "`var'" == "nondurables" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5nondurablesraw.tex, frag title("Real nondurables spending before and after retirement by social security income tertiles (RAND category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace		
		save $folder\Intermediate\table2.5nondurablesdata.dta, replace
	}
	if "`var'" == "food" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5foodraw.tex, frag title("Real food spending before and after retirement by social security income tertiles (Generated category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by food/drink and dining out in CAMS. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table2.5fooddata.dta, replace
	}
	if "`var'" == "foodhome" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5foodhomeraw.tex, frag title("Real food at home spending before and after retirement by social security income tertiles (PSID category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by food/drink in CAMS. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table2.5foodhomedata.dta, replace
	}
	if "`var'" == "foodaway" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5foodawayraw.tex, frag title("Real food away from home spending before and after retirement by social security income tertiles (PSID category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by dining out in CAMS. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table2.5foodawaydata.dta, replace
	}
	if "`var'" == "transport" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5transportraw.tex, frag title("Real transportation spending before and after retirement by social security income tertiles (RAND and PSID category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace		
		save $folder\Intermediate\table2.5transportdata.dta, replace
	}
	if "`var'" == "health" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5healthraw.tex, frag title("Real health spending before and after retirement by social security income tertiles (PSID category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by health insurance, drugs, health services, and medical supplies in CAMS. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table2.5healthdata.dta, replace
	}
	if "`var'" == "housing" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5housingraw.tex, frag title("Real housing spending before and after retirement by social security income tertiles (RAND and PSID category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace		
		save $folder\Intermediate\table2.5housingdata.dta, replace
	}
	if "`var'" == "recreation" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5recreationraw.tex, frag title("Real recreation spending before and after retirement by social security income tertiles (PSID category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by vacations, tickets, hobbies/sports, hobbies, and sports in CAMS. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table2.5recreationdata.dta, replace
	}
	if "`var'" == "clothes" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table2.5clothesraw.tex, frag title("Real clothing spending before and after retirement by social security income tertiles (PSID category).") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 2 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by clothing in CAMS. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table2.5clothesdata.dta, replace
	}
	if "`var'" == "h_itot_real" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table3.5incomeraw.tex, frag title("Real household income before and after retirement by social security income tertiles.") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 3 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak N = `count'.") hlines(1 4 5) replace
		save $folder\Intermediate\table3.5incomeraw.dta, replace
	}
}
