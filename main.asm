.data
ask_day:        .asciiz     "Nhap ngay DAY: "
ask_month:      .asciiz     "Nhap thang MONTH: "
ask_year:       .asciiz     "Nhap nam YEAR: "

noti_success:   .asciiz     "Done conversion!\n"
noti_fail:      .asciiz     "Can't convert!\n"

buffer_day:     .space      16                      # A character array of size 16
buffer_month:   .space      16                      # A character array of size 16
buffer_year:    .space      16                      # A character array of size 16

day:            .word
month:          .word
year:           .word

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

#     la      $t0, day
#     sw      $v0, 0($t0)
#     lw      $a0, day
#     addi    $v0, $zero, 1
#     syscall


    j       exit


convert_to_unsigned:                                # int convertToUnsigned (string s) {
    addi    $sp, $sp, -16
    sw      $ra, 12($sp)

    add     $s0, $zero, $zero                       #   n = 0;
    add     $s1, $zero, $zero                       #   offset = 0;

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
    bne     $s1, $zero, finish_convert              #   n = -1 if string is empty or exists non-digit character
            j       fail_convert

    fail_convert:
    addi    $s0, $zero, -1

    finish_convert:
    add     $v0, $zero, $s0			    #	res = n;
    lw      $ra, 12($sp)
    addi    $sp, $sp, 16
    jr      $ra                                     #   return res;
                                                    # }

multi:                                              # int multi (int a, int b) {
    add     $s0, $zero, $zero                       #   sign = 0;

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
    add     $v0, $zero, $zero                       #   product = 0;
    
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
    jr      $ra    				    #	return res;
    						    # }


exit: