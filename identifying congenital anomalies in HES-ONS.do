********************************************************************************
*
*	Title: Phenotyping congenital anomalies in administrative hospital records
*	Authors: Ania Zylbersztejn & Maximiliane Verfuerden, Ruth Gilbert, Pia Hardelid, Linda Wijlaars
*   DOI: TBA
*	Created: 29.10.2019
*
********************************************************************************

/*******************************************************************************

PROJECT DESCRIPTION:
We derived indicators of congenital anomalies (CA) according to 3 code lists: 
	1) EUROCAT list for CA surveillance in Europe
	2) Hardelid list developed to identify children with chronic conditions 
	  (including CAs) admitted to hospitals in England; 
	3) Feudtner list developed to indicate children with complex chronic conditions 
	  (including CAs) admitted to hospitals in the United States
We compared prevalence of CAs, risks of postnatal hospitalisation and mortality 
in children aged <2 years old identified using each of the code lists. 
See our paper for details.

DO-FILE DESCRIPTION:
This do-file goes through all recorded diagnoses and causes of death to indicate children with
congenital anomaly according to each code list and saves the date of first recorded diagnosis. 
We used Hospital Episode Statistics (HES) linked to Office for National Statistics (ONS) 
Mortality data.

REQUIRED VARIABLES
- each childs HESID (encrypted_hesid)
- all variables indicating diagnoses (in the code: vars starting with "diag")
- all variables denoting causes of death (in the code: underlying_cause & all starting 
  with cod - these include neonatal and non-neonatal causes of death) 
- information about child's age: 
	- age at start of admission (startage)
	- estimated birthday (bday)
	- age at death (ageatdeath)
- information about date of CA diagnosis:
	- date of episode start (epistart)
	- date of death (dod)

********************************************************************************/


******* keep only relevant records and variables to speed up the code

* we were interested in CAs under the age of 2:
keep if startage>7000 | startage==1

* keep only relevant variables: 
keep encrypted_hesid underlying_cause diag* cod* bday startage ageatdeath epistart dod


* combine all diagnoses and causes of death into a string:
gen diag_concat=diag_01 + "."+diag_02 + "." + diag_03 + "."+ diag_04 + "."+ diag_05 + "."+ diag_06 + "."+ diag_07 + "."+ diag_08 + "."+ diag_09 + "."+ diag_10 + "."+ diag_11 + "."+ diag_12 + "."+ diag_13 + "."+ diag_14 + "."+ diag_15 + "."+ diag_16 + "."+ diag_17 + "."+ diag_18 + "."+  diag_19 + "."+ diag_20

gen cod_neo_concat=cod_neo_1 + "." + cod_neo_2 + "." + cod_neo_3 + "." + cod_neo_4 + "." + cod_neo_5 + "." + cod_neo_6 + "." + cod_neo_7 + "." + cod_neo_8 + "." + cod_neo_9 + "." + cod_neo_10 + "." + cod_neo_11 + "." + cod_neo_12 + "." + cod_neo_13 + "." + cod_neo_14 + "." + cod_neo_15 + "." + underlying_cause

gen cod_non_neo_concat=cod_neo_1 + "." + cod_non_neo_2 + "." + cod_non_neo_3 + "." + cod_non_neo_4 + "." + cod_non_neo_5 + "." + cod_non_neo_6 + "." + cod_non_neo_7 + "." + cod_non_neo_8 + "." + cod_non_neo_9 + "." + cod_non_neo_10 + "." + cod_non_neo_11 + "." + cod_non_neo_12 + "." + cod_non_neo_13 + "." + cod_non_neo_14 + "." + cod_non_neo_15 + "." + underlying_cause




******* indicate a CA diagnosis according to each code list and date of the diagnosis

*** local macros for each code list:

* EUROCAT codes
local ca1 "D181 D215 D821 P350 P351 P371 Q00 Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q100 Q104 Q106 Q107 Q11 Q12 Q130 Q131 Q132 Q133 Q134 Q138 Q139 Q14 Q15 Q16 Q178 Q183 Q188 Q20 Q21 Q22 Q23 Q24 Q25 Q260 Q262 Q263 Q264 Q265 Q266 Q268 Q269 Q271 Q272 Q273 Q274 Q278 Q279 Q28 Q30 Q310 Q311 Q312 Q313 Q315 Q318 Q319 Q321 Q323 Q324 Q330 Q332 Q333 Q334 Q335 Q336 Q338 Q339 Q34 Q350 Q351 Q353 Q355 Q359 Q36 Q37 Q380 Q383 Q384 Q385 Q386 Q387 Q388 Q39 Q402 Q403 Q408 Q409 Q41 Q42 Q431 Q432 Q433 Q434 Q435 Q436 Q437 Q438 Q439 Q440 Q441 Q442 Q443 Q445 Q446 Q447 Q45 Q500 Q503 Q504 Q506 Q51 Q520 Q521 Q522 Q524 Q526 Q528 Q529 Q540 Q541 Q542 Q543 Q548 Q549 Q55 Q56 Q60 Q611 Q612 Q613 Q614 Q615 Q618 Q619 Q620 Q621 Q622 Q623 Q624 Q625 Q626 Q628 Q630 Q631 Q632 Q638 Q639 Q64 Q650 Q651 Q652 Q660 Q676 Q677 Q681 Q682 Q688 Q69 Q70 Q71 Q72 Q73 Q74 Q750 Q751 Q754 Q755 Q758 Q759 Q761 Q762 Q763 Q764 Q766 Q767 Q768 Q769 Q77 Q78 Q79 Q80 Q81 Q820 Q821 Q822 Q823 Q824 Q828 Q829 Q830 Q831 Q832 Q838 Q839 Q840 Q841 Q842 Q843 Q844 Q848 Q849 Q85 Q86 Q87 Q890 Q891 Q892 Q893 Q894 Q897 Q898 Q90 Q91 Q92 Q93 Q96 Q97 Q98 Q99"
 
*Hardelid codes
local ca2 "Q00 Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q104 Q107 Q11 Q12 Q130 Q131 Q132 Q133 Q134 Q138 Q139 Q14 Q15 Q16 Q188 Q20 Q21 Q22 Q23 Q24 Q25 Q26 Q27 Q28 Q30 Q31 Q32 Q33 Q34 Q35 Q36 Q37 Q380 Q383 Q384 Q386 Q387 Q388 Q39 Q402 Q403 Q408 Q409 Q41 Q42 Q431 Q433 Q434 Q435 Q436 Q437 Q439 Q44 Q45 Q500 Q51 Q520 Q521 Q522 Q524 Q540 Q541 Q542 Q543 Q548 Q549 Q550 Q555 Q56 Q601 Q602 Q604 Q605 Q606 Q61 Q620 Q621 Q622 Q623 Q624 Q625 Q626 Q628 Q630 Q631 Q632 Q638 Q639 Q64 Q650 Q651 Q652 Q658 Q659 Q675 Q682 Q683 Q684 Q685 Q71 Q72 Q73 Q74 Q750 Q751 Q753 Q754 Q755 Q756 Q757 Q758 Q759 Q761 Q762 Q763 Q764 Q77 Q78 Q790 Q792 Q793 Q794 Q795 Q796 Q798 Q80 Q81 Q820 Q821 Q822 Q823 Q824 Q829 Q85 Q860 Q861 Q862 Q868 Q87 Q891 Q892 Q893 Q894 Q897 Q898 Q899 Q90 Q91 Q92 Q93 Q952 Q953 Q97 Q980 Q99"

*Feudtner codes
local ca3 "Q00 Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q20 Q212 Q213 Q214 Q218 Q219 Q22 Q23 Q24 Q251 Q252 Q253 Q254 Q255 Q256 Q257 Q258 Q259 Q26 Q282 Q283 Q289 Q30 Q31 Q32 Q33 Q34 Q390 Q391 Q392 Q393 Q394 Q41 Q42 Q43 Q44 Q45 Q60 Q61 Q62 Q63 Q64 Q722 Q750 Q752 Q759 Q760 Q761 Q762 Q764 Q765 Q766 Q767 Q77 Q780 Q781 Q782 Q783 Q784 Q788 Q789 Q790 Q791 Q792 Q793 Q794 Q795 Q799 Q81 Q851 Q871 Q872 Q873 Q874 Q878 Q879 Q897 Q899 Q909 Q913 Q914 Q917 Q928 Q93 Q950 Q969 Q97 Q98 Q992 Q998 Q999"


*** loop for identifying CAs:

/* for each macro, the loop saves:
- an indicator of CA derived from hospital record (ca_group_hes1, ca_group_hes2, ca_group_hes3)
- an indicator of CA derived from mortality record (ca_group_ons1, ca_group_ons2, ca_group_ons3)
- date of diagnosis each time one of the codes shows in hospital records (ca_group_hes1, ca_group_hes2, ca_group_hes3)
- date of death if diagnosis appears as a cause of death (ca_group_ons1, ca_group_ons2, ca_group_ons3)
*/

forvalues j=1(1)3 {
    capture drop ca_group_hes`j'
    capture drop ca_group_ons`j'
    capture drop diag_date_hes`j'
    capture drop diag_date_ons`j'

    gen ca_group_hes`j'=0
    gen ca_group_ons`j'=0
    gen diag_date_hes`j'=.
	gen diag_date_ons`j'=.
    qui foreach k of local ca`j' {
           replace ca_group_hes`j'=1 if strpos(diag_concat,"`k'")>0 
		   replace ca_group_ons`j'=1 if strpos(cod_neo_concat,"`k'")>0 | strpos(cod_non_neo_concat,"`k'")>0
           replace diag_date_hes`j'=epistart if strpos(diag_concat,"`k'")>0
           replace diag_date_ons`j'=dod if (strpos(cod_neo_concat,"`k'")>0 | strpos(cod_non_neo_concat,"`k'")>0) 
         }                       
 }

* add labels
label var ca_group_hes1 "EUROCAT"
label var ca_group_hes2 "Hardelid"
label var ca_group_hes3 "Feudtner"
 
* format all dates
format diag_dat* %d

* generate age at diagnosis
gen ageatdiag1=diag_date_hes1-bday
gen ageatdiag2=diag_date_hes2-bday
gen ageatdiag3=diag_date_hes3-bday

replace ageatdiag1=. if ca_group_hes1==0
replace ageatdiag2=. if ca_group_hes2==0
replace ageatdiag3=. if ca_group_hes3==0

capture drop ca1 ca2 ca3 ca_group1 ca_group2 ca_group3

* we were interested in CAs diagnosed under 2 so we generated a new CA indicator 
* which only flags diagnoses before that age. The criteria based on age at diagnosis 
* can be easily changed by changing thresholds for ageatdiag1 and ageatdeath
gen ca1=0
replace ca1=1 if ca_group_hes1==1 & ageatdiag1<730
replace ca1=1 if ca_group_ons1==1 & ageatdeath<730

gen ca2=0
replace ca2=1 if ca_group_hes2==1 & ageatdiag2<730
replace ca2=1 if ca_group_ons2==1 & ageatdeath<730

gen ca3=0
replace ca3=1 if ca_group_hes3==1 & ageatdiag3<730
replace ca3=1 if ca_group_ons3==1 & ageatdeath<730
 
* copy the indicator across all records of a child 
bysort encrypted_hesid: egen ca_group1=max(ca1)
bysort encrypted_hesid: egen ca_group2=max(ca2)
bysort encrypted_hesid: egen ca_group3=max(ca3)
 
* keep only records with a CA according to at least one code list
keep if ca_group1==1 | ca_group2==1 | ca_group3==1 

* you can further use ageatdiag* and ageatdeath to derive age at first diagnosis etc.
