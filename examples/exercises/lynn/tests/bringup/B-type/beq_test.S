// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_beq_test
.extern fail

    .section .text.init
    .globl beq_test
    .type  beq_test, @function

beq_test:

    # 1: 0 == 0 (equal)
    test1:
        li t0, 0
        li t1, 0
        beq t0, t1, test2
        j Fail_Beq_1

    # 2: 1 == 1 (equal positive)
    test2:
        li t0, 1
        li t1, 1
        beq t0, t1, test3
        j Fail_Beq_2

    # 3: -1 == -1 (equal negative)
    test3:
        li t0, -1
        li t1, -1
        beq t0, t1, test4
        j Fail_Beq_3

    # 4: 5 != 6 (positive not equal)
    test4:
        li t0, 5
        li t1, 6
        beq t0, t1, Fail_Beq_4
        j test5

    # 5: -5 != -6 (negative not equal)
    test5:
        li t0, -5
        li t1, -6
        beq t0, t1, Fail_Beq_5
        j test6

    # 6: 7 != -7 (positive vs negative)
    test6:
        li t0, 7
        li t1, -7
        beq t0, t1, Fail_Beq_6
        j test7

    # 7: -8 != 8 (negative vs positive)
    test7:
        li t0, -8
        li t1, 8
        beq t0, t1, Fail_Beq_7
        j test8

    # 8: 12345 == 12345 (large positive equal)
    test8:
        li t0, 12345
        li t1, 12345
        beq t0, t1, test9
        j Fail_Beq_8

    # 9: -12345 == -12345 (large negative equal)
    test9:
        li t0, -12345
        li t1, -12345
        beq t0, t1, test10
        j Fail_Beq_9

    # 10: 0x7FFFFFFF != 0x80000000 (max vs min int)
    test10:
        li t0, 0x7FFFFFFF
        li t1, 0x80000000
        beq t0, t1, Fail_Beq_10
        j pass


pass:
        j return_beq_test


Fail_Beq_1:
    li   gp, 701
    j    fail

Fail_Beq_2:
    li   gp, 702
    j    fail

Fail_Beq_3:
    li   gp, 703
    j    fail

Fail_Beq_4:
    li   gp, 704
    j    fail

Fail_Beq_5:
    li   gp, 705
    j    fail

Fail_Beq_6:
    li   gp, 706
    j    fail

Fail_Beq_7:
    li   gp, 707
    j    fail

Fail_Beq_8:
    li   gp, 708
    j    fail

Fail_Beq_9:
    li   gp, 709
    j    fail

Fail_Beq_10:
    li   gp, 710
    j    fail
