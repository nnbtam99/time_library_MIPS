.data
day:            .word       -1
month:          .word       -1
year:           .word       -1

ask_day:        .asciiz     "Nhap ngay DAY: "
ask_month:      .asciiz     "Nhap thang MONTH: "
ask_year:       .asciiz     "Nhap nam YEAR: "

buffer_day:     .space      16                      # A character array of size 16
buffer_month:   .space      16                      # A character array of size 16
buffer_year:    .space      16                      # A character array of size 16

.text
.globl main

main:

    la      $a0, ask_day
    addi    $v0, $zero, 4                           # cout << "Nhap ngay DAY: ";
    syscall

    la      $a0, buffer_day
    la      $a1, buffer_day
    addi    $v0, $zero, 8                           # cin >> buffer_day;
    syscall

    la      $a0, ask_month
    addi    $v0, $zero, 4                           # cout << "Nhap thang MONTH: ";
    syscall

    la      $a0, buffer_month
    la      $a1, buffer_month
    addi    $v0, $zero, 8                           # cin >> buffer_month;
    syscall

    la      $a0, ask_year               
    addi    $v0, $zero, 4                           # cout << "Nhap nam YEAR: ";
    syscall

    la      $a0, buffer_year
    la      $a1, buffer_year
    addi    $v0, $zero, 8                           # cin >> buffer_year;
    syscall

    la      $a0, buffer_day
    jal     convert_to_unsigned
    sw      $v0, day                                # int day = convertToUnsigned(buffer_day);

    la      $a0, buffer_month
    jal     convert_to_unsigned
    sw      $v0, month                              # int month = convertToUnsigned(buffer_month);


    la      $a0, buffer_year
    jal     convert_to_unsigned
    sw      $v0, year                               # int year = convertToUnsigned(buffer_year);

    lw      $a0, day
    lw      $a1, month
    lw      $a2, year
    jal     check_date
    j       exit


convert_to_unsigned:                                # int convertToUnsigned(string s) {
    addi    $sp, $sp, -16
    sw      $ra, 12($sp)

    add     $s0, $zero, $zero                       #   int n = 0;
    add     $s1, $zero, $zero                       #   int offset = 0;

    string_iterate:
    add     $t0, $a0, $s1                           #   i = s.base_addr + offset
    lb      $t1, 0($t0)                             #   s[i]

    beq     $t1, $zero, end_of_string
        addi    $t2, $zero, '\n'
        beq     $t1, $t2, end_of_string             #   while (s[i] != '\0' && s[i] != '\n') {
            addi    $t2, $zero, '0'
            slt     $t3, $t1, $t2
            bne     $t3, $zero, fail_convert
                addi    $t2, $zero, '9'
                slt     $t3, $t2, $t1
                bne     $t3, $zero, fail_convert    #       if (s[i] >= '0' && s[i] <= '9') {

                    sw      $s1, 8($sp)             # -- Store current offset
                    sw      $a0, 4($sp)             # -- Store current s.base_addr
                    sw      $t1, 0($sp)             # -- Store current s[i]

                    add     $a0, $zero, $s0
                    addi    $a1, $zero, 10
                    jal     multi

                    lw      $t1, 0($sp)             # -- Restore current s[i]
                    lw      $a0, 4($sp)             # -- Restore current s.base_addr
                    lw      $s1, 8($sp)             # -- Restore current offset

                    add     $s0, $zero, $v0         #           n = n * 10;
                    sub     $t2, $t1, '0'           #           temp = s[i] - '\0';
                    add     $s0, $s0, $t2           #           n = n + temp; 
                    addi    $s1, $s1, 1             #           offset++;
                    j       string_iterate          #   }

    
    end_of_string:
    bne     $s1, $zero, finish_convert              #   if (s.size() == 0 || !s[i].isdigit) {    
            j       fail_convert

    fail_convert:
    addi    $s0, $zero, -1                          #       n = -1;
                                                    #   }
    finish_convert:
    add     $v0, $zero, $s0			                #	res = n;
    lw      $ra, 12($sp)
    addi    $sp, $sp, 16
    jr      $ra                                     #   return res;
                                                    # }

multi:                                              # int multi(int a, int b) {
    add     $s0, $zero, $zero                       #   int sign = 0;

    slt     $t0, $a0, $zero                     
    beq     $t0, $zero, update_sign                 #   if (a < 0) {
            addi    $t1, $zero, 1
            sub     $s0, $t1, $s0                   #       sign = 1 - sign;               
            sub     $a0, $zero, $a0                 #       a = -a;
                                                    #   }
    update_sign:
    slt     $t0, $a1, $zero                     
    beq     $t0, $zero, do_multi                    #   if (b < 0) {
            addi    $t1, $zero, 1               
            sub     $s0, $t1, $s0                   #        sign = 1 - sign;   
            sub     $a1, $zero, $a1                 #        b = -b;
                                                    #   }
    do_multi:
    add     $v0, $zero, $zero                       #   int res = 0;
    
    loop:
    beq     $a1, $zero, change_sign                 #   while (b != 0) {
            add     $v0, $v0, $a0                   #        res += a;
            addi    $a1, $a1, -1                    #        a--;
            j       loop                            #   }

    change_sign:
    beq     $s0, $zero, finish_multi                #   if (sign != 0) {
            sub     $v0, $zero, $v0                 #        res = -res;
                                                    #   }

    finish_multi:
    jr      $ra    				                    #	return res;
    						                        # }


check_date:                                         # bool checkDate(int day, int month, int year) {
    addi    $sp, $sp, -16
    sw      $ra, 12($sp)

    addi    $t0, $zero, -1
    beq     $a0, $t0, not_valid_date                #   if (day == -1) { return false; }
    beq     $a1, $t0, not_valid_date                #   if (month == -1) { return false; }
    beq     $a2, $t0, not_valid_date                #   if (year == -1) { return false; }

    addi    $t0, $zero, 1                           #   if (month < 1) { return false; }
    slt     $t1, $a1, $t0
    bne     $t1, $zero, not_valid_date
    
    addi    $t0, $zero, 12                          #   if (month > 12) { return false; }
    slt     $t1, $t0, $a1
    bne     $t1, $zero, not_valid_date

    addi    $t0, $zero, 1                           #   if (day < 1) { return false; }
    slt     $t1, $a0, $t0
    bne     $t1, $zero, not_valid_date

    sw      $a0, 8($sp)
    sw      $a1, 4($sp)
    sw      $a2, 0($sp)

    add     $a0, $zero, $a1
    add     $a1, $zero, $a2
    jal     max_day

    lw      $a2, 0($sp)
    lw      $a1, 4($sp)
    lw      $a0, 8($sp)

    slt     $t0, $v0, $a0
    bne     $t0, $zero, not_valid_date              #   if (day > max_day) { return false; }
    j       valid_date                              #   return true;

    not_valid_date:
        addi    $v0, $zero, 0
        j       finish_check_date

    valid_date:
        addi    $v0, $zero, 1
        j       finish_check_date

    finish_check_date:
        lw      $ra, 12($sp)
        addi    $sp, $sp, 16
        jr      $ra                                 # }


max_day:                                            # int maxDay(int month, int year) {
    addi    $sp, $sp, -12
    sw      $ra, 8($sp)
    sw      $a0, 4($sp)
    sw      $a1, 0($sp)
    
    addi    $t0, $zero, 2
    beq     $a0, $t0, max_feb                       #   if (month == 2) { return max_feb; }

    addi    $t0, $zero, 7
    slt     $t1, $a1, $t0
    beq     $t0, $0, gt_july                        #   if (month < 7) {
            addi    $a1, $zero, 2
            jal     mod
            beq     $v0, $zero, thirty              #       return (month % 2 == 0 ? 30 : 31);
                    j       thirty_one              #   }

    gt_july:
    addi    $a1, $zero, 2
    jal     mod
    beq     $v0, $zero, thirty_one                  #   return (month % 2 == 0 ? 31 : 30);
            j       thirty

    max_feb:
    add     $a0, $zero, $a1
    jal     check_leap_year                         #   max_feb = (isLeapYear(year) ? 29 : 28);
    beq     $v0, $zero, ninty_eight
            addi    $v0, $zero, 29
            j       finish_max_day
    
    ninty_eight:
        addi    $v0, $zero, 28
        j       finish_max_day
    
    thirty_one:
        addi    $v0, $zero, 31
        j       finish_max_day
    
    thirty:
        addi    $v0, $zero, 30
        j       finish_max_day

    finish_max_day:
        lw      $a1, 0($sp)
        lw      $a0, 4($sp)
        lw      $ra, 8($sp)
        addi    $sp, $sp, 12
        jr      $ra                                 # }


check_leap_year:                                    # bool checkLeapYear(int year) {
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    addi    $a1, $zero, 400
    jal     mod
    beq     $v0, $zero, is_leap_year                #   if (year % 400 == 0) { return true; }
    
    addi    $a1, $zero, 100
    jal     mod
    beq     $v0, $zero, not_leap_year               #   if (year % 100 == 0) { return false; }

    addi    $a1, $zero, 4
    jal     mod
    beq     $v0, $zero, is_leap_year                #   if (year % 4 == 0) { return true; }

    j       not_leap_year                           #   return false;
                                                    # }
    is_leap_year:
    addi    $v0, $zero, 1
    j       finish_check_leap_year

    not_leap_year:
    addi    $v0, $zero, 0
    j       finish_check_leap_year

    finish_check_leap_year:
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra


mod:
    div     $a0, $a1
    mfhi    $v0
    jr      $ra


exit: