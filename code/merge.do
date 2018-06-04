/*
This merges HRS and CAMS data files by household ID and personal identifier
value. Note that the HRS data files are collected in even years and the 
CAMS data files are collected in odd years. CAMS year (n+1) will be merged
with HRS year (n). This year mismatch leads to an incomplete merge from 
years 2005 on (referring to CAMS) that misses around 2.5% of the CAMS data.

The years are staggered as such with CAMS ahead because CAMS wave 3 in 2005
was fielded to an additional 850 households representing the new cohort of 
51–56 year-olds who were inducted into HRS in 2004. 

Written by Lan Luo, Yale University
Herb Scarf RA for Cormac O'Dea @Yale Economics Department
lan.luo@yale.edu

First version: 5/28/18
*/
clear

//Set up directories:
***** Lan ***** 
global tpPath "C:\Users\ericluo04\Dropbox\MoranOConnellODea\data\IndividualWaves"
***** Cormac ***** 
//global tpPath 

//CAMS 2001
use $tpPath\h00f1c_STATA\h00f1c
rename hhid HHID
rename pn PN
merge 1:1 HHID PN using $tpPath\cams2001\CAMS01_R
//drop if observations from HRS and not from CAMS, label todrop if not matched from CAMS to HRS
drop if _merge == 1								
gen todrop = 0
replace todrop = 1 if _merge == 2
drop _merge
save $tpPath\CAMS_HRS_Merged\CAMS01HRS00, replace
clear

//CAMS 2003
use $tpPath\h02f2c_STATA\h02f2c
rename hhid HHID
rename pn PN
merge 1:1 HHID PN using $tpPath\cams2003\CAMS03_R
drop if _merge == 1
gen todrop = 0
replace todrop = 1 if _merge == 2
drop _merge
save $tpPath\CAMS_HRS_Merged\CAMS03HRS02, replace
clear

//CAMS 2005
use $tpPath\h04f1b_STATA\h04f1b
rename hhid HHID
rename pn PN
merge 1:1 HHID PN using $tpPath\cams2005\CAMS05_R
drop if _merge == 1
gen todrop = 0
replace todrop = 1 if _merge == 2
drop _merge
save $tpPath\CAMS_HRS_Merged\CAMS05HRS04, replace
clear

//CAMS 2007
use $tpPath\h06f3a_STATA\h06f3a 
rename hhid HHID
rename pn PN
merge 1:1 HHID PN using $tpPath\cams2007\CAMS07_R
drop if _merge == 1
gen todrop = 0
replace todrop = 1 if _merge == 2
drop _merge
save $tpPath\CAMS_HRS_Merged\CAMS07HRS06, replace
clear

//CAMS 2009
use $tpPath\h08f2a_STATA\h08f3a 
rename hhid HHID
rename pn PN
merge 1:1 HHID PN using $tpPath\cams2009\CAMS09_R
drop if _merge == 1
gen todrop = 0
replace todrop = 1 if _merge == 2
drop _merge
save $tpPath\CAMS_HRS_Merged\CAMS09HRS08, replace
clear

//CAMS 2011
use $tpPath\hd10f5d_stata\hd10f5d
rename hhid HHID
rename pn PN
merge 1:1 HHID PN using $tpPath\cams2011\CAMS11_R
drop if _merge == 1
gen todrop = 0
replace todrop = 1 if _merge == 2
drop _merge
save $tpPath\CAMS_HRS_Merged\CAMS11HRS10, replace
clear

//CAMS 2013
use $tpPath\h12f1a_stata\h12f1a
rename hhid HHID
rename pn PN
merge 1:1 HHID PN using $tpPath\cams2013\CAMS13_R
drop if _merge == 1
gen todrop = 0
replace todrop = 1 if _merge == 2
drop _merge
save $tpPath\CAMS_HRS_Merged\CAMS13HRS12, replace
clear

//CAMS 2015
use $tpPath\h14e1a_stata\h14e1a
rename hhid HHID
rename pn PN
merge 1:1 HHID PN using $tpPath\cams2015\CAMS15_R
drop if _merge == 1
gen todrop = 0
replace todrop = 1 if _merge == 2
drop _merge
save $tpPath\CAMS_HRS_Merged\CAMS15HRS14, replace
clear
