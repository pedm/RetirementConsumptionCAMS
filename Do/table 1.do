/*
This code seeks to reproduce table 1 from Hurd and Rohwedder's paper on 
Heterogeneity in spending change at retirement. Table 1 shows the means
and medians of total real spending before and after retirement and the 
median of the change in spending calculated over households where 
retirement occurred between CAMS waves.

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

use $folder\Intermediate\CAMSHRSpanelrawmergereal.dta, clear
drop if wave < 5 // because expenditure data begins in wave 5
drop if wave > 8
//drop if recollect == . & retired == 1
//drop if recollect == . & retired == 1
sort id wave

//generate wave consistent spending categories by generating from individual wave CAMS data
egen total = rowtotal(auto1_real auto2_real auto3_real refrig_real washdry_real dishwash_real tv_real computer_real electricity_real water_real heat_real phonecableinternet_real healthinsur_real houseyardsupplies_real housesupplies_real yardsupplies_real fooddrink_real diningout_real clothing_real drugs_real healthservices_real medicalsupplies_real vacations_real tickets_real hobbiessports_real hobbies_real sports_real contributions_real gifts_real carpayments_real autoinsur_real gas_real vehicleservices_real mortgage_real homerentinsur_real propertytax_real rent_real hrepsuppliesservices_real hrepsupplies_real hrepservices_real)
egen nondurables = rowtotal(electricity_real water_real heat_real phonecableinternet_real healthinsur_real houseyardsupplies_real housesupplies_real yardsupplies_real fooddrink_real diningout_real clothing_real drugs_real healthservices_real medicalsupplies_real vacations_real tickets_real hobbiessports_real hobbies_real sports_real contributions_real gifts_real carpayments_real autoinsur_real gas_real vehicleservices_real mortgage_real homerentinsur_real propertytax_real rent_real hrepsuppliesservices_real hrepsupplies_real hrepservices_real)
egen durables = rowtotal(auto1_real auto2_real auto3_real refrig_real washdry_real dishwash_real tv_real computer_real)
egen food = rowtotal(fooddrink_real diningout_real)

* todo later: perhaps do this for F2 F3 etc
gen ret_transition = retired == 1 & L.retired == 5 & (F.retired == 1 | F.retired == . | F.retired == 9 ) 
replace ret_transition = 0 if r_age < 50 | r_age > 70
tab ret_transition if nondur != .

gen time = "immediately_before_ret" if F.ret_transition == 1
replace time = "immediately_after_ret" if ret_transition == 1
drop if time == ""

//drop if missing either the before or after observation
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
	collapse (mean) total nondurables food (median) total_med = total nondurables_med = nondurables food_med = food diftotal_med = diftotal difnondurables_med = difnondurables diffood_med = diffood (count) n = nondurables, by(time)
	
	//make more observations to manually produce table 1
	set obs 12

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
	replace Spending = "Population Percent change" in 4
		replace Total = (total[2] - total[1]) / total[1] * 100 in 4
		replace Nondurables = (nondurables[2] - nondurables[1]) / nondurables[1] * 100 in 4
		replace Food = (food[2] - food[1]) / food[1] * 100 in 4
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
	replace Spending = "Population Percent change" in 9
		replace Total = (total_med[2] - total_med[1]) / total_med[1] * 100 in 9
		replace Nondurables = (nondurables_med[2] - nondurables_med[1]) / nondurables_med[1] * 100 in 9
		replace Food = (food_med[2] - food_med[1]) / food_med[1] * 100 in 9
	replace Spending = "95% confidence interval" in 10
	replace Spending = "Household-level change" in 11
		replace Total = diftotal_med[1] * 100 in 11
		replace Nondurables = difnondurables_med[1] * 100 in 11
		replace Food = diffood_med[1] * 100 in 11
	replace Spending = "95% confidence interval" in 12

	keep Spending Total Nondurables Food
	replace Total = round(Total, 0.001)
	replace Nondurables = round(Nondurables, 0.001)
	replace Food = round(Food, 0.001)
	list
	
	texsave Spending Total Nondurables Food using $folder\Final\Table1.tex, title("Average and median real spending before and after retirement") footnote("Population percent change is calculated as the differences of the means (or medians), and household-level change is calculated as the median of the differences. \linebreak --- \linebreak The average change at the household level is not reported because observation error on spending can produce large outliers when spending is put in ratio form. \linebreak --- \linebreak Retirement sample, N = 442.") hlines(1 5 6) replace
	save $folder\Final\table1.dta, replace
restore

save $folder\Intermediate\table1data.dta, replace
