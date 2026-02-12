// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/11/2026

.extern return_slti_test
.extern fail

    .section .text.init
    .globl slti_test
    .type  slti_test, @function

slti_test:
    test1:
        # 0x05 < 0x0A = 1
        li   t0, 0x05
        slti t2, t0, 0x0A
        li   t3, 1
        beq  t2, t3, test2
        j Fail_Slti_1

    test2:
        # 0x0A < 0x05 = 0
        li   t0, 0x0A
        slti t2, t0, 0x05
        li   t3, 0
        beq  t2, t3, test3
        j Fail_Slti_2

    test3:
        # 0x10 < 0x10 = 0
        li   t0, 0x10
        slti t2, t0, 0x10
        li   t3, 0
        beq  t2, t3, test4
        j Fail_Slti_3

    test4:
        # 0x00 < 0x01 = 1
        li   t0, 0x00
        slti t2, t0, 0x01
        li   t3, 1
        beq  t2, t3, test5
        j Fail_Slti_4

    test5:
        # 0x01 < 0x00 = 0
        li   t0, 0x01
        slti t2, t0, 0x00
        li   t3, 0
        beq  t2, t3, test6
        j Fail_Slti_5

    test6:
        # -1 < 0 = 1
        li   t0, -1
        slti t2, t0, 0
        li   t3, 1
        beq  t2, t3, test7
        j Fail_Slti_6

    test7:
        # 0 < -1 = 0
        li   t0, 0
        slti t2, t0, -1
        li   t3, 0
        beq  t2, t3, test8
        j Fail_Slti_7

    test8:
        # -5 < -3 = 1
        li   t0, -5
        slti t2, t0, -3
        li   t3, 1
        beq  t2, t3, test9
        j Fail_Slti_8

    test9:
        # -3 < -5 = 0
        li   t0, -3
        slti t2, t0, -5
        li   t3, 0
        beq  t2, t3, test10
        j Fail_Slti_9

    test10:
        # 127 < -128 = 0
        li   t0, 127
        slti t2, t0, -128
        li   t3, 0
        beq  t2, t3, pass
        j Fail_Slti_10

pass:
        j return_slti_test

Fail_Slti_1:
    li   gp, 511
    j    fail

Fail_Slti_2:
    li   gp, 512
    j    fail

Fail_Slti_3:
    li   gp, 513
    j    fail

Fail_Slti_4:
    li   gp, 514
    j    fail

Fail_Slti_5:
    li   gp, 515
    j    fail

Fail_Slti_6:
    li   gp, 516
    j    fail

Fail_Slti_7:
    li   gp, 517
    j    fail

Fail_Slti_8:
    li   gp, 518
    j    fail

Fail_Slti_9:
    li   gp, 519
    j    fail

Fail_Slti_10:
    li   gp, 520
    j    fail
