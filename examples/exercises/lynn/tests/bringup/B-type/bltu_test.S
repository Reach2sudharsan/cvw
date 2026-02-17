// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_bltu_test
.extern fail

    .section .text.init
    .globl bltu_test
    .type  bltu_test, @function

bltu_test:

    # Test 1: 1 < 2 (positive numbers, branch expected)
    test1:
        li t0, 1
        li t1, 2
        bltu t0, t1, test2      # branch if t0 < t1 (unsigned)
        j Fail_Bltu_1            # fail if branch not taken

    # Test 2: 0x0011 < 0x1100 (hex comparison, branch expected)
    test2:
        li t0, 0x0011
        li t1, 0x1100
        bltu t0, t1, test3
        j Fail_Bltu_2

    # Test 3: -5 < 5 (unsigned: 0xFFFFFFFB < 5 is FALSE, branch NOT expected)
    test3:
        li t0, -5
        li t1, 5
        bltu t0, t1, Fail_Bltu_3
        j test4

    # Test 4: 5 < -5 (unsigned: 5 < 0xFFFFFFFB is TRUE, branch expected)
    test4:
        li t0, 5
        li t1, -5
        bltu t0, t1, test5
        j Fail_Bltu_4

    # Test 5: 7 < 7 (equal numbers, branch NOT expected)
    test5:
        li t0, 7
        li t1, 7
        bltu t0, t1, Fail_Bltu_5
        j test6

    # Test 6: 12345 < 54321 (large positive numbers, branch expected)
    test6:
        li t0, 12345
        li t1, 54321
        bltu t0, t1, test7
        j Fail_Bltu_6

    # Test 7: -54321 < -12345 (unsigned: 0xFFFF29CF < 0xFFFFCFC7 is TRUE, branch expected)
    test7:
        li t0, -54321
        li t1, -12345
        bltu t0, t1, test8
        j Fail_Bltu_7

    # Test 8: 0x7FFFFFFF < 0x80000000 (branch expected)
    test8:
        li t0, 0x7FFFFFFF
        li t1, 0x80000000
        bltu t0, t1, test9
        j Fail_Bltu_8

    # Test 9: 0x80000000 < 0x7FFFFFFF (branch NOT expected)
    test9:
        li t0, 0x80000000
        li t1, 0x7FFFFFFF
        bltu t0, t1, Fail_Bltu_9
        j test10

    # Test 10: 0 < -1 (unsigned: 0 < 0xFFFFFFFF is TRUE, branch expected)
    test10:
        li t0, 0
        li t1, -1
        bltu t0, t1, pass
        j Fail_Bltu_10


pass:
        j return_bltu_test


Fail_Bltu_1:
    li   gp, 531
    j    fail

Fail_Bltu_2:
    li   gp, 532
    j    fail

Fail_Bltu_3:
    li   gp, 533
    j    fail

Fail_Bltu_4:
    li   gp, 534
    j    fail

Fail_Bltu_5:
    li   gp, 535
    j    fail

Fail_Bltu_6:
    li   gp, 536
    j    fail

Fail_Bltu_7:
    li   gp, 537
    j    fail

Fail_Bltu_8:
    li   gp, 538
    j    fail

Fail_Bltu_9:
    li   gp, 539
    j    fail

Fail_Bltu_10:
    li   gp, 540
    j    fail
