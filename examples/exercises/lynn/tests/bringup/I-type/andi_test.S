// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_andi_test
.extern fail

    .section .text.init
    .globl andi_test
    .type  andi_test, @function

andi_test:
    test1:
        # 0x55 AND 0xAA = 0x00
        li   t0, 0x55
        andi t2, t0, 0xAA
        li   t3, 0x00
        beq  t2, t3, test2
        j Fail_Andi_1

    test2:
        # 0x3C AND 0xC3 = 0x00
        li   t0, 0x3C
        andi t2, t0, 0xC3
        li   t3, 0x00
        beq  t2, t3, test3
        j Fail_Andi_2

    test3:
        # 0xFF AND 0x0F = 0x0F
        li   t0, 0xFF
        andi t2, t0, 0x0F
        li   t3, 0x0F
        beq  t2, t3, test4
        j Fail_Andi_3

    test4:
        # 0xF0 AND 0x0F = 0x00
        li   t0, 0xF0
        andi t2, t0, 0x0F
        li   t3, 0x00
        beq  t2, t3, test5
        j Fail_Andi_4

    test5:
        # 0x33 AND 0xCC = 0x00
        li   t0, 0x33
        andi t2, t0, 0xCC
        li   t3, 0x00
        beq  t2, t3, test6
        j Fail_Andi_5

    test6:
        # 0x0F AND 0x0F = 0x0F
        li   t0, 0x0F
        andi t2, t0, 0x0F
        li   t3, 0x0F
        beq  t2, t3, test7
        j Fail_Andi_6

    test7:
        # 0xAA AND 0xFF = 0xAA
        li   t0, 0xAA
        andi t2, t0, 0xFF
        li   t3, 0xAA
        beq  t2, t3, test8
        j Fail_Andi_7

    test8:
        # 0xF0 AND 0xF0 = 0xF0
        li   t0, 0xF0
        andi t2, t0, 0xF0
        li   t3, 0xF0
        beq  t2, t3, test9
        j Fail_Andi_8

    test9:
        # 0xFF AND 0x01 = 0x01
        li   t0, 0xFF
        andi t2, t0, 0x01
        li   t3, 0x01
        beq  t2, t3, test10
        j Fail_Andi_9

    test10:
        # 0x80 AND 0x7F = 0x00
        li   t0, 0x80
        andi t2, t0, 0x7F
        li   t3, 0x00
        beq  t2, t3, pass
        j Fail_Andi_10

pass:
        j return_andi_test

Fail_Andi_1:
    li   gp, 341
    j    fail

Fail_Andi_2:
    li   gp, 342
    j    fail

Fail_Andi_3:
    li   gp, 343
    j    fail

Fail_Andi_4:
    li   gp, 344
    j    fail

Fail_Andi_5:
    li   gp, 345
    j    fail

Fail_Andi_6:
    li   gp, 346
    j    fail

Fail_Andi_7:
    li   gp, 347
    j    fail

Fail_Andi_8:
    li   gp, 348
    j    fail

Fail_Andi_9:
    li   gp, 349
    j    fail

Fail_Andi_10:
    li   gp, 350
    j    fail
