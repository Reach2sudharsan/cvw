// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/11/2026

.extern return_slt_test
.extern fail

    .section .text.init
    .globl slt_test
    .type  slt_test, @function

slt_test:
    test1:
        # 0x05 < 0x0A = 1
        li   t0, 0x05
        li   t1, 0x0A
        slt  t2, t0, t1
        li   t3, 1
        beq  t2, t3, test2
        j Fail_Slt_1

    test2:
        # 0x0A < 0x05 = 0
        li   t0, 0x0A
        li   t1, 0x05
        slt  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test3
        j Fail_Slt_2

    test3:
        # 0x10 < 0x10 = 0
        li   t0, 0x10
        li   t1, 0x10
        slt  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test4
        j Fail_Slt_3

    test4:
        # 0x00 < 0x01 = 1
        li   t0, 0x00
        li   t1, 0x01
        slt  t2, t0, t1
        li   t3, 1
        beq  t2, t3, test5
        j Fail_Slt_4

    test5:
        # 0x01 < 0x00 = 0
        li   t0, 0x01
        li   t1, 0x00
        slt  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test6
        j Fail_Slt_5

    test6:
        # -1 < 0 = 1
        li   t0, -1
        li   t1, 0
        slt  t2, t0, t1
        li   t3, 1
        beq  t2, t3, test7
        j Fail_Slt_6

    test7:
        # 0 < -1 = 0
        li   t0, 0
        li   t1, -1
        slt  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test8
        j Fail_Slt_7

    test8:
        # -5 < -3 = 1
        li   t0, -5
        li   t1, -3
        slt  t2, t0, t1
        li   t3, 1
        beq  t2, t3, test9
        j Fail_Slt_8

    test9:
        # -3 < -5 = 0
        li   t0, -3
        li   t1, -5
        slt  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test10
        j Fail_Slt_9

    test10:
        # 127 < -128 = 0
        li   t0, 127
        li   t1, -128
        slt  t2, t0, t1
        li   t3, 0
        beq  t2, t3, pass
        j Fail_Slt_10

    pass:
        j return_slt_test

Fail_Slt_1:
    li   gp, 501
    j    fail

Fail_Slt_2:
    li   gp, 502
    j    fail

Fail_Slt_3:
    li   gp, 503
    j    fail

Fail_Slt_4:
    li   gp, 504
    j    fail

Fail_Slt_5:
    li   gp, 505
    j    fail

Fail_Slt_6:
    li   gp, 506
    j    fail

Fail_Slt_7:
    li   gp, 507
    j    fail

Fail_Slt_8:
    li   gp, 508
    j    fail

Fail_Slt_9:
    li   gp, 509
    j    fail

Fail_Slt_10:
    li   gp, 510
    j    fail
