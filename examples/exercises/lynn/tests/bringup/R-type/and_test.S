// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_and_test
.extern fail

    .section .text.init
    .globl and_test
    .type  and_test, @function

and_test:
    test1:
        # 0x55 AND 0xAA = 0x00
        li   t0, 0x55
        li   t1, 0xAA
        and  t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, test2
        j Fail_And_1

    test2:
        # 0x3C AND 0xC3 = 0x00
        li   t0, 0x3C      # 00111100
        li   t1, 0xC3      # 11000011
        and  t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, test3
        j Fail_And_2

    test3:
        # 0xFF AND 0x0F = 0x0F
        li   t0, 0xFF
        li   t1, 0x0F
        and  t2, t0, t1
        li   t3, 0x0F
        beq  t2, t3, test4
        j Fail_And_3

    test4:
        # 0xF0 AND 0x0F = 0x00
        li   t0, 0xF0
        li   t1, 0x0F
        and  t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, test5
        j Fail_And_4

    test5:
        # 0x33 AND 0xCC = 0x00
        li   t0, 0x33
        li   t1, 0xCC
        and  t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, test6
        j Fail_And_5

    test6:
        # 0x0F AND 0x0F = 0x0F
        li   t0, 0x0F
        li   t1, 0x0F
        and  t2, t0, t1
        li   t3, 0x0F
        beq  t2, t3, test7
        j Fail_And_6

    test7:
        # 0xAA AND 0xFF = 0xAA
        li   t0, 0xAA
        li   t1, 0xFF
        and  t2, t0, t1
        li   t3, 0xAA
        beq  t2, t3, test8
        j Fail_And_7

    test8:
        # 0xF0 AND 0xF0 = 0xF0
        li   t0, 0xF0
        li   t1, 0xF0
        and  t2, t0, t1
        li   t3, 0xF0
        beq  t2, t3, test9
        j Fail_And_8

    test9:
        # 0xFF AND 0x01 = 0x01
        li   t0, 0xFF
        li   t1, 0x01
        and  t2, t0, t1
        li   t3, 0x01
        beq  t2, t3, test10
        j Fail_And_9

    test10:
        # 0x80 AND 0x7F = 0x00
        li   t0, 0x80
        li   t1, 0x7F
        and  t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, pass
        j Fail_And_10

    pass:
        j return_and_test

Fail_And_1:
    li   gp, 201
    j    fail

Fail_And_2:
    li   gp, 202
    j    fail

Fail_And_3:
    li   gp, 203
    j    fail

Fail_And_4:
    li   gp, 204
    j    fail

Fail_And_5:
    li   gp, 205
    j    fail

Fail_And_6:
    li   gp, 206
    j    fail

Fail_And_7:
    li   gp, 207
    j    fail

Fail_And_8:
    li   gp, 208
    j    fail

Fail_And_9:
    li   gp, 209
    j    fail

Fail_And_10:
    li   gp, 210
    j    fail
