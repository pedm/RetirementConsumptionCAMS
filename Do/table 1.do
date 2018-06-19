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

ssc install zipsave, replace
ssc install winsor, replace
ssc install estout, replace
ssc install dataout, replace

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
save $folder\Final\CAMSHRStable1.dta, replace

//nondurables mean
use $folder\Final\CAMSHRStable1.dta, clear
gen dif = (nondurables - L.nondurables) / L.nondurables

//preserve
// 	collapse (mean) total nondurables durables, by(wave)
// 	list 
//restore

preserve
	collapse (mean) total nondurables durables dif (median) total_med = total nondurables_med = nondurables durables_med = durables dif_med = dif (count) n = nondurables, by(time)
	list
restore
