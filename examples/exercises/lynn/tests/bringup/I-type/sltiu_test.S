// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_sltui_test
.extern fail

    .section .text.init
    .globl sltui_test
    .type  sltui_test, @function

sltui_test:
    test1:
        # 0x05 < 0x0A = 1
        li   t0, 0x05
        sltiu t2, t0, 0x0A
        li   t3, 1
        beq  t2, t3, test2
        j Fail_Sltui_1

    test2:
        # 0x0A < 0x05 = 0
        li   t0, 0x0A
        sltiu t2, t0, 0x05
        li   t3, 0
        beq  t2, t3, test3
        j Fail_Sltui_2

    test3:
        # 0x10 < 0x10 = 0
        li   t0, 0x10
        sltiu t2, t0, 0x10
        li   t3, 0
        beq  t2, t3, test4
        j Fail_Sltui_3

    test4:
        # 0x00 < 0x01 = 1
        li   t0, 0x00
        sltiu t2, t0, 0x01
        li   t3, 1
        beq  t2, t3, test5
        j Fail_Sltui_4

    test5:
        # 0x01 < 0x00 = 0
        li   t0, 0x01
        sltiu t2, t0, 0x00
        li   t3, 0
        beq  t2, t3, test6
        j Fail_Sltui_5

    test6:
        # -1 < 0 = 1 (unsigned comparison: 0xFFFFFFFF > 0x0 → t2 = 0)
        li   t0, -1
        sltiu t2, t0, 0x0
        li   t3, 0
        beq  t2, t3, test7
        j Fail_Sltui_6

    test7:
        # 0 < -1 = 1 (unsigned: 0x0 < 0xFFFFFFFF → t2 = 1)
        li   t0, 0
        sltiu t2, t0, -1
        li   t3, 1
        beq  t2, t3, test8
        j Fail_Sltui_7

    test8:
        # -5 < -3 = 1 (unsigned: 0xFFFFFFFB < 0xFFFFFFFD → t2 = 1)
        li   t0, -5
        sltiu t2, t0, -3
        li   t3, 1
        beq  t2, t3, test9
        j Fail_Sltui_8

    test9:
        # -3 < -5 = 0 (unsigned: 0xFFFFFFFD < 0xFFFFFFFB → t2 = 0)
        li   t0, -3
        sltiu t2, t0, -5
        li   t3, 0
        beq  t2, t3, test10
        j Fail_Sltui_9

    test10:
        # 127 < -128 = 1 (unsigned: 0x7F < 0xFFFFFF80 → t2 = 1)
        li   t0, 127
        sltiu t2, t0, -128
        li   t3, 1
        beq  t2, t3, pass
        j Fail_Sltui_10

    pass:
        j return_sltui_test

Fail_Sltui_1:
    li   gp, 381
    j    fail

Fail_Sltui_2:
    li   gp, 382
    j    fail

Fail_Sltui_3:
    li   gp, 383
    j    fail

Fail_Sltui_4:
    li   gp, 384
    j    fail

Fail_Sltui_5:
    li   gp, 385
    j    fail

Fail_Sltui_6:
    li   gp, 386
    j    fail

Fail_Sltui_7:
    li   gp, 387
    j    fail

Fail_Sltui_8:
    li   gp, 388
    j    fail

Fail_Sltui_9:
    li   gp, 389
    j    fail

Fail_Sltui_10:
    li   gp, 390
    j    fail
