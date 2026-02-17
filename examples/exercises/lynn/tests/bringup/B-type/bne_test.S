// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_bne_test
.extern fail

    .section .text.init
    .globl bne_test
    .type  bne_test, @function

bne_test:

    # 1: 0 != 1 (0 not equal 1)
    test1:
        li t0, 0
        li t1, 1
        bne t0, t1, test2      # branch if not equal
        j Fail_Bne_1            # fail if branch not taken

    # 2: 1 != 0 (1 not equal 0)
    test2:
        li t0, 1
        li t1, 0
        bne t0, t1, test3
        j Fail_Bne_2

    # 3: -1 != -2 (negative numbers not equal)
    test3:
        li t0, -1
        li t1, -2
        bne t0, t1, test4
        j Fail_Bne_3

    # 4: 5 == 5 (equal positive numbers)
    test4:
        li t0, 5
        li t1, 5
        bne t0, t1, Fail_Bne_4  # should NOT branch
        j test5

    # 5: -5 == -5 (equal negative numbers)
    test5:
        li t0, -5
        li t1, -5
        bne t0, t1, Fail_Bne_5
        j test6

    # 6: 7 == 7 (positive vs positive equal)
    test6:
        li t0, 7
        li t1, 7
        bne t0, t1, Fail_Bne_6
        j test7

    # 7: -8 == -8 (negative vs negative equal)
    test7:
        li t0, -8
        li t1, -8
        bne t0, t1, Fail_Bne_7
        j test8

    # 8: 12345 != 12344 (large positive numbers not equal)
    test8:
        li t0, 12345
        li t1, 12344
        bne t0, t1, test9
        j Fail_Bne_8

    # 9: -12345 != -12344 (large negative numbers not equal)
    test9:
        li t0, -12345
        li t1, -12344
        bne t0, t1, test10
        j Fail_Bne_9

    # 10: 0x7FFFFFFF == 0x7FFFFFFF (max int equal to itself)
    test10:
        li t0, 0x7FFFFFFF
        li t1, 0x7FFFFFFF
        bne t0, t1, Fail_Bne_10
        j pass


pass:
        j return_bne_test


Fail_Bne_1:
    li   gp, 511
    j    fail

Fail_Bne_2:
    li   gp, 512
    j    fail

Fail_Bne_3:
    li   gp, 513
    j    fail

Fail_Bne_4:
    li   gp, 514
    j    fail

Fail_Bne_5:
    li   gp, 515
    j    fail

Fail_Bne_6:
    li   gp, 516
    j    fail

Fail_Bne_7:
    li   gp, 517
    j    fail

Fail_Bne_8:
    li   gp, 518
    j    fail

Fail_Bne_9:
    li   gp, 519
    j    fail

Fail_Bne_10:
    li   gp, 520
    j    fail
