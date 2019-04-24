.data

ask_day:        .asciiz         "Nhap ngay DAY: "
ask_month:      .asciiz         "Nhap thang MONTH: "
ask_year:       .asciiz         "Nhap nam YEAR: "
ask_reinput:    .asciiz         "Ngay thang nam khong hop le. Vui long nhap lai.\n"
ask_date2:	.asciiz		"Nhap ngay thang nam can tinh khoang cach voi ngay hien tai. \n"
ask_type:	 .asciiz	"\nChon dinh dang muon thay doi: A hay B hay C? "
noti_errortype:	 .asciiz	"\nSai kieu dinh dang. Khoi phuc dinh dang  mac dinh:  "
noti_convert:	 .asciiz	"\nDinh dang thanh cong. Chuoi moi la: "

menu_opt:       .asciiz         "--------- Ban hay chon 1 trong cac thao tac duoi day ----------\n1. Xuat chuoi TIME theo dinh dang DD/MM/YY\n2. Chuyen doi chuoi TIME thanh mot trong cac dinh dang sau:\n\tA. MM/DD/YYYY\n\tB. Month DD, YYYY\n\tC. DD Month, YYYY\n3. Cho biet ngay vua nhap la ngay thu may trong tuan\n4. Kiem tra nam trong chuoi TIME co phai la nam nhuan hay khong\n5. Cho biet khoang thoi gian giua chuoi TIME_1 va TIME_2\n6. Cho biet 2 nam nhuan gan nhat voi nam trong chuoi TIME.\n7. Thoat chuong trinh.\n----------------------------------------------------------------"
menu_inp:       .asciiz         "\nLua chon: "
menu_outp:      .asciiz         "Ket qua: "

true_lyear:     .asciiz         "Nam vua nhap la nam nhuan."
false_lyear:    .asciiz         "Nam vua nhap khong phai la nam nhuan."

mon:		.asciiz		"Thu 2."
tue:		.asciiz		"Thu 3."
wed:		.asciiz		"Thu 4."
thu:		.asciiz		"Thu 5."
fri:		.asciiz		"Thu 6."
sat:		.asciiz		"Thu 7."
sun:		.asciiz		"Chu Nhat."

buffer:         .space          256
buffer_2:	 .space		  256

timeFormatted:	 .space          25
time:            .space          11
time2:		 .space          11

Jan:		.asciiz		"January"
Feb:		.asciiz		"February"
Mar:		.asciiz		"March"
April: 		.asciiz		"April"
May:		.asciiz		"May"
June:		.asciiz		"June"
July:		.asciiz		"July"
Aug:		.asciiz		"August"
Sep:		.asciiz		"September"
Oct:		.asciiz		"October"
Nov:		.asciiz		"November"
Dec:		.asciiz		"December"

.text
.globl main

main:
    # $s0 - day, $s1 - month, $s2 - year
    addi    $s6, $zero, 0
    userInput:                          # while (true) {
    la      $a0, ask_day
    addi    $v0, $zero, 4
    syscall                             #   cout << ask_day;

    la      $a0, buffer
    la      $a1, buffer
    addi    $v0, $zero, 8
    syscall                             #   cin >> buffer;

    la      $a0, buffer
    jal     stringToNum
    add     $s0, $zero, $v0             #   day = stringToNum(buffer);

    la      $a0, ask_month
    addi    $v0, $zero, 4
    syscall                             #   cout << ask_month;

    la      $a0, buffer
    la      $a1, buffer
    addi    $v0, $zero, 8
    syscall                             #   cin >> buffer;

    la      $a0, buffer
    jal     stringToNum
    add     $s1, $zero, $v0             #   month = stringToNum(buffer);

    la      $a0, ask_year
    addi    $v0, $zero, 4
    syscall                             #   cout << ask_year;

    la      $a0, buffer
    la      $a1, buffer
    addi    $v0, $zero, 8
    syscall                             #   cin >> buffer;

    la      $a0, buffer
    jal     stringToNum
    add     $s2, $zero, $v0             #   year = stringToNum(buffer);

    add     $a0, $zero, $s0
    add     $a1, $zero, $s1
    add     $a2, $zero, $s2
    jal     isValidDate

    bne     $v0, $zero, convertToTime   #   if (isValidDate(day, month, year)) break;
    la      $a0, ask_reinput
    addi    $v0, $zero, 4
    syscall                             #   cout << ask_reinput;
    j       userInput                   #   }


    convertToTime:
    add     $a0, $zero, $s0
    add     $a1, $zero, $s1
    add     $a2, $zero, $s2
    
    bne	    $s6, $zero, ePrintGetTime
    
    la      $a3, time
    jal     date                        #   date(day, month, year, time);

    showMenu:
    la      $a0, menu_opt
    addi    $v0, $zero, 4
    syscall                             #   cout << menu_opt;

    processCmd:                         #   while (true) {
    la      $a0, menu_inp
    addi    $v0, $zero, 4               #       cout << endl << menu_inp;
    syscall

    addi    $v0, $zero, 5
    syscall                             #       cin >> cmd;
    add     $s0, $zero, $v0             

    la      $a0, menu_outp
    add     $v0, $zero, 4
    syscall                             #       cout << menu_res;

    beq     $s0, 1, printTime           #       if (cmd == 1) goto printTime;
    beq	    $s0, 2, convertFormat	#	if (cmd == 2) goto convertFormat
    beq	    $s0, 3, printWeekDay	#	if (cmd == 3) goto printWeekDay; 
    beq     $s0, 4, printIsLeapYear     #       if (cmd == 4) goto printIsLeapYear;	
    beq	    $s0, 5, printGetTime 	#   	if (cmd == 5) goto printGetTime;
    beq     $s0, 6, print2LYears        #       if (cmd == 6) goto print2LYears;
    beq     $s0, 7, exit

    # ------------------------ Opt 1. Print time DD/MM/YY ----------------------
    printTime:                          #       printTime:
    la      $a0, time
    addi    $v0, $zero, 4               #       cout << time;
    syscall
    j       processCmd

    # ------------------------ Opt 2. Convert to 3 types -------------------------

    convertFormat:
    
    la	   $a0, timeFormatted 
    la     $a1, time	
    jal    strcpy
    add    $t0, $zero, $v0		  # store address of timeFormatted


    la 	   $a0, ask_type 		  # cout << ask_type
    addi   $v0, $zero, 4
    syscall
  
    addi   $v0, $zero, 12		  # cin >> type (for reading character)
    syscall 
 
    add     $a0, $zero, $t0		  # load address of timeFormatted
    addi    $a1, $v0, 0		  	  # la      $a1, type
    

    jal convertTIME

    add     $a1, $zero, $v0

    la      $a0, noti_convert
    addi    $v0, $zero, 4 
    syscall

    add     $a0, $zero, $a1		  
    addi    $v0, $zero, 4 
    syscall

    j	    processCmd

    
    # ------------------------ Opt 3. Print Date of Week   ----------------------
    printWeekDay:                        #       printWeekDay:
    la      $a0, time
    jal	    weekDay
        
    la      $a0, sun		            #       res = sun;
    beq     $v0, $zero, ePrintWeekDay   #	go to ePrintWeekDay;
    la      $a0, mon		            #       res = mon;
    beq     $v0, 1, ePrintWeekDay	    #	go to ePrintWeekDay;    
    la      $a0, tue		            #       res = tue;
    beq     $v0, 2, ePrintWeekDay	    #	go to ePrintWeekDay; 
    la      $a0, wed		            #       res = wed;
    beq     $v0, 3, ePrintWeekDay	    #	go to ePrintWeekDay; 
    la      $a0, thu		            #       res = thu;
    beq     $v0, 4, ePrintWeekDay	    #	go to ePrintWeekDay; 
    la      $a0, fri		            #       res = fri;
    beq     $v0, 5, ePrintWeekDay	    #	go to ePrintWeekDay; 
    la      $a0, sat		            #       res = sat;
    beq     $v0, 6, ePrintWeekDay	    #	go to ePrintWeekDay; 
    
    ePrintWeekDay:
    addi    $v0, $zero, 4               #       cout << res;
    syscall
    j       processCmd

    # ------------------------ Opt 4. Print is leap year --------------------------
    printIsLeapYear:                    #       printIsLeapYearHelper:
    la      $a0, time
    jal     isLeapYearHelper
    beq     $v0, $zero, printFalseLYear #       if (!isLeapYearHelper(time)) goto printFalseLYear;
    la      $a0, true_lyear             #       res = true_lyear;
    j       ePrintLeapYear

    printFalseLYear:
    la      $a0, false_lyear            #       printFalseLYear: res = false_lyear;
    j       ePrintLeapYear

    ePrintLeapYear:
    addi    $v0, $zero, 4               #       cout << res;
    syscall
    j       processCmd

    # ------------------------ Opt 5. Print Get Time  -----------------------------------
    printGetTime:                        #       printWeekDay:
    # Lay gia tri ngay thang nam thu hai
    la      $a0, ask_date2
    addi    $v0, $zero, 4
    syscall  
    addi    $s6, $zero, 1
    j	    userInput
    
    ePrintGetTime:
    la      $a3, time2
    jal     date                        #      date(day, month, year, time
    
    #------------------------------------------------------------------------------------
    la 	    $a1, time2
    la      $a0, time    
    jal	    getTime
    add    $a0, $zero, $v0
    addi    $v0, $zero, 1               #       cout << res;
    syscall
    j       processCmd

    # ------------------------ Opt 6. Print two nearest leap years --------------------------
    print2LYears:
    la      $a0, time                   #       print2LYear:
    jal     year
    add     $s1, $zero, $v0             #       year = year(time);
    div     $s1, $s1, 4                 #       year /= 4;
    mulo    $s1, $s1, 4                 #       year *= 4;

    add     $s2, $zero, $zero           #       n_lyear = 0;
    
    loopGet2LYear:
    beq     $s2, 2, e2LYear             #       while (n_lyear != 2) {
    addi    $s1, $s1, 4                 #           year += 4;
    add     $a0, $zero, $s1
    jal     isLeapYear

    beq     $v0, $zero, loopGet2LYear   #       if (!isLeapYear(year)) continue;
    
    addi    $s2, $s2, 1                 #       n_lyear++;
    add     $a0, $zero, $s1
    addi    $v0, $zero, 1
    syscall                             #       cout << year;
    addi    $a0, $zero, ' '
    addi    $v0, $zero, 11
    syscall                             #       cout << " ";
    j       loopGet2LYear               #       }

    e2LYear:
    j       processCmd




# -------------------------------- int stringToNum(string s) ---------------------------
stringToNum:                            
addi    $sp, $sp, -16                   # int stringToNum(string s) {
sw      $ra, 12($sp)
sw      $s0, 8($sp)
sw      $s1, 4($sp)
sw      $s2, 0($sp)

add     $v0, $zero, $zero               #   res = 0;
add     $s0, $zero, $a0                 #   offset = s.base_addr;

loopStringToNum:                        #   while (true) {
lb      $t0, 0($s0)
beq     $t0, $zero, eosToNum            #       if (s[i] == '\0) goto eosToNum;
beq     $t0, '\n', eosToNum             #       if (s[i] == '\n') goto eosToNum;

addi    $t1, $zero, '0'
slt     $t2, $t0, $t1
bne     $t2, $zero, failStringToNum     #       if (s[i] < '0') return false;
addi    $t1, $zero, '9'
slt     $t2, $t1, $t0
bne     $t2, $zero, failStringToNum     #       if (s[i] > '9') return false;

mulo    $v0, $v0, 10                    #       res *= 10;
add     $v0, $v0, $t0                   #       res += s[i];
sub     $v0, $v0, '0'                   #       res -= '0';

addi    $s0, $s0, 1                     #       offset++;
j       loopStringToNum                 #   }

eosToNum:
beq     $s0, $zero, failStringToNum     #   if (s.size() == 0) goto failStringToNum;
j       eStringToNum

failStringToNum:
addi    $v0, $zero, -1                  #   failStringToNum (empty string or exists non-digit character): res = -1;
j       eStringToNum

eStringToNum:
lw      $s2, 0($sp)
lw      $s1, 4($sp)
lw      $s0, 8($sp)
lw      $ra, 12($sp)                    #   return res;
addi    $sp, $sp, 16                    
jr      $ra                             # }


# -------------------- bool isValidDate(int day, int month, int year) ---------------------
isValidDate:
addi    $sp, $sp, -20                   # bool isValidDate(int day, int month, int year) {
sw      $ra, 16($sp)
sw      $s0, 12($sp)
sw      $s1, 8($sp)
sw      $s2, 4($sp)

addi    $t0, $zero, -1
beq     $a0, $t0, invalidDate           #   if (day == -1) return false;
beq     $a1, $t0, invalidDate           #   if (month == -1) return false;
beq     $a2, $t0, invalidDate           #   if (year == -1) return false;

addi    $t0, $zero, 1
slt     $t1, $a0, $t0                   
bne     $t1, $zero, invalidDate         #   if (day < 1) return false;
slt     $t1, $a1, $t0
bne     $t1, $zero, invalidDate         #   if (month < 1) return false;
slt     $t1, $a2, $t0
bne     $t1, $zero, invalidDate         #   if (year < 1) return false;

addi    $t0, $zero, 12
slt     $t1, $t0, $a1
bne     $t1, $zero, invalidDate         #   if (month > 12) return false;

sw      $a0, 0($sp)
add     $a0, $zero, $a1
add     $a1, $zero, $a2
jal     getMaxDay

lw      $a0, 0($sp)
slt     $t1, $v0, $a0
bne     $t1, $zero, invalidDate         #   if (day > getMaxDay(month, year)) return false;
j       validDate

invalidDate:
add     $v0, $zero, $zero               #   false: res = 0;
j       eIsValidDate

validDate:
addi    $v0, $zero, 1                   #   true: res = 1;
j       eIsValidDate

eIsValidDate:
lw      $s2, 4($sp)
lw      $s1, 8($sp)
lw      $s0, 12($sp)
lw      $ra, 16($sp)                    #   return res;
addi    $sp, $sp, 20                    
jr      $ra                             # }


# --------------------- int getMaxDay(int month, int year) --------------------------
getMaxDay:
addi    $sp, $sp, -16                   # int getMaxDay(int month, int year) {
sw      $ra, 12($sp)
sw      $s0, 8($sp)
sw      $s1, 4($sp)
sw      $s2, 0($sp)

beq     $a0, 2, getMaxFeb               #   if (month == 2) goto getMaxFeb;

addi    $t0, $zero, 7
slt     $t1, $t0, $a0
bne     $t1, $zero, getMaxAfterJuly     #   if (month > 7) goto getMaxAfterJuly;
addi    $t0, $zero, 2
div     $a0, $t0
mfhi    $t1
bne     $t1, 0, max31Days               #   goto (month % 2 ? max31Days : max30Days);
j       max30Days

getMaxAfterJuly:
addi    $t0, $zero, 2
div     $a0, $t0
mfhi    $t1
bne     $t1, 0, max30Days               #   getMaxAfterJuly: goto (month % 2 ? max30Days : max31Days);
j       max31Days

getMaxFeb:
add     $a0, $zero, $a1
jal     isLeapYear
beq     $v0, 0, max28Days               #   getMaxFeb: if (!isLeapYear(year)) goto max28Days;
addi    $v0, $zero, 29                  #              else res = 29;
j       eGetMaxDay

max28Days:
addi    $v0, $zero, 28                  #   max28Days: res = 28;
j       eGetMaxDay

max30Days:
addi    $v0, $zero, 30                  #   max30Days: res = 30;
j       eGetMaxDay

max31Days:
addi    $v0, $zero, 31                  #   max31Days: res = 31;
j       eGetMaxDay

eGetMaxDay:
lw      $s2, 0($sp)
lw      $s1, 4($sp)
lw      $s0, 8($sp)
lw      $ra, 12($sp)                    #   return res;
addi    $sp, $sp, 16                    
jr      $ra                             # }


# ---------------------- bool isLeapYear(int year) -----------------------
isLeapYear:
addi    $sp, $sp, -16                   # bool isLeapYear(int year) {
sw      $ra, 12($sp)
sw      $s0, 8($sp)
sw      $s1, 4($sp)
sw      $s2, 0($sp)

addi    $t0, $zero, 400
div     $a0, $t0
mfhi    $t1
beq     $t1, $zero, leapYear            #   if (year % 400 == 0) goto leapYear;

addi    $t0, $zero, 100
div     $a0, $t0
mfhi    $t1
beq     $t1, $zero, notLeapYear         #   if (year % 100 == 0) goto notLeapYear;

addi    $t0, $zero, 4
div     $a0, $t0
mfhi    $t1
beq     $t1, $zero, leapYear            #   if (year % 4 == 0) goto leapYear;

j       notLeapYear                     #   goto notLeapYear;

leapYear:
addi    $v0, $zero, 1                   #   leapYear: res = 1;
j       eLeapYear

notLeapYear:
add     $v0, $zero, $zero               #   notLeapYear: res = 0;
j       eLeapYear

eLeapYear:
lw      $s2, 0($sp)
lw      $s1, 4($sp)
lw      $s0, 8($sp)
lw      $ra, 12($sp)                    #   return res;
addi    $sp, $sp, 16
jr      $ra                             # }


# ---------------- char* date(int day, int month, int year, char* time) ---------------
date:
addi    $sp, $sp, -16                   # char* date(int day, int month, int year, char* time) {
sw      $ra, 12($sp)
sw      $s0, 8($sp)
sw      $s1, 4($sp)
sw      $s2, 0($sp)

add     $s0, $zero, $a3                 #   offset = time.base_addr
addi    $t0, $zero, 2                   #   width_day = 2
addi    $t2, $zero, 10

loopDayToTime:                          
beq     $t0, $zero, monthToTime         #   while (width_day != 0) {
addi    $t0, $t0, -1                    #       width_day--;
add     $t3, $s0, $t0                   #       i = offset + width_day;

div     $a0, $t2
mfhi    $t1
addi    $t1, $t1, '0'                   #       temp = (day % 10) + '0';
sb      $t1, 0($t3)                     #       s[i] = temp;
mflo    $a0                             #       day /= 10;
j       loopDayToTime                   #   }

monthToTime:
addi    $s0, $s0, 2                     #   offset += 2;
addi    $t1, $zero, '/'
sb      $t1, 0($s0)                     #   s[i] = '/'
addi    $s0, $s0, 1                     #   offset++;
addi    $t0, $zero, 2                   #   width_month = 2;

loopMonthToTime:                          
beq     $t0, $zero, yearToTime          #   while (width_month != 0) {
addi    $t0, $t0, -1                    #       width_month--;
add     $t3, $s0, $t0                   #       i = offset + width_month;

div     $a1, $t2
mfhi    $t1
addi    $t1, $t1, '0'                   #       temp = (month % 10) + '0';
sb      $t1, 0($t3)                     #       s[i] = temp;
mflo    $a1                             #       month /= 10;
j       loopMonthToTime                 #   }

yearToTime:
addi    $s0, $s0, 2                     #   offset += 2;
addi    $t1, $zero, '/'
sb      $t1, 0($s0)                     #   s[i] = '/'
addi    $s0, $s0, 1                     #   offset++;
addi    $t0, $zero, 4                   #   width_year = 4;

loopYearToTime:                          
beq     $t0, $zero, eDate               #   while (width_year != 0) {
addi    $t0, $t0, -1                    #       width_year--;
add     $t3, $s0, $t0                   #       i = offset + width_year;

div     $a2, $t2
mfhi    $t1
addi    $t1, $t1, '0'                   #       temp = (year % 10) + '0';
sb      $t1, 0($t3)                     #       s[i] = temp;
mflo    $a2                             #       year /= 10;
j       loopYearToTime                  #   }

eDate:
addi    $s0, $s0, 4                     #   offset += 4;
sb      $zero, 0($s0)                   #   s[i] = '\0'
add     $v0, $zero, $a3                 #   res = time.base_addr;
lw      $s2, 0($sp)
lw      $s1, 4($sp)
lw      $s0, 8($sp)
lw      $ra, 12($sp)                    #   return res;
addi    $sp, $sp, 16
jr      $ra                             # }


# ------------------------- int day(char* time) ----------------------------
day:
addi    $sp, $sp, -16                   # int day(char* time) {
sw      $ra, 12($sp)
sw      $s0, 8($sp)
sw      $s1, 4($sp)
sw      $s2, 0($sp)

la      $s0, buffer                     #   offset_buffer = buffer.base_addr  
loopDayFromTime:
lb      $t0, 0($a0)
beq     $t0, '/', dayToNum              #   while (time[i_time] != '/') {
sb      $t0, 0($s0)                     #       buffer[i_buffer] = time[i_time];
addi    $a0, $a0, 1                     #       offset_time++;
addi    $s0, $s0, 1                     #       offset_buffer++;
j       loopDayFromTime                 #   }

dayToNum:
sb      $zero, 0($s0)                   #   buffer[i_buffer] = '\0'
la      $a0, buffer
jal     stringToNum
add     $v0, $zero, $v0                 #   res = stringToNum(buffer);

lw      $s2, 0($sp)
lw      $s1, 4($sp)
lw      $s0, 8($sp)
lw      $ra, 12($sp)                    #   return res;
addi    $sp, $sp, 16
jr      $ra                             # }


# ---------------------- int month(char* time) ------------------------
month:
addi    $sp, $sp, -16                   # int month(char* time) {
sw      $ra, 12($sp)
sw      $s0, 8($sp)
sw      $s1, 4($sp)
sw      $s2, 0($sp)

la      $s0, buffer                     #   offset_buffer = buffer.base_addr 
add     $s1, $zero, $zero               #   backslash = 0;
 
skipToMonth:
lb      $t0, 0($a0)
beq     $s1, 1, loopMonthFromTime       #   while (backslash != 1) {
bne     $t0, '/', continueMonth         #       if (time[i_time] == '/') backslash++;
addi    $s1, $s1, 1
continueMonth:
addi    $a0, $a0, 1                     #       offset_time++;
j       skipToMonth                     #   }

loopMonthFromTime:
lb      $t0, 0($a0)
beq     $t0, '/', monthToNum            #   while (time[i_time] != '/') {
sb      $t0, 0($s0)                     #       buffer[i_buffer] = time[i_time];
addi    $a0, $a0, 1                     #       offset_time++;
addi    $s0, $s0, 1                     #       offset_buffer++;
j       loopMonthFromTime               #   }

monthToNum:
sb      $zero, 0($s0)                   #   buffer[i_buffer] = '\0'
la      $a0, buffer
jal     stringToNum
add     $v0, $zero, $v0                 #   res = stringToNum(buffer);

lw      $s2, 0($sp)
lw      $s1, 4($sp)
lw      $s0, 8($sp)
lw      $ra, 12($sp)                    #   return res;
addi    $sp, $sp, 16
jr      $ra                             # }


# ---------------------- int year(char* time) ------------------------
year:
addi    $sp, $sp, -16                   # int year(char* time) {
sw      $ra, 12($sp)
sw      $s0, 8($sp)
sw      $s1, 4($sp)
sw      $s2, 0($sp)

la      $s0, buffer                     #   offset_buffer = buffer.base_addr 
add     $s1, $zero, $zero               #   backslash = 0;
 
skipToYear:
lb      $t0, 0($a0)
beq     $s1, 2, loopYearFromTime        #   while (backslash != 2) {
bne     $t0, '/', continueYear          #       if (time[i_time] == '/') backslash++;
addi    $s1, $s1, 1
continueYear:
addi    $a0, $a0, 1                     #       offset_time++;
j       skipToYear                      #   }

loopYearFromTime:
lb      $t0, 0($a0)
beq     $t0, $zero, yearToNum           #   while (time[i_time] != '\0') {
sb      $t0, 0($s0)                     #       buffer[i_buffer] = time[i_time];
addi    $a0, $a0, 1                     #       offset_time++;
addi    $s0, $s0, 1                     #       offset_buffer++;
j       loopYearFromTime                #   }

yearToNum:
sb      $zero, 0($s0)                   #   buffer[i_buffer] = '\0'
la      $a0, buffer
jal     stringToNum
add     $v0, $zero, $v0                 #   res = stringToNum(buffer);

lw      $s2, 0($sp)
lw      $s1, 4($sp)
lw      $s0, 8($sp)
lw      $ra, 12($sp)                    #   return res;
addi    $sp, $sp, 16
jr      $ra                             # }


# ----------------------- bool isLeapYearHelper(char* time) -----------------
isLeapYearHelper:
addi    $sp, $sp, -16                   # bool isLeapYearHelper(char* time) {
sw      $ra, 12($sp)
sw      $s0, 8($sp)
sw      $s1, 4($sp)
sw      $s2, 0($sp)

jal     year                            #   year = year(time);
add     $a0, $zero, $v0
jal     isLeapYear                      #   res = isLeapYear(year);

lw      $s2, 0($sp)
lw      $s1, 4($sp)
lw      $s0, 8($sp)
lw      $ra, 12($sp)                    #   return res;
addi    $sp, $sp, 16
jr      $ra                             # }   

#----------------- int Weekday(int day, int month, int year)	-------------------
weekDay:
addi    $sp, $sp, -20                 	#   int Weekday(int day, int month, int year){
sw      $ra, 16($sp)
sw      $s0, 12($sp)
sw      $s1, 8($sp)
sw 	$s2, 4($sp)
sw 	$a0, 0($sp)

add     $v0, $zero, $zero              #   res = 0;

add	$s0, $zero, $a0
add	$a0, $zero, $s0
jal     year                           #   year = year(time);
add     $a2, $zero, $v0

add	$a0, $zero, $s0
jal     month                          #   month = year(month);
add     $a1, $zero, $v0

add	$a0, $zero, $s0
jal     day                            #   day = year(day);
add     $a0, $zero, $v0


addi 	$t0, $zero, 3
slt     $t1, $a1, $t0                   
beq	$t1, $zero, calculator		#   if (month > 3) goto calculator
addi	$a1, $a1, 12			#   month=month+12;
addi	$a2, $a2, -1			#   year=year-1;

calculator:				        #   date=(day + 2*month + 3*(month+1)/5+year+(year/4))%7;
add 	$t0, $a0, $a2			#   date=day + year
mulo 	$t1, $a1, 2						
add 	$t0, $t0, $t1 			#   date=day + year + 2*month
addi	$t1, $a1, 1						
mulo	$t1, $t1, 3						
addi    $t2, $zero, 5
div 	$t1, $t2
mflo	$t1
add	$t0, $t0, $t1 	    		#   date=day + year + 2*month + 3*(month+1)/5
addi    $t2, $zero, 4
div 	$a2, $t2
mflo	$t1
add	$t0, $t0, $t1 		    	#   date=day + year + 2*month + 3*(month+1)/5 + (year/4)
addi    $t2, $zero, 7
div 	$t0, $t2
mfhi	$t0				        #   date=(day + year + 2*month + 3*(month+1)/5 + (year/4))%7

add 	$v0, $t0, $zero

lw      $a0, 0($sp)
lw      $s2, 4($sp)
lw      $s1, 8($sp)
lw      $s0, 12($sp)
lw      $ra, 16($sp)                    #   return res;
addi    $sp, $sp, 20                    
jr      $ra                             # }

# ------------------------int getTime(char* TIME_1, char* TIME_2) -----------------
getTime:                                    
addi    $sp, $sp, -24               	#   int getTime(char* TIME_1, char* TIME_2){
sw      $ra, 20($sp)
sw      $s0, 16($sp)
sw      $s1, 12($sp)
sw 	$s2, 8($sp)

# Lay ngay thang nam cho nam thu hai
add	$s0, $zero, $a0
add	$a0, $zero, $a1
jal     year                            #   year = year(time);
add     $t5, $zero, $v0

add	$a0, $zero, $a1
jal     month                           #   month = year(month);
add     $t4, $zero, $v0

add	$a0, $zero, $a1
jal     day                             #   day = year(day);
add 	$t3, $zero, $v0

# Lay ngay thang nam cho nam thu nhat
add	$a0, $zero, $s0
jal     year                            #   year = year(time);
add     $t2, $zero, $v0
sw 	$t2, 4($sp)

add	$a0, $zero, $s0
jal     month                           #   month = year(month);
add     $t1, $zero, $v0
sw 	$t1, 0($sp)

add	$a0, $zero, $s0
jal     day                             #   day = year(day);
add 	$t0, $zero, $v0
#--------------------------------------

lw      $t1, 0($sp)
lw      $t2, 4($sp)


# Bat dau tinh khoang cach
sub 	$v0, $t5, $t2		        	#   res = y2 - y1

beq	$v0, $zero, eGetTime		        #   if(res==0) goto eGetTime
 
slt 	$t6, $v0, $zero
beq	$t6, $zero, checkMonth		        #   if(res>0) goto checkMonth
# Swap
sub	$v0, $zero, $v0			            #   if(res<0) res=0-res; swap(TIME_1, TIME_2)

add 	$t6, $zero, $t0
add 	$t0, $zero, $t3
add 	$t3, $zero, $t6

add 	$t6, $zero, $t1
add 	$t1, $zero, $t4
add 	$t4, $zero, $t6

add 	$t6, $zero, $t2
add 	$t2, $zero, $t5
add 	$t5, $zero, $t6
      
checkMonth:
slt 	$t6, $t4, $t1		
beq 	$t6, $zero, checkDay		    #   if(m2 >= m1){
addi 	$v0, $v0, -1			        #   res--
j 	eGetTime			                #   goto eGetTime 

checkDay:				                #   }
bne 	$t4, $t1, eGetTime		        #   else if(m2 != m1) goto eGetTime 
					                    #   else {
slt 	$t6, $t3, $t0					
beq 	$t6, $zero, eGetTime	    	#   if(d2 >= d1) goto eGetTime 
addi 	$v0, $v0, -1			        #   else res--;
					                    #   }
eGetTime:


lw      $s2, 8($sp)
lw      $s1, 12($sp)
lw      $s0, 16($sp)
lw      $ra, 20($sp)                   	#   return res;
addi	$sp, $sp, 24  
jr  	$ra            	                #   }


		#-------------------------char* Convert(char* TIME, char type)--------------------------#

convertTIME:				# char* Convert(char* TIME, char type){
beq	    $a1, 'A', convertTypeA	# if (type == 'A') goto convertTypeA // MM/DD/YYYY

beq	    $a1, 'B', convertTypeB	# else if (type == 'B') goto convertTypeB // Month DD, YYYY

beq	    $a1, 'C', convertTypeC	# else if (type == 'C') goto convertTypeC // DD Month, YYYY

j failToConvert				# else goto failToConvert
	
# A. MM/DD/YYYY
# swap DD and MM			
convertTypeA:				
addi	$sp, $sp, -16			
sw	$ra, 12($sp)
sw	$s0, 8($sp)
sw	$s1, 4($sp)
sw	$s2, 0($sp)		
					# //a0 = &time. Default format: DD/MM/YYYY
lb	$t0, 0($a0) 			# t0 = time[0]; t1 = time[1];
lb	$t1, 1($a0)			# t2 = time[3]; t4 = time[4];
lb	$t2, 3($a0) 			
lb 	$t3, 4($a0) 				

sb 	$t0, 3($a0) 			# time[3] = t0; time[4] = t1;
sb	$t1, 4($a0) 			# time[0] = t2; time[1] = t4;
sb	$t2, 0($a0) 
sb	$t3, 1($a0) 

lw	$ra, 12($sp)
lw	$s0, 8($sp)
lw	$s1, 4($sp)
lw	$s2, 0($sp)
addi	$sp, $sp, 16

j exitConvert

# B. Month DD, YYYY
convertTypeB:
addi	$sp, $sp, -32
sw	$ra, 28($sp)
sw	$s0, 24($sp)
sw	$s1, 20($sp)
sw	$s2, 16($sp)
sw	$a0, 12($sp)
					# //a0 = &time. Default format: DD/MM/YYYY)	

jal	month		
add	$a0, $zero, $v0			# int num = month(time); 

jal	convertMonth			# char* month = convertMonth(num);
sw	$v0, 0($sp)			# //save month (string) to stack

lw	$a0, 12($sp)			# //load $a0 from stack to get each byte

#	Get DD, modify 
la	$t4, buffer			# //temp string of DD and change to ' DD, ' format

addi	$t2, $zero, ' ' 
addi	$t3, $zero, ','			
					
sb	$t2, 0($t4)			# buffer[0] = ' ';
lb	$t0, 0($a0)			# buffer[1] = time[0]; 
sb	$t0, 1($t4)			# buffer[2] = time[1]
lb	$t0, 1($a0)			# buffer[3] = ','; 
sb	$t0, 2($t4)			# buffer[4] = ' ';
sb	$t3, 3($t4)			# buffer[5] = '\0'
sb	$t2, 4($t4)
sb	$zero, 5($t4)

sw	$t4, 8($sp)


#	Get YYYY		
la 	$t5, buffer_2			

lb	$t0, 6($a0)			# buffer_2[0] = time[6];
sb	$t0, 0($t5)			# buffer_2[1] = time[7];
lb	$t0, 7($a0)			# buffer_2[2] = time[8];
sb	$t0, 1($t5)			# buffer_2[3] = time[9];
lb	$t0, 8($a0)			# buffer_2[4] = '\0';
sb	$t0, 2($t5)
lb	$t0, 9($a0)
sb	$t0, 3($t5)
sb	$zero, 4($t5)

sw	$t5, 4($sp)

#	Concatenation Month DD, YYYY
lw	$a1, 0($sp)			# //a1 = month (string) (load from stack)
jal 	strcpy 				# strcpy(time, month);

lw	$a1, 8($sp)			# strcat(time, buffer);
jal 	strcat	

lw	$a1, 4($sp)			# strcat(time, buffer_2);
jal 	strcat

lw	$ra, 28($sp)			
lw	$s0, 24($sp)
lw	$s1, 20($sp)
lw	$s2, 16($sp)
addi	$sp, $sp, 32

j exitConvert

# C. DD Month, YYYY
convertTypeC:
addi	$sp, $sp, -32
sw	$ra, 28($sp)
sw	$s0, 24($sp)
sw	$s1, 20($sp)
sw	$s2, 16($sp)
sw	$a0, 12($sp)

#	Get MM				# //a0 = &time. Default format: DD/MM/YYYY

jal	month
add	$a0, $zero, $v0			# int num = month(time);

jal	convertMonth			# char* month = convertMonth(num);
sw	$v0, 0($sp)			# save month (string) to stack

lw	$a0, 12($sp)			# //load $a0 from stack to get each byte

#	Get DD, modify 
la	$t4, buffer			# //temp string of DD and change to 'DD ' format

addi	$t2, $zero, ' ' 
			
lb	$t0, 0($a0)			# buffer[0] = time[0];
sb	$t0, 0($t4)			# buffer[1] = time[1]; 
lb	$t0, 1($a0)			# buffer[2] = ' ';
sb	$t0, 1($t4)			# buffer[3] = '\0';
sb	$t2, 2($t4)
sb	$zero, 3($t4)
sw	$t4, 4($sp)

#	Get YYYY
la 	$t5, buffer_2			#temp string of YYYY and change to ', YYYY' format

addi 	$t2, $zero, ','
addi	$t3, $zero, ' '

sb	$t2, 0($t5)			# buffer_2[0] = ',';
sb	$t3, 1($t5)			# buffer_2[1] = ' ';
lb	$t0, 6($a0)			# buffer_2[2] = time[6];
sb	$t0, 2($t5)			# buffer_2[3] = time[7];
lb	$t0, 7($a0)			# buffer_2[4] = time[8];
sb	$t0, 3($t5)			# buffer_2[5] = time[9];
lb	$t0, 8($a0)			# buffer_2[6] = '\0';
sb	$t0, 4($t5)
lb	$t0, 9($a0)
sb	$t0, 5($t5)
sb	$zero, 6($t5)

sw	$t5, 8($sp)

#	Concatenation DD Month, YYYY

lw	$a1, 4($sp)			
jal 	strcpy 				# strcpy(time, buffer);
					
lw	$a1, 0($sp)			#//a1 = month (load from stack)#
jal 	strcat				# strcat(time, month);

lw	$a1, 8($sp)			# strcat(time, buffer_2);
jal 	strcat

lw	$ra, 28($sp)
lw	$s0, 24($sp)
lw	$s1, 20($sp)
lw	$s2, 16($sp)
addi	$sp, $sp, 32
j	 exitConvert


failToConvert:				
addi	$sp, $sp, -8
sw	$a0, 4($sp)
sw	$a1, 0($sp)
					#//if (type != 'A' && type !+= 'B' && type != 'C')
la	$a0, noti_errortype		#// cout << noti_errortype;}
addi	$v0, $zero, 4
syscall

lw	$a0, 4($sp)
lw	$a1, 0($sp)
addi	$sp, $sp, 8
j 	exitConvert			

exitConvert:
add	$v0, $zero, $a0
jr	$ra	

	#-------------------char * convertMonth(int month)--------------------------
# $a0 -- month(int)
# $v0 -- month(char*)
convertMonth:				# char* convertMonth(int month){
					# char* res = new char[10];
beq	$a0, 1, Month_1			# if (month == 1)
					# 	res = Month_1(month);
beq	$a0, 2, Month_2			# else if (month == 2)
					#	res = Month_2(month);
beq	$a0, 3, Month_3			# else if (month == 3)
					#	res = Month_3(month);
beq	$a0, 4, Month_4			# else if (month == 4)
					#	res = Month_4(month);
beq	$a0, 5, Month_5			# else if (month == 5)
					#	res = Month_5(month);
beq	$a0, 6, Month_6			# else if (month == 6)
					#	res = Month_6(month);
beq	$a0, 7, Month_7			# else if (month == 7)
					#	res = Month_7(month);
beq	$a0, 8, Month_8			# else if (month == 8)
					#	res = Month_8(month);
beq	$a0, 9, Month_9			# else if (month == 9)
					#	res = Month_9(month);
beq	$a0, 10, Month_10		# else if (month == 10)
					#	res = Month_10(month);
beq	$a0, 11, Month_11		# else if (month == 11)
					#	res = Month_11(month);
la $v0, Dec				# else
j end					#	res = Month_12(month);
					# return res;}
Month_1:				
	la $v0, Jan
	j end
Month_2:
	la $v0, Feb
	j end
Month_3:
	la $v0, Mar
	j end
Month_4:
	la $v0, April
	j end
Month_5:
	la $v0, May
	j end
Month_6:
	la $v0, June
	j end
Month_7:
	la $v0, July
	j end
Month_8:
	la $v0, Aug
	j end
Month_9:
	la $v0, Sep
	j end
Month_10:
	la $v0, Oct
	j end
Month_11:
	la $v0, Nov
	j end
end:
	jr $ra

	#-----------------------void strcpy(char *&des, char *src)-------------------
#reference: https://www.cs.utah.edu/~rajeev/cs3810/slides/3810-05.pdf
strcpy: 				# void strcpy(char *&des, char *src){
addi 	$sp, $sp, -4			
sw 	$s0, 0($sp)		
add 	$s0, $zero, $zero		# int i = 0;

strcpy_loop: 			
add 	$t1, $s0, $a1			# while(des[i] = src[i] != '\0')
lb 	$t2, 0($t1)			#  	i += 1;}
add 	$t3, $s0, $a0		
sb 	$t2, 0($t3)
beq 	$t2, $zero, strcpy_end
addi 	$s0, $s0, 1
j strcpy_loop

strcpy_end: 
lw 	$s0, 0($sp)
addi 	$sp, $sp, 4
add     $v0, $zero, $a0
jr 	$ra


	#--------------------------void strcat(char *&des, char *src)------------------------
# $a0 -- 1st string
# $a1 -- 2nd string
strcat:					# void strcat(char *&des, char *src){
addi 	$sp, $sp, -8		
sw 	$s0, 0($sp)
sw	$s1, 4($sp)

add	$s0, $zero, $zero		# int i = 0;
add 	$s1, $zero, $zero 		# int j = 0;

findEndFirstStr:				
add 	$t0, $a0, $s0			# while(des[i] != '\0')
lb 	$t1, 0($t0) 			# 	i += 1;
beq 	$t1, $zero, appendSecStr	# 
addi 	$s0, $s0, 1  			# 
j findEndFirstStr

appendSecStr:
add 	$t2, $a1, $s1 			# 
lb 	$t3, 0($t2) 			# while(des[i] = src[j] != '\0'){
add 	$t0, $a0, $s0 			# 	i += 1;
sb 	$t3, 0($t0) 			# 	j += 1;
beq 	$t3, $zero, strcatEnd		# }
addi 	$s0, $s0, 1			# }
addi 	$s1, $s1, 1			# 
j appendSecStr
strcatEnd:
lw 	$s0, 0($sp)
lw 	$s1, 4($sp)
addi 	$sp, $sp, 8
jr 	$ra
#---------------------------------------------
exit:


