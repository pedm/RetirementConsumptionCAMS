/*
This code seeks to reproduce table 1 from Hurd and Rohwedder's paper on 
Heterogeneity in spending change at retirement. Table 1 shows the means
and medians of total real spending before and after retirement and the 
median of the change in spending calculated over households where 
retirement occurred between CAMS waves.

The first section of code is for the retirement sample, and the second is for
the comparison sample. 

Written by Lan Luo, Yale University
Herb Scarf RA for Cormac O'Dea @Yale Economics Department
lan.luo@yale.edu

First version: 6/18/18
*/
clear

ssc install texsave, replace

//Set up directories:
***** Lan ***** 
global folder "C:\Users\ericluo04\Documents\GitHub\RetirementConsumptionCAMS\Data"
***** Cormac ***** 
//global folder

////////////////////////////// Retirement Sample //////////////////////////////

use $folder\Intermediate\CAMSHRSpanelrawmergereal.dta, clear
//drop if wave < 5
//drop if wave > 8
sort id wave

drop if r_age < 50 | r_age > 70
//drop if recollect == . & retired == 1
//drop if expect == . & retired == 5

//generate wave consistent spending categories by generating from individual wave CAMS data
egen total = rowtotal(auto1_real auto2_real auto3_real refrig_real washdry_real dishwash_real tv_real computer_real electricity_real water_real heat_real phonecableinternet_real healthinsur_real houseyardsupplies_real housesupplies_real yardsupplies_real fooddrink_real diningout_real clothing_real drugs_real healthservices_real medicalsupplies_real vacations_real tickets_real hobbiessports_real hobbies_real sports_real contributions_real gifts_real carpayments_real autoinsur_real gas_real vehicleservices_real mortgage_real homerentinsur_real propertytax_real rent_real hrepsuppliesservices_real hrepsupplies_real hrepservices_real)
egen nondurables = rowtotal(electricity_real water_real heat_real phonecableinternet_real healthinsur_real houseyardsupplies_real housesupplies_real yardsupplies_real fooddrink_real diningout_real clothing_real drugs_real healthservices_real medicalsupplies_real vacations_real tickets_real hobbiessports_real hobbies_real sports_real contributions_real gifts_real carpayments_real autoinsur_real gas_real vehicleservices_real mortgage_real homerentinsur_real propertytax_real rent_real hrepsuppliesservices_real hrepsupplies_real hrepservices_real)
egen durables = rowtotal(auto1_real auto2_real auto3_real refrig_real washdry_real dishwash_real tv_real computer_real)
egen food = rowtotal(fooddrink_real diningout_real)

//generate PSID consistent categories to use in spending tertile tables
gen foodhome = fooddrink_real
gen foodaway =  diningout_real
egen transport = rowtotal(auto1_real auto2_real auto3_real carpayments_real autoinsur_real gas_real vehicleservices_real)
egen health = rowtotal(healthinsur_real drugs_real healthservices_real medicalsupplies_real)
//no education
egen housing = rowtotal(mortgage_real homerentinsur_real propertytax_real rent_real hrepsuppliesservices_real hrepsupplies_real hrepservices_real)
egen recreation = rowtotal(vacations_real tickets_real hobbiessports_real hobbies_real sports_real)
gen clothes = clothing_real

//generate max social security across all waves
egen max_ssinc_head = max(r_isret), by(id)

save $folder\Intermediate\pretable1.dta, replace
use $folder\Intermediate\pretable1.dta, clear

* todo later: perhaps do this for F2 F3 etc
gen ret_transition = retired == 1 & L.retired == 5 & (F.retired == 1 | F.retired == . | F.retired == 9 ) 
tab ret_transition if nondur != .

gen time = "pre-retirement" if F.ret_transition == 1
replace time = "post-retirement" if ret_transition == 1
drop if time == ""

//drop if missing either the before or after observation
tab r_age if time == "pre-retirement"
by id, sort: egen n = count(nondurables) if time != ""
drop if n < 2
tab time

//household-level change
gen diftotal = (total - L.total) / L.total
gen difnondurables = (nondurables - L.nondurables) / L.nondurables
gen diffood = (food - L.food) / L.food

//preserve
// 	collapse (mean) total nondurables durables, by(wave)
// 	list 
//restore

preserve
	keep id wave r_age h_cmstat
	collapse (count) c = id, by(wave r_age h_cmstat)
	save $folder\Intermediate\weightsretirement.dta, replace
restore

count if time == "pre-retirement"
local count = r(N)

collapse (mean) total nondurables food (median) total_med = total nondurables_med = nondurables food_med = food diftotal_med = diftotal difnondurables_med = difnondurables diffood_med = diffood (p10) diftotal10 = diftotal difnondurables10 = difnondurables diffood10 = diffood (p25) diftotal25 = diftotal difnondurables25 = difnondurables diffood25 = diffood (p75) diftotal75 = diftotal difnondurables75 = difnondurables diffood75 = diffood (p90) diftotal90 = diffood difnondurables90 = difnondurables diffood90 = diffood (count) n = nondurables, by(time)
	
//make more observations to manually produce table 1
set obs 16

gen Spending = ""
gen Total = .
gen Nondurables = .
gen Food = .
order Spending Total Nondurables Food
	
replace Spending = "Means:" in 1
replace Spending = "Pre-retirement" in 2
	replace Total = total[2] in 2
	replace Nondurables = nondurables[2] in 2
	replace Food = food[2] in 2
replace Spending = "Post-retirement" in 3
	replace Total = total[1] in 3
	replace Nondurables = nondurables[1] in 3
	replace Food = food[1] in 3
replace Spending = "Percent Change in Means" in 4
	replace Total = (total[1] - total[2]) / total[2] * 100 in 4
	replace Nondurables = (nondurables[1] - nondurables[2]) / nondurables[2] * 100 in 4
	replace Food = (food[1] - food[2]) / food[2] * 100 in 4
replace Spending = "95% confidence interval" in 5
replace Spending = "Medians:" in 6
replace Spending = "Pre-retirement" in 7
	replace Total = total_med[2] in 7
	replace Nondurables = nondurables_med[2] in 7
	replace Food = food_med[2] in 7
replace Spending = "Post-retirement" in 8
	replace Total = total_med[1] in 8
	replace Nondurables = nondurables_med[1] in 8
	replace Food = food_med[1] in 8
replace Spending = "Percent Change in Medians" in 9
	replace Total = (total_med[1] - total_med[2]) / total_med[2] * 100 in 9
	replace Nondurables = (nondurables_med[1] - nondurables_med[2]) / nondurables_med[2] * 100 in 9
	replace Food = (food_med[1] - food_med[2]) / food_med[2] * 100 in 9
replace Spending = "95% confidence interval" in 10
replace Spending = "Median Percent Change (p10)*" in 11
	replace Total = diftotal10[1] * 100 in 11
	replace Nondurables = difnondurables10[1] * 100 in 11
	replace Food = diffood10[1] * 100 in 11
replace Spending = "Median Percent Change (p25)*" in 12
	replace Total = diftotal25[1] * 100 in 12
	replace Nondurables = difnondurables25[1] * 100 in 12
	replace Food = diffood25[1] * 100 in 12
replace Spending = "Median Percent Change (p50)" in 13
	replace Total = diftotal_med[1] * 100 in 13
	replace Nondurables = difnondurables_med[1] * 100 in 13
	replace Food = diffood_med[1] * 100 in 13
replace Spending = "Median Percent Change (p75)*" in 14
	replace Total = diftotal75[1] * 100 in 14
	replace Nondurables = difnondurables75[1] * 100 in 14
	replace Food = diffood75[1] * 100 in 14
replace Spending = "Median Percent Change (p90)*" in 15
	replace Total = diftotal90[1] * 100 in 15
	replace Nondurables = difnondurables90[1] * 100 in 15
	replace Food = diffood90[1] * 100 in 15
replace Spending = "95% confidence interval (p50)" in 16
keep Spending Total Nondurables Food

replace Total = round(Total) if Spending == "Pre-retirement" | Spending == "Post-retirement"
replace Nondurables = round(Nondurables) if Spending == "Pre-retirement" | Spending == "Post-retirement"
replace Food = round(Food) if Spending == "Pre-retirement" | Spending == "Post-retirement"
replace Total = round(Total, .1) if Spending != "Pre-retirement" | Spending != "Post-retirement"
replace Nondurables = round(Nondurables, .1) if Spending != "Pre-retirement" | Spending != "Post-retirement"
replace Food = round(Food, .1) if Spending != "Pre-retirement" | Spending != "Post-retirement"

tostring Total Nondurables Food, replace force format(%9.1f)
replace Total = substr(Total, 1, 2) + "," + substr(Total, 3, 3) if Spending == "Pre-retirement" | Spending == "Post-retirement"
replace Nondurables = substr(Nondurables, 1, 2) + "," + substr(Nondurables, 3, 3) if Spending == "Pre-retirement" | Spending == "Post-retirement"
replace Food = substr(Food, 1, 1) + "," + substr(Food, 2, 3) if Spending == "Pre-retirement" | Spending == "Post-retirement"

replace Total = "" if Spending == "Means:" | Spending == "Medians:"
replace Nondurables = "" if Spending == "Means:" | Spending == "Medians:"
replace Food = "" if Spending == "Means:" | Spending == "Medians:"
list
	
texsave Spending Total Nondurables Food using $folder\Final\table1raw.tex, frag title("Average and median real spending before and after retirement") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 1 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. Hurd and Rohwedder bootstrap their confidence intervals. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak Retirement sample, N = `count'. This sample consists of households where we have panel data on actual spending pre- and post-retirement, and on the anticipations of spending change prior to retirement and recollections of spending change after retirement. The sample describes retirement transitions among 50 to 70 year-olds where the responses to the question “Are you retired?” indicate a transition from not retired to retired. These responses are constructed from four waves of CAMS, 2001 to 2007, yielding three panel transitions where we observe actual spending data before and after retirement for these observations.") hlines(1 5 6) replace
save $folder\Intermediate\table1data.dta, replace


////////////////////////////// Comparison Sample //////////////////////////////


//(already dropped if wave not between 5 and 8) / if age not between 50 and 70 / if recollect/expect == . & retired == 1
use $folder\Intermediate\pretable1.dta, clear

//households who don't report a retirement transition between waves 5 and 6
preserve 
	keep if wave == 5 | wave == 6
	drop if retired == .
	keep if (retired == L.retired) | (retired == F.retired)
	gen time = "pre-retirement"
	replace time = "post-retirement" if wave == 6 
	
	tostring id, gen(newid) 
	replace newid = "56_" + newid 
	save $folder\Intermediate\pretable1.5.dta, replace
	tab time
restore

//households who don't report a retirement transition between waves 6 and 7
preserve 
	keep if wave == 6 | wave == 7
	drop if retired == .
	keep if (retired == L.retired) | (retired == F.retired)
	gen time = "pre-retirement"
	replace time = "post-retirement" if wave == 7
	
	tostring id, gen(newid) 
	replace newid = "67_" + newid 
	append using $folder\Intermediate\pretable1.5.dta
	save $folder\Intermediate\pretable1.5.dta, replace
	tab time
restore

//households who don't report a retirement transition between waves 7 and 8
preserve 
	keep if wave == 7 | wave == 8
	drop if retired == .
	keep if (retired == L.retired) | (retired == F.retired)
	gen time = "pre-retirement"
	replace time = "post-retirement" if wave == 8
	
	tostring id, gen(newid) 
	replace newid = "78_" + newid 
	append using $folder\Intermediate\pretable1.5.dta
	save $folder\Intermediate\pretable1.5.dta, replace
	tab time
restore

//households who don't report a retirement transition between waves 8 and 9
preserve 
	keep if wave == 8 | wave == 9
	drop if retired == .
	keep if (retired == L.retired) | (retired == F.retired)
	gen time = "pre-retirement"
	replace time = "post-retirement" if wave == 9
	
	tostring id, gen(newid) 
	replace newid = "89_" + newid 
	append using $folder\Intermediate\pretable1.5.dta
	save $folder\Intermediate\pretable1.5.dta, replace
	tab time
restore

//households who don't report a retirement transition between waves 9 and 10
preserve 
	keep if wave == 9 | wave == 10
	drop if retired == .
	keep if (retired == L.retired) | (retired == F.retired)
	gen time = "pre-retirement"
	replace time = "post-retirement" if wave == 10
	
	tostring id, gen(newid) 
	replace newid = "910_" + newid 
	append using $folder\Intermediate\pretable1.5.dta
	save $folder\Intermediate\pretable1.5.dta, replace
	tab time
restore

//households who don't report a retirement transition between waves 10 and 11
preserve 
	keep if wave == 10 | wave == 11
	drop if retired == .
	keep if (retired == L.retired) | (retired == F.retired)
	gen time = "pre-retirement"
	replace time = "post-retirement" if wave == 11
	
	tostring id, gen(newid) 
	replace newid = "1011_" + newid 
	append using $folder\Intermediate\pretable1.5.dta
	save $folder\Intermediate\pretable1.5.dta, replace
	tab time
restore

//households who don't report a retirement transition between waves 11 and 12
preserve 
	keep if wave == 11 | wave == 12
	drop if retired == .
	keep if (retired == L.retired) | (retired == F.retired)
	gen time = "pre-retirement"
	replace time = "post-retirement" if wave == 12
	
	tostring id, gen(newid) 
	replace newid = "1112_" + newid 
	append using $folder\Intermediate\pretable1.5.dta
	save $folder\Intermediate\pretable1.5.dta, replace
	tab time
restore

use $folder\Intermediate\pretable1.5.dta, clear
encode newid, gen(newid2)
gen time2 = 1 if time == "pre-retirement"
replace time2 = 2 if time == "post-retirement"
xtset newid2 time2

//drop if missing either the before or after observation
tab r_age if time == "pre-retirement"
by newid2, sort: egen n = count(nondurables) if time != ""
drop if n < 2
tab time

//Median Percent Change
gen diftotal = (total - L.total) / L.total
gen difnondurables = (nondurables - L.nondurables) / L.nondurables
gen diffood = (food - L.food) / L.food

//preserve
// 	collapse (mean) total nondurables durables, by(wave)
// 	list 
//restore

preserve
	keep newid2 wave r_age h_cmstat
	collapse (count) c = newid2, by(wave r_age h_cmstat)
	save $folder\Intermediate\weightscomparison.dta, replace
restore

count if time == "pre-retirement"
local count = r(N)

collapse (mean) total nondurables food (median) total_med = total nondurables_med = nondurables food_med = food diftotal_med = diftotal difnondurables_med = difnondurables diffood_med = diffood (p10) diftotal10 = diftotal difnondurables10 = difnondurables diffood10 = diffood (p25) diftotal25 = diftotal difnondurables25 = difnondurables diffood25 = diffood (p75) diftotal75 = diftotal difnondurables75 = difnondurables diffood75 = diffood (p90) diftotal90 = diffood difnondurables90 = difnondurables diffood90 = diffood (count) n = nondurables, by(time)
	
//make more observations to manually produce table 1
set obs 16

gen Spending = ""
gen Total = .
gen Nondurables = .
gen Food = .
order Spending Total Nondurables Food
	
replace Spending = "Means:" in 1
replace Spending = "Pre-wave" in 2
	replace Total = total[2] in 2
	replace Nondurables = nondurables[2] in 2
	replace Food = food[2] in 2
replace Spending = "Post-wave" in 3
	replace Total = total[1] in 3
	replace Nondurables = nondurables[1] in 3
	replace Food = food[1] in 3
replace Spending = "Percent Change in Means" in 4
	replace Total = (total[1] - total[2]) / total[2] * 100 in 4
	replace Nondurables = (nondurables[1] - nondurables[2]) / nondurables[2] * 100 in 4
	replace Food = (food[1] - food[2]) / food[2] * 100 in 4
replace Spending = "95% confidence interval" in 5
replace Spending = "Medians:" in 6
replace Spending = "Pre-wave" in 7
	replace Total = total_med[2] in 7
	replace Nondurables = nondurables_med[2] in 7
	replace Food = food_med[2] in 7
replace Spending = "Post-wave" in 8
	replace Total = total_med[1] in 8
	replace Nondurables = nondurables_med[1] in 8
	replace Food = food_med[1] in 8
replace Spending = "Percent Change in Medians" in 9
	replace Total = (total_med[1] - total_med[2]) / total_med[2] * 100 in 9
	replace Nondurables = (nondurables_med[1] - nondurables_med[2]) / nondurables_med[2] * 100 in 9
	replace Food = (food_med[1] - food_med[2]) / food_med[2] * 100 in 9
replace Spending = "95% confidence interval" in 10
replace Spending = "Median Percent Change (p10)*" in 11
	replace Total = diftotal10[1] * 100 in 11
	replace Nondurables = difnondurables10[1] * 100 in 11
	replace Food = diffood10[1] * 100 in 11
replace Spending = "Median Percent Change (p25)*" in 12
	replace Total = diftotal25[1] * 100 in 12
	replace Nondurables = difnondurables25[1] * 100 in 12
	replace Food = diffood25[1] * 100 in 12
replace Spending = "Median Percent Change (p50)" in 13
	replace Total = diftotal_med[1] * 100 in 13
	replace Nondurables = difnondurables_med[1] * 100 in 13
	replace Food = diffood_med[1] * 100 in 13
replace Spending = "Median Percent Change (p75)*" in 14
	replace Total = diftotal75[1] * 100 in 14
	replace Nondurables = difnondurables75[1] * 100 in 14
	replace Food = diffood75[1] * 100 in 14
replace Spending = "Median Percent Change (p90)*" in 15
	replace Total = diftotal90[1] * 100 in 15
	replace Nondurables = difnondurables90[1] * 100 in 15
	replace Food = diffood90[1] * 100 in 15
replace Spending = "95% confidence interval (p50)" in 16
keep Spending Total Nondurables Food

replace Total = round(Total) if Spending == "Pre-wave" | Spending == "Post-wave"
replace Nondurables = round(Nondurables) if Spending == "Pre-wave" | Spending == "Post-wave"
replace Food = round(Food) if Spending == "Pre-wave" | Spending == "Post-wave"
replace Total = round(Total, .1) if Spending != "Pre-wave" | Spending != "Post-wave"
replace Nondurables = round(Nondurables, .1) if Spending != "Pre-wave" | Spending != "Post-wave"
replace Food = round(Food, .1) if Spending != "Pre-wave" | Spending != "Post-wave"

tostring Total Nondurables Food, replace force format(%9.1f)
replace Total = substr(Total, 1, 2) + "," + substr(Total, 3, 3) if Spending == "Pre-wave" | Spending == "Post-wave"
replace Nondurables = substr(Nondurables, 1, 2) + "," + substr(Nondurables, 3, 3) if Spending == "Pre-wave" | Spending == "Post-wave"
replace Food = substr(Food, 1, 1) + "," + substr(Food, 2, 3) if Spending == "Pre-wave" | Spending == "Post-wave"

replace Total = "" if Spending == "Means:" | Spending == "Medians:"
replace Nondurables = "" if Spending == "Means:" | Spending == "Medians:"
replace Food = "" if Spending == "Means:" | Spending == "Medians:"
list
	
texsave Spending Total Nondurables Food using $folder\Final\table1.5raw.tex, frag title("Average and median real spending without retirement transition") footnote("*These values are not medians but percentiles, as indicated in the parentheses. \linebreak --- \linebreak This table references Table 1 of Hurd and Rohwedder's paper: Heterogeneity in spending change at retirement. Hurd and Rohwedder bootstrap their confidence intervals. \linebreak --- \linebreak Mean percent change is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak Comparison sample, N = `count'. This sample consists of households whose respondents reported no retirement transition between waves (retired to retired, or not retired to not retired). The comparison sample is weighted to match the composition of the retirement sample with respect to age and marital status and wave.") hlines(1 5 6) replace
save $folder\Intermediate\table1.5data.dta, replace
