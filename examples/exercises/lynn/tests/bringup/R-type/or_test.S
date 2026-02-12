// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/11/2026

.extern return_or_test
.extern fail

    .section .text.init
    .globl or_test
    .type  or_test, @function

or_test:
    test1:
        # 0x0F OR 0xF0 = 0xFF
        li   t0, 0x0F
        li   t1, 0xF0
        or   t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test2
        j Fail_Or_1

    test2:
        # 0x33 OR 0xCC = 0xFF
        li   t0, 0x33
        li   t1, 0xCC
        or   t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test3
        j Fail_Or_2

    test3:
        # 0x55 OR 0xAA = 0xFF
        li   t0, 0x55
        li   t1, 0xAA
        or   t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test4
        j Fail_Or_3

    test4:
        # 0x11 OR 0xEE = 0xFF
        li   t0, 0x11
        li   t1, 0xEE
        or   t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test5
        j Fail_Or_4

    test5:
        # 0x00 OR 0x00 = 0x00
        li   t0, 0x00
        li   t1, 0x00
        or   t2, t0, t1
        li   t3, 0x00
        beq  t2, t3, test6
        j Fail_Or_5

    test6:
        # 0x0F OR 0x0F = 0x0F
        li   t0, 0x0F
        li   t1, 0x0F
        or   t2, t0, t1
        li   t3, 0x0F
        beq  t2, t3, test7
        j Fail_Or_6

    test7:
        # 0xF0 OR 0x0F = 0xFF
        li   t0, 0xF0
        li   t1, 0x0F
        or   t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test8
        j Fail_Or_7

    test8:
        # 0xAA OR 0x55 = 0xFF
        li   t0, 0xAA
        li   t1, 0x55
        or   t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, test9
        j Fail_Or_8

    test9:
        # 0x01 OR 0x02 = 0x03
        li   t0, 0x01
        li   t1, 0x02
        or   t2, t0, t1
        li   t3, 0x03
        beq  t2, t3, test10
        j Fail_Or_9

    test10:
        # 0x80 OR 0x7F = 0xFF
        li   t0, 0x80
        li   t1, 0x7F
        or   t2, t0, t1
        li   t3, 0xFF
        beq  t2, t3, pass
        j Fail_Or_10

    pass:
        j return_or_test

Fail_Or_1:
    li   gp, 101
    j    fail

Fail_Or_2:
    li   gp, 102
    j    fail

Fail_Or_3:
    li   gp, 103
    j    fail

Fail_Or_4:
    li   gp, 104
    j    fail

Fail_Or_5:
    li   gp, 105
    j    fail

Fail_Or_6:
    li   gp, 106
    j    fail

Fail_Or_7:
    li   gp, 107
    j    fail

Fail_Or_8:
    li   gp, 108
    j    fail

Fail_Or_9:
    li   gp, 109
    j    fail

Fail_Or_10:
    li   gp, 110
    j    fail
