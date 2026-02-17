// C Runtime entry point
// Sudharsan Gopalakrishnan
// sgopalakrishnan@g.hmc.edu
// 2/12/2026

.extern return_sub_test
.extern fail

    .section .text.init
    .globl sub_test
    .type  sub_test, @function

sub_test:
    test1:
        # 0x09 - 0x04 = 0x05
        li   t0, 9
        li   t1, 4
        sub  t2, t0, t1
        li   t3, 5
        beq  t2, t3, test2
        j Fail_Sub_1

    test2:
        # 0x1B - 0x0E = 0x0D
        li   t0, 27
        li   t1, 14
        sub  t2, t0, t1
        li   t3, 13
        beq  t2, t3, test3
        j Fail_Sub_2

    test3:
        # 0x50 - 0x20 = 0x30
        li   t0, 80
        li   t1, 32
        sub  t2, t0, t1
        li   t3, 48
        beq  t2, t3, test4
        j Fail_Sub_3

    test4:
        # 0x0A - 0x0A = 0x00
        li   t0, 10
        li   t1, 10
        sub  t2, t0, t1
        li   t3, 0
        beq  t2, t3, test5
        j Fail_Sub_4

    test5:
        # 0x00 - 0x01 = -0x01
        li   t0, 0
        li   t1, 1
        sub  t2, t0, t1
        li   t3, -1
        beq  t2, t3, test6
        j Fail_Sub_5

    test6:
        # 0xFF - 0x01 = 0xFE
        li   t0, 0xFF
        li   t1, 0x01
        sub  t2, t0, t1
        li   t3, 0xFE
        beq  t2, t3, test7
        j Fail_Sub_6

    test7:
        # 0x80 - 0xFF = -0x7F
        li   t0, 0x80
        li   t1, 0xFF
        sub  t2, t0, t1
        li   t3, -127
        beq  t2, t3, test8
        j Fail_Sub_7

    test8:
        # 0x7F - 0x80 = -0x01
        li   t0, 0x7F
        li   t1, 0x80
        sub  t2, t0, t1
        li   t3, -1
        beq  t2, t3, test9
        j Fail_Sub_8

    test9:
        # 0xAA - 0x55 = 0x55
        li   t0, 0xAA
        li   t1, 0x55
        sub  t2, t0, t1
        li   t3, 0x55
        beq  t2, t3, test10
        j Fail_Sub_9

    test10:
        # 0x01 - 0xFF = 0xFFFFFF02 (-254 in 32-bit signed)
        li   t0, 0x01
        li   t1, 0xFF
        sub  t2, t0, t1
        li   t3, -254       # 32-bit signed result
        beq  t2, t3, pass
        j Fail_Sub_10

    pass:
        j return_sub_test

Fail_Sub_1:
    li   gp, 111
    j    fail

Fail_Sub_2:
    li   gp, 112
    j    fail

Fail_Sub_3:
    li   gp, 113
    j    fail

Fail_Sub_4:
    li   gp, 114
    j    fail

Fail_Sub_5:
    li   gp, 115
    j    fail

Fail_Sub_6:
    li   gp, 116
    j    fail

Fail_Sub_7:
    li   gp, 117
    j    fail

Fail_Sub_8:
    li   gp, 118
    j    fail

Fail_Sub_9:
    li   gp, 119
    j    fail

Fail_Sub_10:
    li   gp, 120
    j    fail
