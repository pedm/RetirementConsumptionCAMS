/* Command file to read ASCII data file into SAS /*
/* Note 1: change SAS library and dataset name as necessary */
LIBNAME cams05 'c:\cams2005\sas\';
DATA cams05.cams05_r;
 
/* Note 2: change location of input data file to match your system */
INFILE 'c:\cams2005\data\cams05_r.da' LRECL= 564;
 
INPUT
   HHID $  1- 6
   PN $  7- 9
   JSUBHH $  10- 10
   HSUBHH $  11- 11
   GSUBHH $  12- 12
   JPN_SP $  13- 15
   QNR05 $  16- 21
   QTYPE05    22- 22
   A1_05    23- 28
   A2_05    29- 34
   A3_05    35- 39
   A4_05    40- 45
   A5_05    46- 51
   A6_05    52- 57
   A7_05    58- 63
   A8_05    64- 69
   A9_05    70- 75
   A10_05    76- 81
   A11_05    82- 87
   A12_05    88- 93
   A13_05    94- 98
   A14_05    99- 103
   A15_05    104- 109
   A16_05    110- 115
   A17_05    116- 121
   A18_05    122- 127
   A19_05    128- 133
   A20_05    134- 139
   A21_05    140- 145
   A22_05    146- 151
   A23_05    152- 157
   A24_05    158- 163
   A25_05    164- 169
   A26_05    170- 175
   A27_05    176- 181
   A28_05    182- 187
   A29_05    188- 193
   A30_05    194- 198
   A31_05    199- 204
   A32_05    205- 210
   A33_05    211- 216
   A34_05    217- 219
   A35_05    220- 222
   A36_05    223- 223
   A37_05    224- 224
   A38_05    225- 225
   A39_05    226- 226
   A40_05    227- 227
   A41_05    228- 230
   B1_05    231- 231
   B1a1_05    232- 233
   B1a2_05    234- 234
   B1a3_05    235- 238
   B1a4_05    239- 244
   B1a5_05    245- 245
   B1b1_05    246- 247
   B1b2_05    248- 248
   B1b3_05    249- 252
   B1b4_05    253- 258
   B1b5_05    259- 259
   B1c1_05    260- 261
   B1c2_05    262- 262
   B1c3_05    263- 266
   B1c4_05    267- 271
   B1c5_05    272- 272
   B2_05    273- 273
   B2a_05    274- 278
   B3_05    279- 279
   B3a_05    280- 283
   B4_05    284- 284
   B4a_05    285- 288
   B5_05    289- 289
   B5a_05    290- 293
   B6_05    294- 294
   B6a_05    295- 298
   B7_05    299- 303
   B7d_05    304- 304
   B8_05    305- 309
   B8d_05    310- 310
   B9_05    311- 315
   B10_05    316- 320
   B11_05    321- 325
   B12_05    326- 331
   B13_05    332- 337
   B14_05    338- 342
   B15_05    343- 347
   B16_05    348- 353
   B17_05    354- 359
   B18_05    360- 365
   B18a_05    366- 366
   B18d_05    367- 367
   B19_05    368- 372
   B19a_05    373- 373
   B19d_05    374- 374
   B20_05    375- 379
   B20a_05    380- 380
   B20d_05    381- 381
   B21_05    382- 385
   B21a_05    386- 386
   B21d_05    387- 387
   B22_05    388- 392
   B22a_05    393- 393
   B22d_05    394- 394
   B23_05    395- 399
   B23a_05    400- 400
   B24_05    401- 405
   B24a_05    406- 406
   B25_05    407- 410
   B25a_05    411- 411
   B26_05    412- 416
   B26a_05    417- 417
   B27_05    418- 421
   B27a_05    422- 422
   B28_05    423- 427
   B28a_05    428- 428
   B29_05    429- 433
   B29a_05    434- 434
   B30_05    435- 438
   B30a_05    439- 439
   B31_05    440- 444
   B31a_05    445- 445
   B32_05    446- 450
   B32a_05    451- 451
   B33_05    452- 456
   B33a_05    457- 457
   B34_05    458- 461
   B34a_05    462- 462
   B35_05    463- 467
   B35a_05    468- 468
   B36_05    469- 473
   B36a_05    474- 474
   B37_05    475- 480
   B37a_05    481- 481
   B38_05    482- 486
   B38a_05    487- 487
   B39_05    488- 492
   B39a_05    493- 493
   B40_05    494- 494
   B40a_05    495- 500
   B40b_05    501- 506
   B41_05    507- 507
   B41a_05    508- 510
   B41b_05    511- 513
   B42M1_05    514- 514
   B42M2_05    515- 515
   B42M3_05    516- 516
   B42M4_05    517- 517
   B42M5_05    518- 518
   B42M6_05    519- 519
   B43_05    520- 520
   B43a_05    521- 523
   B44M1_05    524- 524
   B44M2_05    525- 525
   B44M3_05    526- 526
   B44M4_05    527- 527
   B44M5_05    528- 528
   B44M6_05    529- 529
   B45_05    530- 530
   B45a_05    531- 531
   B45b_05    532- 535
   B45d_05    536- 536
   B45e_05    537- 539
   B46a_05    540- 540
   B46b_05    541- 541
   B46c_05    542- 542
   B46d_05    543- 543
   B46e_05    544- 544
   B46f_05    545- 545
   B47_05    546- 546
   B48_05    547- 552
   C1_05    553- 553
   C2M1_05    554- 554
   C2M2_05    555- 555
   C2M3_05    556- 556
   C2M4_05    557- 557
   C4_05    558- 558
   C5_05    559- 564
;
 
LABEL
   HHID='HOUSEHOLD IDENTIFIER'
   PN='PERSON NUMBER'
   JSUBHH='2004 SUB HOUSEHOLD IDENTIFICATION NUMBER'
   HSUBHH='2002 SUB HOUSEHOLD IDENTIFICATION NUMBER'
   GSUBHH='2000 SUB HOUSEHOLD IDENTIFICATION NUMBER'
   JPN_SP='2004 SPOUSE/PARTNER PERSON NUMBER'
   QNR05='2005 CAMS QUESTIONNAIRE IDENTIFIER'
   QTYPE05='QUESTIONNAIRE TYPE - R OR SP'
   A1_05='A1. WATCH TV'
   A2_05='A2. READ PAPERS/MAGS'
   A3_05='A3. READ BOOKS'
   A4_05='A4. LISTEN MUSIC'
   A5_05='A5. SLEEP/NAP'
   A6_05='A6. WALK'
   A7_05='A7. SPORTS/EXERCISE'
   A8_05='A8. VISIT IN PERSON'
   A9_05='A9. PHONE/LETTERS/EMAIL'
   A10_05='A10. WORK FOR PAY'
   A11_05='A11. USE COMPUTER'
   A12_05='A12. PRAY/MEDITATE'
   A13_05='A13. HOUSE CLEANING'
   A14_05='A14. WASH/IRON/MEND'
   A15_05='A15. YARD WORK/GARDEN'
   A16_05='A16. SHOP/RUN ERRANDS'
   A17_05='A17. MEALS PREP/CLEAN-UP'
   A18_05='A18. PERSONAL GROOMING'
   A19_05='A19. PET CARE'
   A20_05='A20. SHOW AFFECTION'
   A21_05='A21. HELP OTHERS'
   A22_05='A22. VOLUNTEER WORK'
   A23_05='A23. RELIGIOUS ATTENDANCE'
   A24_05='A24. ATTEND MEETINGS'
   A25_05='A25. MONEY MANAGEMENT'
   A26_05='A26. MANAGING MEDICAL CONDITION'
   A27_05='A27. PLAY CARDS/GAMES/PUZZLES'
   A28_05='A28. CONCERTS/MOVIES/LECTURES'
   A29_05='A29. SING/PLAY MUSIC'
   A30_05='A30. ARTS AND CRAFTS'
   A31_05='A31. HOME IMPROVEMENTS'
   A32_05='A32. VEHICLE MAINTENANCE/CLEANING'
   A33_05='A33. LEISURE DINING/EATING OUT'
   A34_05='A34. DAYS AWAY OVERNIGHT- BUSINESS'
   A35_05='A35. DAYS AWAY OVERNIGHT - NONBUSINESS'
   A36_05='A36. OFTEN USE MIND'
   A37_05='A37. OFTEN USE BODY'
   A38_05='A38. OFTEN ACTIVE WITH OTHERS'
   A39_05='A39. OFTEN BENEFIT OTHERS'
   A40_05='A40. WHO ANSWER QUESTIONNAIRE'
   A41_05='A41. SECTION A TIME'
   B1_05='B1. PURCHASE/LEASE AUTO'
   B1a1_05='B1A1. AUTO MAKE - 1'
   B1a2_05='B1A2. AUTO MODEL - 1'
   B1a3_05='B1A3. AUTO YEAR - 1'
   B1a4_05='B1A4. AUTO PRICE - 1'
   B1a5_05='B1A5. AUTO/TRUCK NEW OR USED - 1'
   B1b1_05='B1B1. AUTO MAKE - 2'
   B1b2_05='B1B2. AUTO MODEL - 2'
   B1b3_05='B1B3. AUTO YEAR - 2'
   B1b4_05='B1B4. AUTO PRICE - 2'
   B1b5_05='B1B5. AUTO/TRUCK NEW OR USED - 2'
   B1c1_05='B1C1. AUTO MAKE - 3'
   B1c2_05='B1C2. AUTO MODEL - 3'
   B1c3_05='B1C3. AUTO YEAR - 3'
   B1c4_05='B1C4. AUTO PRICE - 3'
   B1c5_05='B1C5. AUTO/TRUCK NEW OR USED - 3'
   B2_05='B2. BUY REFRIGERATOR'
   B2a_05='B2A. REFRIGERATOR PRICE'
   B3_05='B3. BUY WASHER/DRYER'
   B3a_05='B3A. WASHER/DRYER PRICE'
   B4_05='B4. BUY DISWASHER'
   B4a_05='B4A. DISHWASHER PRICE'
   B5_05='B5. BUY TELEVISION'
   B5a_05='B5A. TELEVISION PRICE'
   B6_05='B6. BUY COMPUTER'
   B6a_05='B6A. COMPUTER PRICE'
   B7_05='B7. HOME/RENTERS INSURANCE'
   B7d_05='COMBINED WITH HOME INSURANCE'
   B8_05='B8. PROPERTY TAXES'
   B8d_05='COMBINED WITH PROPERTY TAXES'
   B9_05='B9. VEHICLE INSURANCE'
   B10_05='B10. VEHICLE MAINTENANCE'
   B11_05='B11. HEALTH INSURANCE'
   B12_05='B12. TRIPS AND VACATIONS'
   B13_05='B13. HOME REPAIRS/MAINTENANCE DIY'
   B14_05='B14. HOME REPAIRS/MAINTENANCE SERVICES'
   B15_05='B15. HOUSEHOLD FURNISHINGS AND EQUIPMENT'
   B16_05='B16. CONTRIBUTIONS'
   B17_05='B17. GIFTS'
   B18_05='B18. MORTGAGE'
   B18a_05='B18A. MORTAGAGE - PER'
   B18d_05='COMBINED WITH MORTGAGE'
   B19_05='B19. RENT'
   B19a_05='B19A. RENT - PER'
   B19d_05='COMBINED WITH RENT'
   B20_05='B20. ELECTRICITY'
   B20a_05='B20A. ELECTRICITY - PER'
   B20d_05='COMBINED WITH ELECTRICITY'
   B21_05='B21. WATER'
   B21a_05='B21A. WATER - PER'
   B21d_05='COMBINED WITH WATER'
   B22_05='B22. HEAT'
   B22a_05='B22A. HEAT - PER'
   B22d_05='COMBINED WITH HEAT'
   B23_05='B23. PHONE/CABLE/INTERNET'
   B23a_05='B23A. PHONE/CABLE - PER'
   B24_05='B24. CAR PAYMENTS INTEREST/PRINCIPAL'
   B24a_05='B24A. CAR PAYMENTS - PER'
   B25_05='B25. HOUSEKEEPING SUPPLIES'
   B25a_05='B25A. HOUSEKEEPING SUPPLIES - PER'
   B26_05='B26. HOUSEKEEPING SERVICES'
   B26a_05='B26A. HOUSEKEEPING SERVICES - PER'
   B27_05='B27.GARDENING/YARD SUPPLIES'
   B27a_05='B27A. GARDEN/YARD SUPPLIES - PER'
   B28_05='B28. GARDEN/YARD SERVICES'
   B28a_05='B28A. GARDEN/YARD SERVICES - PER'
   B29_05='B29. CLOTHING AND APPAREL'
   B29a_05='B29A. CLOTHING - PER'
   B30_05='B30. PERSONAL CARE PRODUCTS/SERVICES'
   B30a_05='B30A. PERSONAL CARE PROD/SERVICES - PER'
   B31_05='B31. DRUGS OOP'
   B31a_05='B31A. DRUGS OOP - PER'
   B32_05='B32. HEALTH SERVICES'
   B32a_05='B32A. HEALTH SERVICES - PER'
   B33_05='B33. MEDICAL SUPPLIES'
   B33a_05='B33A. MED SUPPLIES - PER'
   B34_05='B34. TICKETS'
   B34a_05='B34A. TICKETS - PER'
   B35_05='B35. SPORTS EQUIPMENT'
   B35a_05='B35A. SPORTS EQUIPMENT - PER'
   B36_05='B36. HOBBIES/LEISURE EQUIPMENT'
   B36a_05='B36A. HOBBIES/LEISURE EQUIPMENT - PER'
   B37_05='B37. FOOD/DRINK GROCERY'
   B37a_05='B37A. FOOD/DRINK GROC - PER'
   B38_05='B38. DINING OUT'
   B38a_05='B38A. DINING OUT - PER'
   B39_05='B39. GASOLINE'
   B39a_05='B39A. GASOLINE - PER'
   B40_05='B40. HH SPENT'
   B40a_05='B40A. HH AMOUNT SPENT MORE'
   B40b_05='B40B. HH AMOUNT SPENT LESS'
   B41_05='B41. 20% MORE INCOME'
   B41a_05='B41A. % SPEND'
   B41b_05='B41B. % SAVE'
   B42M1_05='B42M1. WHAT EXTRA INCOME SPEND ON'
   B42M2_05='B42M2. WHAT EXTRA INCOME SPEND ON'
   B42M3_05='B42M3. WHAT EXTRA INCOME SPEND ON'
   B42M4_05='B42M4. WHAT EXTRA INCOME SPEND ON'
   B42M5_05='B42M5. WHAT EXTRA INCOME SPEND ON'
   B42M6_05='B42M6. WHAT EXTRA INCOME SPEND ON'
   B43_05='B43. 20% LESS INCOME'
   B43a_05='B43A. % CUT SPENDING'
   B44M1_05='B44M1. WHAT ITEMS SPEND LESS ON'
   B44M2_05='B44M2. WHAT ITEMS SPEND LESS ON'
   B44M3_05='B44M3. WHAT ITEMS SPEND LESS ON'
   B44M4_05='B44M4. WHAT ITEMS SPEND LESS ON'
   B44M5_05='B44M5. WHAT ITEMS SPEND LESS ON'
   B44M6_05='B44M6. WHAT ITEMS SPEND LESS ON'
   B45_05='B45. RETIRED'
   B45a_05='B45A. RETIRED SPENDING CHANGE HOW'
   B45b_05='B45B. RETIRED SPENDING CHANGE PERCENT'
   B45d_05='B45D. NOT RETIRED SPEND CHANGE HOW'
   B45e_05='B45E. NOT RETIRED SPEND CHANGE PERCENT'
   B46a_05='B46A. SPENDING ON TRIPS'
   B46b_05='B46B. SPENDING ON CLOTHES'
   B46c_05='B46C. SPENDING ON EATING OUT'
   B46d_05='B46D. SPENDING ON HOME/HOUSEHOLD'
   B46e_05='B46E. SPENDING ON ENTERTAINMENT'
   B46f_05='B46F. SPENDING ON AUTO EXPENSES'
   B47_05='B47. WHO ANSWER QUESTIONNAIRE'
   B48_05='B48. SECTION B TIME'
   C1_05='C1. MARITAL STATUS'
   C2M1_05='C2M1. WORKING STATUS - 1'
   C2M2_05='C2M2. WORKING STATUS - 2'
   C2M3_05='C2M3. WORKING STATUS - 3'
   C2M4_05='C2M4. WORKING STATUS - 4'
   C4_05='C4. WHO ANSWER QUESTIONNAIRE'
   C5_05='C5. SECTION C TIME'
;
run;
