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

//merge with individual wave CAMS, consistent naming, replace missing values (e.g. 999999 to .), annualize spending measures
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
			//auto price
			rename B1A_4_`year_string' auto1
			replace auto1 = . if auto1 == 99999
			rename B1B_4_`year_string' auto2
			replace auto2 = . if auto2 == 999999
			rename B1C_4_`year_string' auto3
			replace auto3 = . if auto3 == 99999
			//refrigerator price
			rename B2A_`year_string' refrig
			replace refrig = . if refrig == 9999
			//washer/dryer price
			rename B3A_`year_string' washdry
			replace washdry = . if washdry == 9999
			//dishwasher price
			rename B4A_`year_string' dishwash
			replace dishwash = . if dishwash == 9999
			//television price
			rename B5A_`year_string' tv
			replace tv = . if tv == 99999
			//computer price
			rename B6A_`year_string' computer
			replace computer = . if computer == 9999
			//electricity
			rename B11_`year_string' electricity
			rename B11A_`year_string' electricityPer
			replace electricity = electricity * 12 if electricityPer == 1
			replace electricity = electricity if electricityPer == 2
			replace electricity = 0 if electricityPer == 3
			//water
			rename B12_`year_string' water
			rename B12A_`year_string' waterPer
			replace water = water * 12 if waterPer == 1
			replace water = water if waterPer == 2
			replace water = 0 if waterPer == 3
			//heat
			rename B13_`year_string' heat
			rename B13A_`year_string' heatPer
			replace heat = heat * 12 if heatPer == 1
			replace heat = heat if heatPer == 2
			replace heat = 0 if heatPer == 3
			//phone/cable/internet
			rename B14_`year_string' phonecableinternet
			rename B14A_`year_string' phonecableinternetPer
			replace phonecableinternet = phonecableinternet * 12 if phonecableinternetPer == 1
			replace phonecableinternet = phonecableinternet if phonecableinternetPer == 2
			replace phonecableinternet = 0 if phonecableinternetPer == 3	
			//health insurance
			rename B17_`year_string' healthinsur
			rename B17A_`year_string' healthinsurPer
			replace healthinsur = healthinsur * 12 if healthinsurPer == 1
			replace healthinsur = healthinsur if healthinsurPer == 2
			replace healthinsur = 0 if healthinsurPer == 3
			//house/yard supplies
			rename B18_`year_string' houseyardsupplies
			rename B18A_`year_string' houseyardsuppliesPer
			replace houseyardsupplies = houseyardsupplies * 365/7 if houseyardsuppliesPer == 1
			replace houseyardsupplies = houseyardsupplies * 12 if houseyardsuppliesPer == 2
			replace houseyardsupplies = houseyardsupplies if houseyardsuppliesPer == 3
			replace houseyardsupplies = 0 if houseyardsuppliesPer == 4
			//food/drink grocery
			rename B20_`year_string' fooddrink
			rename B20A_`year_string' fooddrinkPer
			replace fooddrink = fooddrink * 365/7 if fooddrinkPer == 1
			replace fooddrink = fooddrink * 12 if fooddrinkPer == 2
			replace fooddrink = fooddrink if fooddrinkPer == 3
			replace fooddrink = 0 if fooddrinkPer == 4
			//dining out
			rename B21_`year_string' diningout
			rename B21A_`year_string' diningoutPer
			replace diningout = diningout * 365/7 if diningoutPer == 1
			replace diningout = diningout * 12 if diningoutPer == 2
			replace diningout = diningout if diningoutPer == 3
			replace diningout = 0 if diningoutPer == 4
			//clothing
			rename B22_`year_string' clothing
			rename B22A_`year_string' clothingPer
			replace clothing = clothing * 365/7 if clothingPer == 1
			replace clothing = clothing * 12 if clothingPer == 2
			replace clothing = clothing if clothingPer == 3
			replace clothing = 0 if clothingPer == 4
			//drugs
			rename B25_`year_string' drugs
			rename B25A_`year_string' drugsPer
			replace drugs = drugs * 365/7 if drugsPer == 1
			replace drugs = drugs * 12 if drugsPer == 2
			replace drugs = drugs if drugsPer == 3
			replace drugs = 0 if drugsPer == 4
			//health services
			rename B26_`year_string' healthservices
			rename B26A_`year_string' healthservicesPer
			replace healthservices = healthservices * 365/7 if healthservicesPer == 1
			replace healthservices = healthservices * 12 if healthservicesPer == 2
			replace healthservices = healthservices if healthservicesPer == 3
			replace healthservices = 0 if healthservicesPer == 4
			//medical supplies
			rename B27_`year_string' medicalsupplies
			rename B27A_`year_string' medicalsuppliesPer
			replace medicalsupplies = medicalsupplies * 365/7 if medicalsuppliesPer == 1
			replace medicalsupplies = medicalsupplies * 12 if medicalsuppliesPer == 2
			replace medicalsupplies = medicalsupplies if medicalsuppliesPer == 3
			replace medicalsupplies = 0 if medicalsuppliesPer == 4
			//vacations
			rename B28_`year_string' vacations
			rename B28A_`year_string' vacationsPer
			replace vacations = vacations * 365/7 if vacationsPer == 1
			replace vacations = vacations * 12 if vacationsPer == 2
			replace vacations = vacations if vacationsPer == 3
			replace vacations = 0 if vacationsPer == 4
			//tickets
			rename B29_`year_string' tickets
			rename B29A_`year_string' ticketsPer
			replace tickets = tickets * 365/7 if ticketsPer == 1
			replace tickets = tickets * 12 if ticketsPer == 2
			replace tickets = tickets if ticketsPer == 3
			replace tickets = 0 if ticketsPer == 4
			//hobbies/sports equipment
			rename B30_`year_string' hobbiessports
			rename B30A_`year_string' hobbiessportsPer
			replace hobbiessports = hobbiessports * 365/7 if hobbiessportsPer == 1
			replace hobbiessports = hobbiessports * 12 if hobbiessportsPer == 2
			replace hobbiessports = hobbiessports if hobbiessportsPer == 3
			replace hobbiessports = 0 if hobbiessportsPer == 4
			//contributions
			rename B31_`year_string' contributions
			rename B31A_`year_string' contributionsPer
			replace contributions = contributions * 365/7 if contributionsPer == 1
			replace contributions = contributions * 12 if contributionsPer == 2
			replace contributions = contributions if contributionsPer == 3
			replace contributions = 0 if contributionsPer == 4
			//gifts
			rename B32_`year_string' gifts
			rename B32A_`year_string' giftsPer
			replace gifts = gifts * 365/7 if giftsPer == 1
			replace gifts = gifts * 12 if giftsPer == 2
			replace gifts = gifts if giftsPer == 3
			replace gifts = 0 if giftsPer == 4
			//car payments
			rename B15_`year_string' carpayments
			rename B15A_`year_string' carpaymentsPer
			replace carpayments = carpayments * 12 if carpaymentsPer == 1
			replace carpayments = carpayments if carpaymentsPer == 2
			replace carpayments = 0 if carpaymentsPer == 3
			//auto insurance
			rename B16_`year_string' autoinsur
			rename B16A_`year_string' autoinsurPer
			replace autoinsur = autoinsur * 12 if autoinsurPer == 1
			replace autoinsur = autoinsur if autoinsurPer == 2
			replace autoinsur = 0 if autoinsurPer == 3
			//gasoline
			rename B23_`year_string' gas
			rename B23A_`year_string' gasPer
			replace gas = gas * 365/7 if gasPer == 1
			replace gas = gas * 12 if gasPer == 2
			replace gas = gas if gasPer == 3
			replace gas = 0 if gasPer == 4
			//vehicle services
			rename B24_`year_string' vehicleservices
			rename B24A_`year_string' vehicleservicesPer
			replace vehicleservices = vehicleservices * 365/7 if vehicleservicesPer == 1
			replace vehicleservices = vehicleservices * 12 if vehicleservicesPer == 2
			replace vehicleservices = vehicleservices if vehicleservicesPer == 3
			replace vehicleservices = 0 if vehicleservicesPer == 4
			//mortgage
			rename B7_`year_string' mortgage
			rename B7A_`year_string' mortgagePer
			replace mortgage = mortgage * 12 if mortgagePer == 1
			replace mortgage = mortgage if mortgagePer == 2
			replace mortgage = 0 if mortgagePer == 3
			//home/rent insurance
			rename B8_`year_string' homerentinsur
			rename B8A_`year_string' homerentinsurPer
			replace homerentinsur = homerentinsur * 12 if homerentinsurPer == 1
			replace homerentinsur = homerentinsur if homerentinsurPer == 2
			replace homerentinsur = 0 if homerentinsurPer == 3
			//property tax
			rename B9_`year_string' propertytax
			rename B9A_`year_string' propertytaxPer
			replace propertytax = propertytax * 12 if propertytaxPer == 1
			replace propertytax = propertytax if propertytaxPer == 2
			replace propertytax = 0 if propertytaxPer == 3
			//rent
			rename B10_`year_string' rent
			rename B10A_`year_string' rentPer
			replace rent = rent * 12 if rentPer == 1
			replace rent = rent if rentPer == 2
			replace rent = 0 if rentPer == 3
			//home repairs supplies and services
			rename B19_`year_string' hrepsuppliesservices
			rename B19A_`year_string' hrepsuppliesservicesPer
			replace hrepsuppliesservices = hrepsuppliesservices * 365/7 if hrepsuppliesservicesPer == 1
			replace hrepsuppliesservices = hrepsuppliesservices * 12 if hrepsuppliesservicesPer == 2
			replace hrepsuppliesservices = hrepsuppliesservices if hrepsuppliesservicesPer == 3
			replace hrepsuppliesservices = 0 if hrepsuppliesservicesPer == 4
			
			//measure of retired
			rename B38_`year_string' retired
			rename B38A_`year_string' recollect
			rename B38B_`year_string' recollectPerc
			rename B38D_`year_string' expect
			rename B38E_`year_string' expectPerc
			
			keep id wave auto1 auto2 auto3 refrig washdry dishwash tv computer electricity water heat phonecableinternet healthinsur houseyardsupplies fooddrink diningout clothing drugs healthservices medicalsupplies vacations tickets hobbiessports contributions gifts carpayments autoinsur gas vehicleservices mortgage homerentinsur propertytax rent hrepsuppliesservices retired recollect recollectPerc expect expectPerc
		} 
		if `year' == 3{
			//auto price
			rename B1A4_`year_string' auto1
			replace auto1 = . if auto1 == 999999
			rename B1B4_`year_string' auto2
			replace auto2 = . if auto2 == 999999
			rename B1C4_`year_string' auto3
			replace auto3 = . if auto3 == 999999
			//refrigerator price
			rename B2A_`year_string' refrig
			replace refrig = . if refrig == 999999
			//washer/dryer price
			rename B3A_`year_string' washdry
			replace washdry = . if washdry == 999999
			//dishwasher price
			rename B4A_`year_string' dishwash
			replace dishwash = . if dishwash == 999999
			//television price
			rename B5A_`year_string' tv
			replace tv = . if tv == 999999
			//computer price
			rename B6A_`year_string' computer
			replace computer = . if computer == 999999
			//electricity
			rename B15_`year_string' electricity
			rename B15A_`year_string' electricityPer
			replace electricity = electricity * 12 if electricityPer == 1
			replace electricity = electricity if electricityPer == 2
			replace electricity = 0 if electricityPer == 3
			//water
			rename B16_`year_string' water
			rename B16A_`year_string' waterPer
			replace water = water * 12 if waterPer == 1
			replace water = water if waterPer == 2
			replace water = 0 if waterPer == 3
			//heat
			rename B17_`year_string' heat
			rename B17A_`year_string' heatPer
			replace heat = heat * 12 if heatPer == 1
			replace heat = heat if heatPer == 2
			replace heat = 0 if heatPer == 3
			//phone/cable/internet
			rename B18_`year_string' phonecableinternet
			rename B18A_`year_string' phonecableinternetPer
			replace phonecableinternet = phonecableinternet * 12 if phonecableinternetPer == 1
			replace phonecableinternet = phonecableinternet if phonecableinternetPer == 2
			replace phonecableinternet = 0 if phonecableinternetPer == 3
			//health insurance
			rename B11_`year_string' healthinsur
			//housekeeping supplies
			rename B20_`year_string' housesupplies
			rename B20A_`year_string' housesuppliesPer
			replace housesupplies = housesupplies * 12 if housesuppliesPer == 1
			replace housesupplies = housesupplies if housesuppliesPer == 2
			replace housesupplies = 0 if housesuppliesPer == 3
			//garden/yard supplies
			rename B22_`year_string' yardsupplies
			rename B22A_`year_string' yardsuppliesPer
			replace yardsupplies = yardsupplies * 12 if yardsuppliesPer == 1
			replace yardsupplies = yardsupplies if yardsuppliesPer == 2
			replace yardsupplies = 0 if yardsuppliesPer == 3
			//housekeeping services
			rename B21_`year_string' houseservices
			rename B21A_`year_string' houseservicesPer
			replace houseservices = houseservices * 12 if houseservicesPer == 1
			replace houseservices = houseservices if houseservicesPer == 2
			replace houseservices = 0 if houseservicesPer == 3
			//gardening/yard services
			rename B23_`year_string' yardservices
			rename B23A_`year_string' yardservicesPer
			replace yardservices = yardservices * 12 if yardservicesPer == 1
			replace yardservices = yardservices if yardservicesPer == 2
			replace yardservices = 0 if yardservicesPer == 3
			//food/drink grocery
			rename B36_`year_string' fooddrink
			rename B36A_`year_string' fooddrinkPer
			replace fooddrink = fooddrink * 365/7 if fooddrinkPer == 1
			replace fooddrink = fooddrink * 12 if fooddrinkPer == 2
			replace fooddrink = fooddrink if fooddrinkPer == 3
			replace fooddrink = 0 if fooddrinkPer == 4
			//dining out
			rename B37_`year_string' diningout
			rename B37A_`year_string' diningoutPer
			replace diningout = diningout * 365/7 if diningoutPer == 1
			replace diningout = diningout * 12 if diningoutPer == 2
			replace diningout = diningout if diningoutPer == 3
			replace diningout = 0 if diningoutPer == 4
			//clothing
			rename B26_`year_string' clothing
			rename B26A_`year_string' clothingPer
			replace clothing = clothing * 12 if clothingPer == 1
			replace clothing = clothing if clothingPer == 2
			replace clothing = 0 if clothingPer == 3
			//drugs
			rename B28_`year_string' drugs
			rename B28A_`year_string' drugsPer
			replace drugs = drugs * 12 if drugsPer == 1
			replace drugs = drugs if drugsPer == 2
			replace drugs = 0 if drugsPer == 3
			//health services
			rename B29_`year_string' healthservices
			rename B29A_`year_string' healthservicesPer
			replace healthservices = healthservices * 12 if healthservicesPer == 1
			replace healthservices = healthservices if healthservicesPer == 2
			replace healthservices = 0 if healthservicesPer == 3
			//medical supplies
			rename B30_`year_string' medicalsupplies
			rename B30A_`year_string' medicalsuppliesPer
			replace medicalsupplies = medicalsupplies * 12 if medicalsuppliesPer == 1
			replace medicalsupplies = medicalsupplies if medicalsuppliesPer == 2
			replace medicalsupplies = 0 if medicalsuppliesPer == 3
			//vacations
			rename B12_`year_string' vacations
			//tickets
			rename B31_`year_string' tickets
			rename B31A_`year_string' ticketsPer
			replace tickets = tickets * 12 if ticketsPer == 1
			replace tickets = tickets if ticketsPer == 2
			replace tickets = 0 if ticketsPer == 3
			//hobbies
			rename B33_`year_string' hobbies
			rename B33A_`year_string' hobbiesPer
			replace hobbies = hobbies * 12 if hobbiesPer == 1
			replace hobbies = hobbies if hobbiesPer == 2
			replace hobbies = 0 if hobbiesPer == 3
			//sports
			rename B32_`year_string' sports
			rename B32A_`year_string' sportsPer
			replace sports = sports * 12 if sportsPer == 1
			replace sports = sports if sportsPer == 2
			replace sports = 0 if sportsPer == 3
			//contributions
			rename B34_`year_string' contributions
			rename B34A_`year_string' contributionsPer
			replace contributions = contributions * 12 if contributionsPer == 1
			replace contributions = contributions if contributionsPer == 2
			replace contributions = 0 if contributionsPer == 3
			//gifts
			rename B35_`year_string' gifts
			rename B35A_`year_string' giftsPer
			replace gifts = gifts * 12 if giftsPer == 1
			replace gifts = gifts if giftsPer == 2
			replace gifts = 0 if giftsPer == 3
			//personal care
			rename B27_`year_string' personalcare
			rename B27A_`year_string' personalcarePer
			replace personalcare = personalcare * 12 if personalcarePer == 1
			replace personalcare = personalcare if personalcarePer == 2
			replace personalcare = 0 if personalcarePer == 3
			//car payments
			rename B19_`year_string' carpayments
			rename B19A_`year_string' carpaymentsPer
			replace carpayments = carpayments * 12 if carpaymentsPer == 1
			replace carpayments = carpayments if carpaymentsPer == 2
			replace carpayments = 0 if carpaymentsPer == 3
			//auto insurance
			rename B9_`year_string' autoinsur
			//gasoline
			rename B38_`year_string' gas
			rename B38A_`year_string' gasPer
			replace gas = gas * 365/7 if gasPer == 1
			replace gas = gas * 12 if gasPer == 2
			replace gas = gas if gasPer == 3
			replace gas = 0 if gasPer == 4
			//vehicle services
			rename B10_`year_string' vehicleservices
			//mortgage
			rename B13_`year_string' mortgage
			rename B13A_`year_string' mortgagePer
			replace mortgage = mortgage * 12 if mortgagePer == 1
			replace mortgage = mortgage if mortgagePer == 2
			replace mortgage = 0 if mortgagePer == 3
			//home/rent insurance
			rename B7_`year_string' homerentinsur
			//property tax
			rename B8_`year_string' propertytax
			//rent
			rename B14_`year_string' rent
			rename B14A_`year_string' rentPer
			replace rent = rent * 12 if rentPer == 1
			replace rent = rent if rentPer == 2
			replace rent = 0 if rentPer == 3
			//home repairs supplies
			rename B24_`year_string' hrepsupplies
			rename B24A_`year_string' hrepsuppliesPer
			replace hrepsupplies = hrepsupplies * 12 if hrepsuppliesPer == 1
			replace hrepsupplies = hrepsupplies if hrepsuppliesPer == 2
			replace hrepsupplies = 0 if hrepsuppliesPer == 3
			//home repairs services
			rename B25_`year_string' hrepservices
			rename B25A_`year_string' hrepservicesPer
			replace hrepservices = hrepservices * 12 if hrepservicesPer == 1
			replace hrepservices = hrepservices if hrepservicesPer == 2
			replace hrepservices = 0 if hrepservicesPer == 3
			
			//measure of retired
			rename B44_`year_string' retired
			rename B44A_`year_string' recollect
			rename B44B_`year_string' recollectPerc
			rename B44D_`year_string' expect
			rename B44E_`year_string' expectPerc
			
			keep id wave auto1 auto2 auto3 refrig washdry dishwash tv computer electricity water heat phonecableinternet healthinsur housesupplies yardsupplies houseservices yardservices fooddrink diningout clothing drugs healthservices medicalsupplies vacations tickets hobbies sports contributions gifts personalcare carpayments autoinsur gas vehicleservices mortgage homerentinsur propertytax rent hrepsupplies hrepservices retired recollect recollectPerc expect expectPerc
		}
		if `year' == 5 | `year' == 7 | `year' == 9 | `year' == 11 | `year' == 13 | `year' == 15{
			//auto price
			rename B1a4_`year_string' auto1
			replace auto1 = . if auto1 == 999999
			rename B1b4_`year_string' auto2
			replace auto2 = . if auto2 == 999999
			rename B1c4_`year_string' auto3	
			replace auto3 = . if auto3 == 99999
			//refrigerator price
			rename B2a_`year_string' refrig
			replace refrig = . if refrig == 99999
			//washer/dryer price
			rename B3a_`year_string' washdry
			replace washdry = . if washdry == 9999
			//dishwasher price
			rename B4a_`year_string' dishwash
			replace dishwash = . if dishwash == 9999
			//television price
			rename B5a_`year_string' tv
			replace tv = . if tv == 9999
			//computer price
			rename B6a_`year_string' computer
			replace computer = . if computer == 9999
			//electricity
			rename B20_`year_string' electricity
			rename B20a_`year_string' electricityPer
			replace electricity = electricity * 12 if electricityPer == 1
			replace electricity = electricity if electricityPer == 2
			replace electricity = 0 if electricityPer == 3
			//water
			rename B21_`year_string' water
			rename B21a_`year_string' waterPer
			replace water = water * 12 if waterPer == 1
			replace water = water if waterPer == 2
			replace water = 0 if waterPer == 3
			//heat
			rename B22_`year_string' heat
			rename B22a_`year_string' heatPer
			replace heat = heat * 12 if heatPer == 1
			replace heat = heat if heatPer == 2
			replace heat = 0 if heatPer == 3
			//phone/cable/internet
			rename B23_`year_string' phonecableinternet
			rename B23a_`year_string' phonecableinternetPer
			replace phonecableinternet = phonecableinternet * 12 if phonecableinternetPer == 1
			replace phonecableinternet = phonecableinternet if phonecableinternetPer == 2
			replace phonecableinternet = 0 if phonecableinternetPer == 3
			//health insurance
			rename B11_`year_string' healthinsur
			//housekeeping supplies
			rename B25_`year_string' housesupplies
			rename B25a_`year_string' housesuppliesPer
			replace housesupplies = housesupplies * 12 if housesuppliesPer == 1
			replace housesupplies = housesupplies if housesuppliesPer == 2
			replace housesupplies = 0 if housesuppliesPer == 3
			//garden/yard supplies
			rename B27_`year_string' yardsupplies
			rename B27a_`year_string' yardsuppliesPer
			replace yardsupplies = yardsupplies * 12 if yardsuppliesPer == 1
			replace yardsupplies = yardsupplies if yardsuppliesPer == 2
			replace yardsupplies = 0 if yardsuppliesPer == 3
			//housekeeping services
			rename B26_`year_string' houseservices
			rename B26a_`year_string' houseservicesPer
			replace houseservices = houseservices * 12 if houseservicesPer == 1
			replace houseservices = houseservices if houseservicesPer == 2
			replace houseservices = 0 if houseservicesPer == 3
			//gardening/yard services
			rename B28_`year_string' yardservices
			rename B28a_`year_string' yardservicesPer
			replace yardservices = yardservices * 12 if yardservicesPer == 1
			replace yardservices = yardservices if yardservicesPer == 2
			replace yardservices = 0 if yardservicesPer == 3
			//food/drink grocery
			rename B37_`year_string' fooddrink
			rename B37a_`year_string' fooddrinkPer
			replace fooddrink = fooddrink * 365/7 if fooddrinkPer == 1
			replace fooddrink = fooddrink * 12 if fooddrinkPer == 2
			replace fooddrink = fooddrink if fooddrinkPer == 3
			replace fooddrink = 0 if fooddrinkPer == 4
			//dining out
			rename B38_`year_string' diningout
			rename B38a_`year_string' diningoutPer
			replace diningout = diningout * 365/7 if diningoutPer == 1
			replace diningout = diningout * 12 if diningoutPer == 2
			replace diningout = diningout if diningoutPer == 3
			replace diningout = 0 if diningoutPer == 4
			//clothing
			rename B29_`year_string' clothing
			rename B29a_`year_string' clothingPer
			replace clothing = clothing * 12 if clothingPer == 1
			replace clothing = clothing if clothingPer == 2
			replace clothing = 0 if clothingPer == 3
			//drugs
			rename B31_`year_string' drugs
			rename B31a_`year_string' drugsPer
			replace drugs = drugs * 12 if drugsPer == 1
			replace drugs = drugs if drugsPer == 2
			replace drugs = 0 if drugsPer == 3
			//health services
			rename B32_`year_string' healthservices
			rename B32a_`year_string' healthservicesPer
			replace healthservices = healthservices * 12 if healthservicesPer == 1
			replace healthservices = healthservices if healthservicesPer == 2
			replace healthservices = 0 if healthservicesPer == 3
			//medical supplies
			rename B33_`year_string' medicalsupplies
			rename B33a_`year_string' medicalsuppliesPer
			replace medicalsupplies = medicalsupplies * 12 if medicalsuppliesPer == 1
			replace medicalsupplies = medicalsupplies if medicalsuppliesPer == 2
			replace medicalsupplies = 0 if medicalsuppliesPer == 3
			//vacations
			rename B12_`year_string' vacations
			//tickets
			rename B34_`year_string' tickets
			rename B34a_`year_string' ticketsPer
			replace tickets = tickets * 12 if ticketsPer == 1
			replace tickets = tickets if ticketsPer == 2
			replace tickets = 0 if ticketsPer == 3
			//hobbies
			rename B36_`year_string' hobbies
			rename B36a_`year_string' hobbiesPer
			replace hobbies = hobbies * 12 if hobbiesPer == 1
			replace hobbies = hobbies if hobbiesPer == 2
			replace hobbies = 0 if hobbiesPer == 3
			//sports
			rename B35_`year_string' sports
			rename B35a_`year_string' sportsPer
			replace sports = sports * 12 if sportsPer == 1
			replace sports = sports if sportsPer == 2
			replace sports = 0 if sportsPer == 3
			//contributions
			rename B16_`year_string' contributions
			//gifts
			rename B17_`year_string' gifts
			//personal care
			rename B30_`year_string' personalcare
			rename B30a_`year_string' personalcarePer
			replace personalcare = personalcare * 12 if personalcarePer == 1
			replace personalcare = personalcare if personalcarePer == 2
			replace personalcare = 0 if personalcarePer == 3
			//household furnishings
			rename B15_`year_string' hhfurnishings
			//car payments
			rename B24_`year_string' carpayments
			rename B24a_`year_string' carpaymentsPer
			replace carpayments = carpayments * 12 if carpaymentsPer == 1
			replace carpayments = carpayments if carpaymentsPer == 2
			replace carpayments = 0 if carpaymentsPer == 3
			//auto insurance
			rename B9_`year_string' autoinsur
			//gasoline
			rename B39_`year_string' gas
			rename B39a_`year_string' gasPer
			replace gas = gas * 365/7 if gasPer == 1
			replace gas = gas * 12 if gasPer == 2
			replace gas = gas if gasPer == 3
			replace gas = 0 if gasPer == 4
			//vehicle services
			rename B10_`year_string' vehicleservices
			//mortgage
			rename B18_`year_string' mortgage
			rename B18a_`year_string' mortgagePer
			replace mortgage = mortgage * 12 if mortgagePer == 1
			replace mortgage = mortgage if mortgagePer == 2
			replace mortgage = 0 if mortgagePer == 3
			//home/rent insurance
			rename B7_`year_string' homerentinsur
			//property tax
			rename B8_`year_string' propertytax
			//rent
			rename B19_`year_string' rent
			rename B19a_`year_string' rentPer
			replace rent = rent * 12 if rentPer == 1
			replace rent = rent if rentPer == 2
			replace rent = 0 if rentPer == 3
			//home repairs supplies
			rename B13_`year_string' hrepsupplies
			//home repairs services
			rename B14_`year_string' hrepservices
			
			//measure of retired
			rename B45_`year_string' retired
			rename B45a_`year_string' recollect
			rename B45b_`year_string' recollectPerc
			rename B45d_`year_string' expect
			rename B45e_`year_string' expectPerc
			
			keep id wave auto1 auto2 auto3 refrig washdry dishwash tv computer electricity water heat phonecableinternet healthinsur housesupplies yardsupplies houseservices yardservices fooddrink diningout clothing drugs healthservices medicalsupplies vacations tickets hobbies sports contributions gifts personalcare hhfurnishings carpayments autoinsur gas vehicleservices mortgage homerentinsur propertytax rent hrepsupplies hrepservices retired recollect recollectPerc expect expectPerc
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

//check spending categories by wave
preserve
	collapse (mean) auto1 auto2 auto3 refrig washdry dishwash tv computer electricity water heat phonecableinternet healthinsur houseyardsupplies housesupplies yardsupplies houseservices yardservices fooddrink diningout clothing drugs healthservices medicalsupplies vacations tickets hobbiessports hobbies sports contributions gifts personalcare hhfurnishings carpayments autoinsur gas vehicleservices mortgage homerentinsur propertytax rent hrepsuppliesservices hrepsupplies hrepservices, by(wave)
	list 
restore

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

//TODO: REAL EXPENDITURE HERE FROM LAST WAVES
//create real variables for spending values
foreach var of varlist auto1 auto2 auto3 refrig washdry dishwash tv computer electricity water heat phonecableinternet healthinsur houseyardsupplies housesupplies yardsupplies houseservices yardservices fooddrink diningout clothing drugs healthservices medicalsupplies vacations tickets hobbiessports hobbies sports contributions gifts personalcare hhfurnishings carpayments autoinsur gas vehicleservices mortgage homerentinsur propertytax rent hrepsuppliesservices hrepsupplies hrepservices *ctots *cdurs *cndur *ctranss *chouss *cautoall *ccarpay *cmort *cmortint *ctotc *cdurc *ctransc *chousc *chmeqf {
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

//generate spending categories
egen autopurchlease = rowtotal(auto1_real auto2_real auto3_real)
egen newmeasures1 = rowtotal(houseservices_real yardservices_real personalcare_real)
egen newmeasures2 = rowtotal(houseservices_real yardservices_real personalcare_real hhfurnishings_real)
//consistent nondurable definition across waves based on first six categories of CAMS
gen nondur = h_ctots_real - h_cdurs_real - autopurchlease
replace nondur = h_ctots_real - h_cdurs_real - autopurchlease - newmeasures1 if wave == 6
replace nondur = h_ctots_real - h_cdurs_real - autopurchlease - newmeasures2 if wave == 7 | wave == 8 | wave == 9 | wave == 10 | wave == 11 | wave == 12
//consistent total expenditure definition across waves
gen total = h_ctots_real
replace total = h_ctots_real - newmeasures1 if wave == 6
replace total = h_ctots_real - newmeasures2 if wave == 7 | wave == 8 | wave == 9 | wave == 10 | wave == 11 | wave == 12

//nondurable/total definition by adding up individual spending categories
egen nondurfull = rowtotal(electricity_real water_real heat_real phonecableinternet_real healthinsur_real houseyardsupplies_real housesupplies_real yardsupplies_real fooddrink_real diningout_real clothing_real drugs_real healthservices_real medicalsupplies_real vacations_real tickets_real hobbiessports_real hobbies_real sports_real contributions_real gifts_real carpayments_real autoinsur_real gas_real vehicleservices_real mortgage_real homerentinsur_real propertytax_real rent_real hrepsuppliesservices_real hrepsupplies_real hrepservices_real)
egen totalfull = rowtotal(auto1_real auto2_real auto3_real refrig_real washdry_real dishwash_real tv_real computer_real electricity_real water_real heat_real phonecableinternet_real healthinsur_real houseyardsupplies_real housesupplies_real yardsupplies_real fooddrink_real diningout_real clothing_real drugs_real healthservices_real medicalsupplies_real vacations_real tickets_real hobbiessports_real hobbies_real sports_real contributions_real gifts_real carpayments_real autoinsur_real gas_real vehicleservices_real mortgage_real homerentinsur_real propertytax_real rent_real hrepsuppliesservices_real hrepsupplies_real hrepservices_real)

* todo later: perhaps do this for F2 F3 etc
gen ret_transition = retired == 1 & L.retired == 5 & (F.retired == 1 | F.retired == . | F.retired == 9 ) 
replace ret_transition = 0 if r_age < 50 | r_age > 70
tab ret_transition if nondur != .

gen time = "immediately_before_ret" if F.ret_transition == 1
replace time = "immediately_after_ret" if ret_transition == 1
 drop if time == ""

//drop if missing either the before or after observation
by id, sort: egen n = count(nondur) if time != ""
drop if n < 2
tab time
save $folder\Final\CAMSHRStable1.dta, replace

//nondurables mean
use $folder\Final\CAMSHRStable1.dta, clear
gen dif = (nondur - L.nondur) / L.nondur

// preserve
// 	collapse (mean) nondur h_ctots h_cdurs, by(wave)
// 	list 
// restore

preserve
	collapse (mean) totalfull nondurfull total nondur dur = h_cdurs_real (count) n = nondur [pw = weight], by(time)
	//collapse (mean) nondur total = h_ctots (median) nondur_med = nondur total_med = h_ctots hhchange = dif (count) n = nondur, by(time)
	list
restore
