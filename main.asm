.data

ask_day:        .asciiz         "Nhap ngay DAY: "
ask_month:      .asciiz         "Nhap thang MONTH: "
ask_year:       .asciiz         "Nhap nam YEAR: "
ask_reinput:    .asciiz         "Ngay thang nam khong hop le. Vui long nhap lai.\n"
menu_opt:       .asciiz         "--------- Ban hay chon 1 trong cac thao tac duoi day ----------\n1. Xuat chuoi TIME theo dinh dang DD/MM/YY\n2. Chuyen doi chuoi TIME thanh mot trong cac dinh dang sau:\n\tA. MM/DD/YYYY\n\tB. Month DD, YYYY\n\tC. DD Month, YYYY\n3. Cho biet ngay vua nhap la ngay thu may trong tuan\n4. Kiem tra nam trong chuoi TIME co phai la nam nhuan hay khong\n5. Cho biet khoang thoi gian giua chuoi TIME_1 va TIME_2\n6. Cho biet 2 nam nhuan gan nhat voi nam trong chuoi TIME.\n----------------------------------------------------------------\nLua chon: "

buffer:         .space          256
time:           .space          11

.text
.globl main

main:
    # $s0 - day, $s1 - month, $s2 - year
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
    j       userInput                   # }


    convertToTime:
    add     $a0, $zero, $s0
    add     $a1, $zero, $s1
    add     $a2, $zero, $s2
    la      $a3, time
    jal     date                        #   date(day, month, year, time);

    showMenu:
    la      $a0, menu_opt
    addi    $v0, $zero, 4
    syscall                             #   cout << menu_opt;
    j       exit


# -------------------------------- int stringToNum(string s) ---------------------------
stringToNum:                            
addi    $sp, $sp, -16                   # int stringToNum(string s) {
sw      $ra, 12($sp)                    # -- Store function addr
sw      $s0, 8($sp)                     # -- Store $s0
sw      $s1, 4($sp)                     # -- Store $s1
sw      $s2, 0($sp)                     # -- Store $s2

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


exit: