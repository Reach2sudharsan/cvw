// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_blt_test
.extern fail

    .section .text.init
    .globl blt_test
    .type  blt_test, @function

blt_test:

    # Test 1: 1 < 2 (positive numbers, branch expected)
    test1:
        li t0, 1
        li t1, 2
        blt t0, t1, test2      # branch if t0 < t1
        j Fail_Blt_1            # fail if branch not taken

    # Test 2: 0x0011 < 0x1100 (hex comparison, branch expected)
    test2:
        li t0, 0x0011
        li t1, 0x1100
        blt t0, t1, test3
        j Fail_Blt_2

    # Test 3: -5 < 5 (negative vs positive, branch expected)
    test3:
        li t0, -5
        li t1, 5
        blt t0, t1, test4
        j Fail_Blt_3

    # Test 4: 5 < -5 (positive vs negative, branch NOT expected)
    test4:
        li t0, 5
        li t1, -5
        blt t0, t1, Fail_Blt_4
        j test5

    # Test 5: 7 < 7 (equal numbers, branch NOT expected)
    test5:
        li t0, 7
        li t1, 7
        blt t0, t1, Fail_Blt_5
        j test6

    # Test 6: 12345 < 54321 (large positive numbers, branch expected)
    test6:
        li t0, 12345
        li t1, 54321
        blt t0, t1, test7
        j Fail_Blt_6

    # Test 7: -54321 < -12345 (large negative numbers, branch expected)
    test7:
        li t0, -54321
        li t1, -12345
        blt t0, t1, test8
        j Fail_Blt_7

    # Test 8: 0x7FFFFFFF < 0x80000000 (max int vs min int, branch NOT expected)
    test8:
        li t0, 0x7FFFFFFF
        li t1, 0x80000000
        blt t0, t1, Fail_Blt_8
        j test9

    # Test 9: 0x80000000 < 0x7FFFFFFF (min int vs max int, branch expected)
    test9:
        li t0, 0x80000000
        li t1, 0x7FFFFFFF
        blt t0, t1, test10
        j Fail_Blt_9

    # Test 10: 0 < -1 (zero vs negative, branch NOT expected)
    test10:
        li t0, 0
        li t1, -1
        blt t0, t1, Fail_Blt_10
        j pass


pass:
        j return_blt_test


Fail_Blt_1:
    li   gp, 521
    j    fail

Fail_Blt_2:
    li   gp, 522
    j    fail

Fail_Blt_3:
    li   gp, 523
    j    fail

Fail_Blt_4:
    li   gp, 524
    j    fail

Fail_Blt_5:
    li   gp, 525
    j    fail

Fail_Blt_6:
    li   gp, 526
    j    fail

Fail_Blt_7:
    li   gp, 527
    j    fail

Fail_Blt_8:
    li   gp, 528
    j    fail

Fail_Blt_9:
    li   gp, 529
    j    fail

Fail_Blt_10:
    li   gp, 530
    j    fail
