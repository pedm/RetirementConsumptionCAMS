/*
This code seeks to reproduce table 6 from Hurd and Rohwedder's paper on 
Heterogeneity in spending change at retirement. Table 6 shows median percent 
change before and after retirement in real spending categories by wealth tertiles 
and financial planning horizon.

This table describes spending in social security income tertiles. The spending categories 
are: nondurables, durables, totals; food at home, food away from home, 
transportation, health, education (no spending variable in CAMS or HRS), housing, 
recreation, and clothing - household income is then included for table 3. 

Written by Lan Luo, Yale University
Herb Scarf RA for Cormac O'Dea @Yale Economics Department
lan.luo@yale.edu

First version: 6/23/18
*/

//Set up directories:
***** Lan ***** 
global folder "C:\Users\ericluo04\Documents\GitHub\RetirementConsumptionCAMS\Data"
***** Cormac ***** 
//global folder

//already dropped (if wave not between 5 and 8) / if age not between 50 and 70 / (if recollect/expect == . & retired == 1)
use $folder\Intermediate\pretable1.dta, clear

foreach var of varlist total durables nondurables food foodhome foodaway transport health housing recreation clothes {
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
	gen dif`var' = (`var' - L.`var') / L.`var'

	count if time == "Pre-retirement"
	local count = r(N)
	di `count'
	
	//short financial planning horizon
	preserve 
		keep if shortHorizon == 1
		
		collapse (median) dif`var', by(time tertile)
		reshape wide dif`var', i(time) j(tertile)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Short horizon" in 1
		rename dif`var'1 `var'1
		rename dif`var'2 `var'2
		rename dif`var'3 `var'3

		save $folder\Intermediate\table6.5tertilesshorthorizon, replace
	restore
	
	//long financial planning horizon
	preserve 
		keep if shortHorizon == 0
		
		collapse (median) dif`var', by(time tertile)
		reshape wide dif`var', i(time) j(tertile)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Long horizon" in 1
		rename dif`var'1 `var'1
		rename dif`var'2 `var'2
		rename dif`var'3 `var'3

		save $folder\Intermediate\table6.5tertileslonghorizon, replace
	restore
	
	//all financial planning horizon
	preserve 
		keep if shortHorizon != .
		
		collapse (median) dif`var', by(time tertile)
		reshape wide dif`var', i(time) j(tertile)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "All" in 1
		rename dif`var'1 `var'1
		rename dif`var'2 `var'2
		rename dif`var'3 `var'3

		save $folder\Intermediate\table6.5tertilesallhorizon, replace
	restore
	
	//percent who say short horizon financial planning 
	preserve 
		count if shortHorizon == 1 & tertile == 1
		local countshortHorizon1 = r(N)
		count if shortHorizon == 1 & tertile == 2
		local countshortHorizon2 = r(N)
		count if shortHorizon == 1 & tertile == 3
		local countshortHorizon3 = r(N)
		
		count if shortHorizon != . & tertile == 1
		local countall1 = r(N)
		count if shortHorizon != . & tertile == 2
		local countall2 = r(N)
		count if shortHorizon != . & tertile == 3
		local countall3 = r(N)
		
		clear 
		set obs 1
		gen time = ""
		gen `var'1 = .
		gen `var'2 = .
		gen `var'3 = .
				
		replace time = "Percent with short horizon" in 1
		replace `var'1 = `countshortHorizon1' / `countall1' in 1
		replace `var'2 = `countshortHorizon2' / `countall2' in 1
		replace `var'3 = `countshortHorizon3' / `countall3' in 1

		save $folder\Intermediate\table6.5tertilespercent, replace
	restore

	use $folder\Intermediate\table6.5tertilesshorthorizon, clear
	append using $folder\Intermediate\table6.5tertileslonghorizon
	append using $folder\Intermediate\table6.5tertilesallhorizon
	append using $folder\Intermediate\table6.5tertilespercent
	gen combine = _n
	save $folder\Intermediate\table6.5tertiles, replace

	//////////////////////////////////// Total ////////////////////////////////////
	
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
	gen dif`var' = (`var' - L.`var') / L.`var'
	
	//short financial planning horizon
	preserve 
		keep if shortHorizon == 1
		
		collapse (median) dif`var', by(time)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Short horizon" in 1
		rename dif`var' `var'

		save $folder\Intermediate\table6.5allshorthorizon, replace
	restore
	
	//long financial planning horizon
	preserve 
		keep if shortHorizon == 0
		
		collapse (median) dif`var', by(time)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Long horizon" in 1
		rename dif`var' `var'

		save $folder\Intermediate\table6.5alllonghorizon, replace
	restore
	
	//all financial planning horizon
	preserve 
		keep if shortHorizon != .
		
		collapse (median) dif`var', by(time)
		
		drop if time == "Pre-retirement"
		set obs 1

		replace time = "Long horizon" in 1
		rename dif`var' `var'

		save $folder\Intermediate\table6.5allallhorizon, replace
	restore
	
	//percent who say short horizon financial planning 
	preserve 
		count if shortHorizon == 1
		local countshortHorizon = r(N)
		
		count if shortHorizon != .
		local countall = r(N)
		
		clear 
		set obs 1
		gen time = ""
		gen `var' = .
				
		replace time = "Percent with short horizon" in 1
		replace `var' = `countshortHorizon' / `countall' in 1

		save $folder\Intermediate\table6.5allpercent, replace
	restore

	use $folder\Intermediate\table6.5allshorthorizon, clear
	append using $folder\Intermediate\table6.5alllonghorizon
	append using $folder\Intermediate\table6.5allallhorizon
	append using $folder\Intermediate\table6.5allpercent
	gen combine = _n
	save $folder\Intermediate\table6.5total, replace

	use $folder\Intermediate\table6.5tertiles, clear
	merge 1:1 combine using $folder\Intermediate\table6.5total
	drop combine _merge
	rename time SS_Tertiles
	rename `var'1 First
	rename `var'2 Second
	rename `var'3 Third
	rename `var' All
	
	//make into percentage
	replace First = First*100
	replace Second = Second*100
	replace Third = Third*100
	replace All = All*100
	
	//appropriate rounding
	replace First = round(First, .1)
	replace Second = round(Second, .1)
	replace Third = round(Third, .1)
	replace All = round(All, .1)
	list
	
	if "`var'" == "total" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5totalraw.tex, frag title("Median percent change before and after retirement in real total spending (%) by social security income tertiles and financial planning horizon (RAND category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak N = `count'.") replace
		save $folder\Intermediate\table6.5totaldata.dta, replace
	}
	if "`var'" == "durables" {		
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5durablesraw.tex, frag title("Median percent change before and after retirement in real durables spending (%) by social security income tertiles and financial planning horizon (RAND category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak N = `count'.") replace
		save $folder\Intermediate\table6.5durablesdata.dta, replace
	}
	if "`var'" == "nondurables" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5nondurablesraw.tex, frag title("Median percent change before and after retirement in real nondurables spending (%) by social security income tertiles and financial planning horizon (RAND category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak N = `count'.") replace		
		save $folder\Intermediate\table6.5nondurablesdata.dta, replace
	}
	if "`var'" == "food" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5foodraw.tex, frag title("Median percent change before and after retirement in real food spending (%) by social security income tertiles and financial planning horizon (Generated category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by food/drink and dining out in CAMS. \linebreak --- \linebreak N = `count'.") replace
		save $folder\Intermediate\table6.5fooddata.dta, replace
	}
	if "`var'" == "foodhome" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5foodhomeraw.tex, frag title("Median percent change before and after retirement in real food at home spending (%) by social security income tertiles and financial planning horizon (PSID category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by food/drink in CAMS. \linebreak --- \linebreak N = `count'.") replace
		save $folder\Intermediate\table6.5foodhomedata.dta, replace
	}
	if "`var'" == "foodaway" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5foodawayraw.tex, frag title("Median percent change before and after retirement in real food away from home spending (%) by social security income tertiles and financial planning horizon (PSID category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by dining out in CAMS. \linebreak --- \linebreak N = `count'.") replace
		save $folder\Intermediate\table6.5foodawaydata.dta, replace
	}
	if "`var'" == "transport" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5transportraw.tex, frag title("Median percent change before and after retirement in real transportation spending (%) by social security income tertiles and financial planning horizon (RAND and PSID category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak N = `count'.") replace		
		save $folder\Intermediate\table6.5transportdata.dta, replace
	}
	if "`var'" == "health" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5healthraw.tex, frag title("Median percent change before and after retirement in real health spending (%) by social security income tertiles and financial planning horizon (PSID category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by health insurance, drugs, health services, and medical supplies in CAMS. \linebreak --- \linebreak N = `count'.") replace
		save $folder\Intermediate\table6.5healthdata.dta, replace
	}
	if "`var'" == "housing" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5housingraw.tex, frag title("Median percent change before and after retirement in real housing spending (%) by social security income tertiles and financial planning horizon (RAND and PSID category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined in accordance with page 9 (Table 1: Variable Names Across Waves) of the RAND_CAMS_2015V2 Data Documentation file. \linebreak --- \linebreak N = `count'.") replace		
		save $folder\Intermediate\table6.5housingdata.dta, replace
	}
	if "`var'" == "recreation" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5recreationraw.tex, frag title("Median percent change before and after retirement in real recreation spending (%) by social security income tertiles and financial planning horizon (PSID category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by vacations, tickets, hobbies/sports, hobbies, and sports in CAMS. \linebreak --- \linebreak N = `count'.") replace
		save $folder\Intermediate\table6.5recreationdata.dta, replace
	}
	if "`var'" == "clothes" {
		texsave SS_Tertiles First Second Third All using $folder\Final\table6.5clothesraw.tex, frag title("Median percent change before and after retirement in real clothes spending (%) by social security income tertiles and financial planning horizon (PSID category).") footnote("This table references Table 6 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. \linebreak --- \linebreak This spending category is defined by clothing in CAMS. \linebreak --- \linebreak N = `count'.") replace
		save $folder\Intermediate\table6.5clothesdata.dta, replace
	}
}
