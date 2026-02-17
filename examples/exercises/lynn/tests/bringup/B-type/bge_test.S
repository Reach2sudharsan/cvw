// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_bge_test
.extern fail

    .section .text.init
    .globl bge_test
    .type  bge_test, @function

bge_test:

    # Test 1: 1 >= 2 (branch NOT expected)
    test1:
        li t0, 1
        li t1, 2
        bge t0, t1, Fail_Bge_1     # branch if t0 >= t1
        j test2                     # continue to next test

    # Test 2: 0x0011 >= 0x1100 (branch NOT expected)
    test2:
        li t0, 0x0011
        li t1, 0x1100
        bge t0, t1, Fail_Bge_2
        j test3

    # Test 3: -5 >= 5 (branch NOT expected)
    test3:
        li t0, -5
        li t1, 5
        bge t0, t1, Fail_Bge_3
        j test4

    # Test 4: 5 >= -5 (branch expected)
    test4:
        li t0, 5
        li t1, -5
        bge t0, t1, test5
        j Fail_Bge_4

    # Test 5: 7 >= 7 (equal numbers, branch expected)
    test5:
        li t0, 7
        li t1, 7
        bge t0, t1, test6
        j Fail_Bge_5

    # Test 6: 12345 >= 54321 (branch NOT expected)
    test6:
        li t0, 12345
        li t1, 54321
        bge t0, t1, Fail_Bge_6
        j test7

    # Test 7: -54321 >= -12345 (branch NOT expected)
    test7:
        li t0, -54321
        li t1, -12345
        bge t0, t1, Fail_Bge_7
        j test8

    # Test 8: 0x7FFFFFFF >= 0x80000000 (branch NOT expected, signed)
    test8:
        li t0, 0x7FFFFFFF
        li t1, 0x80000000
        bge t0, t1, test9
        j Fail_Bge_8

    # Test 9: 0x80000000 >= 0x7FFFFFFF (branch expected, signed)
    test9:
        li t0, 0x80000000
        li t1, 0x7FFFFFFF
        bge t0, t1, Fail_Bge_9
        j test10

    # Test 10: 0 >= -1 (branch expected)
    test10:
        li t0, 0
        li t1, -1
        bge t0, t1, pass
        j Fail_Bge_10


pass:
        j return_bge_test


Fail_Bge_1:
    li   gp, 541
    j    fail

Fail_Bge_2:
    li   gp, 542
    j    fail

Fail_Bge_3:
    li   gp, 543
    j    fail

Fail_Bge_4:
    li   gp, 544
    j    fail

Fail_Bge_5:
    li   gp, 545
    j    fail

Fail_Bge_6:
    li   gp, 546
    j    fail

Fail_Bge_7:
    li   gp, 547
    j    fail

Fail_Bge_8:
    li   gp, 548
    j    fail

Fail_Bge_9:
    li   gp, 549
    j    fail

Fail_Bge_10:
    li   gp, 550
    j    fail
