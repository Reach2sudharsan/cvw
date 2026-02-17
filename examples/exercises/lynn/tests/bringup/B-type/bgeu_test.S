// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_bgeu_test
.extern fail

    .section .text.init
    .globl bgeu_test
    .type  bgeu_test, @function

bgeu_test:

    # Test 1: 1 >= 2 (branch NOT expected, unsigned)
    test1:
        li t0, 1
        li t1, 2
        bgeu t0, t1, Fail_Bgeu_1   # branch if t0 >= t1 (unsigned)
        j test2                      # continue to next test

    # Test 2: 0x0011 >= 0x1100 (branch NOT expected, unsigned)
    test2:
        li t0, 0x0011
        li t1, 0x1100
        bgeu t0, t1, Fail_Bgeu_2
        j test3

    # Test 3: -5 >= 5 (unsigned: 0xFFFFFFFB >= 5 is TRUE, branch expected)
    test3:
        li t0, -5
        li t1, 5
        bgeu t0, t1, test4
        j Fail_Bgeu_3

    # Test 4: 5 >= -5 (unsigned: 5 >= 0xFFFFFFFB is FALSE, branch NOT expected)
    test4:
        li t0, 5
        li t1, -5
        bgeu t0, t1, Fail_Bgeu_4
        j test5

    # Test 5: 7 >= 7 (equal numbers, branch expected)
    test5:
        li t0, 7
        li t1, 7
        bgeu t0, t1, test6
        j Fail_Bgeu_5

    # Test 6: 12345 >= 54321 (branch NOT expected, unsigned)
    test6:
        li t0, 12345
        li t1, 54321
        bgeu t0, t1, Fail_Bgeu_6
        j test7

    # Test 7: -54321 >= -12345 (unsigned: 0xFFFF29CF >= 0xFFFFCFC7 is FALSE, branch NOT expected)
    test7:
        li t0, -54321
        li t1, -12345
        bgeu t0, t1, Fail_Bgeu_7
        j test8

    # Test 8: 0x7FFFFFFF >= 0x80000000 (unsigned: FALSE, branch NOT expected)
    test8:
        li t0, 0x7FFFFFFF
        li t1, 0x80000000
        bgeu t0, t1, Fail_Bgeu_8
        j test9

    # Test 9: 0x80000000 >= 0x7FFFFFFF (unsigned: TRUE, branch expected)
    test9:
        li t0, 0x80000000
        li t1, 0x7FFFFFFF
        bgeu t0, t1, test10
        j Fail_Bgeu_9

    # Test 10: 0 >= -1 (unsigned: 0 >= 0xFFFFFFFF is FALSE, branch NOT expected)
    test10:
        li t0, 0
        li t1, -1
        bgeu t0, t1, Fail_Bgeu_10
        j pass


pass:
        j return_bgeu_test


Fail_Bgeu_1:
    li   gp, 551
    j    fail

Fail_Bgeu_2:
    li   gp, 552
    j    fail

Fail_Bgeu_3:
    li   gp, 553
    j    fail

Fail_Bgeu_4:
    li   gp, 554
    j    fail

Fail_Bgeu_5:
    li   gp, 555
    j    fail

Fail_Bgeu_6:
    li   gp, 556
    j    fail

Fail_Bgeu_7:
    li   gp, 557
    j    fail

Fail_Bgeu_8:
    li   gp, 558
    j    fail

Fail_Bgeu_9:
    li   gp, 559
    j    fail

Fail_Bgeu_10:
    li   gp, 560
    j    fail
